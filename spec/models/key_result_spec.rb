# frozen_string_literal: true

require "rails_helper"

RSpec.describe KeyResult, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:title) }

  it "belongs to an okr" do
    key_result = create(:key_result, target_value: 10, current_value: 3)
    expect(key_result.okr).to be_a(Okr)
  end
end
