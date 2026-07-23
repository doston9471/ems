# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance::DailySummaryQuery do
  let(:company) { create(:company) }
  let(:date) { Date.new(2026, 7, 22) }
  let(:employee) { create(:employee, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "summarizes attendance days for a given date" do
    open_day = create(:attendance_day, company: company, employee: employee, work_date: date, status: "open",
                                       clock_in_at: Time.utc(2026, 7, 22, 10, 0, 0))
    open_day.attendance_events.create!(
      company: company,
      employee: employee,
      kind: "clock_in",
      occurred_at: Time.utc(2026, 7, 22, 10, 0, 0),
      metadata: { "late" => true }
    )

    other = create(:employee, company: company)
    create(:attendance_day, company: company, employee: other, work_date: date, status: "complete",
                            clock_in_at: Time.utc(2026, 7, 22, 9, 0, 0),
                            clock_out_at: Time.utc(2026, 7, 22, 17, 0, 0),
                            worked_minutes: 480)

    result = described_class.new(company: company, date: date).call

    expect(result[:date]).to eq(date)
    expect(result[:total]).to eq(2)
    expect(result[:open]).to eq(1)
    expect(result[:complete]).to eq(1)
    expect(result[:late]).to eq(1)
    expect(result[:days].size).to eq(2)
  end
end
