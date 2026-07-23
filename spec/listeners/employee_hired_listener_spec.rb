# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeHiredListener do
  include ActiveJob::TestHelper

  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let(:event) do
    Employees::HiredEvent.new(
      "company_id" => company.id,
      "employee_id" => employee.id,
      "applicant_id" => 1
    )
  end

  before do
    allow(Webhooks::DispatchService).to receive(:call).and_return(
      ApplicationService::Result.new(success: true, value: [], errors: [])
    )
  end

  it "enqueues NotificationJob for hired employees" do
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

  it "dispatches webhooks for the hired event" do
    described_class.call(event)

    expect(Webhooks::DispatchService).to have_received(:call).with(
      hash_including(company_id: company.id, event_key: event.event_key)
    )
  end
end
