# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance::ClockOutService do
  let(:company) { create(:company, settings: { "standard_day_minutes" => 480 }) }
  let(:employee) { create(:employee, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "sets overtime minutes and pending status when above the standard day" do
    day = create(:attendance_day, company: company, employee: employee, status: :open,
                                  work_date: Date.current, clock_in_at: Time.zone.parse("09:00"), break_minutes: 0)

    result = described_class.call(employee: employee, occurred_at: Time.zone.parse("19:00"))

    expect(result).to be_success
    expect(result.value.worked_minutes).to eq(600)
    expect(result.value.overtime_minutes).to eq(120)
    expect(result.value.overtime_status).to eq("pending")
  end
end
