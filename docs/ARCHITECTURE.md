# Employee Management System — System Architecture

## Product Positioning

EMS is a multi-tenant HR SaaS platform. Each **Company** is an isolated tenant. All domain records are scoped by `company_id`. Authorization is RBAC with configurable permissions; authentication supports session + JWT for APIs.

## Architectural Style

| Concern | Choice | Rationale |
|--------|--------|-----------|
| Domain organization | DDD-inspired bounded contexts | Keeps HR domains (people, time, leave, payroll) separable without premature microservices |
| Application layer | Service Objects + Form Objects + Query Objects | Controllers stay thin; models stay persistence-focused |
| Authorization | Policy objects (Pundit-style) | Permissions are explicit, testable, and role-configurable |
| Async work | Solid Queue (Active Job) | Rails 8 Solid Trifecta — one Postgres stack, no Redis required for MVP |
| Realtime | Solid Cable (Action Cable) | Same DB-backed approach; Redis optional later for scale |
| Cache | Solid Cache | DB-backed; Redis optional for high-throughput caches |
| API surface | REST + GraphQL | REST for integrations/webhooks; GraphQL for rich clients |
| Multi-tenancy | Shared DB + `company_id` row isolation | Simpler ops than schema-per-tenant; enforce via `Current` + default scopes + policies |
| Events | Domain events + Active Job listeners | Decouples side effects (audit, notifications, payroll triggers) |

### Tradeoff: Solid Trifecta vs Sidekiq/Redis

**Decision:** Prefer Solid Queue / Solid Cache / Solid Cable.

- **Pros:** Fewer moving parts in Docker Compose; transactional job enqueue with business writes; lower ops cost for portfolio/SaaS MVP.
- **Cons:** Very high job throughput and multi-region fan-out favor Redis + Sidekiq later.
- **Escape hatch:** Active Job adapter can switch to Sidekiq without rewriting job classes.

### Tradeoff: Shared DB tenancy vs schema-per-tenant

**Decision:** Shared schema with mandatory `company_id`.

- **Pros:** Simple migrations, cheaper hosting, easier analytics across tenants (for Super Admin).
- **Cons:** Requires disciplined scoping; a missed scope is a data-leak risk.
- **Mitigations:** `acts_as_tenant`-style `Current.company`, DB constraints, policy specs, request specs that assert cross-tenant denial.

## High-Level Component Diagram

```text
                    ┌──────────────────────────────────────────┐
                    │              Clients                     │
                    │  Hotwire UI  │  REST clients  │  GraphQL │
                    └──────┬───────┴───────┬────────┴────┬─────┘
                           │               │             │
                    ┌──────▼───────────────▼─────────────▼─────┐
                    │           Rails Application              │
                    │  Controllers / Channels / GraphQL        │
                    │  Form Objects → Services → Domain Models │
                    │  Policies (RBAC)  │  Query Objects       │
                    └──────┬───────────────────┬───────────────┘
                           │                   │
              ┌────────────▼──────┐   ┌────────▼─────────────┐
              │   PostgreSQL      │   │  Solid Queue workers │
              │  (primary + cable │   │  payroll, mail,      │
              │   + queue + cache)│   │  imports, reports    │
              └───────────────────┘   └──────────────────────┘
```

## Bounded Contexts

1. **Identity & Access** — Users, sessions, OAuth, MFA, JWT, password reset/verification
2. **Tenancy & Org** — Companies, offices, departments, teams, org hierarchy
3. **People** — Employees, profiles, emergency contacts, documents, assets
4. **Time** — Attendance, breaks, overtime, late detection
5. **Leave** — Leave types, balances, multi-step approval workflow
6. **Compensation** — Salary components, payroll runs, PDF export
7. **Talent** — Recruitment pipeline, applicant → employee conversion
8. **Performance** — Goals, OKRs, KPIs, review cycles (self/manager/360)
9. **Reporting & Analytics** — Aggregations, exports, dashboards
10. **Integrations & Notifications** — Slack, Teams, Telegram, SMS, email, calendar, webhooks
11. **Platform** — Audit log, feature flags, search, custom fields, i18n

## Request Lifecycle

1. Middleware / rate limit / CSRF (web) or JWT (API)
2. Authenticate → set `Current.user`
3. Resolve tenant → set `Current.company` (from membership or subdomain/header)
4. Authorize via Policy
5. Form Object validates input (writes) or Query Object builds relation (reads)
6. Service Object executes use-case, emits domain events
7. Persist + enqueue jobs; respond via Turbo Stream / JSON / GraphQL

## Security Baseline

- Tenant isolation on every query path
- RBAC with configurable permission matrix
- Encrypted credentials / Active Record encryption for PII where appropriate
- CSRF for cookie sessions; JWT for APIs (short-lived access + refresh strategy)
- Rate limiting & brute-force lockout on auth endpoints
- Password history; session revocation
- Full audit trail (who, what, old/new, IP, user agent, time)

## Scalability Path

1. **MVP:** Single Rails process + Solid Queue on Postgres
2. **Growth:** Split web / job / cable processes; read replicas; object storage for documents
3. **Scale:** Redis for cache/cable if needed; Sidekiq for heavy queues; optional tenant sharding later

## Delivery Order

Architecture → Domain model → Schema → Rails structure → Auth → RBAC → Employees → Departments → Attendance → Leave → Payroll → Recruitment → Reviews → Assets → Documents → Reporting → API → Frontend polish → Tests → CI/CD → Docker/K8s/Terraform → Docs
