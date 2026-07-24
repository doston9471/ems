# frozen_string_literal: true

class LeaveRequestsController < ApplicationController
  before_action :require_company!
  before_action :set_leave_request, only: %i[show approve reject]
  before_action :require_employee!, only: %i[new create]

  def index
    authorize LeaveRequest
    @leave_requests = policy_scope(LeaveRequest).includes(:employee, :leave_type).order(created_at: :desc)
  end

  def show
    authorize @leave_request
  end

  def new
    @leave_request = Current.company.leave_requests.new(employee: Current.employee)
    authorize @leave_request
    load_form_collections
  end

  def create
    @leave_request = Current.company.leave_requests.new(leave_request_params.merge(employee: Current.employee))
    authorize @leave_request

    result = Leave::SubmitRequestService.call(
      employee: Current.employee,
      attributes: leave_request_params
    )

    if result.success?
      redirect_to leave_requests_path, notice: t("flash.leave.submitted")
    else
      @leave_request.assign_attributes(leave_request_params)
      @leave_request.errors.add(:base, result.errors.join(", "))
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    authorize @leave_request, :approve?
    result = Leave::ApproveService.call(leave_request: @leave_request, approver: Current.user, comment: params[:comment])
    redirect_with_result(result, t("flash.leave.approved"))
  end

  def reject
    authorize @leave_request, :reject?
    result = Leave::RejectService.call(leave_request: @leave_request, approver: Current.user, reason: params[:reason])
    redirect_with_result(result, t("flash.leave.rejected"))
  end

  private

  def set_leave_request
    @leave_request = policy_scope(LeaveRequest).find(params[:id])
  end

  def require_employee!
    return if Current.employee

    redirect_to leave_requests_path, alert: t("flash.no_employee_profile")
  end

  def leave_request_params
    params.require(:leave_request).permit(:leave_type_id, :start_on, :end_on, :days, :reason)
  end

  def load_form_collections
    @leave_types = LeaveType.order(:name)
  end

  def redirect_with_result(result, notice)
    if result.success?
      redirect_to leave_request_path(result.value), notice: notice
    else
      redirect_to leave_request_path(@leave_request), alert: result.errors.join(", ")
    end
  end
end
