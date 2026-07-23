# frozen_string_literal: true

module My
  class AttendanceController < BaseController
    def show
      authorize AttendanceDay, :index?
      @employee = Current.employee
      @today = AttendanceDay.find_by(employee: @employee, work_date: Date.current)
      @days = @employee.attendance_days.order(work_date: :desc).limit(30)
    end

    def clock_in
      authorize AttendanceDay, :clock_in?
      redirect_with_result(Attendance::ClockInService.call(employee: Current.employee), "Clocked in.")
    end

    def clock_out
      authorize AttendanceDay, :clock_out?
      redirect_with_result(Attendance::ClockOutService.call(employee: Current.employee), "Clocked out.")
    end

    def break_start
      authorize AttendanceDay, :break_start?
      redirect_with_result(Attendance::BreakStartService.call(employee: Current.employee), "Break started.")
    end

    def break_end
      authorize AttendanceDay, :break_end?
      redirect_with_result(Attendance::BreakEndService.call(employee: Current.employee), "Break ended.")
    end

    private

    def redirect_with_result(result, notice)
      if result.success?
        redirect_to my_attendance_path, notice: notice
      else
        redirect_to my_attendance_path, alert: result.errors.join(", ")
      end
    end
  end
end
