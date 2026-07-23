# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance::BreakStartService do
  let(:company) { create(:company, timezone: "UTC") }
  let(:employee) { create(:employee, company: company) }
  let(:work_date) { Date.new(2026, 7, 22) }
  let(:clock_in_at) { Time.utc(2026, 7, 22, 9, 0, 0) }
  let!(:day) do
    create(
      :attendance_day,
      company: company,
      employee: employee,
      work_date: work_date,
      clock_in_at: clock_in_at,
      status: "open"
    )
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "starts a break on an open clocked-in day" do
    occurred_at = Time.utc(2026, 7, 22, 12, 0, 0)

    result = described_class.call(employee: employee, occurred_at: occurred_at)

    expect(result).to be_success
    expect(result.value.kind).to eq("break_start")
    expect(result.value.occurred_at).to eq(occurred_at)
  end

  it "fails when a break is already started" do
    create(
      :attendance_event,
      company: company,
      attendance_day: day,
      employee: employee,
      kind: "break_start",
      occurred_at: Time.utc(2026, 7, 22, 12, 0, 0)
    )

    result = described_class.call(employee: employee, occurred_at: Time.utc(2026, 7, 22, 12, 5, 0))

    expect(result).to be_failure
    expect(result.errors).to include("Break already started")
  end
end
