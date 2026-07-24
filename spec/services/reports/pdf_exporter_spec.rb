# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::PdfExporter do
  let(:company) { create(:company, name: "Acme Corp") }
  let!(:employee) { create(:employee, company: company, first_name: "Export", last_name: "Me") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "renders a PDF employee report" do
    binary = described_class.new(employees: company.employees.kept, company: company).call

    expect(binary).to be_a(String)
    expect(binary.bytesize).to be > 0
    expect(binary[0, 4]).to eq("%PDF")
  end

  it "renders a PDF for a non-default locale" do
    I18n.with_locale(:es) do
      binary = described_class.new(employees: company.employees.kept, company: company).call
      expect(binary).to be_a(String)
      expect(binary.bytesize).to be > 0
      expect(binary[0, 4]).to eq("%PDF")
    end
  end
end
