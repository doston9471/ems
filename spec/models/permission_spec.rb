# frozen_string_literal: true

require "rails_helper"

RSpec.describe Permission, type: :model do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:category) }

  it "enforces unique key" do
    create(:permission, key: "reports.read")
    duplicate = build(:permission, key: "reports.read")
    expect(duplicate).not_to be_valid
  end
end
