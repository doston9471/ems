# frozen_string_literal: true

module Identity
  class ConfirmEmailVerificationService < ApplicationService
    def initialize(token:)
      @token = token
    end

    def call
      return failure("Verification token is required") if @token.blank?

      user = User.find_signed(@token, purpose: :email_verification)
      return failure("Verification link is invalid or has expired") if user.blank?

      user.update!(email_verified_at: Time.current) if user.email_verified_at.blank?
      success(user)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
