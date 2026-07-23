# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My::Dashboard", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:employee) { create(:employee, company: company, user: user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  before do
    create_membership_with(
      "company.read", "attendance.clock", "attendance.read",
      "leave.read", "leave.request", "performance.review", "payroll.payslip"
    )
    sign_in(user)
  end

  it "shows the workspace overview" do
    get my_dashboard_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("My workspace")
    expect(response.body).to include("Today's actions")
    expect(response.body).to include("Action inbox")
    expect(response.body).to include("Leave balances")
    expect(response.body).to include("Week attendance")
    expect(response.body).to include("Profile")
  end
end
