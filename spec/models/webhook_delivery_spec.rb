# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebhookDelivery, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:event_key) }
  it { is_expected.to validate_presence_of(:status) }

  it "belongs to a webhook" do
    delivery = create(:webhook_delivery, status: "pending")
    expect(delivery.webhook).to be_a(Webhook)
  end
end
