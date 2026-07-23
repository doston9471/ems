# frozen_string_literal: true

require "rails_helper"

RSpec.describe JwtService do
  it "encodes and decodes a user payload" do
    token = described_class.encode({ user_id: 42 })
    payload = described_class.decode(token)

    expect(payload[:user_id]).to eq(42)
  end

  it "returns nil for an invalid token" do
    expect(described_class.decode("not-a-token")).to be_nil
  end
end
