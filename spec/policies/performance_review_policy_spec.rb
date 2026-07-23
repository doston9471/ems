# frozen_string_literal: true

require "rails_helper"

RSpec.describe PerformanceReviewPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, review) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:review) { ActsAsTenant.with_tenant(company) { create(:performance_review, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with performance.read" do
    let(:membership) { membership_with("performance.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.submit?).to be(false) }
  end

  context "with performance.review" do
    let(:membership) { membership_with("performance.review") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.submit?).to be(true) }
  end

  context "as assigned reviewer" do
    let(:membership) { membership_with("company.read") }
    let(:reviewer) { ActsAsTenant.with_tenant(company) { create(:employee, company: company, user: user) } }
    let(:review) do
      ActsAsTenant.with_tenant(company) do
        create(:performance_review, company: company, reviewer: reviewer, status: "pending")
      end
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.submit?).to be(true) }
  end
end
