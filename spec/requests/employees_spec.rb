# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EmployeesController", type: :request do
  let(:company) { create(:company, currency: "USD") }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "updates salary from major units on edit" do
    create_membership_with("employees.read", "employees.update", "company.read")
    employee = create(:employee, company: company, salary_cents: 80_000_00, currency: "USD")
    sign_in(user)

    patch employee_path(employee), params: {
      employee: { salary: "125000.50", currency: "USD" }
    }

    expect(response).to redirect_to(employee_path(employee))
    expect(employee.reload.salary_cents).to eq(12_500_050)
    expect(employee.salary).to eq(BigDecimal("125000.50"))
  end

  it "shows salary on the employee page" do
    create_membership_with("employees.read", "company.read")
    employee = create(:employee, company: company, salary_cents: 95_000_00, currency: "USD")
    sign_in(user)

    get employee_path(employee)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Salary")
    expect(response.body).to include("95,000.00")
  end
end
