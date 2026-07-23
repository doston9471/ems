# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::DispatchService do
  let(:company) { create(:company) }
  let!(:webhook) do
    ActsAsTenant.with_tenant(company) do
      create(:webhook, company: company, url: "https://hooks.example.com/ems", event_keys: [ "leave.approved_event" ])
    end
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "records a delivery attempt for matching webhooks" do
    stub_request = instance_double(Net::HTTP)
    allow(Net::HTTP).to receive(:start).and_yield(stub_request)
    response = Net::HTTPOK.new("1.1", "200", "OK")
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    allow(response).to receive(:code).and_return("200")
    allow(stub_request).to receive(:request).and_return(response)

    result = described_class.call(
      company_id: company.id,
      event_key: "leave.approved_event",
      payload: { "leave_request_id" => 1 }
    )

    expect(result).to be_success
    delivery = webhook.webhook_deliveries.last
    expect(delivery.status).to eq("delivered")
    expect(delivery.response_code).to eq(200)
  end
end
