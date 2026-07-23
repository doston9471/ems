# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationJob, type: :job do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { create(:employee, company: company, user: user, email: user.email_address) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "delivers through Notifications::DeliveryService" do
    expect(Notifications::DeliveryService).to receive(:call).with(
      hash_including(
        company: company,
        event_key: "leave.approved",
        employee_id: employee.id,
        channels: %w[email]
      )
    ).and_call_original

    described_class.perform_now(
      event_key: "leave.approved",
      company_id: company.id,
      employee_id: employee.id,
      payload: { "message" => "ok" },
      channels: %w[email]
    )

    expect(NotificationDelivery.where(channel: "email", event_key: "leave.approved")).to exist
  end
end
