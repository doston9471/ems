# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "belongs to a company via tenancy" do
    employee = create(:employee, company: company)
    expect(employee.company).to eq(company)
  end

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) }

  it "scopes uniqueness of email per company" do
    create(:employee, company: company, email: "same@example.com")
    duplicate = build(:employee, company: company, email: "same@example.com")
    expect(duplicate).not_to be_valid
  end

  it "converts salary major units to salary_cents" do
    employee = build(:employee, company: company, salary: "120000.25")
    expect(employee.salary_cents).to eq(12_000_025)
    expect(employee.salary).to eq(BigDecimal("120000.25"))
  end
end
