# =============================================================
# DevOps Platform - Main Terraform Configuration
# =============================================================
# Author: Jan Duczek
# Project: Engineering Thesis - GitOps Platform
# =============================================================
#
# This Terraform configuration deploys the entire DevOps platform:
#   - Namespaces (task-management, argocd, monitoring)
#   - ArgoCD (GitOps continuous delivery)
#   - Prometheus + Grafana (monitoring stack)
#   - ServiceMonitor for application metrics
#
# Application itself is deployed via ArgoCD from GitOps repo:
#   https://github.com/dxczek/devops-platform-gitops.git
#
# =============================================================
# Usage:
#   terraform init
#   terraform plan
#   terraform apply
# =============================================================

# Random suffix for unique resource names (if needed in future)
resource "random_id" "suffix" {
  byte_length = 4
}
