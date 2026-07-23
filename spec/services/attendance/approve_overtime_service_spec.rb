# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance::ApproveOvertimeService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let(:user) { create(:user) }
  let(:day) do
    create(:attendance_day, company: company, employee: employee, status: :complete,
                            worked_minutes: 600, overtime_minutes: 120, overtime_status: :pending)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "approves pending overtime" do
    result = described_class.call(attendance_day: day, approver: user, decision: :approve)

    expect(result).to be_success
    expect(day.reload.overtime_status).to eq("approved")
  end

  it "rejects pending overtime" do
    result = described_class.call(attendance_day: day, approver: user, decision: :reject)

    expect(result).to be_success
    expect(day.reload.overtime_status).to eq("rejected")
  end

  it "fails when overtime is not pending" do
    day.update!(overtime_status: :approved)
    result = described_class.call(attendance_day: day, approver: user, decision: :approve)

    expect(result).not_to be_success
  end
end
