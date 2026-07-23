# frozen_string_literal: true

require "rails_helper"

RSpec.describe OauthIdentity, type: :model do
  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to validate_presence_of(:uid) }

  it "enforces unique uid per provider" do
    identity = create(:oauth_identity, provider: "google_oauth2", uid: "abc")
    duplicate = build(:oauth_identity, provider: "google_oauth2", uid: "abc")
    expect(duplicate).not_to be_valid
  end
end
