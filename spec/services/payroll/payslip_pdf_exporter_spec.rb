# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payroll::PayslipPdfExporter do
  let(:company) { create(:company, name: "Acme") }
  let(:employee) { create(:employee, company: company, first_name: "Ada", last_name: "Lovelace") }
  let(:run) { create(:payroll_run, company: company, status: :completed, generated_at: Time.current) }
  let(:item) { create(:payroll_item, payroll_run: run, employee: employee) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "renders a PDF document" do
    pdf = described_class.new(payroll_item: item).call

    expect(pdf).to start_with("%PDF")
    expect(pdf.bytesize).to be > 100
  end
end
