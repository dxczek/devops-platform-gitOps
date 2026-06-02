# Kustomize Overlays - Multi-Environment Deployment

## Struktura
gitops/
├── base/                    # Wspolna konfiguracja (DRY!)
│   └── app/
│       ├── app-deployment.yaml
│       ├── app-service.yaml
│       ├── app-secret.yaml
│       ├── hpa.yaml
│       └── kustomization.yaml
│
└── overlays/                # Srodowiska
├── dev/                 # Development
│   └── kustomization.yaml
└── prod/                # Production
└── kustomization.yaml

## Roznice miedzy srodowiskami

| Parameter | Base | Dev | Prod |
|-----------|------|-----|------|
| Replicas | 3 | 2 | 5 |
| HPA min | 2 | 2 | 5 |
| HPA max | 10 | 5 | 20 |
| HPA CPU target | 70% | 70% | 60% |
| Memory request | 128Mi | 128Mi | 256Mi |
| Memory limit | 512Mi | 512Mi | 1Gi |
| CPU request | 100m | 100m | 250m |
| CPU limit | 500m | 500m | 1000m |

## Uzycie

### Preview manifestow (dry run):
```powershell
kubectl kustomize overlays/dev   # Dev
kubectl kustomize overlays/prod  # Prod
```

### Aplikuj na klaster:
```powershell
kubectl apply -k overlays/dev   # Dev
kubectl apply -k overlays/prod  # Prod
```

## DevOps Best Practices

1. **DRY:** Wspolny kod w `base/`
2. **Environment Parity:** Te same manifesty, rozne parametry
3. **GitOps Compatible:** ArgoCD moze deployowac
4. **Auditable:** Latwo zobaczyc co sie zmienia per srodowisko
