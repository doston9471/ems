# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CsvExporter do
  let(:company) { create(:company) }
  let!(:employee) { create(:employee, company: company, first_name: "Export", last_name: "Me") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "exports employee rows as CSV" do
    csv = described_class.new(employees: company.employees.kept).call
    expect(csv).to include("employee_number")
    expect(csv).to include("Export")
    expect(csv).to include("Me")
  end
end
