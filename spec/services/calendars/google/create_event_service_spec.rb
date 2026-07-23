# frozen_string_literal: true

require "rails_helper"

RSpec.describe Calendars::Google::CreateEventService do
  let(:company) { create(:company, settings: { "google_calendar_stub" => true }) }
  let(:employee) { create(:employee, company: company) }
  let(:leave_request) { create(:leave_request, company: company, employee: employee) }

  around { |example| ActsAsTenant.with_tenant(company) { example.run } }

  def build_event(connection_attrs: {})
    create(:calendar_connection, { company: company, provider: "google", enabled: true }.merge(connection_attrs))
    create(
      :calendar_event,
      company: company,
      provider: "google",
      eventable: leave_request,
      status: "pending",
      payload: { "summary" => "Leave" }
    )
  end

  it "fails clearly when access_token and calendar_id are missing" do
    event = build_event(connection_attrs: { access_token: nil, calendar_id: nil })

    result = described_class.call(calendar_event: event)

    expect(result).to be_failure
    expect(result.errors.join).to match(/access_token and calendar_id/i)
    expect(event.reload.status).to eq("failed")
    expect(event.error_message).to match(/access_token and calendar_id/i)
  end

  it "marks synced with a stub external id in stub mode" do
    event = build_event

    result = described_class.call(calendar_event: event)

    expect(result).to be_success
    expect(event.reload.status).to eq("synced")
    expect(event.external_event_id).to start_with("stub-google-")
    expect(event.synced_at).to be_present
  end
end
