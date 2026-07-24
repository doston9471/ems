# frozen_string_literal: true

module My
  class NotificationPreferencesController < BaseController
    skip_after_action :verify_authorized

    def edit
      @user = Current.user
      @channels = User::NOTIFICATION_PREF_CHANNELS
    end

    def update
      Current.user.update_notification_preferences!(preference_params)
      redirect_to edit_my_notification_preferences_path, notice: t("flash.my.preferences_saved")
    end

    private

    def preference_params
      raw = params.fetch(:preferences, {}).permit(*User::NOTIFICATION_PREF_CHANNELS)
      User::NOTIFICATION_PREF_CHANNELS.index_with do |ch|
        ActiveModel::Type::Boolean.new.cast(raw[ch])
      end
    end
  end
end
