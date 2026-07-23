# frozen_string_literal: true

require "rails_helper"

RSpec.describe Assets::ReturnService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let(:company_asset) { create(:company_asset, company: company, status: "assigned") }
  let!(:assignment) do
    create(:asset_assignment, company_asset: company_asset, employee: employee, assigned_on: Date.current - 7)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "returns an assigned asset and closes the active assignment" do
    result = described_class.call(
      company_asset: company_asset,
      returned_on: Date.current,
      condition_on_return: "good",
      notes: "Back to inventory"
    )

    expect(result).to be_success
    expect(result.value.returned_on).to eq(Date.current)
    expect(result.value.condition_on_return).to eq("good")
    expect(company_asset.reload).to be_returned
  end

  it "fails when there is no active assignment" do
    assignment.update!(returned_on: Date.current - 1)
    company_asset.update!(status: "returned")

    result = described_class.call(company_asset: company_asset)

    expect(result).to be_failure
    expect(result.errors.join).to match(/no active assignment/i)
  end
end
