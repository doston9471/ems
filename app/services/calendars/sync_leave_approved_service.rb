# frozen_string_literal: true

module Calendars
  class SyncLeaveApprovedService < ApplicationService
    def initialize(company_id:, leave_request_id:, event_key: "leave.approved")
      @company_id = company_id
      @leave_request_id = leave_request_id
      @event_key = event_key.to_s
    end

    def call
      company = Company.find(@company_id)

      ActsAsTenant.with_tenant(company) do
        leave_request = LeaveRequest.find(@leave_request_id)
        connections = CalendarConnection.enabled.where(company_id: company.id, provider: %w[google outlook])
        return success([]) if connections.empty?

        events = connections.map { |connection| sync_connection(connection, leave_request) }
        success(events)
      end
    end

    private

    def sync_connection(connection, leave_request)
      payload = leave_payload(leave_request)
      calendar_event = CalendarEvent.create!(
        company_id: connection.company_id,
        provider: connection.provider,
        eventable: leave_request,
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

    def leave_payload(leave_request)
      employee = leave_request.employee
      timezone = leave_request.company.timezone.presence || "UTC"
      {
        "event_key" => @event_key,
        "summary" => "Leave: #{employee&.full_name || employee&.email} (#{leave_request.leave_type&.name})",
        "description" => "Approved leave #{leave_request.start_on}–#{leave_request.end_on} (#{leave_request.days} days)",
        "start" => { "date" => leave_request.start_on.iso8601 },
        "end" => { "date" => (leave_request.end_on + 1.day).iso8601 },
        "start_datetime" => {
          "dateTime" => leave_request.start_on.in_time_zone(timezone).beginning_of_day.iso8601,
          "timeZone" => timezone
        },
        "end_datetime" => {
          "dateTime" => (leave_request.end_on + 1.day).in_time_zone(timezone).beginning_of_day.iso8601,
          "timeZone" => timezone
        },
        "leave_request_id" => leave_request.id,
        "employee_id" => leave_request.employee_id
      }
    end
  end
end
