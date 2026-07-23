# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeatureFlagPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, feature_flag) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:feature_flag) { create(:feature_flag, company: company) }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with feature_flags.manage" do
    let(:membership) { membership_with("feature_flags.manage") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.update?).to be(true) }
  end

  context "without permission" do
    let(:membership) { membership_with("company.read") }

    it { expect(policy.index?).to be(false) }
    it { expect(policy.update?).to be(false) }
  end
end
