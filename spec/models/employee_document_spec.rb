# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeDocument, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:title) }

  it "returns the latest_version" do
    document = create(:employee_document, company: company)
    create(:document_version, employee_document: document, version_number: 1)
    latest = create(:document_version, employee_document: document, version_number: 2)
    expect(document.latest_version).to eq(latest)
  end
end
