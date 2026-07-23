# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::AttritionQuery do
  let(:company) { create(:company) }
  let(:year) { 2026 }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "computes active headcount, departures, and attrition rate" do
    create(:employee, company: company, employment_status: "active")
    create(:employee, company: company, employment_status: "probation")
    departed = create(:employee, company: company, employment_status: "terminated")
    departed.update_columns(updated_at: Time.utc(2026, 3, 15))

    result = described_class.new(company: company, year: year).call

    expect(result[:year]).to eq(year)
    expect(result[:active_headcount]).to eq(2)
    expect(result[:departed]).to eq(1)
    expect(result[:attrition_rate_pct]).to eq(33.3)
  end
end
