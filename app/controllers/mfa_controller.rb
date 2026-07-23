# frozen_string_literal: true

class MfaController < ApplicationController
  skip_after_action :verify_authorized

  def show
    if current_user.mfa_enabled?
      @enabled = true
    else
      result = Identity::Mfa::SetupService.call(user: current_user)
      if result.failure?
        redirect_to root_path, alert: Array(result.errors).to_sentence
        return
      end

      @secret = result.value[:secret]
      @qr_svg = result.value[:qr_svg]
      @provisioning_uri = result.value[:provisioning_uri]
    end
  end

  def create
    result = Identity::Mfa::EnableService.call(user: current_user, code: params[:code])

    if result.success?
      redirect_to mfa_path, notice: "Two-factor authentication enabled."
    else
      redirect_to mfa_path, alert: Array(result.errors).to_sentence
    end
  end

  def destroy
    result = Identity::Mfa::DisableService.call(user: current_user, code: params[:code])

    if result.success?
      redirect_to mfa_path, notice: "Two-factor authentication disabled."
    else
      redirect_to mfa_path, alert: Array(result.errors).to_sentence
    end
  end
end
