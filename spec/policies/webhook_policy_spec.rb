# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebhookPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, webhook) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:webhook) { ActsAsTenant.with_tenant(company) { create(:webhook, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with company.update" do
    let(:membership) { membership_with("company.update") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "without permission" do
    let(:membership) { membership_with("company.read") }

    it { expect(policy.index?).to be(false) }
    it { expect(policy.create?).to be(false) }
  end
end
