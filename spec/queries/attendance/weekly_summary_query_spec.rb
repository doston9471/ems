# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance::WeeklySummaryQuery do
  let(:company) { create(:company) }
  let(:week_start) { Date.new(2026, 7, 20) } # Monday
  let(:employee) { create(:employee, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "aggregates attendance metrics for the week" do
    create(:attendance_day, company: company, employee: employee, work_date: week_start,
                            worked_minutes: 480, overtime_minutes: 30, break_minutes: 45)
    create(:attendance_day, company: company, employee: employee, work_date: week_start + 1,
                            worked_minutes: 400, overtime_minutes: 0, break_minutes: 30)

    result = described_class.new(company: company, week_start: week_start).call

    expect(result[:week_start]).to eq(week_start)
    expect(result[:week_end]).to eq(week_start.end_of_week)
    expect(result[:days_count]).to eq(2)
    expect(result[:worked_minutes]).to eq(880)
    expect(result[:overtime_minutes]).to eq(30)
    expect(result[:break_minutes]).to eq(75)
    expect(result[:by_date][week_start]).to eq(1)
  end
end
