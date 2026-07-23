# frozen_string_literal: true

module Identity
  module Mfa
    class SetupService < ApplicationService
      ISSUER = "EMS"

      def initialize(user:)
        @user = user
      end

      def call
        return failure("User is required") if @user.blank?
        return failure("MFA is already enabled") if @user.mfa_enabled?

        secret = @user.mfa_secret.presence || ROTP::Base32.random
        @user.update!(mfa_secret: secret) if @user.mfa_secret != secret

        totp = ROTP::TOTP.new(secret, issuer: ISSUER)
        provisioning_uri = totp.provisioning_uri(@user.email_address)

        success(
          secret: secret,
          provisioning_uri: provisioning_uri,
          qr_svg: qr_svg(provisioning_uri)
        )
      rescue ActiveRecord::RecordInvalid => e
        failure(e.record.errors.full_messages)
      end

      private

      def qr_svg(uri)
        RQRCode::QRCode.new(uri).as_svg(
          color: "0f172a",
          shape_rendering: "crispEdges",
          module_size: 4,
          standalone: true,
          use_path: true
        )
      end
    end
  end
end
