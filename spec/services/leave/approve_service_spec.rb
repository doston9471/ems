# frozen_string_literal: true

require "rails_helper"

RSpec.describe Leave::ApproveService do
  let(:company) { create(:company) }
  let(:manager_user) { create(:user) }
  let(:manager_employee) { create(:employee, company: company, user: manager_user) }
  let(:employee) { create(:employee, company: company, manager: manager_employee) }
  let(:leave_type) { create(:leave_type, company: company, requires_manager: true, requires_hr: true) }
  let(:leave_request) do
    create(
      :leave_request,
      company: company,
      employee: employee,
      leave_type: leave_type,
      status: "pending_manager",
      manager: manager_employee
    )
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "moves pending_manager to pending_hr when HR is required" do
    result = described_class.call(leave_request: leave_request, approver: manager_user)

    expect(result).to be_success
    expect(result.value.status).to eq("pending_hr")
    expect(result.value.leave_approvals.last.step).to eq("manager")
  end

  it "approves when HR confirms" do
    leave_request.update!(status: "pending_hr")
    hr_user = create(:user)
    create(:employee, company: company, user: hr_user)

    result = described_class.call(leave_request: leave_request, approver: hr_user)

    expect(result).to be_success
    expect(result.value.status).to eq("approved")
  end
end
