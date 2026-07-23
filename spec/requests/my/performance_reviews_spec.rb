# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My::PerformanceReviews", type: :request do
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
    create_membership_with("company.read", "performance.review")
    sign_in(user)
  end

  it "lists my performance reviews" do
    get my_performance_reviews_path
    expect(response).to have_http_status(:ok)
  end
end
