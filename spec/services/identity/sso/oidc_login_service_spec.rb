# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Sso::OidcLoginService do
  let(:company) { create(:company, slug: "acme-sso") }
  let(:config) do
    create(
      :sso_configuration,
      company: company,
      provider: "oidc",
      enabled: true,
      metadata: {
        "issuer" => "https://idp.example.com",
        "client_id" => "ems-client",
        "client_secret" => "secret",
        "authorization_endpoint" => "https://idp.example.com/oauth/authorize"
      }
    )
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  def encode_jwt(payload)
    header = Base64.urlsafe_encode64({ alg: "none", typ: "JWT" }.to_json, padding: false)
    body = Base64.urlsafe_encode64(payload.to_json, padding: false)
    "#{header}.#{body}."
  end

  describe "authorize URL" do
    it "builds an authorize URL from metadata" do
      result = described_class.call(
        sso_configuration: config,
        redirect_uri: "http://localhost:3000/sso/oidc/callback",
        state: "abc123"
      )

      expect(result).to be_success
      uri = URI.parse(result.value[:url])
      expect(uri.host).to eq("idp.example.com")
      expect(uri.path).to eq("/oauth/authorize")
      params = Rack::Utils.parse_query(uri.query)
      expect(params["client_id"]).to eq("ems-client")
      expect(params["redirect_uri"]).to eq("http://localhost:3000/sso/oidc/callback")
      expect(params["response_type"]).to eq("code")
      expect(params["state"]).to eq("abc123")
      expect(params["scope"]).to include("openid")
      expect(params["nonce"]).to be_present
    end

    it "fails when client_secret is blank" do
      config.update!(metadata: config.metadata.merge("client_secret" => ""))

      result = described_class.call(
        sso_configuration: config,
        redirect_uri: "http://localhost:3000/sso/oidc/callback"
      )

      expect(result).to be_failure
      expect(result.errors.join).to include("client_secret")
    end
  end

  describe "callback" do
    it "finds an existing user by email from id_token claims" do
      user = create(:user, email_address: "sso.user@example.com")
      token = encode_jwt("sub" => "oidc-1", "email" => "sso.user@example.com")

      result = described_class.call(sso_configuration: config, id_token: token)

      expect(result).to be_success
      expect(result.value).to eq(user)
    end

    it "creates a user when email is new" do
      token = encode_jwt(
        "sub" => "oidc-new",
        "email" => "new.sso@example.com",
        "given_name" => "New",
        "family_name" => "Person"
      )

      expect {
        result = described_class.call(sso_configuration: config, id_token: token)
        expect(result).to be_success
        expect(result.value.email_address).to eq("new.sso@example.com")
        expect(result.value.first_name).to eq("New")
      }.to change(User, :count).by(1)
    end
  end
end
