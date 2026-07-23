# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::SendEmailVerificationService do
  include ActiveJob::TestHelper

  it "enqueues a verification email for an unverified user" do
    user = create(:user, email_verified_at: nil)

    expect {
      result = described_class.call(user: user)
      expect(result).to be_success
    }.to have_enqueued_mail(EmailVerificationsMailer, :verify)
  end

  it "rejects when email is already verified" do
    user = create(:user, email_verified_at: Time.current)

    result = described_class.call(user: user)

    expect(result).to be_failure
    expect(result.errors).to include("Email is already verified")
  end
end
