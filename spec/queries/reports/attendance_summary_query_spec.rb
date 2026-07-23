# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::AttendanceSummaryQuery do
  let(:company) { create(:company) }
  let(:from) { Date.new(2026, 7, 1) }
  let(:to) { Date.new(2026, 7, 31) }
  let(:employee) { create(:employee, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "summarizes attendance days in the date range" do
    create(:attendance_day, company: company, employee: employee, work_date: Date.new(2026, 7, 10),
                            status: "open")
    create(:attendance_day, company: company, employee: employee, work_date: Date.new(2026, 7, 11),
                            status: "complete")
    create(:attendance_day, company: company, employee: create(:employee, company: company),
                            work_date: Date.new(2026, 6, 30), status: "complete")

    result = described_class.new(company: company, from: from, to: to).call

    expect(result[:from]).to eq(from)
    expect(result[:to]).to eq(to)
    expect(result[:total_days]).to eq(2)
    expect(result[:unique_employees]).to eq(1)
    expect(result[:by_status]).to include("open" => 1, "complete" => 1)
  end
end
