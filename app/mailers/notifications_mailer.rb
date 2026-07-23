# frozen_string_literal: true

class NotificationsMailer < ApplicationMailer
  def event_notification(delivery, email)
    @delivery = delivery
    @payload = delivery.payload
    mail(to: email, subject: "[EMS] #{delivery.event_key}")
  end
end
