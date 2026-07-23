# frozen_string_literal: true

class EmailVerificationsMailer < ApplicationMailer
  def verify(user)
    @user = user
    @token = user.signed_id(purpose: :email_verification, expires_in: 2.days)
    mail subject: "Verify your email address", to: user.email_address
  end
end
