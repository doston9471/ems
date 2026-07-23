# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ApplicantsController", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "allows index with recruitment.read" do
    create_membership_with("recruitment.read", "company.read")
    create(:applicant, company: company)
    sign_in(user)

    get applicants_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Recruitment")
  end

  it "denies index without recruitment.read" do
    create_membership_with("company.read")
    sign_in(user)

    get applicants_path

    expect(response).to redirect_to(root_path)
  end

  it "hires an applicant with recruitment.manage" do
    create_membership_with("recruitment.read", "recruitment.manage", "company.read", "employees.read")
    applicant = create(:applicant, company: company, stage: :offer)
    sign_in(user)

    expect {
      post hire_applicant_path(applicant), params: { hire: { salary: "90000", currency: "USD" } }
    }.to change(Employee, :count).by(1)

    hired = Employee.last
    expect(response).to redirect_to(employee_path(hired))
    expect(applicant.reload).to be_hired
    expect(hired.salary_cents).to eq(9_000_000)
  end
end
