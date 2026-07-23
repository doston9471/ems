# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My::EmergencyContacts", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:employee) { create(:employee, company: company, user: user) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  before do
    role = create(:role, :with_permissions, permission_keys: %w[company.read])
    create(:membership, company: company, user: user, role: role)
    sign_in(user)
  end

  it "lists and creates emergency contacts" do
    get my_emergency_contacts_path
    expect(response).to have_http_status(:ok)

    expect {
      post my_emergency_contacts_path, params: {
        emergency_contact: { name: "Pat Lee", relationship: "Spouse", phone: "+123", primary: true }
      }
    }.to change { employee.emergency_contacts.count }.by(1)

    expect(response).to redirect_to(my_emergency_contacts_path)
  end
end
