# frozen_string_literal: true

require "rails_helper"

RSpec.describe AttendanceDayPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, attendance_day) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:attendance_day) { ActsAsTenant.with_tenant(company) { create(:attendance_day, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with attendance.read" do
    let(:membership) { membership_with("attendance.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
  end

  context "with attendance.clock" do
    let(:membership) { membership_with("attendance.clock") }

    it { expect(policy.clock_in?).to be(true) }
    it { expect(policy.update?).to be(false) }
  end

  context "with attendance.manage" do
    let(:membership) { membership_with("attendance.manage") }

    it { expect(policy.update?).to be(true) }
  end
end
