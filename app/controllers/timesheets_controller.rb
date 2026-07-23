# frozen_string_literal: true

class TimesheetsController < ApplicationController
  before_action :require_company!
  before_action :set_day, only: %i[approve reject]

  def index
    authorize AttendanceDay, :index?
    scope = policy_scope(AttendanceDay).includes(:employee)
    @pending = scope.where(overtime_status: "pending").where("overtime_minutes > 0").order(work_date: :desc)
    @recent = scope.where(overtime_status: %w[approved rejected]).where("overtime_minutes > 0").order(updated_at: :desc).limit(30)
  end

  def approve
    authorize @day, :update?
    result = Attendance::ApproveOvertimeService.call(attendance_day: @day, approver: Current.user, decision: :approve)
    redirect_with(result, "Overtime approved.")
  end

  def reject
    authorize @day, :update?
    result = Attendance::ApproveOvertimeService.call(attendance_day: @day, approver: Current.user, decision: :reject)
    redirect_with(result, "Overtime rejected.")
  end

  private

  def set_day
    @day = policy_scope(AttendanceDay).find(params[:id])
  end

  def redirect_with(result, notice)
    if result.success?
      redirect_to timesheets_path, notice: notice
    else
      redirect_to timesheets_path, alert: result.errors.join(", ")
    end
  end
end
