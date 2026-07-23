# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::GlobalSearchQuery do
  let(:company) { create(:company) }
  let!(:department) { create(:department, company: company, name: "Platform Engineering") }
  let!(:employee) do
    create(:employee, company: company, department: department, first_name: "Zara", last_name: "Ahmed",
                      email: "zara.ahmed@example.com", job_title: "Staff Engineer")
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "finds employees by name and departments by name" do
    result = described_class.new(company: company, query: "Zara").call
    expect(result.employees).to include(employee)

    dept_result = described_class.new(company: company, query: "Platform").call
    expect(dept_result.departments).to include(department)
  end

  it "returns empty relations for blank query" do
    result = described_class.new(company: company, query: "  ").call
    expect(result.employees).to be_empty
    expect(result.departments).to be_empty
  end
end
