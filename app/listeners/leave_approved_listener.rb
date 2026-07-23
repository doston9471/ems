# frozen_string_literal: true

class LeaveApprovedListener
  def self.call(event)
    return unless event.is_a?(Leave::ApprovedEvent)

    NotificationJob.perform_later(
      event_key: event.event_key,
      company_id: event.company_id,
      employee_id: event.employee_id,
      payload: event.payload.merge("occurred_at" => event.occurred_at.iso8601)
    )

    Webhooks::DispatchService.call(
      company_id: event.company_id,
      event_key: event.event_key,
      payload: event.payload
    )

    CalendarSyncJob.perform_later(
      event_key: event.event_key,
      company_id: event.company_id,
      leave_request_id: event.leave_request_id
    )
  end
end
