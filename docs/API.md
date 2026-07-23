# REST API

Base path: `/api/v1`

Authentication uses either:

1. **JWT** — `Authorization: Bearer <token>` from `POST /api/v1/session`
2. **Session cookie** — signed `session_id` from HTML `POST /session`

Optional tenancy header: `X-Company-Id: <company_id>`

## Auth

### Create session (JWT)

```bash
curl -s -X POST http://localhost:3000/api/v1/session \
  -H "Content-Type: application/json" \
  -d '{"email_address":"admin@example.com","password":"Password1!"}'
```

Example response:

```json
{
  "token": "<jwt>",
  "token_type": "Bearer",
  "expires_in": 86400,
  "user": {
    "id": 1,
    "email_address": "admin@example.com",
    "full_name": "Admin User"
  }
}
```

Use the token on subsequent requests:

```bash
curl -s http://localhost:3000/api/v1/employees \
  -H "Authorization: Bearer <jwt>" \
  -H "X-Company-Id: 1"
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/session` | Email/password → JWT |
| `GET` | `/api/v1/employees` | List employees |
| `GET` | `/api/v1/employees/:id` | Show employee |
| `GET` | `/api/v1/departments` | List departments |
| `POST` | `/api/v1/attendance/clock_in` | Clock in current employee |
| `POST` | `/api/v1/attendance/clock_out` | Clock out current employee |
| `POST` | `/api/v1/leave_requests` | Submit leave request |
| `GET` | `/api/v1/webhooks` | List company webhooks (requires `company.update`) |
| `POST` | `/api/v1/webhooks` | Create webhook (`url`, `event_keys[]`, `active`) |
| `GET` | `/api/v1/webhooks/:id` | Show webhook |
| `PATCH` | `/api/v1/webhooks/:id` | Update webhook |
| `DELETE` | `/api/v1/webhooks/:id` | Delete webhook |
| `GET` | `/api/v1/scim/Users` | SCIM Users list (Bearer SCIM token) |
| `POST` | `/api/v1/scim/Users` | SCIM Users create |
| `GET` | `/api/v1/scim/Users/:id` | SCIM Users show |
| `PUT`/`PATCH` | `/api/v1/scim/Users/:id` | SCIM Users update / PatchOp (`active`) |
| `DELETE` | `/api/v1/scim/Users/:id` | Deactivate (terminate + soft-delete) |

Responses under `/api/*` include `X-API-Version: v1`. Only `/api/v1` is supported today.

Interactive docs: browse **[/api-docs](/api-docs)** (Swagger UI) or the machine-readable [`openapi.yaml`](openapi.yaml).
Auth sequence diagram: [`uml/sequences/api_auth.md`](uml/sequences/api_auth.md).

## Webhooks

Create a webhook for leave/hire domain events:

```bash
curl -s -X POST http://localhost:3000/api/v1/webhooks \
  -H "Authorization: Bearer <jwt>" \
  -H "X-Company-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"webhook":{"url":"https://example.com/hooks/ems","event_keys":["leave.approved_event","employees.hired_event"],"active":true}}'
```

Deliveries POST JSON `{ event, payload, delivered_at }` with `X-EMS-Event` and `X-EMS-Signature` (HMAC-SHA256 of body using webhook secret).

## SCIM

Authenticate with a company `ScimToken` as Bearer token (SHA-256 digest stored). Users map to `Employee` records.

```bash
curl -s http://localhost:3000/api/v1/scim/Users \
  -H "Authorization: Bearer <scim-raw-token>"

curl -s -X PATCH http://localhost:3000/api/v1/scim/Users/123 \
  -H "Authorization: Bearer <scim-raw-token>" \
  -H "Content-Type: application/json" \
  -d '{"schemas":["urn:ietf:params:scim:api:messages:2.0:PatchOp"],"Operations":[{"op":"Replace","path":"active","value":false}]}'
```

## Calendar sync (HTML)

Leave approvals and interview scheduling enqueue `CalendarSyncJob`. Connect Google/Outlook via OAuth at `/calendar_oauth/:provider/initiate` (requires calendar client ENV). Placeholder tokens stub in non-production; OAuth-connected tokens call live APIs. Sync history: `/calendar_events`.

## SSO

HTML SSO at `/sso/:provider/initiate` and `/sso/:provider/callback` for enabled `SsoConfiguration` records.

- **OIDC:** authorization-code exchange + optional JWKS verification (`metadata.jwks_uri`).
- **SAML:** `ruby-saml` AuthnRequest/assertion validation when `idp_cert` / `idp_cert_fingerprint` is set; demo ACS (NameID/email params) allowed outside production.

HTML session login remains at `POST /session`. Integration credentials UI: `/company_settings/edit`.
