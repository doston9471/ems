# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL Mutation.submitLeaveRequest", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:membership) do
    role = create(:role, :with_permissions, permission_keys: %w[leave.request company.read])
    create(:membership, company: company, user: user, role: role)
  end
  let!(:employee) { create(:employee, company: company, user: user, email: user.email_address) }
  let!(:leave_type) { create(:leave_type, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "submits a leave request for the linked employee" do
    start_on = (Date.current + 5).iso8601
    end_on = (Date.current + 7).iso8601

    graphql_post(<<~GRAPHQL, headers: bearer_headers_for(user, company: company))
      mutation {
        submitLeaveRequest(input: {
          leaveTypeId: "#{leave_type.id}"
          startOn: "#{start_on}"
          endOn: "#{end_on}"
          reason: "Family trip"
        }) {
          leaveRequest { id status days reason }
          errors
        }
      }
    GRAPHQL

    expect(response).to have_http_status(:ok)
    body = graphql_json
    expect(body["errors"]).to be_blank
    payload = body.dig("data", "submitLeaveRequest")
    expect(payload["errors"]).to eq([])
    expect(payload.dig("leaveRequest", "status")).to eq("pending_manager")
    expect(payload.dig("leaveRequest", "days")).to eq(3.0)
    expect(payload.dig("leaveRequest", "reason")).to eq("Family trip")
  end
end
