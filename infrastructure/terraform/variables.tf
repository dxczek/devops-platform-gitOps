# =============================================================
# Terraform Variables
# =============================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-platform"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_namespace" {
  description = "Namespace for the application"
  type        = string
  default     = "task-management"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "torpeda808/devops-platform-app"
}

variable "app_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 3
}

variable "gitops_repo_url" {
  description = "GitOps repository URL"
  type        = string
  default     = "https://github.com/dxczek/devops-platform-gitops.git"
}

variable "gitops_target_revision" {
  description = "Git branch or tag to track"
  type        = string
  default     = "main"
}

variable "enable_monitoring" {
  description = "Enable Prometheus + Grafana monitoring"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default = {
    project    = "devops-platform"
    managed-by = "terraform"
    environment = "dev"
  }
}
