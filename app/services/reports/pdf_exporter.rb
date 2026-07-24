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
        pdf.text I18n.t("reports.export.pdf_title", company: @company.name), size: 18, style: :bold
        pdf.move_down 12
        pdf.text I18n.t("reports.export.generated", timestamp: Time.current.strftime("%Y-%m-%d %H:%M UTC")), size: 9, color: "666666"
        pdf.move_down 16

        data = [ [
          I18n.t("reports.export.number"),
          I18n.t("reports.export.name"),
          I18n.t("reports.export.email"),
          I18n.t("reports.export.title"),
          I18n.t("reports.export.department"),
          I18n.t("reports.export.status")
        ] ]
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
