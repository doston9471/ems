# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::ExcelExporter do
  let(:company) { create(:company) }
  let!(:employee) { create(:employee, company: company, first_name: "Export", last_name: "Me") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "exports employees as an xlsx binary" do
    binary = described_class.new(employees: company.employees.kept).call

    expect(binary).to be_a(String)
    expect(binary.bytesize).to be > 0
    # XLSX files are ZIP archives
    expect(binary[0, 2]).to eq("PK")
  end
end
