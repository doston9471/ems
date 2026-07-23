# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AuditLogsController#index authorization", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "allows access with audit.read" do
    create_membership_with("audit.read", "company.read")
    create(:audit_log, company: company, user: user)
    sign_in(user)

    get audit_logs_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Audit log")
  end

  it "denies access without audit.read" do
    create_membership_with("company.read")
    sign_in(user)

    get audit_logs_path

    expect(response).to redirect_to(root_path)
  end
end
