# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :me, Types::UserType, null: true, description: "The currently authenticated user"

    field :employees, [ Types::EmployeeType ], null: false do
      description "Employees in the current company"
    end

    field :employee, Types::EmployeeType, null: true do
      argument :id, ID, required: true
    end

    field :departments, [ Types::DepartmentType ], null: false

    def me
      context[:current_user]
    end

    def employees
      require_company!
      policy_scope(Employee).kept.order(:employee_number)
    end

    def employee(id:)
      require_company!
      record = policy_scope(Employee).find_by(id: id)
      return nil unless record

      Pundit.authorize(context[:current_membership], record, :show?)
      record
    end

    def departments
      require_company!
      policy_scope(Department).order(:name)
    end

    private

    def require_company!
      raise GraphQL::ExecutionError, "Authentication required" unless context[:current_user]
      raise GraphQL::ExecutionError, "No active company membership" unless context[:current_company]
    end

    def policy_scope(scope)
      Pundit.policy_scope!(context[:current_membership], scope)
    end
  end
end
