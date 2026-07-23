# frozen_string_literal: true

require "rails_helper"

RSpec.describe Applicant, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) }

  it "exposes full_name and stage enum" do
    applicant = create(:applicant, company: company, first_name: "Ada", last_name: "Lovelace", stage: "applied")
    expect(applicant.full_name).to eq("Ada Lovelace")
    expect(applicant).to be_applied
  end
end
