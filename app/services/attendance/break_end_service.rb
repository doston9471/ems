# frozen_string_literal: true

module Attendance
  class BreakEndService < ApplicationService
    def initialize(employee:, occurred_at: Time.current, source: "web")
      @employee = employee
      @occurred_at = occurred_at
      @source = source
    end

    def call
      day = open_day
      return failure("No open attendance day") unless day

      start_event = day.attendance_events.where(kind: :break_start).order(:occurred_at, :id).last
      return failure("No active break") unless start_event

      end_after_start = day.attendance_events
                           .where(kind: :break_end)
                           .where("occurred_at >= ?", start_event.occurred_at)
                           .exists?
      return failure("No active break") if end_after_start

      ActiveRecord::Base.transaction do
        minutes = ((@occurred_at - start_event.occurred_at) / 60).floor
        day.update!(break_minutes: day.break_minutes + [ minutes, 0 ].max)
        day.attendance_events.create!(
          company_id: @employee.company_id,
          employee: @employee,
          kind: :break_end,
          occurred_at: @occurred_at,
          source: @source
        )
      end

      success(day.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def open_day
      work_date = @occurred_at.in_time_zone(@employee.company.timezone).to_date
      @employee.attendance_days.find_by(work_date: work_date, status: :open)
    end
  end
end
