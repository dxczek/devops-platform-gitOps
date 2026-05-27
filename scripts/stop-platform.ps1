# =============================================================
# GitOps Platform - Stop Script
# =============================================================

Write-Host ""
Write-Host "Zatrzymywanie platformy..." -ForegroundColor Cyan
Write-Host ""

# Zatrzymaj wszystkie port-forwards
Write-Host "  -> Zatrzymywanie port-forwards..." -ForegroundColor White

Get-Process powershell -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -match "Port-Forward|kubectl|minikube"
} | ForEach-Object {
    $_ | Stop-Process -Force -ErrorAction SilentlyContinue
}

# Alternatywnie - zabij wszystkie kubectl
Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "  [OK] Port-forwards zatrzymane" -ForegroundColor Green

# Pytaj czy zatrzymac Minikube
Write-Host ""
$answer = Read-Host "Zatrzymac tez Minikube? (oszczedza pamiec RAM) [y/N]"

if ($answer -eq "y" -or $answer -eq "Y") {
    Write-Host "  -> Zatrzymywanie Minikube..." -ForegroundColor White
    minikube stop
    Write-Host "  [OK] Minikube zatrzymany" -ForegroundColor Green
}

Write-Host ""
Write-Host "Platforma zatrzymana!" -ForegroundColor Green
Write-Host ""
