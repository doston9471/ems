# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My::Objectives", type: :request do
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

  it "shows goals, OKRs, and KPIs" do
    get my_objectives_path
    expect(response).to have_http_status(:ok)
  end
end
