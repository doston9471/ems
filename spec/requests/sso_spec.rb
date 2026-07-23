# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SsoController", type: :request do
  let(:company_slug) { "acme-sso-#{SecureRandom.hex(4)}" }
  let(:company) { create(:company, slug: company_slug) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "shows a flash when OIDC secrets are blank on initiate" do
    create(
      :sso_configuration,
      company: company,
      provider: "oidc",
      enabled: true,
      metadata: {
        "issuer" => "https://sso.acme.example",
        "client_id" => "ems-demo",
        "client_secret" => ""
      }
    )

    post sso_initiate_path(provider: "oidc", company_slug: company_slug)

    expect(response).to redirect_to(new_session_path)
    follow_redirect!
    expect(response.body).to include("client_secret")
  end

  it "signs in via OIDC callback with id_token stub" do
    create(
      :sso_configuration,
      company: company,
      provider: "oidc",
      enabled: true,
      metadata: {
        "issuer" => "https://sso.acme.example",
        "client_id" => "ems-demo",
        "client_secret" => "secret"
      }
    )
    user = create(:user, email_address: "oidc.callback.#{SecureRandom.hex(4)}@example.com")
    create(:membership, company: company, user: user)

    payload = Base64.urlsafe_encode64({ email: user.email_address, sub: "1" }.to_json, padding: false)
    id_token = "header.#{payload}."

    get sso_callback_path(provider: "oidc"), params: { id_token: id_token, company_slug: company_slug }

    expect(response).to redirect_to(root_url)
    expect(cookies[:session_id]).to be_present
  end
end
