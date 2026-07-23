# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmergencyContact, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:name) }

  it "belongs to an employee" do
    contact = create(:emergency_contact)
    expect(contact.employee).to be_present
  end
end
