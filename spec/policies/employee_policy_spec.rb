# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeePolicy, type: :policy do
  subject(:policy) { described_class.new(membership, employee) }

  let(:company) { create(:company) }
  let(:other_company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { ActsAsTenant.with_tenant(company) { create(:employee, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  context "with employees.read" do
    let(:membership) { membership_with("employees.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
    it { expect(policy.update?).to be(false) }
  end

  context "with full employee permissions" do
    let(:membership) { membership_with("employees.read", "employees.create", "employees.update", "employees.delete") }

    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "cross-tenant record" do
    let(:membership) { membership_with("employees.read", "employees.update") }
    let(:employee) { ActsAsTenant.with_tenant(other_company) { create(:employee, company: other_company) } }

    it { expect(policy.show?).to be(false) }
    it { expect(policy.update?).to be(false) }
  end

  describe "Scope" do
    it "returns company employees when permitted" do
      membership = membership_with("employees.read")
      owned = employee
      ActsAsTenant.with_tenant(other_company) { create(:employee, company: other_company) }

      resolved = described_class::Scope.new(membership, Employee).resolve
      expect(resolved).to contain_exactly(owned)
    end

    it "returns none without permission" do
      membership = membership_with("company.read")
      expect(described_class::Scope.new(membership, Employee).resolve).to be_empty
    end
  end
end
