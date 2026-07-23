# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::ChangePasswordService do
  let(:user) { create(:user, password: "Password1!") }

  it "rejects a password that matches the current password" do
    result = described_class.call(
      user: user,
      password: "Password1!",
      password_confirmation: "Password1!"
    )

    expect(result).to be_failure
    expect(result.errors.join).to match(/used recently/i)
  end

  it "rejects a password that matches recent password history" do
    old_digest = BCrypt::Password.create("OldPassword1!", cost: 4)
    user.password_histories.create!(password_digest: old_digest, created_at: 1.day.ago)

    result = described_class.call(
      user: user,
      password: "OldPassword1!",
      password_confirmation: "OldPassword1!"
    )

    expect(result).to be_failure
    expect(result.errors.join).to match(/used recently/i)
  end

  it "updates the password and appends history" do
    previous_digest = user.password_digest

    result = described_class.call(
      user: user,
      password: "BrandNewPass1!",
      password_confirmation: "BrandNewPass1!"
    )

    expect(result).to be_success
    expect(user.reload.authenticate("BrandNewPass1!")).to eq(user)
    expect(user.password_histories.order(created_at: :desc).first.password_digest).to eq(previous_digest)
  end

  it "rejects mismatched confirmation" do
    result = described_class.call(
      user: user,
      password: "BrandNewPass1!",
      password_confirmation: "OtherPass1!"
    )

    expect(result).to be_failure
    expect(result.errors).to include("Passwords did not match")
  end
end
