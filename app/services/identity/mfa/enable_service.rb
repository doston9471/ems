# frozen_string_literal: true

module Identity
  module Mfa
    class EnableService < ApplicationService
      def initialize(user:, code:)
        @user = user
        @code = code.to_s.strip
      end

      def call
        return failure("User is required") if @user.blank?
        return failure("MFA is already enabled") if @user.mfa_enabled?
        return failure("MFA secret is missing. Start setup first.") if @user.mfa_secret.blank?
        return failure("Invalid authentication code") unless valid_code?

        @user.update!(mfa_enabled: true)
        success(@user)
      rescue ActiveRecord::RecordInvalid => e
        failure(e.record.errors.full_messages)
      end

      private

      def valid_code?
        Identity::Mfa::VerifyService.call(user: @user, code: @code).success?
      end
    end
  end
end
