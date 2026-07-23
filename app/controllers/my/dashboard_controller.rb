# frozen_string_literal: true

module My
  class DashboardController < BaseController
    skip_after_action :verify_authorized

    def show
      @employee = Employee.includes(:department, :office, :manager, :teams).find(Current.employee.id)
      @today = AttendanceDay.find_by(employee: @employee, work_date: Date.current)
      @week_days = week_attendance_days
      @leave_balances = @employee.leave_balances.includes(:leave_type).where(year: Date.current.year).order("leave_types.name")
      @leave_requests = @employee.leave_requests.includes(:leave_type).order(created_at: :desc).limit(3)
      @reviews = scoped_reviews.limit(3)
      @payslips = completed_payslips.limit(3)
      @latest_payslip = completed_payslips.first
      @pending_reviews = scoped_reviews.where(reviewer_id: @employee.id, status: :pending).limit(5)
      @awaiting_leave = @employee.leave_requests.where(status: %i[pending_manager pending_hr]).includes(:leave_type).limit(5)
      @unread_notifications = NotificationDelivery.for_user(Current.user).in_app.unread.order(created_at: :desc).limit(5)
      @can_clock = policy(AttendanceDay).clock_in?
    end

    private

    def scoped_reviews
      PerformanceReview.where(employee_id: @employee.id)
                       .or(PerformanceReview.where(reviewer_id: @employee.id))
                       .includes(:review_cycle, :employee, :reviewer)
                       .order(updated_at: :desc)
    end

    def completed_payslips
      PayrollItem.joins(:payroll_run)
                 .where(employee_id: @employee.id, payroll_runs: { status: :completed })
                 .includes(:payroll_run)
                 .order("payroll_runs.period_end DESC")
    end

    def week_attendance_days
      dates = (6.days.ago.to_date..Date.current).to_a
      by_date = @employee.attendance_days.where(work_date: dates).index_by(&:work_date)
      dates.map { |date| { date: date, day: by_date[date] } }
    end
  end
end
