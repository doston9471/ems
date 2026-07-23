# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to validate_uniqueness_of(:email_address).ignoring_case_sensitivity }

  it "has secure password" do
    expect(user).to respond_to(:authenticate)
    expect(user.authenticate("Password1!")).to eq(user)
    expect(user.authenticate("wrong")).to be_falsey
  end

  it "rejects short passwords when password is set" do
    user.password = "short"
    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end
end
