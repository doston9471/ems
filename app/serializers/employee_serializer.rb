# frozen_string_literal: true

class EmployeeSerializer
  include JSONAPI::Serializer

  attributes :employee_number, :first_name, :last_name, :email, :job_title,
             :employment_status, :department_id, :office_id, :manager_id, :joining_date

  attribute :full_name do |employee|
    employee.full_name
  end
end
