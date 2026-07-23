# DigitalOcean infrastructure stub for Employee Management System.
# Replace placeholders before applying. This is intentionally minimal.
#
# Intended shape:
# - VPC
# - Managed PostgreSQL
# - Kubernetes (DOKS) for web/worker deployments
# - Container Registry

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  # Token via DIGITALOCEAN_TOKEN env var
}

variable "region" {
  type        = string
  description = "DigitalOcean region"
  default     = "nyc3"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "staging"
}

# resource "digitalocean_vpc" "ems" {
#   name   = "ems-${var.environment}"
#   region = var.region
# }

# resource "digitalocean_database_cluster" "ems" {
#   name       = "ems-${var.environment}"
#   engine     = "pg"
#   version    = "16"
#   size       = "db-s-1vcpu-1gb"
#   region     = var.region
#   node_count = 1
# }

# resource "digitalocean_kubernetes_cluster" "ems" {
#   name    = "ems-${var.environment}"
#   region  = var.region
#   version = "1.31.1-do.0"
# }

output "placeholder" {
  value       = "Configure VPC/Postgres/DOKS for ${var.environment} in ${var.region}"
  description = "Reminder that this stub must be expanded before use"
}
