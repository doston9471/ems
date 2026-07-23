# frozen_string_literal: true

# Canonical permission catalog. Seeds and policies should use these keys.
module Permissions
  CATALOG = [
    [ "company.read", "View company", "company" ],
    [ "company.update", "Update company", "company" ],
    [ "members.read", "View members", "members" ],
    [ "members.manage", "Manage members", "members" ],
    [ "roles.read", "View roles", "roles" ],
    [ "roles.manage", "Manage roles", "roles" ],
    [ "employees.read", "View employees", "employees" ],
    [ "employees.create", "Create employees", "employees" ],
    [ "employees.update", "Update employees", "employees" ],
    [ "employees.delete", "Delete employees", "employees" ],
    [ "departments.read", "View departments", "departments" ],
    [ "departments.manage", "Manage departments", "departments" ],
    [ "teams.read", "View teams", "teams" ],
    [ "teams.manage", "Manage teams", "teams" ],
    [ "offices.read", "View offices", "offices" ],
    [ "offices.manage", "Manage offices", "offices" ],
    [ "attendance.read", "View attendance", "attendance" ],
    [ "attendance.manage", "Manage attendance", "attendance" ],
    [ "attendance.clock", "Clock in/out", "attendance" ],
    [ "leave.read", "View leave", "leave" ],
    [ "leave.request", "Request leave", "leave" ],
    [ "leave.approve", "Approve leave", "leave" ],
    [ "leave.manage", "Manage leave types/balances", "leave" ],
    [ "audit.read", "View audit logs", "audit" ],
    [ "payroll.read", "View payroll runs", "payroll" ],
    [ "payroll.manage", "Generate and manage payroll", "payroll" ],
    [ "payroll.payslip", "View own payslips", "payroll" ],
    [ "recruitment.read", "View applicants and interviews", "recruitment" ],
    [ "recruitment.manage", "Manage applicants and hiring", "recruitment" ],
    [ "performance.read", "View performance reviews", "performance" ],
    [ "performance.manage", "Manage performance cycles and goals", "performance" ],
    [ "performance.review", "Submit performance reviews", "performance" ],
    [ "notifications.read", "View notifications", "notifications" ],
    [ "notifications.manage", "Manage notifications", "notifications" ],
    [ "reports.read", "View reports", "reports" ],
    [ "reports.export", "Export reports", "reports" ],
    [ "feature_flags.manage", "Manage feature flags", "feature_flags" ],
    [ "calendars.read", "View calendar connections and sync status", "calendars" ],
    [ "calendars.manage", "Manage calendar connections", "calendars" ],
    [ "assets.read", "View company assets", "assets" ],
    [ "assets.manage", "Manage company assets", "assets" ],
    [ "documents.read", "View employee documents", "documents" ],
    [ "documents.manage", "Manage employee documents", "documents" ]
  ].freeze

  KEYS = CATALOG.map(&:first).freeze
end
