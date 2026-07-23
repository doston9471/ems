# frozen_string_literal: true

module Api
  module V1
    class LeaveRequestsController < BaseController
      before_action :require_employee!

      def create
        leave_request = Current.company.leave_requests.new(leave_request_params.merge(employee: Current.employee))
        authorize leave_request

        result = Leave::SubmitRequestService.call(
          employee: Current.employee,
          attributes: leave_request_params
        )

        if result.success?
          render json: {
            id: result.value.id,
            status: result.value.status,
            start_on: result.value.start_on,
            end_on: result.value.end_on,
            days: result.value.days
          }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def leave_request_params
        params.require(:leave_request).permit(:leave_type_id, :start_on, :end_on, :days, :reason)
      end
    end
  end
end
