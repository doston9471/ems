# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, :report) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with reports.read" do
    let(:membership) { membership_with("reports.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.export?).to be(false) }
  end

  context "with reports.export" do
    let(:membership) { membership_with("reports.export") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.export?).to be(true) }
  end
end
