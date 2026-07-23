# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::ConfirmEmailVerificationService do
  it "confirms a valid signed token" do
    user = create(:user, email_verified_at: nil)
    token = user.signed_id(purpose: :email_verification, expires_in: 2.days)

    result = described_class.call(token: token)

    expect(result).to be_success
    expect(user.reload.email_verified_at).to be_present
  end

  it "rejects an invalid token" do
    result = described_class.call(token: "not-a-valid-token")

    expect(result).to be_failure
    expect(result.errors).to include("Verification link is invalid or has expired")
  end

  it "is idempotent when already verified" do
    user = create(:user, email_verified_at: 1.day.ago)
    verified_at = user.email_verified_at
    token = user.signed_id(purpose: :email_verification, expires_in: 2.days)

    result = described_class.call(token: token)

    expect(result).to be_success
    expect(user.reload.email_verified_at).to be_within(1.second).of(verified_at)
  end
end
