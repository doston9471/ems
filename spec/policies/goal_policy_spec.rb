# frozen_string_literal: true

require "rails_helper"

RSpec.describe GoalPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, goal) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:goal) { ActsAsTenant.with_tenant(company) { create(:goal, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with performance.read" do
    let(:membership) { membership_with("performance.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
  end

  context "with performance.manage" do
    let(:membership) { membership_with("performance.manage") }

    it { expect(policy.create?).to be(true) }
  end
end
