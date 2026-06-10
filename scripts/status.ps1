

Write-Host ""
Write-Host "=== STATUS PLATFORMY GITOPS ===" -ForegroundColor Cyan
Write-Host ""

# Docker
Write-Host "Docker Desktop:" -ForegroundColor White
try {
    docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Dziala" -ForegroundColor Green
    }
} catch {
    Write-Host "  [STOP] Nie dziala - uruchom Docker Desktop" -ForegroundColor Red
}

# Minikube
Write-Host ""
Write-Host "Minikube:" -ForegroundColor White
$minikubeStatus = minikube status --format='{{.Host}}' 2>$null
if ($minikubeStatus -eq "Running") {
    Write-Host "  [OK] Dziala" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "  Zasoby klastra:" -ForegroundColor White
    kubectl top nodes 2>$null
} else {
    Write-Host "  [STOP] Nie dziala - uruchom .\start-platform.ps1" -ForegroundColor Red
    exit
}

# Pody
Write-Host ""
Write-Host "Pody argocd:" -ForegroundColor White
kubectl get pods -n argocd --no-headers 2>$null | ForEach-Object { Write-Host "    $_" }

Write-Host ""
Write-Host "Pody task-management:" -ForegroundColor White
kubectl get pods -n task-management --no-headers 2>$null | ForEach-Object { Write-Host "    $_" }

Write-Host ""
Write-Host "Pody monitoring:" -ForegroundColor White
kubectl get pods -n monitoring --no-headers 2>$null | ForEach-Object { Write-Host "    $_" }

# Port-forwards
Write-Host ""
Write-Host "Aktywne port-forwards:" -ForegroundColor White
$kubectlProcs = Get-Process kubectl -ErrorAction SilentlyContinue
if ($kubectlProcs) {
    Write-Host "  [OK] Procesow kubectl: $($kubectlProcs.Count)" -ForegroundColor Green
} else {
    Write-Host "  [STOP] Brak port-forwards - uruchom .\start-platform.ps1" -ForegroundColor Yellow
}

# Sprawdz porty
Write-Host ""
Write-Host "Dostepne UI:" -ForegroundColor Cyan
$ports = @(
    @{Port=8090; Name="ArgoCD    "; URL="https://localhost:8090"},
    @{Port=3000; Name="Grafana   "; URL="http://localhost:3000"},
    @{Port=8080; Name="Task-API  "; URL="http://localhost:8080/docs"},
    @{Port=9090; Name="Prometheus"; URL="http://localhost:9090"}
)

foreach ($p in $ports) {
    $test = Test-NetConnection -ComputerName localhost -Port $p.Port -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($test) {
        Write-Host "  [OK]   $($p.Name): $($p.URL)" -ForegroundColor Green
    } else {
        Write-Host "  [STOP] $($p.Name): NIE DZIALA" -ForegroundColor Red
    }
}

Write-Host ""
