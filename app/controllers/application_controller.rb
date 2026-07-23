# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  include Tenancy

  allow_browser versions: :modern
  stale_when_importmap_changes

  around_action :switch_locale
  before_action :assign_unread_notification_count
  after_action :verify_authorized, unless: :skip_authorization?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_company

  private

  def assign_unread_notification_count
    return unless Current.user

    @unread_notification_count = NotificationDelivery.for_user(Current.user).in_app.unread.count
  end

  def switch_locale(&action)
    locale = params[:locale].presence ||
             Current.user&.preferred_locale.presence ||
             Current.company&.locale.presence ||
             I18n.default_locale
    locale = Locale.valid?(locale) ? locale.to_sym : I18n.default_locale

    if Current.user && params[:locale].present? && Locale.valid?(params[:locale])
      preferred = params[:locale].to_s
      Current.user.update_column(:preferred_locale, preferred) if Current.user.preferred_locale != preferred
    end

    I18n.with_locale(locale, &action)
  end

  def default_url_options
    locale = I18n.locale.to_s
    return {} if locale == I18n.default_locale.to_s

    { locale: locale }
  end

  def pundit_user
    Current.membership
  end

  def skip_authorization?
    false
  end

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: "You are not authorized to perform this action." }
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end
end
