# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL Query.employees", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:membership) do
    role = create(:role, :with_permissions, permission_keys: %w[employees.read company.read])
    create(:membership, company: company, user: user, role: role)
  end
  let!(:employee) { create(:employee, company: company, first_name: "Ada", last_name: "Lovelace") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "returns employees for an authorized JWT user" do
    graphql_post(<<~GRAPHQL, headers: bearer_headers_for(user, company: company))
      { employees { fullName email } }
    GRAPHQL

    expect(response).to have_http_status(:ok)
    body = graphql_json
    expect(body["errors"]).to be_blank
    expect(body.dig("data", "employees").map { |row| row["fullName"] }).to include("Ada Lovelace")
  end
end
