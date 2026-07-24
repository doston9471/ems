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
    body = CGI.unescapeHTML(response.body)
    expect(body).to include(I18n.t("my.dashboard.title"))
    expect(body).to include(I18n.t("my.dashboard.todays_actions"))
    expect(body).to include(I18n.t("my.dashboard.action_inbox"))
    expect(body).to include(I18n.t("my.dashboard.leave_balances"))
    expect(body).to include(I18n.t("my.dashboard.week_attendance"))
    expect(body).to include(I18n.t("my.dashboard.profile"))
  end
end
