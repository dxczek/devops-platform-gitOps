
# Install ArgoCD via Helm chart
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.argocd_namespace
  version    = "7.7.5"

  timeout = 600

  values = [
    yamlencode({
      global = {
        domain = "localhost"
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      server = {
        service = {
          type = "NodePort"
        }
      }
      controller = {
        resources = {
          requests = {
            memory = "256Mi"
            cpu    = "100m"
          }
          limits = {
            memory = "1Gi"
            cpu    = "500m"
          }
        }
      }
      repoServer = {
        resources = {
          requests = {
            memory = "128Mi"
            cpu    = "50m"
          }
          limits = {
            memory = "512Mi"
            cpu    = "200m"
          }
        }
      }
      applicationSet = {
        resources = {
          requests = {
            memory = "128Mi"
            cpu    = "50m"
          }
          limits = {
            memory = "256Mi"
            cpu    = "100m"
          }
        }
      }
      dex = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Wait for ArgoCD to be ready
resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]

  create_duration = "60s"
}

# Create ArgoCD Application that watches our GitOps repo (app)
resource "kubectl_manifest" "task_management_app" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: task-management
      namespace: ${var.argocd_namespace}
      finalizers:
        - resources-finalizer.argocd.argoproj.io
      labels:
        managed-by: terraform
    spec:
      project: default
      source:
        repoURL: ${var.gitops_repo_url}
        targetRevision: ${var.gitops_target_revision}
        path: base/app
      destination:
        server: https://kubernetes.default.svc
        namespace: ${var.app_namespace}
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
          - PrunePropagationPolicy=foreground
        retry:
          limit: 5
          backoff:
            duration: 5s
            factor: 2
            maxDuration: 3m
  YAML

  depends_on = [time_sleep.wait_for_argocd]
}

# Create argocd application for PostgreSQL database
resource "kubectl_manifest" "postgres_app" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: postgres-database
      namespace: ${var.argocd_namespace}
      finalizers:
        - resources-finalizer.argocd.argoproj.io
      labels:
        managed-by: terraform
    spec:
      project: default
      source:
        repoURL: ${var.gitops_repo_url}
        targetRevision: ${var.gitops_target_revision}
        path: base/database
      destination:
        server: https://kubernetes.default.svc
        namespace: ${var.app_namespace}
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
  YAML

  depends_on = [time_sleep.wait_for_argocd, kubernetes_namespace.task_management]
}
