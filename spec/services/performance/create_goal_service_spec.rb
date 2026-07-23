# frozen_string_literal: true

require "rails_helper"

RSpec.describe Performance::CreateGoalService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates an open goal with default progress" do
    result = described_class.call(
      company: company,
      attributes: { employee: employee, title: "Ship MFA" }
    )

    expect(result).to be_success
    expect(result.value.title).to eq("Ship MFA")
    expect(result.value.status).to eq("open")
    expect(result.value.progress_percent).to eq(0)
  end

  it "fails when title is blank" do
    result = described_class.call(
      company: company,
      attributes: { employee: employee, title: "" }
    )

    expect(result).to be_failure
    expect(result.errors.join).to match(/title/i)
  end
end
