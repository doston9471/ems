# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeDocumentPolicy, type: :policy do
  subject(:policy) { described_class.new(membership, document) }

  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:document) { ActsAsTenant.with_tenant(company) { create(:employee_document, company: company) } }

  def membership_with(*keys)
    role = create(:role, :with_permissions, permission_keys: keys)
    create(:membership, company: company, user: user, role: role)
  end

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  context "with documents.read" do
    let(:membership) { membership_with("documents.read") }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
  end

  context "with documents.manage" do
    let(:membership) { membership_with("documents.manage") }

    it { expect(policy.create?).to be(true) }
    it { expect(policy.upload_version?).to be(true) }
  end
end
