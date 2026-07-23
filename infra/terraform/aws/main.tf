# AWS infrastructure stub for Employee Management System.
# Replace placeholders before applying. This is intentionally minimal.
#
# Intended shape:
# - VPC + private/public subnets
# - RDS PostgreSQL
# - EKS cluster for web/worker deployments
# - ECR repository for container images

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "ems"
}

variable "environment" {
  type        = string
  description = "Environment name (staging, production)"
  default     = "staging"
}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   name   = "${var.project_name}-${var.environment}"
#   cidr   = "10.0.0.0/16"
# }

# module "rds" {
#   source     = "terraform-aws-modules/rds/aws"
#   identifier = "${var.project_name}-${var.environment}"
#   engine     = "postgres"
# }

# module "eks" {
#   source       = "terraform-aws-modules/eks/aws"
#   cluster_name = "${var.project_name}-${var.environment}"
# }

output "placeholder" {
  value       = "Configure VPC/RDS/EKS modules for ${var.project_name}-${var.environment} in ${var.aws_region}"
  description = "Reminder that this stub must be expanded before use"
}
