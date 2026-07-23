# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "lists and creates offices with offices.manage" do
    create_membership_with("offices.read", "offices.manage", "company.read")
    sign_in(user)

    get offices_path
    expect(response).to have_http_status(:ok)

    expect {
      post offices_path, params: {
        office: { name: "HQ", city: "Tashkent", country: "UZ", address_line1: "1 Navoi" }
      }
    }.to change(Office, :count).by(1)

    expect(response).to redirect_to(office_path(Office.last))
  end
end
