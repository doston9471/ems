# frozen_string_literal: true

require "rails_helper"

RSpec.describe Assets::AssignService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let(:company_asset) { create(:company_asset, company: company, status: "purchased") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "assigns an available asset to an employee" do
    result = described_class.call(company_asset: company_asset, employee: employee)

    expect(result).to be_success
    expect(result.value.employee).to eq(employee)
    expect(result.value.returned_on).to be_nil
    expect(company_asset.reload).to be_assigned
  end

  it "rejects assignment when asset is already assigned" do
    create(:asset_assignment, company_asset: company_asset, employee: employee, assigned_on: Date.current)
    company_asset.update!(status: "assigned")

    other = create(:employee, company: company)
    result = described_class.call(company_asset: company_asset, employee: other)

    expect(result).to be_failure
    expect(result.errors.join).to match(/active assignment|current status/i)
  end

  it "rejects cross-company assignment" do
    other_company = create(:company)
    other_employee = ActsAsTenant.with_tenant(other_company) { create(:employee, company: other_company) }

    result = described_class.call(company_asset: company_asset, employee: other_employee)

    expect(result).to be_failure
    expect(result.errors.join).to match(/same company/i)
  end
end
