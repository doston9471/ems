# Deployment — Docker Compose + Kubernetes sketch

## Docker Compose (local / single host)

From `docker-compose.yml`:

```mermaid
flowchart LR
  subgraph compose["docker compose"]
    Nginx["nginx<br/>profile: nginx<br/>:8080 → :80"]
    Web["web<br/>build .<br/>thrust + rails server<br/>:3000 → :80"]
    Worker["worker<br/>build .<br/>bin/jobs"]
    DB[("db<br/>postgres:16<br/>volume: postgres_data")]
  end

  Client([Clients]) --> Nginx
  Client -.-> Web
  Nginx --> Web
  Web --> DB
  Worker --> DB
  Web -. depends_on .-> DB
  Worker -. depends_on .-> DB
```

| Service | Notes |
|---------|--------|
| `db` | Healthcheck `pg_isready`; env `POSTGRES_*` |
| `web` | `SOLID_QUEUE_IN_PUMA=0` — jobs run in worker |
| `worker` | Same image; `command: ["./bin/jobs"]` |
| `nginx` | Optional; mounts `infra/nginx/default.conf` |

## Kubernetes sketch

Manifests under `infra/kubernetes/` (namespace `ems`): web Deployment + Service, worker Deployment, Postgres, ConfigMap/Secret, Ingress.

```mermaid
flowchart TB
  Ingress["Ingress<br/>infra/kubernetes/ingress.yaml"]

  subgraph ns["Namespace: ems"]
    WebSvc["Service ems-web"]
    WebDep["Deployment ems-web<br/>replicas: 2<br/>container :80 /up probes"]
    WorkerDep["Deployment ems-worker<br/>bin/jobs"]
    PG[("Postgres<br/>postgres.yaml")]
    CM["ConfigMap ems-config"]
    Sec["Secret ems-secrets"]
  end

  Clients([Internet / VPC]) --> Ingress
  Ingress --> WebSvc
  WebSvc --> WebDep
  WebDep --> PG
  WorkerDep --> PG
  CM -.-> WebDep
  Sec -.-> WebDep
  CM -.-> WorkerDep
  Sec -.-> WorkerDep
```

Apply order (from `infra/README.md`): namespace → configmap → secret → postgres → web/worker → ingress.

Placeholder image: `ghcr.io/example/employee-management-system:latest` — replace before real deploy. See [docs/DEPLOYMENT.md](../../DEPLOYMENT.md) when present.
