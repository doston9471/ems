# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::SessionsController", type: :request do
  let(:user) { create(:user, email_address: "api@example.com", password: "Password1!") }

  it "returns a JWT for valid credentials" do
    post "/api/v1/session", params: { email_address: user.email_address, password: "Password1!" }, as: :json

    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body["token"]).to be_present
    expect(body["token_type"]).to eq("Bearer")
    expect(body["user"]["email_address"]).to eq("api@example.com")

    payload = JwtService.decode(body["token"])
    expect(payload[:user_id]).to eq(user.id)
  end

  it "rejects invalid credentials" do
    post "/api/v1/session", params: { email_address: user.email_address, password: "wrong" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)["error"]).to be_present
  end
end
