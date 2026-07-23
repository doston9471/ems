# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeaveApprovedListener do
  include ActiveJob::TestHelper

  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let(:event) do
    Leave::ApprovedEvent.new(
      "leave_request_id" => 1,
      "company_id" => company.id,
      "employee_id" => employee.id
    )
  end

  before do
    allow(Webhooks::DispatchService).to receive(:call).and_return(
      ApplicationService::Result.new(success: true, value: [], errors: [])
    )
  end

  it "enqueues NotificationJob for leave approvals" do
    expect {
      described_class.call(event)
    }.to have_enqueued_job(NotificationJob).with(
      hash_including(
        event_key: event.event_key,
        company_id: company.id,
        employee_id: employee.id
      )
    )
  end

  it "dispatches webhooks for the leave approval event" do
    described_class.call(event)

    expect(Webhooks::DispatchService).to have_received(:call).with(
      hash_including(company_id: company.id, event_key: event.event_key)
    )
  end

  it "enqueues CalendarSyncJob for leave approvals" do
    expect {
      described_class.call(event)
    }.to have_enqueued_job(CalendarSyncJob).with(
      hash_including(
        event_key: event.event_key,
        company_id: company.id,
        leave_request_id: event.leave_request_id
      )
    )
  end
end
