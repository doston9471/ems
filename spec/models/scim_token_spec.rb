# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScimToken, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:token_digest) }

  it "finds by raw token and touches last_used_at" do
    raw = "secret-token"
    token = create(:scim_token, company: company, token_digest: described_class.digest(raw))
    expect(described_class.find_by_raw_token(raw)).to eq(token)
    token.touch_last_used!
    expect(token.reload.last_used_at).to be_present
  end
end
