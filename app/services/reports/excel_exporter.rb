# frozen_string_literal: true

module Reports
  class ExcelExporter
    def initialize(employees:)
      @employees = employees
    end

    def call
      package = Axlsx::Package.new
      workbook = package.workbook
      workbook.add_worksheet(name: I18n.t("reports.export.sheet_name")) do |sheet|
        sheet.add_row Reports::CsvExporter.translated_headers
        @employees.find_each do |employee|
          sheet.add_row [
            employee.employee_number,
            employee.first_name,
            employee.last_name,
            employee.email,
            employee.job_title,
            employee.department&.name,
            employee.office&.name,
            employee.employment_status,
            employee.joining_date&.to_s,
            employee.salary_cents,
            employee.currency,
            employee.manager&.full_name
          ]
        end
      end
      package.to_stream.read
    end
  end
end
