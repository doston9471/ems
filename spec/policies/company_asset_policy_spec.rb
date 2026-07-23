# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompanyAssetPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, asset) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:asset) { ActsAsTenant.with_tenant(company) { create(:company_asset, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with assets.read" do
    let(:membership) { membership_with("assets.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
  end

  context "with assets.manage" do
    let(:membership) { membership_with("assets.manage") }

    it { expect(policy.create?).to be(true) }
    it { expect(policy.assign?).to be(true) }
    it { expect(policy.return_asset?).to be(true) }
  end
end
