# frozen_string_literal: true

module Calendars
  class SyncInterviewService < ApplicationService
    def initialize(company_id:, interview_id:, event_key: "interview.scheduled")
      @company_id = company_id
      @interview_id = interview_id
      @event_key = event_key.to_s
    end

    def call
      company = Company.find(@company_id)

      ActsAsTenant.with_tenant(company) do
        interview = Interview.includes(:applicant, :interviewer).find(@interview_id)
        connections = CalendarConnection.enabled.where(company_id: company.id, provider: %w[google outlook])
        return success([]) if connections.empty?

        events = connections.map { |connection| sync_connection(connection, interview) }
        success(events)
      end
    end

    private

    def sync_connection(connection, interview)
      payload = interview_payload(interview)
      calendar_event = CalendarEvent.create!(
        company_id: connection.company_id,
        provider: connection.provider,
        eventable: interview,
        status: "pending",
        payload: payload
      )

      case connection.provider
      when "google"
        Calendars::Google::CreateEventService.call(calendar_event: calendar_event)
      when "outlook"
        Calendars::Outlook::CreateEventService.call(calendar_event: calendar_event)
      end

      calendar_event.reload
    end

    def interview_payload(interview)
      applicant = interview.applicant
      starts = interview.scheduled_at
      ends = starts + 1.hour
      {
        "event_key" => @event_key,
        "summary" => "Interview: #{applicant&.full_name}",
        "description" => "Interview (#{interview.mode}) with #{interview.interviewer&.full_name || interview.interviewer&.email}",
        "start" => { "dateTime" => starts.iso8601 },
        "end" => { "dateTime" => ends.iso8601 },
        "start_datetime" => { "dateTime" => starts.iso8601, "timeZone" => "UTC" },
        "end_datetime" => { "dateTime" => ends.iso8601, "timeZone" => "UTC" },
        "interview_id" => interview.id,
        "applicant_id" => applicant&.id
      }
    end
  end
end
