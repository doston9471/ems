# frozen_string_literal: true

module Reports
  class AttendanceSummaryQuery
    def initialize(company:, from: 30.days.ago.to_date, to: Date.current)
      @company = company
      @from = from
      @to = to
    end

    def call
      days = @company.attendance_days.where(work_date: @from..@to)
      {
        from: @from,
        to: @to,
        total_days: days.count,
        by_status: days.group(:status).count,
        unique_employees: days.distinct.count(:employee_id)
      }
    rescue StandardError
      # Fallback if status column naming differs
      {
        from: @from,
        to: @to,
        total_days: @company.attendance_days.where(work_date: @from..@to).count,
        by_status: {},
        unique_employees: @company.attendance_days.where(work_date: @from..@to).distinct.count(:employee_id)
      }
    end
  end
end
