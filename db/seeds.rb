# frozen_string_literal: true

# Modular, idempotent seeds for local / staging demos.
#   bin/rails db:seed
#   make db-seed
#   make db-reset

SEED_PASSWORD = "Password1!"

puts "== EMS seeds =="

Dir[Rails.root.join("db/seeds/**/*.rb")].sort.each do |path|
  puts "→ #{Pathname.new(path).relative_path_from(Rails.root)}"
  load path
end

puts
puts "== Seed summary =="
%w[
  Permission Role Company User Membership Office Department Team TeamMembership
  Employee EmergencyContact AttendanceDay AttendanceEvent
  LeaveType LeaveBalance LeaveRequest LeaveApproval
  PayrollRun PayrollItem Applicant Interview
  ReviewCycle PerformanceReview Goal Okr KeyResult Kpi ReviewFeedback
  CompanyAsset AssetAssignment EmployeeDocument DocumentVersion
  NotificationDelivery SsoConfiguration ScimToken Webhook WebhookDelivery
  CalendarConnection CalendarEvent
  FeatureFlag AuditLog OauthIdentity PasswordHistory Session
].each do |name|
  klass = name.constantize
  puts format("  %-28s %4d", "#{name}:", klass.count)
rescue NameError, ActiveRecord::StatementInvalid
  puts format("  %-28s %s", "#{name}:", "n/a")
end

acme = Company.find_by(slug: "acme")
puts
puts "Login (password for all: #{SEED_PASSWORD})"
puts "  owner@acme.example     — Company Owner"
puts "  hr@acme.example        — HR"
puts "  manager@acme.example   — Manager"
puts "  lead@acme.example      — Team Lead"
puts "  employee@acme.example  — Employee"
puts "Company: #{acme&.name} (#{acme&.slug})" if acme
puts "== Done =="
