# frozen_string_literal: true

require "rails_helper"

RSpec.describe DepartmentPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, department) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:department) { ActsAsTenant.with_tenant(company) { create(:department, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with departments.read" do
    let(:membership) { membership_with("departments.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
  end

  context "with departments.manage" do
    let(:membership) { membership_with("departments.manage") }

    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end
end
