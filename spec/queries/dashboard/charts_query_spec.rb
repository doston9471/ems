# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::ChartsQuery do
  let(:company) { create(:company) }
  let(:department) { create(:department, company: company, name: "Engineering") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "builds chart datasets for department, status, attendance, and leave" do
    employee = create(:employee, company: company, department: department, employment_status: :active)
    create(:employee, company: company, department: department, employment_status: :probation)
    create(:attendance_day, company: company, employee: employee, work_date: Date.current, clock_in_at: Time.current)
    leave_type = create(:leave_type, company: company)
    create(:leave_request, company: company, employee: employee, leave_type: leave_type, status: :pending_hr)

    charts = described_class.new(company: company).call

    expect(charts[:headcount_by_department][:labels]).to include("Engineering")
    expect(charts[:headcount_by_department][:values].sum).to eq(2)
    expect(charts[:employment_status][:labels]).to include("Active", "Probation")
    expect(charts[:attendance_trend][:labels].size).to eq(14)
    expect(charts[:attendance_trend][:values].last).to eq(1)
    expect(charts[:leave_pipeline][:labels]).to include("Pending hr")
    expect(charts[:leave_pipeline][:values].sum).to eq(1)
  end
end
