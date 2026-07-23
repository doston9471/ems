# Roadmap

Incremental delivery status for the production-grade EMS portfolio.

## Completed (foundation)

- [x] System architecture & domain model docs
- [x] Multi-tenant schema (`company_id` isolation + ActsAsTenant)
- [x] Rails 8 structure (services, forms folders, queries, policies)
- [x] Session authentication (Rails 8 generators) + JWT API sessions
- [x] RBAC with configurable permission keys (Pundit)
- [x] Employees CRUD + search query
- [x] Departments CRUD + tree query
- [x] Attendance clock in/out/breaks, late + missing clock-out
- [x] Leave submit → manager → HR approval workflow
- [x] Dashboard widgets
- [x] REST API v1 + GraphQL foundation
- [x] Payroll run generation service (foundation)
- [x] Recruitment hire-applicant service (foundation)
- [x] Docker Compose, Nginx config, K8s manifests, Terraform stubs
- [x] GitHub Actions CI (RuboCop, Brakeman, bundler-audit, RSpec)
- [x] Rack::Attack throttling on auth endpoints
- [x] Audit log model + Auditable concern

## Completed (identity hardening)

- [x] Google / GitHub OAuth + email verification UI + MFA (TOTP)
- [x] Password history enforcement on change

## Completed (performance, assets, documents)

- [x] Performance reviews / OKRs / 360
- [x] Assets & document versioning (Active Storage)

## Completed (platform)

- [x] Notifications (email/Slack/Teams/SMS/Telegram adapters)
- [x] Reporting exports (CSV/Excel/PDF) + charts
- [x] Global search (pg_trgm)
- [x] SSO / SCIM / webhooks / public API versioning polish (SSO model + SCIM/webhook stubs)
- [x] Live SAML/OIDC SSO login path (`Identity::Sso::*`, `/sso/:provider/*`, `ruby-saml` + OIDC token/JWKS)
- [x] Payroll & recruitment Hotwire UI + audit log browser
- [x] Calendar sync (Google/Outlook OAuth + live API; stub for placeholder tokens)
- [x] SCIM Users CRUD-ish (list/create/show/update/deactivate)
- [x] Notification credentials UI + Twilio SMS adapter
- [x] Feature flags, i18n (en/es/ru/uz/ky), dark mode, org chart UI
- [x] Raised automated coverage (policy matrix, identity, services, reports/search) — run `make coverage` for SimpleCov; full 95% line coverage remains an ongoing target
- [x] UML use-case, sequence, state, C4, and RBAC docs (`docs/uml/`)
- [x] Close review cycles (submitted → completed; force-close pending; freeze assign)
- [x] Offices & teams CRUD UI
- [x] Employee self-service (`/my`: attendance, leave, reviews, payslips)
- [x] Payslip PDF export per payroll item (employee + HR)
- [x] Enriched My workspace (inbox, balances, profile, objectives, docs, assets, team, contacts, notify prefs)
- [x] OpenAPI + API auth sequence docs (`/api-docs`, `docs/openapi.yaml`)
- [x] Solid Cable notification badge (Action Cable `NotificationsChannel`)
- [x] Kamal `config/deploy.yml` + K8s migrate job / HPA
- [x] Timesheets / overtime approval UI
- [x] Custom fields (definitions + employee values)
- [x] Multi-company switcher (session `company_id`)

## Known stubs / follow-ons

- Richer SCIM Groups / ServiceProviderConfig (Users list/create/show/update/deactivate are implemented)
- SMS without Twilio credentials logs in non-production; production requires Twilio ENV or company settings
- System specs and broader policy matrix to push toward 95% line coverage
- Register real Google/Azure/OIDC/SAML IdP apps and fill secrets in `.env` / company SSO metadata (`idp_cert` for ruby-saml)

## Design stance

Ship vertical slices that stay production-shaped (tenant-safe, authorized, tested, documented) rather than half-wired surface area across every module.
