# frozen_string_literal: true

require "rails_helper"

RSpec.describe AttendanceEvent, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:occurred_at) }

  it "belongs to employee and attendance_day" do
    event = create(:attendance_event, company: company, kind: "clock_in", source: "web")
    expect(event.employee).to eq(event.attendance_day.employee)
    expect(event).to be_clock_in
  end
end
