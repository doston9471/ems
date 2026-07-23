# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My::Payslips", type: :request do
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
    create_membership_with("company.read", "payroll.payslip")
    sign_in(user)
  end

  it "lists and downloads my payslip PDF" do
    run = create(:payroll_run, company: company, status: :completed, generated_at: Time.current)
    item = create(:payroll_item, payroll_run: run, employee: employee)

    get my_payslips_path
    expect(response).to have_http_status(:ok)

    get my_payslip_path(item, format: :pdf)
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/pdf")
    expect(response.body).to start_with("%PDF")
  end
end
