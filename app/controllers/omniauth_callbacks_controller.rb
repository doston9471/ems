# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized
  skip_before_action :set_current_tenant

  def create
    result = Identity::OauthLoginService.call(auth: request.env["omniauth.auth"])

    if result.failure?
      redirect_to new_session_path, alert: Array(result.errors).to_sentence.presence || "OAuth login failed."
      return
    end

    complete_authentication_for(result.value)
  end

  def failure
    redirect_to new_session_path, alert: "OAuth authentication failed. Please try again."
  end

  private

  def complete_authentication_for(user)
    if user.mfa_enabled?
      session[:mfa_pending_user_id] = user.id
      redirect_to new_mfa_challenge_path, notice: "Enter your authenticator code to finish signing in."
    else
      start_new_session_for(user)
      redirect_to after_authentication_url
    end
  end
end
