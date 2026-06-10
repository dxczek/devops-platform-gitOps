
# Kubernetes Namespaces

# Namespace for the app
resource "kubernetes_namespace" "task_management" {
  metadata {
    name = var.app_namespace
    labels = merge(var.labels, {
      name = var.app_namespace
    })
  }
}

# Namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = merge(var.labels, {
      name = var.argocd_namespace
    })
  }
}

# Namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  metadata {
    name = var.monitoring_namespace
    labels = merge(var.labels, {
      name = var.monitoring_namespace
    })
  }
}
