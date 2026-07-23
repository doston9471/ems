# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReviewCycles assign reviews", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:cycle) { create(:review_cycle, company: company, status: :open) }
  let!(:manager) { create(:employee, company: company) }
  let!(:employee) { create(:employee, company: company, manager: manager) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "assigns reviews with performance.manage" do
    create_membership_with("performance.read", "performance.manage", "company.read")
    sign_in(user)

    expect {
      post assign_reviews_review_cycle_path(cycle), params: {
        assign: {
          include_self: "1",
          include_manager: "1",
          employee_ids: [ employee.id ]
        }
      }
    }.to change(PerformanceReview, :count).by(2)

    expect(response).to redirect_to(review_cycle_path(cycle))
    follow_redirect!
    expect(response.body).to include("Assigned 2 reviews")
  end

  it "denies assign without performance.manage" do
    create_membership_with("performance.read", "company.read")
    sign_in(user)

    post assign_reviews_review_cycle_path(cycle), params: {
      assign: { include_self: "1", employee_ids: [ employee.id ] }
    }

    expect(response).to redirect_to(root_path)
    expect(PerformanceReview.count).to eq(0)
  end

  it "shows the assign form on an open cycle" do
    create_membership_with("performance.read", "performance.manage", "company.read")
    sign_in(user)

    get review_cycle_path(cycle)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Assign reviews")
    expect(response.body).to include(employee.full_name)
  end
end
