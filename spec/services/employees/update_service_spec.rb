# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::UpdateService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company, job_title: "Engineer") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "updates employee attributes" do
    result = described_class.call(employee: employee, attributes: { job_title: "Senior Engineer" })

    expect(result).to be_success
    expect(result.value.job_title).to eq("Senior Engineer")
  end

  it "fails when email is blank" do
    result = described_class.call(employee: employee, attributes: { email: "" })

    expect(result).to be_failure
    expect(result.errors.join).to match(/email/i)
  end
end
