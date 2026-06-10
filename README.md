# devops-platform-gitOps

Repozytorium GitOps platformy zbudowanej na potrzeby pracy inżynierskiej. Pełni rolę pojedynczego źródła prawdy dla stanu klastra Kubernetes. Zawiera manifesty Kubernetes, konfigurację ArgoCD oraz kod Terraform odpowiedzialny za przygotowanie środowiska.

Kod aplikacji znajduje się w osobnym repozytorium: [devops-platform-app](https://github.com/dxczek/devops-platform-app). Rozdzielenie kodu aplikacji od konfiguracji wdrożenia jest jedną z podstawowych praktyk GitOps.

## Zasada działania

Stan klastra opisany jest w plikach YAML w tym repozytorium. ArgoCD działa wewnątrz klastra, obserwuje repozytorium i synchronizuje rzeczywisty stan klastra ze stanem zapisanym w Gicie (model pull). Każda zmiana wdrażana jest automatycznie, a ręczne modyfikacje w klastrze są wykrywane i cofane (self-healing).

Aktualizacja obrazu aplikacji następuje automatycznie. Pipeline CI/CD w repozytorium aplikacji po zbudowaniu nowego obrazu commituje zmieniony tag do tego repozytorium, co uruchamia synchronizację przez ArgoCD.

## Struktura

```
base/                manifesty bazowe
  app/               Deployment, Service, Secret i HPA aplikacji
  database/          PostgreSQL
  monitoring/        ServiceMonitor
  namespace/         definicje namespace'ów
overlays/            konfiguracje środowisk (Kustomize)
  dev/               środowisko developerskie
  prod/              środowisko produkcyjne
argocd/              konfiguracja ArgoCD
applications/        definicje aplikacji ArgoCD
infrastructure/
  terraform/         Infrastructure as Code (namespace'y, ArgoCD, monitoring)
scripts/             skrypty pomocnicze
```

## Środowiska i Kustomize

Konfiguracja środowisk oparta jest na Kustomize. Wspólne manifesty znajdują się w katalogu `base`, a różnice między środowiskami w `overlays`. Środowisko `dev` korzysta z mniejszej liczby replik, `prod` z wyższych limitów zasobów i większego zakresu skalowania HPA.

Podgląd wygenerowanych manifestów dla danego środowiska:

```powershell
kubectl kustomize overlays/prod
```

## Infrastruktura

Przygotowanie środowiska (namespace'y, instalacja ArgoCD, monitoring stack Prometheus i Grafana) realizowane jest przez Terraform. Szczegóły oraz instrukcja uruchomienia znajdują się w `infrastructure/terraform/README.md`.

## Środowisko uruchomieniowe

Całość uruchamiana jest lokalnie na klastrze Minikube. Wykorzystane manifesty są przenośne, więc po dostosowaniu kilku elementów (klasy storage, typ Service, provisioning klastra) mogą zostać wdrożone w środowisku chmurowym.

## Powiązane repozytoria

- [devops-platform-app](https://github.com/dxczek/devops-platform-app) – kod aplikacji oraz pipeline CI/CD

## Autor

Jan Duczek, 
nr albumu 44682,
projekt do pracy inżynierskiej.
