# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewFeedback, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:body) }

  it "belongs to a performance review and author" do
    feedback = create(:review_feedback)
    expect(feedback.performance_review).to be_present
    expect(feedback.author_employee).to be_present
  end
end
