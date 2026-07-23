# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::HeadcountQuery do
  let(:company) { create(:company) }
  let(:engineering) { create(:department, company: company, name: "Engineering") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "counts employees by status and department" do
    create(:employee, company: company, department: engineering, employment_status: "active")
    create(:employee, company: company, department: nil, employment_status: "on_leave")

    result = described_class.new(company: company).call

    expect(result[:total]).to eq(2)
    expect(result[:by_status]).to include("active" => 1, "on_leave" => 1)
    expect(result[:by_department]).to include("Engineering" => 1, "Unassigned" => 1)
  end
end
