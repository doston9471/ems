# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL Query.departments", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:membership) do
    role = create(:role, :with_permissions, permission_keys: %w[departments.read company.read])
    create(:membership, company: company, user: user, role: role)
  end
  let!(:department) { create(:department, company: company, name: "Engineering") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "returns departments for an authorized JWT user" do
    graphql_post(<<~GRAPHQL, headers: bearer_headers_for(user, company: company))
      { departments { name } }
    GRAPHQL

    expect(response).to have_http_status(:ok)
    body = graphql_json
    expect(body["errors"]).to be_blank
    expect(body.dig("data", "departments").map { |row| row["name"] }).to include("Engineering")
  end
end
