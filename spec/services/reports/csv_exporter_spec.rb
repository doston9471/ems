# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CsvExporter do
  let(:company) { create(:company) }
  let!(:employee) { create(:employee, company: company, first_name: "Export", last_name: "Me") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "exports employee rows as CSV with translated headers" do
    csv = described_class.new(employees: company.employees.kept).call
    expect(csv).to include(I18n.t("reports.export.headers.employee_number"))
    expect(csv).to include(I18n.t("reports.export.headers.first_name"))
    expect(csv).to include("Export")
    expect(csv).to include("Me")
  end

  it "uses locale-specific header labels" do
    I18n.with_locale(:es) do
      csv = described_class.new(employees: company.employees.kept).call
      expect(csv).to include("Número de empleado")
      expect(csv).to include("Nombre")
    end
  end
end
