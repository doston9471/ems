# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::Adapters::TelegramAdapter do
  let(:company) { create(:company, settings: {}) }
  let(:delivery) do
    ActsAsTenant.with_tenant(company) do
      create(
        :notification_delivery,
        company: company,
        channel: "telegram",
        event_key: "leave.approved",
        payload: { "message" => "Approved" },
        status: "pending"
      )
    end
  end

  it "skips when bot token is missing" do
    result = described_class.new.deliver(delivery)

    expect(result[:success]).to be(false)
    expect(result[:skipped]).to be(true)
    expect(result[:error]).to match(/bot token/i)
  end

  it "skips when chat_id is missing" do
    company.update!(settings: { "telegram_bot_token" => "123:ABC" })

    result = described_class.new.deliver(delivery)

    expect(result[:success]).to be(false)
    expect(result[:skipped]).to be(true)
    expect(result[:error]).to match(/chat_id/i)
  end
end
