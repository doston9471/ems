# frozen_string_literal: true

module My
  class NotificationsController < BaseController
    skip_after_action :verify_authorized
    before_action :set_notification, only: :mark_read

    def index
      @notifications = NotificationDelivery.for_user(Current.user)
                                           .in_app
                                           .order(created_at: :desc)
                                           .limit(50)
    end

    def mark_read
      @notification.mark_read!
      redirect_to my_notifications_path, notice: "Marked as read."
    end

    def mark_all_read
      NotificationDelivery.for_user(Current.user).in_app.unread.find_each(&:mark_read!)
      redirect_to my_notifications_path, notice: "All notifications marked as read."
    end

    private

    def set_notification
      @notification = NotificationDelivery.for_user(Current.user).in_app.find(params[:id])
    end
  end
end
