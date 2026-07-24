# frozen_string_literal: true

module Attendance
  class DaysController < ApplicationController
    before_action :require_company!
    before_action :require_employee!, only: %i[clock_in clock_out break_start break_end]

    def index
      authorize AttendanceDay
      @summary = Attendance::DailySummaryQuery.new(company: Current.company, date: date_param).call
      @weekly = Attendance::WeeklySummaryQuery.new(company: Current.company).call
      @days = policy_scope(AttendanceDay).includes(:employee).order(work_date: :desc, id: :desc).limit(50)
      @today = Current.employee && AttendanceDay.find_by(employee: Current.employee, work_date: Date.current)
    end

    def clock_in
      authorize AttendanceDay, :clock_in?
      result = Attendance::ClockInService.call(employee: Current.employee)
      redirect_with_result(result, t("flash.my.clocked_in"))
    end

    def clock_out
      authorize AttendanceDay, :clock_out?
      result = Attendance::ClockOutService.call(employee: Current.employee)
      redirect_with_result(result, t("flash.my.clocked_out"))
    end

    def break_start
      authorize AttendanceDay, :break_start?
      result = Attendance::BreakStartService.call(employee: Current.employee)
      redirect_with_result(result, t("flash.my.break_started"))
    end

    def break_end
      authorize AttendanceDay, :break_end?
      result = Attendance::BreakEndService.call(employee: Current.employee)
      redirect_with_result(result, t("flash.my.break_ended"))
    end

    private

    def require_employee!
      return if Current.employee

      redirect_to attendance_days_path, alert: t("flash.no_employee_profile")
    end

    def date_param
      params[:date].present? ? Date.parse(params[:date]) : Date.current
    rescue ArgumentError
      Date.current
    end

    def redirect_with_result(result, notice)
      if result.success?
        redirect_to attendance_days_path, notice: notice
      else
        redirect_to attendance_days_path, alert: result.errors.join(", ")
      end
    end
  end
end
