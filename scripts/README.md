# GitOps Platform - Instrukcja uzytkowania

## Pierwsze uruchomienie po restarcie komputera

### Krok 1: Uruchom Docker Desktop
- Start Menu -> Docker Desktop
- Poczekaj az ikona w tray bedzie stabilna (~30 sekund)

### Krok 2: Uruchom platforme
```powershell
cd C:\Projekty\praca-inzynierska\scripts
.\start-platform.ps1
```

Skrypt automatycznie:
- Sprawdzi Docker
- Uruchomi Minikube
- Wyswietli statusy podow
- Pobierze haslo ArgoCD (do schowka)
- Uruchomi 4 port-forwards w osobnych oknach

### Krok 3: Otwórz UI

Po uruchomieniu skryptu, masz dostep do:

| Aplikacja  | URL                            | Login           |
|------------|--------------------------------|-----------------|
| ArgoCD     | https://localhost:8090         | admin / schowek |
| Grafana    | http://localhost:3000          | admin / admin   |
| Task-API   | http://localhost:8080/docs     | -               |
| Prometheus | http://localhost:9090          | -               |

## Sprawdzenie statusu

```powershell
.\status.ps1
```

## Zatrzymanie platformy

```powershell
.\stop-platform.ps1
```

## Najczestsze problemy

### Problem: "Docker Desktop nie dziala"
**Rozwiazanie:** Uruchom Docker Desktop ze Start Menu, poczekaj 30 sekund

### Problem: "Port-forwards padaja"
**Rozwiazanie:** 
- Sprawdz czy okna powershell z port-forwards sa otwarte
- Jesli zamknete - uruchom ponownie: .\start-platform.ps1

### Problem: "ArgoCD pokazuje OutOfSync ale nic sie nie dzieje"
**Rozwiazanie:**
- W ArgoCD UI - klik REFRESH (przycisk u gory)
- Klik SYNC -> SYNCHRONIZE

### Problem: "Grafana wolno dziala"
**Rozwiazanie:**
- Sprawdz pamiec: .\status.ps1
- Jesli za malo RAM - restart Minikube z wieksza pamiecia

### Problem: "Aplikacja nie odpowiada (timeout)"
**Rozwiazanie:**
```powershell
kubectl get pods -n task-management
kubectl logs -n task-management -l app=task-api --tail=50
```

## Architektura

Platforma sklada sie z:

1. **Aplikacja FastAPI** (namespace: task-management)
   - 3 repliki task-api
   - PostgreSQL database
   
2. **ArgoCD** (namespace: argocd)
   - GitOps deployment
   - Synchronizacja z GitHub
   
3. **Monitoring** (namespace: monitoring)
   - Prometheus - metryki
   - Grafana - dashbordy
   - AlertManager - alerty
   - Node Exporter - metryki maszyny

## Repozytoria GitHub

- **Kod aplikacji:** https://github.com/dxczek/devops-platform-app
- **Konfiguracja GitOps:** https://github.com/dxczek/devops-platform-gitops

## Docker Hub

- **Obraz aplikacji:** https://hub.docker.com/r/torpeda808/devops-platform-app
