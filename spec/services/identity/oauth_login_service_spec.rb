# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::OauthLoginService do
  def auth_hash(provider: "google_oauth2", uid: "uid-1", email: "oauth@example.com", name: "OAuth User")
    {
      "provider" => provider,
      "uid" => uid,
      "info" => {
        "email" => email,
        "name" => name,
        "first_name" => "OAuth",
        "last_name" => "User"
      }
    }
  end

  it "creates a user and oauth identity for a new email" do
    result = described_class.call(auth: auth_hash)

    expect(result).to be_success
    user = result.value
    expect(user.email_address).to eq("oauth@example.com")
    expect(user.email_verified_at).to be_present
    expect(user.oauth_identities.find_by(provider: "google_oauth2", uid: "uid-1")).to be_present
  end

  it "links oauth identity to an existing user by email and marks verified" do
    user = create(:user, email_address: "oauth@example.com", email_verified_at: nil)

    result = described_class.call(auth: auth_hash)

    expect(result).to be_success
    expect(result.value).to eq(user)
    expect(user.reload.email_verified_at).to be_present
    expect(user.oauth_identities.count).to eq(1)
  end

  it "reuses an existing oauth identity" do
    user = create(:user, email_address: "oauth@example.com")
    create(:oauth_identity, user: user, provider: "google_oauth2", uid: "uid-1")

    expect {
      result = described_class.call(auth: auth_hash)
      expect(result).to be_success
      expect(result.value).to eq(user)
    }.not_to change(OauthIdentity, :count)
  end

  it "fails when email is missing" do
    result = described_class.call(auth: auth_hash(email: ""))

    expect(result).to be_failure
    expect(result.errors).to include("OAuth provider did not return an email address")
  end
end
