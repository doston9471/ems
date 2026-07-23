# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance::ClockInService do
  let(:company) { create(:company, settings: { "work_start_time" => "09:00" }, timezone: "UTC") }
  let(:employee) { create(:employee, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "clocks in and marks late when after work start" do
    occurred_at = Time.utc(2026, 7, 22, 10, 30, 0)

    result = described_class.call(employee: employee, occurred_at: occurred_at)

    expect(result).to be_success
    expect(result.value.clock_in_at).to eq(occurred_at)
    expect(result.value.status).to eq("open")
    event = result.value.attendance_events.find_by(kind: "clock_in")
    expect(event.metadata["late"]).to eq(true)
  end

  it "marks previous open day as missing_clock_out" do
    yesterday = create(
      :attendance_day,
      company: company,
      employee: employee,
      work_date: Date.new(2026, 7, 21),
      clock_in_at: Time.utc(2026, 7, 21, 9, 0, 0),
      status: "open"
    )

    result = described_class.call(
      employee: employee,
      occurred_at: Time.utc(2026, 7, 22, 8, 30, 0)
    )

    expect(result).to be_success
    expect(yesterday.reload.status).to eq("missing_clock_out")
  end
end
