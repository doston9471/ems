# frozen_string_literal: true

require "rails_helper"

RSpec.describe Departments::UpdateService do
  let(:company) { create(:company) }
  let(:department) { create(:department, company: company, name: "Ops", code: "OPS") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "updates department attributes" do
    result = described_class.call(department: department, attributes: { name: "Operations" })

    expect(result).to be_success
    expect(result.value.name).to eq("Operations")
  end

  it "fails when name is blank" do
    result = described_class.call(department: department, attributes: { name: "" })

    expect(result).to be_failure
    expect(result.errors.join).to match(/name/i)
  end
end
