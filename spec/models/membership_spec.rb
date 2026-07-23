# frozen_string_literal: true

require "rails_helper"

RSpec.describe Membership, type: :model do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  it "enforces unique user per company" do
    role = create(:role)
    create(:membership, company: company, user: user, role: role)
    duplicate = build(:membership, company: company, user: user, role: role)
    expect(duplicate).not_to be_valid
  end

  it "checks permissions via allows?" do
    role = create(:role, :with_permissions, permission_keys: [ "employees.read" ])
    membership = create(:membership, company: company, user: user, role: role)
    expect(membership.allows?("employees.read")).to be(true)
    expect(membership.allows?("employees.delete")).to be(false)
  end
end
