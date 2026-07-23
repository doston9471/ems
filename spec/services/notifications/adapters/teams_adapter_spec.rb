# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::Adapters::TeamsAdapter do
  let(:company) { create(:company, settings: {}) }
  let(:delivery) do
    ActsAsTenant.with_tenant(company) do
      create(
        :notification_delivery,
        company: company,
        channel: "teams",
        event_key: "leave.approved",
        payload: { "message" => "Approved" },
        status: "pending"
      )
    end
  end

  it "skips when webhook URL is missing" do
    result = described_class.new.deliver(delivery)

    expect(result[:success]).to be(false)
    expect(result[:skipped]).to be(true)
    expect(result[:error]).to match(/webhook URL/i)
  end

  it "posts JSON when configured" do
    company.update!(settings: { "teams_webhook_url" => "https://outlook.office.com/webhook/test" })
    response = instance_double(Net::HTTPSuccess, is_a?: true)
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    http = instance_double(Net::HTTP)
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_return(response)

    result = described_class.new.deliver(delivery)

    expect(result[:success]).to be(true)
    expect(http).to have_received(:request)
  end
end
