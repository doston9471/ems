# frozen_string_literal: true

module Identity
  module Sso
    # Production-shaped SAML 2.0 login using ruby-saml when IdP metadata/cert
    # are present. Demo ACS still accepts NameID/email query params when
    # metadata[:allow_demo_acs] is true (default outside production).
    class SamlLoginService < ApplicationService
      def initialize(sso_configuration:, name_id: nil, email: nil, relay_state: nil, saml_response: nil)
        @config = sso_configuration
        @name_id = name_id
        @email = email
        @relay_state = relay_state
        @saml_response = saml_response
      end

      def call
        return failure("SSO configuration is missing") if @config.blank?
        return failure("SSO is not enabled") unless @config.enabled?
        return failure("Provider must be saml") unless @config.provider == "saml"

        if callback?
          handle_callback
        else
          build_redirect_url
        end
      end

      private

      def callback?
        @saml_response.present? || @name_id.present? || @email.present?
      end

      def metadata
        @metadata ||= (@config.metadata || {}).with_indifferent_access
      end

      def build_redirect_url
        idp_sso_url = metadata[:idp_sso_url].to_s.presence
        return failure("SAML idp_sso_url is required") if idp_sso_url.blank?
        return failure("SAML entity_id is not configured") if metadata[:entity_id].to_s.blank?

        if production_saml?
          request = OneLogin::RubySaml::Authrequest.new
          url = request.create(saml_settings, RelayState: @relay_state)
          success(url)
        else
          uri = URI.parse(idp_sso_url)
          params = URI.decode_www_form(uri.query.to_s)
          params << [ "RelayState", @relay_state ] if @relay_state.present?
          params << [ "SAMLRequest", "demo" ] unless params.any? { |k, _| k == "SAMLRequest" }
          uri.query = URI.encode_www_form(params)
          success(uri.to_s)
        end
      rescue URI::InvalidURIError
        failure("Invalid idp_sso_url")
      rescue StandardError => e
        failure("SAML AuthnRequest failed: #{e.message}")
      end

      def handle_callback
        email =
          if @saml_response.present? && production_saml?
            email_from_assertion
          else
            demo_email_from_params
          end
        return failure("SAML response did not include NameID or email") if email.blank?
        return failure("NameID does not look like an email") unless email.include?("@")

        user = find_or_create_user(email: email)
        ensure_membership!(user)
        success(user)
      rescue ActiveRecord::RecordInvalid => e
        failure(e.record.errors.full_messages)
      end

      def production_saml?
        metadata[:idp_cert].present? || metadata[:idp_cert_fingerprint].present? ||
          ActiveModel::Type::Boolean.new.cast(metadata[:use_ruby_saml])
      end

      def allow_demo_acs?
        return true if ActiveModel::Type::Boolean.new.cast(metadata[:allow_demo_acs])
        return false if Rails.env.production?

        !production_saml?
      end

      def demo_email_from_params
        return nil unless allow_demo_acs?

        @email.to_s.strip.downcase.presence || @name_id.to_s.strip.downcase.presence
      end

      def email_from_assertion
        response = OneLogin::RubySaml::Response.new(
          @saml_response,
          settings: saml_settings,
          allowed_clock_drift: metadata.fetch(:allowed_clock_drift, 5).to_i
        )
        unless response.is_valid?
          Rails.logger.warn("[SamlLoginService] invalid assertion: #{response.errors.join(', ')}")
          return nil
        end

        response.nameid.to_s.strip.downcase.presence ||
          response.attributes["email"].to_s.strip.downcase.presence ||
          response.attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"].to_s.strip.downcase.presence
      end

      def saml_settings
        settings = OneLogin::RubySaml::Settings.new
        settings.assertion_consumer_service_url = metadata[:acs_url].presence ||
                                                  metadata[:assertion_consumer_service_url]
        settings.sp_entity_id = metadata[:entity_id]
        settings.idp_sso_service_url = metadata[:idp_sso_url]
        settings.idp_cert = metadata[:idp_cert] if metadata[:idp_cert].present?
        settings.idp_cert_fingerprint = metadata[:idp_cert_fingerprint] if metadata[:idp_cert_fingerprint].present?
        settings.name_identifier_format = metadata[:name_identifier_format].presence ||
                                          "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
        settings.security[:want_assertions_signed] = ActiveModel::Type::Boolean.new.cast(
          metadata.fetch(:want_assertions_signed, true)
        )
        settings
      end

      def find_or_create_user(email:)
        user = User.find_by(email_address: email)
        if user
          user.update!(email_verified_at: Time.current) if user.email_verified_at.blank?
          return user
        end

        local = email.split("@").first.to_s
        user = User.new(
          email_address: email,
          first_name: local.titleize.presence,
          last_name: "SSO",
          email_verified_at: Time.current
        )
        user.oauth_identities.build(
          provider: "saml",
          uid: @name_id.presence || email,
          email: email,
          raw_metadata: { "name_id" => @name_id, "email" => email }
        )
        user.save!
        user
      end

      def ensure_membership!(user)
        company = @config.company
        return if company.blank?
        return if company.memberships.exists?(user_id: user.id)

        role = Role.for_company(company).find_by(key: "employee") || Role.for_company(company).order(:id).first
        return if role.blank?

        company.memberships.create!(user: user, role: role)
      end
    end
  end
end
