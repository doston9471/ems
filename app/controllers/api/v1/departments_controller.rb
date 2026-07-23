# frozen_string_literal: true

module Api
  module V1
    class DepartmentsController < BaseController
      def index
        authorize Department
        departments = policy_scope(Department).order(:name)
        render json: DepartmentSerializer.new(departments).serializable_hash
      end
    end
  end
end
