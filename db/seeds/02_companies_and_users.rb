# frozen_string_literal: true

acme = Company.find_or_initialize_by(slug: "acme")
acme.assign_attributes(
  name: "Acme Corporation",
  timezone: "America/Los_Angeles",
  locale: "en",
  currency: "USD",
  status: "active",
  settings: {
    "work_start" => "09:00",
    "slack_webhook_url" => "",
    "teams_webhook_url" => "",
    "telegram_bot_token" => "",
    "telegram_chat_id" => ""
  }
)
acme.save!

globex = Company.find_or_initialize_by(slug: "globex")
globex.assign_attributes(
  name: "Globex Industries",
  timezone: "Europe/London",
  locale: "en",
  currency: "GBP",
  status: "active",
  settings: { "work_start" => "09:30" }
)
globex.save!

owner = Seeds.ensure_user!(
  email: "owner@acme.example",
  first_name: "Ada",
  last_name: "Owner",
  super_admin: false
)
hr = Seeds.ensure_user!(email: "hr@acme.example", first_name: "Helen", last_name: "Resources")
manager = Seeds.ensure_user!(email: "manager@acme.example", first_name: "Morgan", last_name: "Manager")
lead = Seeds.ensure_user!(email: "lead@acme.example", first_name: "Taylor", last_name: "Lead")
employee_user = Seeds.ensure_user!(email: "employee@acme.example", first_name: "Eddie", last_name: "Employee")
guest = Seeds.ensure_user!(email: "guest@acme.example", first_name: "Gina", last_name: "Guest")
unverified = Seeds.ensure_user!(
  email: "unverified@acme.example",
  first_name: "Una",
  last_name: "Verified",
  email_verified_at: nil
)

Seeds.ensure_membership!(company: acme, user: owner, role_key: "company_owner")
Seeds.ensure_membership!(company: acme, user: hr, role_key: "hr")
Seeds.ensure_membership!(company: acme, user: manager, role_key: "manager")
Seeds.ensure_membership!(company: acme, user: lead, role_key: "team_lead")
Seeds.ensure_membership!(company: acme, user: employee_user, role_key: "employee")
Seeds.ensure_membership!(company: acme, user: guest, role_key: "guest")
Seeds.ensure_membership!(company: acme, user: unverified, role_key: "employee")

globex_owner = Seeds.ensure_user!(
  email: "owner@globex.example",
  first_name: "Greg",
  last_name: "Globex",
  preferred_locale: "es"
)
Seeds.ensure_membership!(company: globex, user: globex_owner, role_key: "company_owner")

# Demo identity extras
OauthIdentity.find_or_create_by!(user: owner, provider: "github") do |identity|
  identity.uid = "seed-github-ada"
  identity.email = owner.email_address
  identity.raw_metadata = { "login" => "ada-owner", "seed" => true }
end

unless PasswordHistory.exists?(user: employee_user)
  PasswordHistory.create!(
    user: employee_user,
    password_digest: employee_user.password_digest,
    created_at: 30.days.ago
  )
end

unless Session.exists?(user: owner, user_agent: "EMS Seed Browser")
  Session.create!(
    user: owner,
    ip_address: "127.0.0.1",
    user_agent: "EMS Seed Browser"
  )
end
Seeds.acme = acme
Seeds.globex = globex
Seeds.users = {
  owner: owner,
  hr: hr,
  manager: manager,
  lead: lead,
  employee: employee_user,
  guest: guest,
  unverified: unverified,
  globex_owner: globex_owner
}
