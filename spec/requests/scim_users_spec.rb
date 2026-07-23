# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SCIM Users API", type: :request do
  let(:company) { create(:company) }
  let(:raw_token) { "scim-test-token" }
  let!(:scim_token) do
    create(:scim_token, company: company, token_digest: ScimToken.digest(raw_token))
  end

  def scim_headers
    { "Authorization" => "Bearer #{raw_token}" }
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates, shows, updates, and deactivates a user" do
    post "/api/v1/scim/Users",
         params: {
           schemas: [ "urn:ietf:params:scim:schemas:core:2.0:User" ],
           userName: "scim.person@example.com",
           name: { givenName: "Scim", familyName: "Person" },
           emails: [ { value: "scim.person@example.com", primary: true } ]
         },
         headers: scim_headers,
         as: :json

    expect(response).to have_http_status(:created), response.body
    id = response.parsed_body["id"]

    get "/api/v1/scim/Users/#{id}", headers: scim_headers
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["active"]).to be(true)

    patch "/api/v1/scim/Users/#{id}",
          params: {
            schemas: [ "urn:ietf:params:scim:api:messages:2.0:PatchOp" ],
            Operations: [ { op: "Replace", path: "active", value: false } ]
          },
          headers: scim_headers,
          as: :json

    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body["active"]).to be(false)
    employee = Employee.with_discarded.find(id)
    expect(employee).to be_terminated
    expect(employee).to be_discarded
  end

  it "rejects missing bearer token" do
    get "/api/v1/scim/Users"
    expect(response).to have_http_status(:unauthorized)
  end
end
