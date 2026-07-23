# frozen_string_literal: true

require "net/http"
require "openssl"
require "jwt"

module Identity
  module Sso
    # Production-shaped OIDC authorization-code login.
    #
    # When client_secret + token_endpoint are configured, exchanges `code` for
    # tokens and optionally verifies the id_token signature via JWKS.
    # Specs may still pass `id_token` or metadata[:demo_id_token] to skip network.
    class OidcLoginService < ApplicationService
      AUTHORIZE_PATH = "/authorize"
      TOKEN_PATH = "/token"

      def initialize(sso_configuration:, redirect_uri: nil, state: nil, code: nil, id_token: nil, nonce: nil)
        @config = sso_configuration
        @redirect_uri = redirect_uri
        @state = state
        @code = code
        @id_token = id_token
        @nonce = nonce
      end

      def call
        return failure("SSO configuration is missing") if @config.blank?
        return failure("SSO is not enabled") unless @config.enabled?
        return failure("Provider must be oidc") unless @config.provider == "oidc"

        if callback?
          handle_callback
        else
          build_authorize_url
        end
      end

      private

      def callback?
        @code.present? || @id_token.present?
      end

      def metadata
        @metadata ||= (@config.metadata || {}).with_indifferent_access
      end

      def build_authorize_url
        issuer = metadata[:issuer].to_s.presence
        client_id = metadata[:client_id].to_s.presence
        return failure("OIDC issuer and client_id are required") if issuer.blank? || client_id.blank?
        return failure("redirect_uri is required") if @redirect_uri.blank?
        return failure("OIDC client_secret is not configured") if metadata[:client_secret].to_s.blank?

        base = issuer.delete_suffix("/")
        authorize_endpoint = metadata[:authorization_endpoint].presence || "#{base}#{AUTHORIZE_PATH}"
        state = @state.presence || SecureRandom.hex(16)
        nonce = @nonce.presence || SecureRandom.hex(16)

        query = {
          client_id: client_id,
          redirect_uri: @redirect_uri,
          response_type: "code",
          scope: metadata[:scope].presence || "openid email profile",
          state: state,
          nonce: nonce
        }

        success({ url: "#{authorize_endpoint}?#{query.to_query}", state: state, nonce: nonce })
      end

      def handle_callback
        token = @id_token.presence || exchange_code_for_id_token
        return failure("Missing id_token") if token.blank?

        claims = verify_and_decode(token)
        return failure("Invalid id_token") if claims.blank?

        email = claims["email"].to_s.strip.downcase.presence ||
                claims["preferred_username"].to_s.strip.downcase.presence
        return failure("id_token did not include an email claim") if email.blank?

        user = find_or_create_user(email: email, claims: claims)
        ensure_membership!(user)
        success(user)
      rescue ActiveRecord::RecordInvalid => e
        failure(e.record.errors.full_messages)
      end

      def exchange_code_for_id_token
        return nil if @code.blank?

        demo_token = metadata[:demo_id_token].presence
        return demo_token if demo_token.present?

        client_id = metadata[:client_id].to_s
        client_secret = metadata[:client_secret].to_s
        return nil if client_id.blank? || client_secret.blank? || @redirect_uri.blank?

        issuer = metadata[:issuer].to_s.delete_suffix("/")
        token_endpoint = metadata[:token_endpoint].presence || "#{issuer}#{TOKEN_PATH}"
        uri = URI.parse(token_endpoint)

        response = Net::HTTP.post_form(uri, {
          grant_type: "authorization_code",
          code: @code,
          redirect_uri: @redirect_uri,
          client_id: client_id,
          client_secret: client_secret
        })
        body = JSON.parse(response.body) rescue {}
        return nil unless response.is_a?(Net::HTTPSuccess)

        body["id_token"].presence
      rescue StandardError => e
        Rails.logger.warn("[OidcLoginService] token exchange failed: #{e.message}")
        nil
      end

      def verify_and_decode(token)
        if metadata[:jwks_uri].present? && !ActiveModel::Type::Boolean.new.cast(metadata[:skip_jwks_verify])
          decode_with_jwks(token)
        else
          decode_jwt_payload(token)
        end
      end

      def decode_with_jwks(token)
        jwks = fetch_jwks
        return {} if jwks.blank?

        JWT.decode(
          token,
          nil,
          true,
          algorithms: Array(metadata[:algorithms].presence || [ "RS256" ]),
          jwks: jwks,
          iss: metadata[:issuer].presence,
          verify_iss: metadata[:issuer].present?,
          aud: metadata[:client_id].presence,
          verify_aud: metadata[:client_id].present?
        ).first
      rescue JWT::DecodeError => e
        Rails.logger.warn("[OidcLoginService] JWKS verify failed: #{e.message}")
        {}
      end

      def fetch_jwks
        uri = URI.parse(metadata[:jwks_uri].to_s)
        response = Net::HTTP.get_response(uri)
        return nil unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      rescue StandardError
        nil
      end

      def decode_jwt_payload(token)
        parts = token.to_s.split(".")
        return {} if parts.size < 2

        payload = parts[1]
        padded = payload.ljust(payload.length + (4 - payload.length % 4) % 4, "=")
        JSON.parse(Base64.urlsafe_decode64(padded))
      rescue ArgumentError, JSON::ParserError
        {}
      end

      def find_or_create_user(email:, claims:)
        user = User.find_by(email_address: email)
        if user
          user.update!(email_verified_at: Time.current) if user.email_verified_at.blank?
          return user
        end

        user = User.new(
          email_address: email,
          first_name: claims["given_name"].presence || claims["name"]&.to_s&.split&.first,
          last_name: claims["family_name"].presence || claims["name"]&.to_s&.split&.drop(1)&.join(" ").presence,
          email_verified_at: Time.current
        )
        user.oauth_identities.build(
          provider: "oidc",
          uid: claims["sub"].presence || email,
          email: email,
          raw_metadata: claims
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
