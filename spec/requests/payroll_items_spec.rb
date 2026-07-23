# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PayrollItems PDF", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { create(:employee, company: company) }
  let(:run) { create(:payroll_run, company: company, status: :completed, generated_at: Time.current) }
  let!(:item) { create(:payroll_item, payroll_run: run, employee: employee) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "allows HR to download a payslip PDF" do
    create_membership_with("payroll.read", "company.read")
    sign_in(user)

    get payroll_item_path(item, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/pdf")
  end

  it "denies without payroll permissions" do
    create_membership_with("company.read")
    sign_in(user)

    get payroll_item_path(item, format: :pdf)

    expect(response).to have_http_status(:not_found)
  end
end
