# frozen_string_literal: true

class MfaChallengesController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized
  skip_before_action :set_current_tenant
  before_action :require_pending_mfa_user
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    result = Identity::Mfa::VerifyService.call(user: @pending_user, code: params[:code])

    if result.success?
      session.delete(:mfa_pending_user_id)
      start_new_session_for(@pending_user)
      redirect_to after_authentication_url
    else
      redirect_to new_mfa_challenge_path, alert: Array(result.errors).to_sentence.presence || "Invalid authentication code."
    end
  end

  private

  def require_pending_mfa_user
    @pending_user = User.find_by(id: session[:mfa_pending_user_id])
    return if @pending_user&.mfa_enabled?

    session.delete(:mfa_pending_user_id)
    redirect_to new_session_path, alert: "Sign in again to continue."
  end
end
