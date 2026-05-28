# =============================================================
# Terraform Outputs
# =============================================================

output "project_info" {
  description = "Project information"
  value = {
    project_name = var.project_name
    environment  = var.environment
    namespaces = {
      app        = var.app_namespace
      argocd     = var.argocd_namespace
      monitoring = var.enable_monitoring ? var.monitoring_namespace : "disabled"
    }
  }
}

output "argocd_info" {
  description = "ArgoCD access information"
  value = {
    namespace = var.argocd_namespace
    access_command = "kubectl port-forward -n ${var.argocd_namespace} svc/argocd-server 8090:443"
    url            = "https://localhost:8090"
    password_command = "kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  }
}

output "monitoring_info" {
  description = "Monitoring access information"
  value = var.enable_monitoring ? {
    namespace = var.monitoring_namespace
    grafana = {
      access_command = "kubectl port-forward -n ${var.monitoring_namespace} svc/kube-prometheus-grafana 3000:80"
      url            = "http://localhost:3000"
      username       = "admin"
      password       = "admin"
    }
    prometheus = {
      access_command = "kubectl port-forward -n ${var.monitoring_namespace} svc/kube-prometheus-kube-prome-prometheus 9090:9090"
      url            = "http://localhost:9090"
    }
  } : null
}

output "app_info" {
  description = "Application information"
  value = {
    namespace = var.app_namespace
    image     = "${var.app_image}:${var.app_image_tag}"
    replicas  = var.app_replicas
    access_command = "kubectl port-forward -n ${var.app_namespace} svc/task-api 8080:8000"
    url            = "http://localhost:8080"
    docs_url       = "http://localhost:8080/docs"
  }
}

output "gitops_info" {
  description = "GitOps repository information"
  value = {
    repo_url        = var.gitops_repo_url
    target_revision = var.gitops_target_revision
  }
}

output "next_steps" {
  description = "What to do after deployment"
  value = <<-EOT

  =============================================================
  DEPLOYMENT COMPLETE!
  =============================================================

  Run these commands to access the platform:

  1. Get ArgoCD password:
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

  2. Access ArgoCD UI:
     kubectl port-forward -n argocd svc/argocd-server 8090:443
     -> Open: https://localhost:8090

  3. Access Grafana:
     kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
     -> Open: http://localhost:3000 (admin/admin)

  4. Access Application:
     kubectl port-forward -n task-management svc/task-api 8080:8000
     -> Open: http://localhost:8080/docs

  Or use the start script: .\start-platform.ps1
  =============================================================
  EOT
}
