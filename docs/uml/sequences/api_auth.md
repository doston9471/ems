# API authentication sequence

JWT session creation and a subsequent tenant-scoped REST call.

```mermaid
sequenceDiagram
  autonumber
  actor Client
  participant API as Api::V1
  participant Auth as Jwt/Session
  participant Tenant as Tenancy
  participant Emp as EmployeesController

  Client->>API: POST /api/v1/session {email, password}
  API->>Auth: authenticate user
  alt invalid credentials
    Auth-->>Client: 401
  else ok
    Auth-->>Client: 200 {token, expires_in, user}
  end

  Client->>API: GET /api/v1/employees<br/>Authorization Bearer + X-Company-Id
  API->>Auth: verify JWT / session
  Auth->>Tenant: resolve membership (header → session → first)
  Tenant->>Emp: policy_scope(Employee)
  Emp-->>Client: 200 JSON:API collection
```

## Notes

- OpenAPI contract: [`../openapi.yaml`](../openapi.yaml) (served at `/api-docs`).
- GraphQL uses the same session or JWT path via `GraphqlController`.
- SCIM endpoints authenticate with a company SCIM bearer token, not the user JWT.
