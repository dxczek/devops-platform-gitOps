# Terraform – Infrastructure as Code

Katalog zawiera config Terraform odpowiedzialną za przygotowanie środowiska platformy na klastrze Kubernetes.

## Zakres

Za pomocą Terraform tworzone są następujące elementy:

- namespace'y Kubernetes (`task-management`, `argocd`, `monitoring`),
- instalacja ArgoCD,
- monitoring stack oparty na Prometheus i Grafana,
- ServiceMonitor zbierający metryki aplikacji,
- aplikacje ArgoCD synchronizowane z repozytorium GitOps.

Sama aplikacja nie jest wdrażana przez Terraform. Odpowiada za to ArgoCD, które pobiera manifesty z repozytorium GitOps.

## Wymagania

- Terraform w wersji 1.5.0 lub nowszej,
- skonfigurowany `kubectl` z kontekstem Minikube,
- zainstalowany Helm,
- uruchomiony klaster Minikube.

## Sposób użycia

Inicjalizacja i pobranie wymaganych providerów:

```powershell
terraform init
```

Podgląd planowanych zmian przed ich wprowadzeniem:

```powershell
terraform plan
```

Wdrożenie infrastruktury (po wyświetleniu planu należy potwierdzić operację wpisując `yes`):

```powershell
terraform apply
```

Wyświetlenie outputów:

```powershell
terraform output
```

Usunięcie utworzonych zasobów:

```powershell
terraform destroy
```

Operacja `destroy` usuwa wszystkie zasoby utworzone przez Terraform. Nie obejmuje repozytoriów GitHub ani obrazów opublikowanych w Docker Hub.

## Konfiguracja

Parametry konfiguracyjne znajdują się w pliku `variables.tf`. Można tam dostosować między innymi namespace'y, image aplikacji, liczbę replik, adres repozytorium GitOps oraz włączenie lub wyłączenie monitoringu.

## Pliki

| Plik | Przeznaczenie |
|------|---------------|
| `main.tf` | Konfiguracja główna |
| `providers.tf` | Wymagane providery (Kubernetes, Helm, Kubectl) |
| `variables.tf` | Zmienne wejściowe |
| `outputs.tf` | Outputy |
| `namespaces.tf` | Namespace'y Kubernetes |
| `argocd.tf` | Instalacja ArgoCD oraz aplikacje |
| `monitoring.tf` | Stack Prometheus i Grafana |

## Terraform state

State przechowywany jest lokalnie w pliku `terraform.tfstate`. W środowisku produkcyjnym powinien zostać przeniesiony do zdalnego backendu, na przykład Amazon S3 lub Azure Storage.
