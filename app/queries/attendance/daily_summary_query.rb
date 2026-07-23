# frozen_string_literal: true

module Attendance
  class DailySummaryQuery
    def initialize(company:, date: Date.current)
      @company = company
      @date = date
    end

    def call
      days = AttendanceDay.where(company: @company, work_date: @date).includes(:employee, :attendance_events)

      {
        date: @date,
        total: days.size,
        open: days.count(&:open?),
        complete: days.count(&:complete?),
        missing_clock_out: days.count(&:missing_clock_out?),
        late: days.count { |d| d.attendance_events.any? { |e| e.clock_in? && e.metadata["late"] } },
        days: days
      }
    end
  end
end
