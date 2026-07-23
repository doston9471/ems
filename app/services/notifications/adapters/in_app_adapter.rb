# frozen_string_literal: true

module Notifications
  module Adapters
    class InAppAdapter
      def deliver(delivery)
        Rails.logger.info("[InAppAdapter] recorded event=#{delivery.event_key} employee=#{delivery.employee_id}")

        user = User.find_by(id: delivery.user_id)
        if user
          NotificationsChannel.broadcast_to(
            user,
            {
              event_key: delivery.event_key,
              delivery_id: delivery.id,
              unread_count: unread_count_for(user.id)
            }
          )
        end

        { success: true }
      end

      private

      def unread_count_for(user_id)
        NotificationDelivery.where(user_id: user_id, channel: "in_app", read_at: nil).count
      end
    end
  end
end
