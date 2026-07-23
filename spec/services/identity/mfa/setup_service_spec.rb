# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Mfa::SetupService do
  let(:user) { create(:user, mfa_enabled: false, mfa_secret: nil) }

  it "generates a secret and provisioning URI" do
    result = described_class.call(user: user)

    expect(result).to be_success
    expect(result.value[:secret]).to be_present
    expect(result.value[:provisioning_uri]).to include(CGI.escape(user.email_address))
    expect(result.value[:qr_svg]).to include("<svg")
    expect(user.reload.mfa_secret).to eq(result.value[:secret])
  end

  it "rejects when MFA is already enabled" do
    user.update!(mfa_enabled: true, mfa_secret: ROTP::Base32.random)

    result = described_class.call(user: user)

    expect(result).to be_failure
    expect(result.errors).to include("MFA is already enabled")
  end
end
