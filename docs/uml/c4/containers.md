# C4 — Containers

Runtime containers for local Compose and typical deploy. Async work uses **Solid Queue** (`bin/jobs`); Postgres holds app data, queue, cache, and cable.

```mermaid
flowchart TB
  Browser([Browser / SPA / mobile])
  APIClient([REST / GraphQL clients])

  subgraph Edge
    Nginx["Nginx<br/>(optional Compose profile)"]
  end

  subgraph Application
    Web["Web — Rails + Puma<br/>(Hotwire, REST, GraphQL)<br/>optional GraphiQL at /graphiql"]
    Worker["Worker — Solid Queue<br/>bin/jobs<br/>NotificationJob, mailers, …"]
  end

  DB[("PostgreSQL 16<br/>primary + Solid Queue<br/>+ Solid Cache + Solid Cable")]

  Browser --> Nginx
  Nginx --> Web
  Browser -.->|direct :3000| Web
  APIClient --> Web

  Web <--> DB
  Worker <--> DB
  Web -->|enqueue jobs| DB
  Worker -->|dequeue / run| DB
```

## Containers

| Container | Tech | Responsibility |
|-----------|------|----------------|
| **web** | Rails 8 + Puma (+ Thruster in Compose) | HTTP: sessions, Hotwire, REST, GraphQL; optional GraphiQL in non-prod |
| **worker** | Solid Queue (`./bin/jobs`) | `NotificationJob`, mailers, background side effects |
| **db** | Postgres 16 | Tenancy data + Solid Trifecta tables |
| **nginx** | nginx:1.27-alpine (Compose profile `nginx`) | Optional reverse proxy in front of web |
| **GraphiQL** | `GraphiQL::Rails::Engine` at `/graphiql` | Dev/ops GraphQL explorer (mounted in routes when enabled) |

Compose reference: `docker-compose.yml` (`web`, `worker`, `db`, optional `nginx`).
