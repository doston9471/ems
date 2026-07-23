# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL Query.employee", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:membership) do
    role = create(:role, :with_permissions, permission_keys: %w[employees.read company.read])
    create(:membership, company: company, user: user, role: role)
  end
  let!(:employee) { create(:employee, company: company, first_name: "Grace", last_name: "Hopper") }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "returns a single employee by id for an authorized JWT user" do
    graphql_post(<<~GRAPHQL, headers: bearer_headers_for(user, company: company))
      { employee(id: "#{employee.id}") { id fullName email } }
    GRAPHQL

    expect(response).to have_http_status(:ok)
    body = graphql_json
    expect(body["errors"]).to be_blank
    expect(body.dig("data", "employee", "fullName")).to eq("Grace Hopper")
    expect(body.dig("data", "employee", "id")).to eq(employee.id.to_s)
  end

  it "returns null when the employee is not found" do
    graphql_post(<<~GRAPHQL, headers: bearer_headers_for(user, company: company))
      { employee(id: "0") { id } }
    GRAPHQL

    expect(response).to have_http_status(:ok)
    body = graphql_json
    expect(body["errors"]).to be_blank
    expect(body.dig("data", "employee")).to be_nil
  end
end
