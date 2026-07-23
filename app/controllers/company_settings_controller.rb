# frozen_string_literal: true

class CompanySettingsController < ApplicationController
  before_action :require_company!

  def edit
    authorize Current.company, :update?
    @company = Current.company
  end

  def update
    authorize Current.company, :update?
    @company = Current.company
    settings = (@company.settings || {}).merge(settings_params.to_h.compact_blank)
    if @company.update(settings: settings)
      redirect_to edit_company_settings_path, notice: "Integration settings saved."
    else
      flash.now[:alert] = @company.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:settings).permit(
      :slack_webhook_url,
      :teams_webhook_url,
      :telegram_bot_token,
      :telegram_chat_id,
      :twilio_account_sid,
      :twilio_auth_token,
      :twilio_from_number,
      :google_calendar_stub,
      :outlook_calendar_stub
    )
  end
end
