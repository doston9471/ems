# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Timesheets", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { create(:employee, company: company) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "lists pending overtime and approves a timesheet day" do
    create_membership_with("company.read", "attendance.read", "attendance.manage")
    day = create(:attendance_day, company: company, employee: employee, status: :complete,
                                  worked_minutes: 600, overtime_minutes: 120, overtime_status: :pending)
    sign_in(user)

    get timesheets_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(employee.full_name)

    post approve_timesheet_path(day)
    expect(response).to redirect_to(timesheets_path)
    expect(day.reload.overtime_status).to eq("approved")
  end
end
