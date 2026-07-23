# Contributing

## Branching

- Branch from `main` with a short descriptive name (`feature/...`, `fix/...`, `chore/...`).
- Keep PRs focused; prefer small reviewable changes over large mixed diffs.

## Pull requests

- Describe **why** the change exists and how to verify it.
- Link related issues when applicable.
- Ensure CI is green (or explain failures) before merge.

## Tests

Mirror `app/` namespaces in `spec/` — one class/feature per file:

```text
app/services/leave/approve_service.rb
  → spec/services/leave/approve_service_spec.rb

app/queries/search/global_search_query.rb
  → spec/queries/search/global_search_query_spec.rb

app/jobs/notification_job.rb
  → spec/jobs/notification_job_spec.rb

app/listeners/leave_approved_listener.rb
  → spec/listeners/leave_approved_listener_spec.rb

app/policies/employee_policy.rb
  → spec/policies/employee_policy_spec.rb

app/controllers/employees_controller.rb (index auth)
  → spec/requests/employees/index_authorization_spec.rb

app/graphql query field `employees`
  → spec/requests/graphql/queries/employees_spec.rb
```

Rules:

- Do **not** put unrelated features in one general file (`graphql_spec.rb`, `employees_spec.rb`, etc.).
- Prefer `RSpec.describe ActualConstant` (or a precise request description) over vague `"API stuff"` names.
- Request/API/GraphQL changes need focused request specs.
- Service objects need service specs when logic is non-trivial.
- Do not leave pending model stubs for core models.

```bash
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
bundle exec rspec
bin/rails zeitwerk:check
```

## Style & security

- Follow RuboCop (omakase).
- Avoid committing secrets (`.env`, `secret.yaml`, credentials).
- Prefer existing patterns: `ApplicationService`, Pundit policies, tenant scoping via `Current` / `acts_as_tenant`.

## Local setup

See [DEVELOPMENT.md](./DEVELOPMENT.md) for database and seed notes.
