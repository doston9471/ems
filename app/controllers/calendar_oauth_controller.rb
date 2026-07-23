# frozen_string_literal: true

class CalendarOauthController < ApplicationController
  before_action :require_company!
  before_action :authorize_manage!
  rate_limit to: 20, within: 1.minute, only: %i[initiate callback], with: -> { redirect_to calendar_connections_path, alert: "Too many OAuth attempts." }

  def initiate
    provider = params[:provider].to_s
    state = SecureRandom.hex(16)
    session[:calendar_oauth_state] = state
    session[:calendar_oauth_provider] = provider

    result = case provider
    when "google"
               Calendars::Oauth::GoogleAuthorizeService.call(redirect_uri: callback_url(provider), state: state)
    when "outlook"
               Calendars::Oauth::OutlookAuthorizeService.call(redirect_uri: callback_url(provider), state: state)
    else
               ApplicationService::Result.new(success: false, value: nil, errors: [ "Unknown provider" ])
    end

    if result.success?
      redirect_to result.value, allow_other_host: true
    else
      redirect_to calendar_connections_path, alert: result.errors.join(", ")
    end
  end

  def callback
    provider = params[:provider].to_s
    if params[:state].blank? || params[:state] != session[:calendar_oauth_state] || provider != session[:calendar_oauth_provider]
      redirect_to calendar_connections_path, alert: "Invalid OAuth state."
      return
    end

    if params[:error].present?
      redirect_to calendar_connections_path, alert: params[:error_description].presence || params[:error]
      return
    end

    result = case provider
    when "google"
               Calendars::Oauth::GoogleCallbackService.call(
                 company: Current.company,
                 code: params[:code],
                 redirect_uri: callback_url(provider)
               )
    when "outlook"
               Calendars::Oauth::OutlookCallbackService.call(
                 company: Current.company,
                 code: params[:code],
                 redirect_uri: callback_url(provider)
               )
    else
               ApplicationService::Result.new(success: false, value: nil, errors: [ "Unknown provider" ])
    end

    session.delete(:calendar_oauth_state)
    session.delete(:calendar_oauth_provider)

    if result.success?
      redirect_to calendar_connections_path, notice: "#{provider.titleize} calendar connected."
    else
      redirect_to calendar_connections_path, alert: result.errors.join(", ")
    end
  end

  private

  def authorize_manage!
    authorize CalendarConnection, :create?
  end

  def callback_url(provider)
    calendar_oauth_callback_url(provider: provider)
  end
end
