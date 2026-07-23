# frozen_string_literal: true

module Notifications
  module Adapters
    class EmailAdapter
      def deliver(delivery)
        user = delivery.user || delivery.employee&.user
        email = user&.email_address || delivery.employee&.email || delivery.payload["email"]

        if email.blank?
          return { success: false, skipped: true, error: "No recipient email" }
        end

        NotificationsMailer.event_notification(delivery, email).deliver_later
        { success: true }
      end
    end
  end
end
