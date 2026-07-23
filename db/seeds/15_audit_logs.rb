# frozen_string_literal: true

company = Seeds.acme
users = Seeds.users
employees = Seeds.employees

# A few readable audit rows for the UI / DB inspection.
[
  [ users[:owner], employees["E005"], "update", { "salary_cents" => [ 115_000_00, 120_000_00 ] } ],
  [ users[:hr], employees["E006"], "create", { "employee_number" => [ nil, "E006" ] } ],
  [ users[:manager], LeaveRequest.first, "update", { "status" => %w[pending_manager pending_hr] } ]
].each do |user, record, action, changes|
  next if record.blank?

  AuditLog.find_or_create_by!(
    company: company,
    user: user,
    auditable_type: record.class.name,
    auditable_id: record.id,
    action: action,
    changes_data: changes
  ) do |log|
    log.ip_address = "127.0.0.1"
    log.user_agent = "EMS Seed"
    log.created_at = rand(1..10).days.ago
  end
end
