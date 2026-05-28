# Terraform - Infrastructure as Code

This directory contains Terraform configuration for deploying the complete DevOps platform.

## Architecture

Terraform manages:
- Kubernetes namespaces (task-management, argocd, monitoring)
- ArgoCD installation
- Prometheus + Grafana monitoring stack
- ServiceMonitor for application metrics
- ArgoCD Applications that sync from GitOps repo

The application itself is deployed via ArgoCD from the GitOps repository.

## Prerequisites

- Terraform >= 1.5.0
- kubectl configured with Minikube context
- Helm installed
- Running Minikube cluster

## Usage

### Initialize Terraform

```powershell
terraform init
```

### Preview changes

```powershell
terraform plan
```

### Apply infrastructure

```powershell
terraform apply
```

Type `yes` when prompted.

### View outputs

```powershell
terraform output
```

### Destroy infrastructure

```powershell
terraform destroy
```

⚠️ This will delete all resources except the GitHub repos and Docker Hub images.

## Variables

Edit `variables.tf` to customize:
- Namespaces
- Application image
- Number of replicas
- GitOps repository URL
- Enable/disable monitoring

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Main configuration |
| `providers.tf` | Required providers (Kubernetes, Helm, Kubectl) |
| `variables.tf` | Input variables |
| `outputs.tf` | Output values |
| `namespaces.tf` | Kubernetes namespaces |
| `argocd.tf` | ArgoCD installation and Applications |
| `monitoring.tf` | Prometheus + Grafana stack |

## State

Terraform state is stored locally in `terraform.tfstate`.
In production, this would be stored in a remote backend (S3, Azure Storage, etc.).
