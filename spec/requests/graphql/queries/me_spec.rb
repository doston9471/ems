# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL Query.me", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:membership) do
    role = create(:role, :with_permissions, permission_keys: %w[company.read])
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "returns the current user for a JWT session" do
    graphql_post(<<~GRAPHQL, headers: bearer_headers_for(user, company: company))
      { me { emailAddress fullName } }
    GRAPHQL

    expect(response).to have_http_status(:ok)
    body = graphql_json
    expect(body["errors"]).to be_blank
    expect(body.dig("data", "me", "emailAddress")).to eq(user.email_address)
  end
end
