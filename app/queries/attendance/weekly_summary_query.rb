# frozen_string_literal: true

module Attendance
  class WeeklySummaryQuery
    def initialize(company:, week_start: Date.current.beginning_of_week)
      @company = company
      @week_start = week_start
      @week_end = week_start.end_of_week
    end

    def call
      days = AttendanceDay.where(company: @company, work_date: @week_start..@week_end)

      {
        week_start: @week_start,
        week_end: @week_end,
        days_count: days.count,
        worked_minutes: days.sum(:worked_minutes),
        overtime_minutes: days.sum(:overtime_minutes),
        break_minutes: days.sum(:break_minutes),
        by_date: days.group(:work_date).count
      }
    end
  end
end
