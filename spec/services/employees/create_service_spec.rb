# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::CreateService do
  let(:company) { create(:company) }
  let(:department) { create(:department, company: company) }
  let(:office) { create(:office, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates an employee for the company" do
    result = described_class.call(
      company: company,
      attributes: {
        employee_number: "E9001",
        first_name: "Ada",
        last_name: "Lovelace",
        email: "ada@example.com",
        employment_status: "active",
        joining_date: Date.current,
        department: department,
        office: office,
        currency: "USD",
        salary_cents: 100_000_00
      }
    )

    expect(result).to be_success
    expect(result.value.first_name).to eq("Ada")
    expect(result.value.email).to eq("ada@example.com")
    expect(result.value.company).to eq(company)
  end

  it "fails when required fields are missing" do
    result = described_class.call(company: company, attributes: { first_name: "Only" })

    expect(result).to be_failure
    expect(result.errors.join).to match(/can't be blank|blank/i)
  end
end
