# Rails Project Structure

```text
app/
  controllers/
    concerns/           # Authentication, tenancy, authorization helpers
    api/
      v1/               # Versioned REST API
    web/                # Hotwire HTML controllers (optional namespace)
  models/
    concerns/           # Tenantable, Auditable, Discardable
  services/             # Use-case / command objects (one public method: call)
    identity/
    employees/
    attendance/
    leave/
    payroll/
  forms/                # ActiveModel form objects for multi-model writes
  queries/              # Read-side query objects returning relations/DTOs
  policies/             # Authorization policies
  repositories/         # Thin wrappers only where AR is insufficient
  events/               # Domain event POROs
  listeners/            # Subscribe to events → jobs/notifications
  graphql/              # Schema, types, mutations, resolvers
  serializers/          # REST JSON serializers
  jobs/                 # ActiveJob (Solid Queue)
  channels/             # ActionCable
  views/
  javascript/
  assets/

config/
lib/
db/
  migrate/
  seeds/
docs/
infra/
  docker/
  kubernetes/
  terraform/
  nginx/
spec/
  models/
  requests/
    api/v1/
    employees/
    graphql/queries/
  services/             # mirrors app/services/**
  queries/              # mirrors app/queries/**
  policies/
  jobs/
  listeners/
  factories/
  support/
```

## Layering Rules

| Layer | May call | Must not |
|-------|----------|----------|
| Controllers | Forms, Services, Queries, Policies | Fat business logic, raw SQL sprawl |
| Forms | Validations, assign attributes | Persist side effects beyond building attrs |
| Services | Models, Repositories, Jobs, Events | Render views, know about HTTP |
| Models | Associations, simple validations, scopes | Cross-aggregate workflows |
| Policies | Current context + record | Persist data |
| Queries | AR relations | Mutations |

## Autoload Paths

Rails 8 zeitwerk autoloads `app/*`. Custom folders (`services`, `forms`, `queries`, `policies`, `events`, `listeners`, `serializers`) live under `app/` and map to matching constants (`Employees::CreateService`, `EmployeePolicy`, etc.).
