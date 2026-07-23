# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::Adapters::InAppAdapter do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { create(:employee, company: company, user: user) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "broadcasts an unread count to the notifications channel" do
    delivery = NotificationDelivery.create!(
      company: company,
      user: user,
      employee: employee,
      channel: "in_app",
      event_key: "leave.approved",
      status: "pending",
      payload: {}
    )

    expect(NotificationsChannel).to receive(:broadcast_to).with(
      user,
      hash_including(event_key: "leave.approved", delivery_id: delivery.id, unread_count: 1)
    )

    result = described_class.new.deliver(delivery)
    expect(result[:success]).to be(true)
  end
end
