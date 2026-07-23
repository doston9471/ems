# frozen_string_literal: true

module Api
  module V1
    class EmployeesController < BaseController
      def index
        authorize Employee
        employees = Employees::SearchQuery.new(
          scope: policy_scope(Employee).kept,
          filters: params.permit(:name, :email, :department_id, :office_id, :manager_id, :status)
        ).call
        render json: EmployeeSerializer.new(employees).serializable_hash
      end

      def show
        employee = policy_scope(Employee).find(params[:id])
        authorize employee
        render json: EmployeeSerializer.new(employee).serializable_hash
      end
    end
  end
end
