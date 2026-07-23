# Employee Management System (EMS)

Multi-tenant HR SaaS built with **Rails 8.1** and **Ruby 4.0**. Each company is an isolated tenant with RBAC, attendance, leave workflows, and a versioned REST API.

## Stack

- Rails 8.1.3 / Ruby 4.0.6 / PostgreSQL 16
- Hotwire (Turbo/Stimulus) + Tailwind CSS
- Pundit RBAC, `acts_as_tenant`, Solid Queue/Cache/Cable
- JWT + session auth for API v1
- RSpec, FactoryBot, Shoulda Matchers

## Setup

```bash
make setup
make dev
```

Docker Compose is available for Postgres and app services — see `docker-compose.yml`.

Useful commands:

- `make help`
- `make test`
- `make check`
- `make docker-up`

## Seed credentials

Password for all demo users: `Password1!`

| Email | Role |
|-------|------|
| `owner@acme.example` | Company Owner |
| `hr@acme.example` | HR |
| `manager@acme.example` | Manager |
| `lead@acme.example` | Team Lead |
| `employee@acme.example` | Employee |
| `guest@acme.example` | Guest |
| `owner@globex.example` | Owner (second tenant) |

Company slug: `acme` (also seeds `globex`). Re-seed with `make db-seed` or full reset via `make db-reset`.

## OAuth (optional)

Google and GitHub sign-in appear on `/session/new` when the matching env vars are set:

| Variable | Purpose |
|----------|---------|
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | Google OAuth |
| `GITHUB_CLIENT_ID` / `GITHUB_CLIENT_SECRET` | GitHub OAuth |

Register callback URLs as `http://localhost:3000/auth/google_oauth2/callback` and `http://localhost:3000/auth/github/callback`. Leave vars blank for local password-only login. MFA (TOTP) is available under **Security (MFA)** after sign-in.

## Architecture

See docs:

- [Architecture](docs/ARCHITECTURE.md)
- [Domain model](docs/DOMAIN_MODEL.md)
- [UML use cases](docs/uml/README.md) · [Sequences](docs/uml/sequences/leave_approve.md) · [RBAC matrix](docs/uml/rbac_matrix.md) · [ER diagram](docs/ER_DIAGRAM.md)
- [Database schema](docs/DATABASE_SCHEMA.md)
- [Project structure](docs/PROJECT_STRUCTURE.md)
- [REST API](docs/API.md) · [GraphQL](docs/GRAPHQL.md)
- [Development](docs/DEVELOPMENT.md) · [Deployment](docs/DEPLOYMENT.md) · [Contributing](docs/CONTRIBUTING.md)
- [Roadmap](docs/ROADMAP.md)

Application layer conventions:

- Controllers stay thin; writes go through **services**, reads through **query objects**
- Authorization via **Pundit** policies using permission keys (`employees.read`, `leave.approve`, …)
- Tenant resolved from session / `X-Company-Id` into `Current.company` and `Current.membership`
- Background work via **Solid Queue** (Solid Trifecta preferred over Sidekiq/Redis for MVP)

## Main routes

| Area | Path |
|------|------|
| Dashboard | `/` |
| Employees | `/employees` |
| Departments | `/departments` |
| Attendance | `/attendance/days` |
| Leave | `/leave_requests` |
| Performance | `/review_cycles` |
| Assets | `/company_assets` |
| Documents | `/employee_documents` |
| Reports | `/reports` |
| Search | `/search?q=` |
| Org chart | `/org_chart` |
| Notifications | `/notifications` |
| MFA setup | `/mfa` |
| API v1 | `/api/v1/*` |
| API login | `POST /api/v1/session` |
| GraphQL | `POST /graphql` |

API auth: session cookie **or** `Authorization: Bearer <jwt>` from `POST /api/v1/session`. Pass `X-Company-Id` for multi-company users.

## Tests

```bash
make check
```

## Infra

- `docker-compose.yml` — web, worker, Postgres, optional Nginx
- `infra/kubernetes/` — deploy manifests
- `infra/terraform/{aws,gcp,digitalocean}/` — cloud stubs
