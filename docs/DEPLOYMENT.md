# Deployment

## Docker Compose (local / small prod)

From the repository root:

```bash
cp .env.example .env   # if present; set RAILS_MASTER_KEY / SECRET_KEY_BASE
docker compose up --build
```

Services:

| Service | Role |
|---------|------|
| `db` | PostgreSQL 16 |
| `web` | Puma behind Thruster (HTTP) |
| `worker` | Solid Queue (`bin/jobs`) |
| `nginx` | Optional reverse proxy (`--profile nginx`) |

Health: `GET /up` on the web service.

## Kamal

`config/deploy.yml` is a ready-to-edit Kamal 2 config (web + Solid Queue job role, TLS proxy, secrets).

1. Set `image`, `servers`, `proxy.host`, and registry credentials.
2. Export `KAMAL_REGISTRY_PASSWORD`, `RAILS_MASTER_KEY`, DB password, `SECRET_KEY_BASE`.
3. `kamal setup` once, then `kamal deploy`.

Helpers: `kamal console`, `kamal logs`, `kamal dbc` (see `.kamal/hooks/README.md`).

## Kubernetes

Manifests live under `infra/kubernetes/`:

1. `namespace.yaml`
2. `configmap.yaml`
3. `secret.yaml` (from `secret.yaml.example`)
4. `postgres.yaml` (dev/small installs; prefer managed DB in production)
5. `migrate-job.yaml` — `db:prepare` (primary + cable/cache/queue DBs as configured)
6. `web-deployment.yaml` + `web-service.yaml` + `web-hpa.yaml`
7. `worker-deployment.yaml`
8. `ingress.yaml` — include WebSocket upgrade for `/cable` on your ingress controller

Replace image, host, and secret placeholders before apply. See `infra/README.md`.

Solid Cable is enabled in production (`config/cable.yml` → `solid_cable` adapter on the `cable` database). Prepare that DB in production (`db:prepare` / migrate cable schema).

## Cloud stubs

Thin Terraform starters:

- `infra/terraform/aws/` — VPC / RDS / EKS sketch
- `infra/terraform/gcp/` — VPC / Cloud SQL / GKE sketch
- `infra/terraform/digitalocean/` — VPC / Postgres / DOKS sketch

These are variables-only stubs with commented resources — expand before real use.

## API docs

- OpenAPI: [`docs/openapi.yaml`](openapi.yaml) — browse at `/api-docs`
- Sequence: [`docs/uml/sequences/api_auth.md`](uml/sequences/api_auth.md)

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs Brakeman, bundler-audit, RuboCop (continue-on-error), importmap audit, and RSpec against Postgres on Ruby 4.0.6.
