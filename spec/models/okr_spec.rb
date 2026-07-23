# frozen_string_literal: true

require "rails_helper"

RSpec.describe Okr, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:objective) }
  it { is_expected.to validate_presence_of(:quarter) }
  it { is_expected.to validate_presence_of(:year) }

  it "rejects quarter outside 1..4" do
    okr = build(:okr, company: company, quarter: 5)
    expect(okr).not_to be_valid
  end
end
