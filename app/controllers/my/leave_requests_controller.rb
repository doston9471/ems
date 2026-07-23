# frozen_string_literal: true

module My
  class LeaveRequestsController < BaseController
    before_action :set_leave_request, only: :show

    def index
      authorize LeaveRequest
      @leave_requests = Current.employee.leave_requests.includes(:leave_type).order(created_at: :desc)
      @balances = Current.employee.leave_balances.includes(:leave_type).order("leave_types.name")
    end

    def show
      authorize @leave_request
    end

    def new
      @leave_request = Current.employee.leave_requests.new
      authorize @leave_request
      @leave_types = Current.company.leave_types.order(:name)
    end

    def create
      @leave_request = Current.employee.leave_requests.new(leave_params)
      authorize @leave_request

      result = Leave::SubmitRequestService.call(employee: Current.employee, attributes: leave_params.to_h)
      if result.success?
        redirect_to my_leave_request_path(result.value), notice: "Leave request submitted."
      else
        @leave_request.assign_attributes(leave_params)
        @leave_request.errors.add(:base, result.errors.join(", "))
        @leave_types = Current.company.leave_types.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_leave_request
      @leave_request = Current.employee.leave_requests.find(params[:id])
    end

    def leave_params
      params.require(:leave_request).permit(:leave_type_id, :start_on, :end_on, :days, :reason)
    end
  end
end
