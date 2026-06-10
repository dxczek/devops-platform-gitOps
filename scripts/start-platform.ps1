
$ErrorActionPreference = "Continue"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "  -> $Message" -ForegroundColor White
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "  [ERROR] $Message" -ForegroundColor Red
}

Write-Step "STEP 1/5: Sprawdzanie docker desktop"

$dockerRunning = $false
try {
    docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $dockerRunning = $true
        Write-Success "Docker Desktop dziala"
    }
} catch {
    $dockerRunning = $false
}

if (-not $dockerRunning) {
    Write-ErrorMsg "Docker desktop NIE dziala"
    Write-Info "uruchom docker Desktop ze Start Menu."
    Read-Host "Nacisnij ENTER aby zakonczyc"
    exit 1
}


Write-Step "STEP 2/5: uruchamianie minikube"

$minikubeStatus = minikube status --format='{{.Host}}' 2>$null

if ($minikubeStatus -eq "Running") {
    Write-Success "Minikube juz dziala"
} else {
    Write-Info "Startowanie Minikube (1-3 minuty)..."
    minikube start --driver=docker --cpus=6 --memory=16384
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Minikube wystartowany"
    } else {
        Write-ErrorMsg "Blad startowania Minikube"
        exit 1
    }
}


Write-Step "STEP 3/5: Sprawdzanie statusu podow"

Write-Info "Pody argoCD:"
kubectl get pods -n argocd --no-headers 2>$null | ForEach-Object { Write-Host "    $_" }

Write-Info ""
Write-Info "Pody task-management:"
kubectl get pods -n task-management --no-headers 2>$null | ForEach-Object { Write-Host "    $_" }

Write-Info ""
Write-Info "Pody monitoring:"
kubectl get pods -n monitoring --no-headers 2>$null | ForEach-Object { Write-Host "    $_" }

Write-Step "STEP 4/5: Pobieranie hasla argoCD"

$password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>$null

if ($password) {
    $decoded = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($password))
    $decoded | Set-Clipboard
    Write-Success "Haslo ArgoCD: $decoded"
    Write-Info "Skopiowane do schowka (Ctrl+V w polu hasla)"
} else {
    Write-ErrorMsg "Nie mozna pobrac hasla ArgoCD"
}

Write-Step "STEP 5/5: Uruchamianie port-forwards"

Write-Info "Zatrzymywanie starych port-forwards..."
Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Info "Uruchamianie ArgoCD na https://localhost:8090..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'ArgoCD Port-Forward' -ForegroundColor Cyan; Write-Host 'URL: https://localhost:8090' -ForegroundColor Yellow; Write-Host 'Zostaw otwarte!' -ForegroundColor Red; kubectl port-forward -n argocd svc/argocd-server 8090:443"
Start-Sleep -Seconds 2

Write-Info "Uruchamianie Grafany na http://localhost:3000..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Grafana Port-Forward' -ForegroundColor Cyan; Write-Host 'URL: http://localhost:3000' -ForegroundColor Yellow; Write-Host 'Login: admin / admin' -ForegroundColor Yellow; Write-Host 'Zostaw otwarte!' -ForegroundColor Red; kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80"
Start-Sleep -Seconds 2

Write-Info "Uruchamianie Task-API na http://localhost:8080..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Task-API Port-Forward' -ForegroundColor Cyan; Write-Host 'URL: http://localhost:8080/docs' -ForegroundColor Yellow; Write-Host 'Zostaw otwarte!' -ForegroundColor Red; kubectl port-forward -n task-management svc/task-api 8080:8000"
Start-Sleep -Seconds 2

Write-Info "Uruchamianie Prometheus na http://localhost:9090..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Prometheus Port-Forward' -ForegroundColor Cyan; Write-Host 'URL: http://localhost:9090' -ForegroundColor Yellow; Write-Host 'Zostaw otwarte!' -ForegroundColor Red; kubectl port-forward -n monitoring svc/kube-prometheus-kube-prome-prometheus 9090:9090"


Write-Step "GOTOWE! Platforma uruchomiona"

Write-Host ""
Write-Host "  Dostepne UI:" -ForegroundColor Cyan
Write-Host "  ============" -ForegroundColor Cyan
Write-Host ""
Write-Host "  ArgoCD:     https://localhost:8090  (admin / haslo w schowku)" -ForegroundColor White
Write-Host "  Grafana:    http://localhost:3000   (admin / admin)" -ForegroundColor White
Write-Host "  Task-API:   http://localhost:8080/docs" -ForegroundColor White
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host ""
Write-Host "  Otwarte zostaly 4 dodatkowe terminale z port-forwards." -ForegroundColor Yellow
Write-Host "  Nie zamykaj ich - inaczej UI przestana dzialac!" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Aby zatrzymac: .\stop-platform.ps1" -ForegroundColor Cyan
Write-Host ""
