# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReviewCycles close", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:cycle) { create(:review_cycle, company: company, status: :open) }
  let(:employee) { create(:employee, company: company) }
  let(:reviewer) { create(:employee, company: company) }

  def create_membership_with(*permission_keys)
    role = create(:role, :with_permissions, permission_keys: permission_keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "closes an open cycle with performance.manage" do
    create(:performance_review, company: company, review_cycle: cycle, employee: employee, reviewer: reviewer, status: :submitted)
    create_membership_with("performance.read", "performance.manage", "company.read")
    sign_in(user)

    post close_review_cycle_path(cycle)

    expect(response).to redirect_to(review_cycle_path(cycle))
    expect(cycle.reload).to be_closed
  end

  it "denies close without performance.manage" do
    create_membership_with("performance.read", "company.read")
    sign_in(user)

    post close_review_cycle_path(cycle)

    expect(response).to redirect_to(root_path)
    expect(cycle.reload).to be_open
  end
end
