# frozen_string_literal: true

company = Seeds.acme
employees = Seeds.employees
uploader = Seeds.users.fetch(:hr)

def attach_seed_pdf!(version, filename)
  return if version.file.attached?

  version.file.attach(
    io: StringIO.new("%PDF-1.4\n1 0 obj<<>>endobj\ntrailer<<>>\n%%EOF\n"),
    filename: filename,
    content_type: "application/pdf"
  )
end

ActsAsTenant.with_tenant(company) do
  docs = [
    [ employees["E005"], "contract", "Eddie Employment Contract", "active" ],
    [ employees["E005"], "nda", "Eddie NDA", "active" ],
    [ employees["E006"], "passport", "Fay Passport Copy", "active" ],
    [ employees["E003"], "insurance", "Morgan Benefits Packet", "archived" ],
    [ employees["E004"], "visa", "Taylor Work Authorization", "active" ]
  ]

  docs.each do |employee, doc_type, title, status|
    document = EmployeeDocument.find_or_initialize_by(company: company, employee: employee, title: title)
    document.assign_attributes(doc_type: doc_type, status: status)
    document.save!

    version = DocumentVersion.find_or_initialize_by(employee_document: document, version_number: 1)
    version.uploaded_by_user = uploader
    version.change_note = "Initial upload (seed)"
    version.save!
    attach_seed_pdf!(version, "#{title.parameterize}.pdf")
    version.save! if version.changed? || version.file.attached?

    next unless title.include?("Contract")

    v2 = DocumentVersion.find_or_initialize_by(employee_document: document, version_number: 2)
    v2.uploaded_by_user = uploader
    v2.change_note = "Amended salary clause"
    v2.save!
    attach_seed_pdf!(v2, "#{title.parameterize}-v2.pdf")
    v2.save! if v2.changed? || v2.file.attached?
  end
end
