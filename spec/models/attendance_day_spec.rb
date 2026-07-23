# frozen_string_literal: true

require "rails_helper"

RSpec.describe AttendanceDay, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:work_date) }

  it "enforces unique work_date per employee" do
    day = create(:attendance_day, company: company)
    duplicate = build(:attendance_day, company: company, employee: day.employee, work_date: day.work_date)
    expect(duplicate).not_to be_valid
  end

  it "defines status enum" do
    day = create(:attendance_day, company: company, status: "open")
    expect(day).to be_open
  end
end
