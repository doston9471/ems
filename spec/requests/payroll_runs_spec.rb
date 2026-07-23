# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PayrollRunsController", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "allows index with payroll.read" do
    create_membership_with("payroll.read", "company.read")
    create(:payroll_run, company: company)
    sign_in(user)

    get payroll_runs_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Payroll")
  end

  it "denies index without payroll.read" do
    create_membership_with("company.read")
    sign_in(user)

    get payroll_runs_path

    expect(response).to redirect_to(root_path)
  end

  it "generates a run via create with payroll.manage" do
    create_membership_with("payroll.read", "payroll.manage", "company.read")
    create(:employee, company: company, salary_cents: 100_000, employment_status: :active)
    sign_in(user)

    expect {
      post payroll_runs_path, params: {
        payroll_run: {
          period_start: Date.new(2026, 7, 1),
          period_end: Date.new(2026, 7, 31)
        }
      }
    }.to change(PayrollRun, :count).by(1)

    expect(response).to redirect_to(payroll_run_path(PayrollRun.last))
  end
end
