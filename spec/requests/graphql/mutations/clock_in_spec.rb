# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL Mutation.clockIn", type: :request do
  let(:company) { create(:company, settings: { "work_start_time" => "09:00" }, timezone: "UTC") }
  let(:user) { create(:user) }
  let!(:membership) do
    role = create(:role, :with_permissions, permission_keys: %w[attendance.clock company.read])
    create(:membership, company: company, user: user, role: role)
  end
  let!(:employee) { create(:employee, company: company, user: user, email: user.email_address) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "clocks in the linked employee and returns an attendance day" do
    graphql_post(<<~GRAPHQL, headers: bearer_headers_for(user, company: company))
      mutation {
        clockIn(input: {}) {
          attendanceDay { id status workDate }
          errors
        }
      }
    GRAPHQL

    expect(response).to have_http_status(:ok)
    body = graphql_json
    expect(body["errors"]).to be_blank
    payload = body.dig("data", "clockIn")
    expect(payload["errors"]).to eq([])
    expect(payload.dig("attendanceDay", "status")).to eq("open")
    expect(payload.dig("attendanceDay", "workDate")).to eq(Date.current.iso8601)
  end
end
