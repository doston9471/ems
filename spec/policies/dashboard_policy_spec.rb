# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, :dashboard) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with company.read" do
    let(:membership) { membership_with("company.read") }

    it { expect(policy.show?).to be(true) }
  end

  context "with employees.read" do
    let(:membership) { membership_with("employees.read") }

    it { expect(policy.show?).to be(true) }
  end

  context "without relevant permissions" do
    let(:membership) { membership_with("leave.read") }

    it { expect(policy.show?).to be(false) }
  end
end
