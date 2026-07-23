# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::Adapters::SmsAdapter do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company, phone: "+15551234567") }
  let(:delivery) do
    ActsAsTenant.with_tenant(company) do
      create(
        :notification_delivery,
        company: company,
        employee: employee,
        channel: "sms",
        event_key: "leave.approved",
        payload: { "message" => "Approved" },
        status: "pending"
      )
    end
  end

  it "succeeds when a phone number is present" do
    result = described_class.new.deliver(delivery)

    expect(result[:success]).to be(true)
  end

  it "skips when no phone is available" do
    bare = ActsAsTenant.with_tenant(company) do
      create(
        :notification_delivery,
        company: company,
        channel: "sms",
        event_key: "leave.approved",
        payload: {},
        status: "pending"
      )
    end

    result = described_class.new.deliver(bare)

    expect(result[:success]).to be(false)
    expect(result[:skipped]).to be(true)
    expect(result[:error]).to match(/phone/i)
  end
end
