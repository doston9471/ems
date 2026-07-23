# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhook, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:secret) }

  it "matches event keys including wildcard" do
    webhook = create(:webhook, company: company, event_keys: [ "*" ])
    expect(webhook.listens_to?("employee.created")).to be(true)
    specific = create(:webhook, company: company, event_keys: [ "employee.updated" ])
    expect(specific.listens_to?("employee.created")).to be(false)
  end
end
