# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Mfa::VerifyService do
  let(:secret) { ROTP::Base32.random }
  let(:user) { create(:user, mfa_secret: secret, mfa_enabled: true) }

  it "accepts a valid TOTP code" do
    code = ROTP::TOTP.new(secret, issuer: Identity::Mfa::SetupService::ISSUER).now

    result = described_class.call(user: user, code: code)

    expect(result).to be_success
  end

  it "rejects an invalid code" do
    result = described_class.call(user: user, code: "000000")

    expect(result).to be_failure
    expect(result.errors).to include("Invalid authentication code")
  end

  it "rejects a blank code" do
    result = described_class.call(user: user, code: "")

    expect(result).to be_failure
  end
end
