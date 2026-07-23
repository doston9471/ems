# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:slug) }

  it "enforces unique slug" do
    create(:company, slug: "acme-test")
    duplicate = build(:company, slug: "acme-test")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:slug]).to be_present
  end
end
