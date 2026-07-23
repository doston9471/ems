# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recruitment::HireApplicantService do
  let(:company) { create(:company) }
  let(:department) { create(:department, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates an employee and marks the applicant hired" do
    applicant = create(:applicant, company: company, department: department, stage: :offer)

    result = described_class.call(applicant: applicant, attributes: { salary_cents: 90_000_00 })

    expect(result).to be_success
    employee = result.value
    expect(employee.first_name).to eq(applicant.first_name)
    expect(employee.email).to eq(applicant.email)
    expect(employee.department).to eq(department)
    expect(employee.salary_cents).to eq(90_000_00)
    expect(applicant.reload).to be_hired
    expect(applicant.hired_employee).to eq(employee)
  end
end
