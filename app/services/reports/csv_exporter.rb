# frozen_string_literal: true

require "csv"

module Reports
  class CsvExporter
    HEADERS = %w[
      employee_number first_name last_name email job_title department office
      employment_status joining_date salary_cents currency manager
    ].freeze

    def initialize(employees:)
      @employees = employees
    end

    def call
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        @employees.find_each do |employee|
          csv << [
            employee.employee_number,
            employee.first_name,
            employee.last_name,
            employee.email,
            employee.job_title,
            employee.department&.name,
            employee.office&.name,
            employee.employment_status,
            employee.joining_date,
            employee.salary_cents,
            employee.currency,
            employee.manager&.full_name
          ]
        end
      end
    end
  end
end
