# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolePermission, type: :model do
  it "links a role to a permission" do
    role = create(:role)
    permission = create(:permission)
    link = described_class.create!(role: role, permission: permission)
    expect(role.permissions).to include(permission)
    expect(link.permission).to eq(permission)
  end

  it "enforces unique permission per role" do
    role = create(:role)
    permission = create(:permission)
    described_class.create!(role: role, permission: permission)
    duplicate = described_class.new(role: role, permission: permission)
    expect(duplicate).not_to be_valid
  end
end
