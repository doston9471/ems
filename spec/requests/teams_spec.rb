# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teams", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "lists and creates teams with teams.manage" do
    department = create(:department, company: company)
    employee = create(:employee, company: company, department: department)
    create_membership_with("teams.read", "teams.manage", "company.read")
    sign_in(user)

    get teams_path
    expect(response).to have_http_status(:ok)

    expect {
      post teams_path, params: {
        team: {
          name: "Platform",
          department_id: department.id,
          lead_employee_id: employee.id,
          employee_ids: [ employee.id ]
        }
      }
    }.to change(Team, :count).by(1)

    team = Team.last
    expect(response).to redirect_to(team_path(team))
    expect(team.employees).to include(employee)
  end
end
