# frozen_string_literal: true

module Identity
  class SendEmailVerificationService < ApplicationService
    def initialize(user:)
      @user = user
    end

    def call
      return failure("User is required") if @user.blank?
      return failure("Email is already verified") if @user.email_verified_at.present?

      EmailVerificationsMailer.verify(@user).deliver_later
      success(@user)
    end
  end
end
