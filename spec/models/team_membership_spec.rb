# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeamMembership, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it "enforces unique employee per team" do
    membership = create(:team_membership)
    duplicate = build(:team_membership, team: membership.team, employee: membership.employee)
    expect(duplicate).not_to be_valid
  end

  it "belongs to team and employee" do
    membership = create(:team_membership)
    expect(membership.team).to be_present
    expect(membership.employee).to be_present
  end
end
