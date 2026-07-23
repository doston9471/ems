# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::SearchQuery do
  let(:company) { create(:company) }
  let(:department) { create(:department, company: company) }
  let(:office) { create(:office, company: company) }
  let!(:ada) do
    create(:employee, company: company, department: department, office: office,
                      first_name: "Ada", last_name: "Lovelace", email: "ada@example.com",
                      employment_status: "active")
  end
  let!(:grace) do
    create(:employee, company: company, first_name: "Grace", last_name: "Hopper",
                      email: "grace@example.com", employment_status: "on_leave")
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "filters by name, email, department, office, and status" do
    by_name = described_class.new(scope: Employee.where(company: company), filters: { name: "Ada" }).call
    expect(by_name).to contain_exactly(ada)

    by_email = described_class.new(scope: Employee.where(company: company), filters: { email: "grace@" }).call
    expect(by_email).to contain_exactly(grace)

    by_dept = described_class.new(
      scope: Employee.where(company: company),
      filters: { department_id: department.id }
    ).call
    expect(by_dept).to contain_exactly(ada)

    by_office = described_class.new(
      scope: Employee.where(company: company),
      filters: { office_id: office.id }
    ).call
    expect(by_office).to contain_exactly(ada)

    by_status = described_class.new(
      scope: Employee.where(company: company),
      filters: { status: "on_leave" }
    ).call
    expect(by_status).to contain_exactly(grace)
  end
end
