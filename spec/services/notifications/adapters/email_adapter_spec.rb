# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::Adapters::EmailAdapter do
  include ActiveJob::TestHelper

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { create(:employee, company: company, user: user, email: user.email_address) }
  let(:delivery) do
    ActsAsTenant.with_tenant(company) do
      create(
        :notification_delivery,
        company: company,
        employee: employee,
        user: user,
        channel: "email",
        event_key: "leave.approved",
        payload: { "message" => "Approved" },
        status: "pending"
      )
    end
  end

  it "enqueues an email when a recipient is present" do
    expect {
      result = described_class.new.deliver(delivery)
      expect(result[:success]).to be(true)
    }.to have_enqueued_mail(NotificationsMailer, :event_notification)
  end

  it "skips when no recipient email is available" do
    bare = ActsAsTenant.with_tenant(company) do
      create(
        :notification_delivery,
        company: company,
        channel: "email",
        event_key: "leave.approved",
        payload: {},
        status: "pending"
      )
    end

    result = described_class.new.deliver(bare)

    expect(result[:success]).to be(false)
    expect(result[:skipped]).to be(true)
    expect(result[:error]).to match(/email/i)
  end
end
