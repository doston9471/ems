# frozen_string_literal: true

require "rails_helper"

RSpec.describe Documents::UploadVersionService do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let(:employee) { create(:employee, company: company) }
  let(:employee_document) { create(:employee_document, company: company, employee: employee) }

  def uploaded_pdf(name)
    tempfile = Tempfile.new([ name, ".pdf" ])
    tempfile.write("%PDF-1.4 sample content")
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile.path, "application/pdf", original_filename: "#{name}.pdf")
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates the first version with an attached file" do
    result = described_class.call(
      employee_document: employee_document,
      uploaded_by_user: user,
      file: uploaded_pdf("contract"),
      change_note: "Initial upload"
    )

    expect(result).to be_success
    expect(result.value.version_number).to eq(1)
    expect(result.value.file).to be_attached
    expect(result.value.change_note).to eq("Initial upload")
  end

  it "increments version numbers" do
    described_class.call(
      employee_document: employee_document,
      uploaded_by_user: user,
      file: uploaded_pdf("contract-v1")
    )

    result = described_class.call(
      employee_document: employee_document,
      uploaded_by_user: user,
      file: uploaded_pdf("contract-v2"),
      change_note: "Revision"
    )

    expect(result).to be_success
    expect(result.value.version_number).to eq(2)
    expect(employee_document.document_versions.count).to eq(2)
  end

  it "requires a file" do
    result = described_class.call(
      employee_document: employee_document,
      uploaded_by_user: user,
      file: nil
    )

    expect(result).to be_failure
    expect(result.errors.join).to match(/file/i)
  end
end
