# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CompanySwitcher", type: :request do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(target_company, *permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: target_company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "switches the session company for multi-tenant users" do
    create_membership_with(company, "company.read", "employees.read")
    create_membership_with(other_company, "company.read", "employees.read")
    sign_in(user)

    post company_switcher_path, params: { company_id: other_company.id }

    expect(response).to redirect_to(root_path)
    expect(session[:company_id]).to eq(other_company.id)
  end
end
