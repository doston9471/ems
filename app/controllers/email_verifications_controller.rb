# frozen_string_literal: true

class EmailVerificationsController < ApplicationController
  allow_unauthenticated_access only: :show
  skip_after_action :verify_authorized

  def show
    result = Identity::ConfirmEmailVerificationService.call(token: params[:token])

    if result.success?
      redirect_to (authenticated? ? root_path : new_session_path), notice: "Email verified successfully."
    else
      redirect_to (authenticated? ? root_path : new_session_path), alert: Array(result.errors).to_sentence
    end
  end

  def create
    result = Identity::SendEmailVerificationService.call(user: current_user)

    if result.success?
      redirect_back fallback_location: root_path, notice: "Verification email sent."
    else
      redirect_back fallback_location: root_path, alert: Array(result.errors).to_sentence
    end
  end
end
