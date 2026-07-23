# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentVersion, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:version_number) }

  it "enforces unique version_number per document" do
    version = create(:document_version)
    duplicate = build(:document_version, employee_document: version.employee_document, version_number: 1)
    expect(duplicate).not_to be_valid
  end
end
