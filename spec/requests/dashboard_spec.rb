# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "renders chart canvases on the dashboard" do
    role = create(:role, :with_permissions, permission_keys: %w[company.read employees.read])
    create(:membership, company: company, user: user, role: role)
    create(:employee, company: company)
    sign_in(user)

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Headcount by department")
    expect(response.body).to include("Attendance (14 days)")
    expect(response.body).to include("data-controller=\"dashboard-charts\"")
    expect(response.body).to include("chart")
  end
end
