# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance::BreakEndService do
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
      status: "open",
      break_minutes: 0
    )
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "ends an active break and accumulates break minutes" do
    create(
      :attendance_event,
      company: company,
      attendance_day: day,
      employee: employee,
      kind: "break_start",
      occurred_at: Time.utc(2026, 7, 22, 12, 0, 0)
    )
    ended_at = Time.utc(2026, 7, 22, 12, 15, 0)

    result = described_class.call(employee: employee, occurred_at: ended_at)

    expect(result).to be_success
    expect(result.value.break_minutes).to eq(15)
    expect(result.value.attendance_events.where(kind: "break_end").count).to eq(1)
  end

  it "fails when no break is active" do
    result = described_class.call(employee: employee, occurred_at: Time.utc(2026, 7, 22, 12, 15, 0))

    expect(result).to be_failure
    expect(result.errors).to include("No active break")
  end
end
