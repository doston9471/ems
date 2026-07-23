# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssetAssignment, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:assigned_on) }

  it "rejects returned_on before assigned_on" do
    assignment = build(:asset_assignment, assigned_on: Date.current, returned_on: Date.yesterday)
    expect(assignment).not_to be_valid
    expect(assignment.errors[:returned_on]).to be_present
  end

  it "scopes active assignments" do
    active = create(:asset_assignment)
    create(:asset_assignment, returned_on: Date.current)
    expect(described_class.active).to contain_exactly(active)
  end
end
