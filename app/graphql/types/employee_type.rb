# frozen_string_literal: true

module Types
  class EmployeeType < Types::BaseObject
    field :id, ID, null: false
    field :employee_number, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :full_name, String, null: false
    field :email, String, null: false
    field :job_title, String, null: true
    field :employment_status, String, null: false
    field :department, Types::DepartmentType, null: true
    field :salary_cents, GraphQL::Types::BigInt, null: false
    field :currency, String, null: false
  end
end
