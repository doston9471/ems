# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationDeliveryPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, delivery) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:delivery) { ActsAsTenant.with_tenant(company) { create(:notification_delivery, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with notifications.read" do
    let(:membership) { membership_with("notifications.read") }

    it { expect(policy.index?).to be(true) }
  end

  context "with notifications.manage" do
    let(:membership) { membership_with("notifications.manage") }

    it { expect(policy.index?).to be(true) }
  end

  context "without permission" do
    let(:membership) { membership_with("company.read") }

    it { expect(policy.index?).to be(false) }
  end
end
