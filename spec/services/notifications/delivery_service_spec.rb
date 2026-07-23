# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::DeliveryService do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { create(:employee, company: company, user: user, email: user.email_address) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "delivers email channel and records delivery" do
    result = described_class.call(
      company: company,
      event_key: "leave.approved_event",
      payload: { "message" => "approved" },
      employee_id: employee.id,
      channels: %w[email]
    )

    expect(result).to be_success
    delivery = result.value.first
    expect(delivery.channel).to eq("email")
    expect(delivery.status).to eq("sent")
    expect(delivery.event_key).to eq("leave.approved_event")
  end

  it "skips channels disabled in user preferences" do
    user.update!(notification_preferences: { "email" => false, "in_app" => true })

    result = described_class.call(
      company: company,
      event_key: "leave.approved_event",
      payload: { "message" => "approved" },
      employee_id: employee.id,
      channels: %w[email in_app]
    )

    expect(result).to be_success
    expect(result.value.map(&:channel)).to eq(%w[in_app])
  end
end
