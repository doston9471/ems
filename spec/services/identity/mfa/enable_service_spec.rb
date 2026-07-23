# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Mfa::EnableService do
  let(:secret) { ROTP::Base32.random }
  let(:user) { create(:user, mfa_secret: secret, mfa_enabled: false) }

  it "enables MFA with a valid setup code" do
    code = ROTP::TOTP.new(secret, issuer: Identity::Mfa::SetupService::ISSUER).now

    result = described_class.call(user: user, code: code)

    expect(result).to be_success
    expect(user.reload.mfa_enabled).to be(true)
  end

  it "rejects an invalid code" do
    result = described_class.call(user: user, code: "000000")

    expect(result).to be_failure
    expect(result.errors).to include("Invalid authentication code")
  end
end
