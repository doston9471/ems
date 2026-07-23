# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CustomFieldDefinitions", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates a custom field definition with company.update" do
    create_membership_with("company.read", "company.update")
    sign_in(user)

    expect {
      post custom_field_definitions_path, params: {
        custom_field_definition: {
          label: "Cost center",
          key: "cost_center",
          field_type: "text",
          resource_type: "Employee",
          required: false,
          position: 1
        },
        options_text: ""
      }
    }.to change(CustomFieldDefinition, :count).by(1)

    expect(response).to redirect_to(custom_field_definitions_path)
  end
end
