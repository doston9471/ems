# Infrastructure

Placeholder and starter manifests for deploying the Employee Management System (EMS).

## Layout

| Path | Purpose |
|------|---------|
| `docker/` | Reserved for extra Docker/build helpers (app `Dockerfile` lives at repo root) |
| `nginx/` | Optional reverse-proxy config used by Compose `nginx` profile |
| `kubernetes/` | Namespace, ConfigMap, Secret example, Postgres, migrate Job, web+HPA, worker, Ingress |
| `../config/deploy.yml` | Kamal 2 deploy config (web + job) |
| `terraform/aws/` | Variables-only stub for VPC / RDS / EKS |
| `terraform/gcp/` | Variables-only stub for VPC / Cloud SQL / GKE |
| `terraform/digitalocean/` | Variables-only stub for VPC / managed Postgres / DOKS |

## Local Compose

From the repo root:

```bash
docker compose up --build
```

See [docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md) for environment variables and worker setup.

## Kubernetes (sketch)

1. Copy `kubernetes/secret.yaml.example` → `secret.yaml` and fill secrets.
2. Apply manifests in order: namespace → configmap → secret → postgres → **migrate-job** → web/worker → HPA → ingress.
3. Point DNS / TLS at your ingress controller. Enable WebSocket support for `/cable` (Solid Cable / Action Cable).

These manifests use placeholder image names (`ghcr.io/example/...`) and hostnames — replace before any real deploy.

## Terraform

Each cloud folder is a **non-production stub**: required providers, variables, and commented module/resource sketches. Expand and review carefully before `terraform apply`.
