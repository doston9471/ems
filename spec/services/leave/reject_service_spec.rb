# frozen_string_literal: true

require "rails_helper"

RSpec.describe Leave::RejectService do
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

  it "rejects a pending manager request with a reason" do
    result = described_class.call(
      leave_request: leave_request,
      approver: manager_user,
      reason: "Insufficient coverage"
    )

    expect(result).to be_success
    expect(result.value.status).to eq("rejected")
    expect(result.value.rejection_reason).to eq("Insufficient coverage")
    expect(result.value.leave_approvals.last.decision).to eq("rejected")
    expect(result.value.leave_approvals.last.step).to eq("manager")
  end

  it "fails when the request is not awaiting approval" do
    leave_request.update!(status: "approved")

    result = described_class.call(leave_request: leave_request, approver: manager_user)

    expect(result).to be_failure
    expect(result.errors).to include("Leave request is not awaiting approval")
  end
end
