# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Mfa::DisableService do
  let(:secret) { ROTP::Base32.random }
  let(:user) { create(:user, mfa_secret: secret, mfa_enabled: true) }

  it "disables MFA with a valid code" do
    code = ROTP::TOTP.new(secret, issuer: Identity::Mfa::SetupService::ISSUER).now

    result = described_class.call(user: user, code: code)

    expect(result).to be_success
    expect(user.reload.mfa_enabled).to be(false)
    expect(user.mfa_secret).to be_nil
  end

  it "rejects when MFA is not enabled" do
    user.update!(mfa_enabled: false)

    result = described_class.call(user: user, code: "123456")

    expect(result).to be_failure
    expect(result.errors).to include("MFA is not enabled")
  end
end
