# frozen_string_literal: true

class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_key:, company_id:, payload:, employee_id: nil, user_id: nil, channels: nil)
    company = Company.find(company_id)
    ActsAsTenant.with_tenant(company) do
      Notifications::DeliveryService.call(
        company: company,
        event_key: event_key,
        payload: payload,
        employee_id: employee_id,
        user_id: user_id,
        channels: channels
      )
    end
  end
end
