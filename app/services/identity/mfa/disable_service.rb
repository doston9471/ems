# frozen_string_literal: true

module Identity
  module Mfa
    class DisableService < ApplicationService
      def initialize(user:, code:)
        @user = user
        @code = code.to_s.strip
      end

      def call
        return failure("User is required") if @user.blank?
        return failure("MFA is not enabled") unless @user.mfa_enabled?
        return failure("Invalid authentication code") unless Identity::Mfa::VerifyService.call(user: @user, code: @code).success?

        @user.update!(mfa_enabled: false, mfa_secret: nil)
        success(@user)
      rescue ActiveRecord::RecordInvalid => e
        failure(e.record.errors.full_messages)
      end
    end
  end
end
