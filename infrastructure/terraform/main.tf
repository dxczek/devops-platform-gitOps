 
# DevOps Platform - Main Terraform Configuration
 
# This Terraform configuration deploys the entire DevOps platform:
#   - Namespaces (task-management, argocd, monitoring)
#   - ArgoCD (GitOps continuous delivery)
#   - Prometheus + Grafana (monitoring stack)
#   - ServiceMonitor for application metrics
# Usage:
#   terraform init
#   terraform plan
#   terraform apply

# Random suffix for unique resource names (if needed in future)
resource "random_id" "suffix" {
  byte_length = 4
}
