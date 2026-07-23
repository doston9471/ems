# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::WidgetsQuery do
  let(:company) { create(:company) }
  let(:today) { Date.new(2026, 7, 22) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "returns dashboard widget counts and collections" do
    employee = create(:employee, company: company, employment_status: "active",
                                 birthday: Date.new(1990, 7, 23),
                                 joining_date: today - 5)
    create(:attendance_day, company: company, employee: employee, work_date: today,
                            clock_in_at: Time.utc(2026, 7, 22, 9, 0, 0))

    leave_type = create(:leave_type, company: company)
    create(:leave_request, company: company, employee: employee, leave_type: leave_type,
                           status: "approved", start_on: today - 1, end_on: today + 1, days: 3)

    result = described_class.new(company: company, today: today).call

    expect(result[:employees_count]).to eq(1)
    expect(result[:present_today]).to eq(1)
    expect(result[:on_leave]).to eq(1)
    expect(result[:birthdays_this_week]).to include(employee)
    expect(result[:recent_hires]).to include(employee)
  end
end
