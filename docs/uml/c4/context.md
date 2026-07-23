# C4 — System context

EMS as a multi-tenant HR SaaS. People and systems outside the boundary interact with the Employee Management System.

```mermaid
flowchart TB
  subgraph People
    Emp([Employees / Managers / HR / Owners])
    SA([Super Admin])
    APIDev([API / integration clients])
  end

  EMS[["Employee Management System<br/>Rails HR platform"]]

  subgraph Identity providers
    Google([Google OAuth])
    GitHub([GitHub OAuth])
  end

  subgraph Notification channels
    Email([Email SMTP])
    Slack([Slack])
    Teams([Microsoft Teams])
    Telegram([Telegram])
    SMS([SMS stub])
  end

  subgraph External consumers
    Hooks([Customer webhooks])
    SCIM([SCIM clients])
  end

  Emp -->|Hotwire UI / sessions| EMS
  SA -->|platform admin| EMS
  APIDev -->|REST / GraphQL / JWT| EMS

  EMS <-->|OmniAuth| Google
  EMS <-->|OmniAuth| GitHub

  EMS -->|NotificationJob adapters| Email
  EMS -->|NotificationJob adapters| Slack
  EMS -->|NotificationJob adapters| Teams
  EMS -->|NotificationJob adapters| Telegram
  EMS -->|NotificationJob adapters| SMS

  EMS -->|Webhooks::DispatchService| Hooks
  EMS -->|SCIM API| SCIM
```

## Relationships

| Actor / system | Interaction |
|----------------|-------------|
| Company users | Browser sessions; RBAC via memberships/roles |
| Super Admin | Cross-tenant platform ops (flags, integrations) |
| Google / GitHub | OAuth identity; optional MFA after callback |
| Email / Slack / Teams / Telegram / SMS | Outbound notifications from domain events |
| Webhook endpoints | Signed delivery of domain events |
| API clients | JWT + tenant header; REST / GraphQL |

See also [docs/ARCHITECTURE.md](../../ARCHITECTURE.md).
