# frozen_string_literal: true

require "rails_helper"

RSpec.describe Goal, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:title) }

  it "validates progress_percent bounds" do
    goal = build(:goal, company: company, progress_percent: 101)
    expect(goal).not_to be_valid
  end
end
