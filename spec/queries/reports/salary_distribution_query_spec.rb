# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::SalaryDistributionQuery do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "buckets salaries and reports average and median" do
    create(:employee, company: company, salary_cents: 40_000_00)
    create(:employee, company: company, salary_cents: 75_000_00)
    create(:employee, company: company, salary_cents: 160_000_00)

    result = described_class.new(company: company).call

    expect(result[:distribution]).to eq(
      "< $50k" => 1,
      "$50k–$100k" => 1,
      "$100k–$150k" => 0,
      "$150k+" => 1
    )
    expect(result[:average_cents]).to eq((40_000_00 + 75_000_00 + 160_000_00) / 3)
    expect(result[:median_cents]).to eq(75_000_00)
  end
end
