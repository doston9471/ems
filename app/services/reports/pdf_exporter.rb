# frozen_string_literal: true

Prawn::Fonts::AFM.hide_m17n_warning = true

module Reports
  class PdfExporter
    def initialize(employees:, company:)
      @employees = employees
      @company = company
    end

    def call
      Prawn::Document.new(page_layout: :landscape) do |pdf|
        pdf.text "#{@company.name} — Employee Report", size: 18, style: :bold
        pdf.move_down 12
        pdf.text "Generated #{Time.current.strftime('%Y-%m-%d %H:%M UTC')}", size: 9, color: "666666"
        pdf.move_down 16

        data = [ [ "Number", "Name", "Email", "Title", "Department", "Status" ] ]
        @employees.includes(:department).find_each do |employee|
          data << [
            employee.employee_number,
            employee.full_name,
            employee.email,
            employee.job_title.to_s.truncate(28),
            employee.department&.name.to_s.truncate(20),
            employee.employment_status
          ]
        end

        pdf.table(data, header: true, row_colors: %w[F8FAFC FFFFFF], cell_style: { size: 8 }) do
          row(0).font_style = :bold
        end
      end.render
    end
  end
end
