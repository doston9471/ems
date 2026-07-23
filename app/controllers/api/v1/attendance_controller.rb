# frozen_string_literal: true

module Api
  module V1
    class AttendanceController < BaseController
      before_action :require_employee!

      def clock_in
        authorize AttendanceDay, :clock_in?
        result = Attendance::ClockInService.call(employee: Current.employee, source: "mobile")
        render_service_result(result)
      end

      def clock_out
        authorize AttendanceDay, :clock_out?
        result = Attendance::ClockOutService.call(employee: Current.employee, source: "mobile")
        render_service_result(result)
      end

      private

      def render_service_result(result)
        if result.success?
          render json: {
            id: result.value.id,
            work_date: result.value.work_date,
            status: result.value.status,
            clock_in_at: result.value.clock_in_at,
            clock_out_at: result.value.clock_out_at
          }
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
