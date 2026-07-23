# frozen_string_literal: true

module Attendance
  class BreakStartService < ApplicationService
    def initialize(employee:, occurred_at: Time.current, source: "web")
      @employee = employee
      @occurred_at = occurred_at
      @source = source
    end

    def call
      day = open_day
      return failure("No open attendance day") unless day
      return failure("Not clocked in") if day.clock_in_at.blank?
      return failure("Already clocked out") if day.clock_out_at.present?
      return failure("Break already started") if last_event_kind(day) == "break_start"

      event = day.attendance_events.create!(
        company_id: @employee.company_id,
        employee: @employee,
        kind: :break_start,
        occurred_at: @occurred_at,
        source: @source
      )

      success(event)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def open_day
      work_date = @occurred_at.in_time_zone(@employee.company.timezone).to_date
      @employee.attendance_days.find_by(work_date: work_date, status: :open)
    end

    def last_event_kind(day)
      day.attendance_events.order(:occurred_at, :id).last&.kind
    end
  end
end
