# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasswordHistory, type: :model do
  it { is_expected.to validate_presence_of(:password_digest) }
  it { is_expected.to validate_presence_of(:created_at) }

  it "belongs to a user" do
    history = create(:password_history)
    expect(history.user).to be_a(User)
  end
end
