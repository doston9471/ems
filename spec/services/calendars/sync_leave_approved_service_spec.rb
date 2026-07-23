# frozen_string_literal: true

require "rails_helper"

RSpec.describe Calendars::SyncLeaveApprovedService do
  let(:company) { create(:company, settings: { "google_calendar_stub" => true, "outlook_calendar_stub" => true }) }
  let(:employee) { create(:employee, company: company) }
  let(:leave_request) { create(:leave_request, company: company, employee: employee, status: "approved") }

  around { |example| ActsAsTenant.with_tenant(company) { example.run } }

  before do
    create(:calendar_connection, company: company, provider: "google", enabled: true)
    create(:calendar_connection, :outlook, company: company, enabled: true)
  end

  it "creates CalendarEvent records for enabled google and outlook connections" do
    result = nil

    expect {
      result = described_class.call(company_id: company.id, leave_request_id: leave_request.id)
    }.to change(CalendarEvent, :count).by(2)

    expect(result).to be_success
    events = CalendarEvent.where(company_id: company.id, eventable: leave_request)
    expect(events.map(&:provider)).to match_array(%w[google outlook])
    expect(events.map(&:status).uniq).to eq(%w[synced])
  end

  it "returns success with no events when no connections are enabled" do
    CalendarConnection.update_all(enabled: false)

    expect {
      result = described_class.call(company_id: company.id, leave_request_id: leave_request.id)
      expect(result).to be_success
      expect(result.value).to eq([])
    }.not_to change(CalendarEvent, :count)
  end
end
