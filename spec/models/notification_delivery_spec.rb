# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationDelivery, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:event_key) }
  it { is_expected.to validate_presence_of(:status) }

  it "accepts known channels and statuses" do
    delivery = create(:notification_delivery, company: company, channel: "email", status: "pending")
    expect(delivery.channel).to eq("email")
    expect(delivery.status).to eq("pending")
  end
end
