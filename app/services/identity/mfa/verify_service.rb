# frozen_string_literal: true

module Identity
  module Mfa
    class VerifyService < ApplicationService
      DRIFT = 1

      def initialize(user:, code:)
        @user = user
        @code = code.to_s.strip
      end

      def call
        return failure("User is required") if @user.blank?
        return failure("Authentication code is required") if @code.blank?
        return failure("MFA secret is missing") if @user.mfa_secret.blank?
        return failure("Invalid authentication code") unless totp.verify(@code, drift_behind: DRIFT, drift_ahead: DRIFT)

        success(@user)
      end

      private

      def totp
        ROTP::TOTP.new(@user.mfa_secret, issuer: Identity::Mfa::SetupService::ISSUER)
      end
    end
  end
end
