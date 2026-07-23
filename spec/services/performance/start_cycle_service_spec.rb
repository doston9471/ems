# frozen_string_literal: true

require "rails_helper"

RSpec.describe Performance::StartCycleService do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates and opens a review cycle" do
    result = described_class.call(
      company: company,
      attributes: {
        name: "Q3 2026",
        period_start: Date.new(2026, 7, 1),
        period_end: Date.new(2026, 9, 30),
        kind: "quarterly"
      }
    )

    expect(result).to be_success
    expect(result.value.name).to eq("Q3 2026")
    expect(result.value.status).to eq("open")
  end

  it "fails when the period is invalid" do
    result = described_class.call(
      company: company,
      attributes: {
        name: "Broken",
        period_start: Date.new(2026, 9, 30),
        period_end: Date.new(2026, 7, 1),
        kind: "quarterly"
      }
    )

    expect(result).to be_failure
    expect(result.errors.join).to match(/period end/i)
  end
end
