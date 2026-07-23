# frozen_string_literal: true

class CalendarSyncJob < ApplicationJob
  queue_as :default

  def perform(event_key:, company_id:, leave_request_id: nil, interview_id: nil)
    if leave_request_id.present?
      Calendars::SyncLeaveApprovedService.call(
        company_id: company_id,
        leave_request_id: leave_request_id,
        event_key: event_key
      )
    elsif interview_id.present?
      Calendars::SyncInterviewService.call(
        company_id: company_id,
        interview_id: interview_id,
        event_key: event_key
      )
    else
      Rails.logger.warn("[CalendarSyncJob] skipped — no leave_request_id or interview_id (event_key=#{event_key})")
    end
  end
end
