# frozen_string_literal: true

module Dashboard
  class ChartsQuery
    ATTENDANCE_DAYS = 14

    def initialize(company:, today: Date.current)
      @company = company
      @today = today
    end

    def call
      {
        headcount_by_department: headcount_by_department,
        employment_status: employment_status,
        attendance_trend: attendance_trend,
        leave_pipeline: leave_pipeline
      }
    end

    private

    def headcount_by_department
      rows = @company.employees.kept
                     .left_joins(:department)
                     .group("departments.name")
                     .count
                     .transform_keys { |name| name.presence || I18n.t("dashboard.unassigned") }
                     .sort_by { |_name, count| -count }

      {
        labels: rows.map(&:first),
        values: rows.map(&:last)
      }
    end

    def employment_status
      counts = @company.employees.kept.group(:employment_status).count
      labels = counts.keys.map { |status| status.to_s.humanize }
      {
        labels: labels,
        values: counts.values
      }
    end

    def attendance_trend
      from = @today - (ATTENDANCE_DAYS - 1)
      range = from..@today
      present_by_date = @company.attendance_days
                                .where(work_date: range)
                                .where.not(clock_in_at: nil)
                                .group(:work_date)
                                .count

      labels = range.map { |date| date.strftime("%b %d") }
      values = range.map { |date| present_by_date[date].to_i }

      {
        labels: labels,
        values: values
      }
    end

    def leave_pipeline
      counts = @company.leave_requests.group(:status).count
      ordered = LeaveRequest.statuses.keys

      {
        labels: ordered.map(&:humanize),
        values: ordered.map { |status| counts.fetch(status, 0) }
      }
    end
  end
end
