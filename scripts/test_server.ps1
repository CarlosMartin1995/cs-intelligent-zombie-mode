# PowerShell script to test server and capture errors
Write-Host "Starting HLDS Server Test..." -ForegroundColor Yellow
Write-Host ""

Set-Location "C:\Projects\cs_zombie_ai\hlds"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# First test - try to run HLDS and capture any output
Write-Host "Attempting to start HLDS..." -ForegroundColor Green
& ".\hlds.exe" -game cstrike -console -port 27015 +maxplayers 16 +map de_dust2 +exec server.cfg 2>&1 | Out-String

Write-Host ""
Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Yellow

# Check for common issues
Write-Host ""
Write-Host "Checking for common issues:" -ForegroundColor Cyan

# Check if metamod.dll exists
if (Test-Path "cstrike\addons\metamod\metamod.dll") {
    Write-Host "[OK] metamod.dll found" -ForegroundColor Green
} else {
    Write-Host "[ERROR] metamod.dll NOT found" -ForegroundColor Red
}

# Check liblist.gam
$liblist = Get-Content "cstrike\liblist.gam" | Select-String "gamedll"
Write-Host "liblist.gam gamedll line: $liblist" -ForegroundColor Yellow

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")