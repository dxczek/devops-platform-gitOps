# =============================================================
# Monitoring Stack - Prometheus + Grafana
# =============================================================
# Installs kube-prometheus-stack via Helm
# =============================================================

resource "helm_release" "kube_prometheus" {
  count = var.enable_monitoring ? 1 : 0

  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.monitoring_namespace
  version    = "65.0.0"

  timeout = 600

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "7d"
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
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false
        }
        service = {
          type     = "NodePort"
          nodePort = 30090
        }
      }
      grafana = {
        enabled       = true
        adminPassword = "admin"
        service = {
          type     = "NodePort"
          nodePort = 30030
        }
        resources = {
          requests = {
            memory = "128Mi"
            cpu    = "50m"
          }
          limits = {
            memory = "256Mi"
            cpu    = "200m"
          }
        }
        defaultDashboardsEnabled = true
      }
      alertmanager = {
        enabled = true
        alertmanagerSpec = {
          resources = {
            requests = {
              memory = "64Mi"
              cpu    = "25m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "100m"
            }
          }
        }
        service = {
          type     = "NodePort"
          nodePort = 30093
        }
      }
      nodeExporter = {
        enabled = true
      }
      prometheusOperator = {
        resources = {
          requests = {
            memory = "128Mi"
            cpu    = "50m"
          }
          limits = {
            memory = "256Mi"
            cpu    = "200m"
          }
        }
      }
      kubeStateMetrics = {
        enabled = true
      }
      # Disable components not available in Minikube
      kubeApiServer = {
        enabled = true
      }
      kubelet = {
        enabled = true
      }
      kubeControllerManager = {
        enabled = false
      }
      kubeScheduler = {
        enabled = false
      }
      kubeProxy = {
        enabled = false
      }
      kubeEtcd = {
        enabled = false
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# ServiceMonitor for task-api application
resource "kubectl_manifest" "task_api_service_monitor" {
  count = var.enable_monitoring ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: task-api-monitor
      namespace: ${var.monitoring_namespace}
      labels:
        release: kube-prometheus
        managed-by: terraform
    spec:
      selector:
        matchLabels:
          app: task-api
      namespaceSelector:
        matchNames:
          - ${var.app_namespace}
      endpoints:
        - port: http
          path: /metrics
          interval: 15s
  YAML

  depends_on = [helm_release.kube_prometheus]
}
