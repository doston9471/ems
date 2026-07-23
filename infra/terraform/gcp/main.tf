# GCP infrastructure stub for Employee Management System.
# Replace placeholders before applying. This is intentionally minimal.
#
# Intended shape:
# - VPC network
# - Cloud SQL (PostgreSQL)
# - GKE cluster for web/worker deployments
# - Artifact Registry for container images

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "staging"
}

# resource "google_compute_network" "ems" {
#   name                    = "ems-${var.environment}"
#   auto_create_subnetworks = false
# }

# resource "google_sql_database_instance" "ems" {
#   name             = "ems-${var.environment}"
#   database_version = "POSTGRES_16"
#   region           = var.region
# }

# resource "google_container_cluster" "ems" {
#   name     = "ems-${var.environment}"
#   location = var.region
# }

output "placeholder" {
  value       = "Configure VPC/Cloud SQL/GKE for ${var.project_id} (${var.environment}) in ${var.region}"
  description = "Reminder that this stub must be expanded before use"
}
