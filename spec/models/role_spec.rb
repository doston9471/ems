# frozen_string_literal: true

require "rails_helper"

RSpec.describe Role, type: :model do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:name) }

  it "scopes key uniqueness per company" do
    company = create(:company)
    create(:role, company: company, key: "manager")
    duplicate = build(:role, company: company, key: "manager")
    expect(duplicate).not_to be_valid
  end
end
