# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EmployeesController#index authorization", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "allows access when membership has employees.read" do
    create_membership_with("employees.read", "company.read")
    create(:employee, company: company)
    sign_in(user)

    get employees_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Employees")
  end

  it "denies access without employees.read" do
    create_membership_with("company.read")
    sign_in(user)

    get employees_path

    expect(response).to redirect_to(root_path)
  end
end
