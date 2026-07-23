# Development Guide

## Prerequisites

- Ruby 4.0.6 (rbenv)
- Rails 8.1.3
- PostgreSQL 16+
- Node.js (for Tailwind standalone binary via gem)

## Setup

```bash
rbenv local 4.0.6
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Visit http://localhost:3000

Default seed logins (development only), password `Password1!` for all:

- `owner@acme.example` — Company Owner
- `hr@acme.example` — HR
- `manager@acme.example` — Manager
- `lead@acme.example` — Team Lead
- `employee@acme.example` — Employee

Seeds live in `db/seeds/*.rb` (loaded by `db/seeds.rb`) and cover every domain table for local manual testing.

Emails in development open in the browser via **letter_opener** (see `config/environments/development.rb`). Notification emails use `deliver_later`, so run Solid Queue (`bin/jobs` / `make dev`) for them to process.

## Locales

UI strings live in separate files under `config/locales/`:

| File | Language |
|------|----------|
| `en.yml` | English (default) |
| `es.yml` | Spanish |
| `ru.yml` | Russian |
| `uz.yml` | Uzbek (Latin) |
| `ky.yml` | Kyrgyz |

Add new keys to **each** file when you introduce `t("...")` usage. Switch language from the sidebar (`?locale=ru`, etc.) or set `users.preferred_locale` / `companies.locale`.

## Architecture folders

Business logic lives in `app/services`, `app/forms`, `app/queries`, and `app/policies`. Keep controllers and models thin.

## Testing

```bash
bundle exec rspec
COVERAGE=true bundle exec rspec
```

## Docker Compose

```bash
docker compose up --build
```

Services: `web`, `worker`, `db`, `nginx` (Solid Queue uses Postgres — no Redis required for MVP).
