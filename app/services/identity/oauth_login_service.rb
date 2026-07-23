# frozen_string_literal: true

module Identity
  class OauthLoginService < ApplicationService
    def initialize(auth:)
      @auth = auth
    end

    def call
      return failure("Missing OAuth payload") if @auth.blank?

      provider = @auth["provider"].to_s
      uid = @auth["uid"].to_s
      return failure("Invalid OAuth provider or uid") if provider.blank? || uid.blank?

      info = @auth["info"] || {}
      email = info["email"].to_s.strip.downcase.presence
      return failure("OAuth provider did not return an email address") if email.blank?

      user = nil

      ActiveRecord::Base.transaction do
        identity = OauthIdentity.find_by(provider: provider, uid: uid)

        if identity
          user = identity.user
          identity.update!(email: email, raw_metadata: serialize_auth)
        else
          user = User.find_by(email_address: email)

          if user
            user.oauth_identities.create!(
              provider: provider,
              uid: uid,
              email: email,
              raw_metadata: serialize_auth
            )
          else
            user = User.new(
              email_address: email,
              first_name: info["first_name"].presence || info["name"]&.split&.first,
              last_name: info["last_name"].presence || info["name"]&.split&.drop(1)&.join(" ").presence,
              email_verified_at: Time.current
            )
            user.oauth_identities.build(
              provider: provider,
              uid: uid,
              email: email,
              raw_metadata: serialize_auth
            )
            user.save!
          end
        end

        user.update!(email_verified_at: Time.current) if user.email_verified_at.blank?
      end

      success(user.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def serialize_auth
      @auth.respond_to?(:to_hash) ? @auth.to_hash : @auth.to_h
    end
  end
end
