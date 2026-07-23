# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payroll::GenerateRunService do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates a completed run with items from active employees" do
    active = create(:employee, company: company, salary_cents: 100_000, employment_status: :active)
    create(:employee, company: company, salary_cents: 50_000, employment_status: :terminated)

    result = described_class.call(
      company: company,
      period_start: Date.new(2026, 7, 1),
      period_end: Date.new(2026, 7, 31)
    )

    expect(result).to be_success
    run = result.value
    expect(run).to be_completed
    expect(run.payroll_items.count).to eq(1)
    item = run.payroll_items.first
    expect(item.employee).to eq(active)
    expect(item.salary_cents).to eq(100_000)
    expect(item.tax_cents).to eq(20_000)
    expect(item.insurance_cents).to eq(5_000)
    expect(item.net_cents).to eq(75_000)
  end
end
