# frozen_string_literal: true

company = Seeds.acme
employees = Seeds.employees

ActsAsTenant.with_tenant(company) do
  assets = [
    [ "MBP-16-001", "MacBook Pro 16", "laptop", "assigned", employees["E005"] ],
    [ "MBP-14-002", "MacBook Pro 14", "laptop", "assigned", employees["E006"] ],
    [ "MON-27-010", "LG 27\" Monitor", "monitor", "assigned", employees["E005"] ],
    [ "KEY-MX-003", "Logitech MX Keys", "keyboard", "purchased", nil ],
    [ "PHN-15-004", "iPhone 15", "phone", "returned", employees["E010"] ],
    [ "CHR-ERG-005", "Ergonomic Chair", "chair", "damaged", nil ],
    [ "BDG-ACME-006", "HQ Badge", "badge", "lost", nil ]
  ]

  assets.each do |serial, name, asset_type, status, assignee|
    asset = CompanyAsset.find_or_initialize_by(company: company, serial_number: serial)
    asset.assign_attributes(
      name: name,
      asset_type: asset_type,
      status: status,
      purchased_on: Date.new(2024, 6, 1),
      notes: "Seeded asset"
    )
    asset.save!

    next if assignee.blank?

    assignment = AssetAssignment.find_or_initialize_by(company_asset: asset, employee: assignee, assigned_on: Date.new(2024, 7, 1))
    if status == "returned"
      assignment.assign_attributes(returned_on: Date.new(2025, 12, 15), condition_on_return: "good", notes: "Collected on exit")
    elsif status == "assigned"
      assignment.assign_attributes(returned_on: nil, notes: "Active assignment")
    end
    assignment.save!
  end
end
