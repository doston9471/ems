# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeaveRequestPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, leave_request) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:leave_request) do
    ActsAsTenant.with_tenant(company) { create(:leave_request, company: company) }
  end

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  context "requester" do
    let(:membership) { membership_with("leave.request", "leave.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.approve?).to be(false) }
  end

  context "approver" do
    let(:membership) { membership_with("leave.read", "leave.approve") }

    it { expect(policy.approve?).to be(true) }
    it { expect(policy.reject?).to be(true) }
  end
end
