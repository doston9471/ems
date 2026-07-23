# Use Cases — API & Integrations

## Actors

- API Client (JWT), Company Owner/HR (webhook admin), External systems (SCIM/IdP)

## Diagram

```mermaid
flowchart LR
  Client([API Client])
  Owner([Company Owner])
  SCIM([SCIM Consumer])
  Ext([External Webhook Consumer])

  UC1((Obtain JWT))
  UC2((List / show employees))
  UC3((List departments))
  UC4((Clock in/out via API))
  UC5((Create leave via API))
  UC6((GraphQL query / mutate))
  UC7((Manage webhooks))
  UC8((SCIM list/create users))
  UC9((Receive webhook delivery))

  Client --> UC1
  Client --> UC2
  Client --> UC3
  Client --> UC4
  Client --> UC5
  Client --> UC6

  Owner --> UC7
  SCIM --> UC8
  Ext --> UC9

  UC5 -.->|on approve| UC9
  UC8 -.->|hire path| UC9
```

## Actor actions

| Actor | Action | Endpoint / surface |
|-------|--------|--------------------|
| API Client | Login | `POST /api/v1/session` → JWT |
| API Client | CRUD-ish reads | `/api/v1/employees`, `/departments` |
| API Client | Attendance | `POST .../attendance/clock_in\|out` |
| API Client | Leave create | `POST /api/v1/leave_requests` |
| API Client | GraphQL | `POST /graphql` (+ Bearer / session) |
| Owner | Webhooks CRUD | `/api/v1/webhooks` |
| SCIM Consumer | Users | `/api/v1/scim/Users` (stub) |
| External system | Receive events | Signed HTTP POST from `Webhooks::DispatchService` |

## Cross-cutting

- Tenant: `X-Company-Id` when user has multiple memberships  
- Rate limit: Rack::Attack on auth + API  
- Version header: `X-API-Version`
