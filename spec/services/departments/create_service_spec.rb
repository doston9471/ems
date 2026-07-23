# frozen_string_literal: true

require "rails_helper"

RSpec.describe Departments::CreateService do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates a department for the company" do
    result = described_class.call(
      company: company,
      attributes: { name: "Engineering", code: "ENG", active: true }
    )

    expect(result).to be_success
    expect(result.value.name).to eq("Engineering")
    expect(result.value.code).to eq("ENG")
    expect(result.value.company).to eq(company)
  end

  it "fails when name is blank" do
    result = described_class.call(company: company, attributes: { name: "", code: "X" })

    expect(result).to be_failure
    expect(result.errors.join).to match(/name/i)
  end
end
