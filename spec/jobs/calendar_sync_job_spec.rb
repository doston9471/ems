# frozen_string_literal: true

require "rails_helper"

RSpec.describe CalendarSyncJob, type: :job do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "delegates leave sync to Calendars::SyncLeaveApprovedService" do
    leave_request = create(:leave_request, company: company, status: "approved")

    expect(Calendars::SyncLeaveApprovedService).to receive(:call).with(
      hash_including(
        company_id: company.id,
        leave_request_id: leave_request.id,
        event_key: "leave.approved_event"
      )
    ).and_return(ApplicationService::Result.new(success: true, value: [], errors: []))

    described_class.perform_now(
      event_key: "leave.approved_event",
      company_id: company.id,
      leave_request_id: leave_request.id
    )
  end

  it "delegates interview sync to Calendars::SyncInterviewService" do
    expect(Calendars::SyncInterviewService).to receive(:call).with(
      hash_including(company_id: company.id, interview_id: 42)
    ).and_return(ApplicationService::Result.new(success: true, value: [], errors: []))

    described_class.perform_now(
      event_key: "interview.scheduled",
      company_id: company.id,
      interview_id: 42
    )
  end
end
