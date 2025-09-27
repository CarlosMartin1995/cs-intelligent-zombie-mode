# Script to install ReHLDS and Metamod-r files to proper locations
$baseDir = "C:\Projects\cs_zombie_ai"

Write-Host "Installing server components..." -ForegroundColor Green

# Install ReHLDS
Write-Host "`n1. Installing ReHLDS..." -ForegroundColor Cyan
$rehldsSource = "$baseDir\downloads\ReHLDS\bin\win32"
$rehldsDest = "$baseDir\hlds"

if (Test-Path $rehldsSource) {
    # Copy ReHLDS files (overwrite HLDS engine)
    Copy-Item -Path "$rehldsSource\*" -Destination $rehldsDest -Recurse -Force
    Write-Host "   ReHLDS installed successfully!" -ForegroundColor Green
} else {
    Write-Host "   ReHLDS source not found. Please extract ReHLDS first." -ForegroundColor Red
}

# Install Metamod-r
Write-Host "`n2. Installing Metamod-r..." -ForegroundColor Cyan
$metamodSource = "$baseDir\downloads\Metamod-r\addons"
$metamodDest = "$baseDir\hlds\cstrike\addons"

if (Test-Path $metamodSource) {
    # Create addons directory if it doesn't exist
    New-Item -ItemType Directory -Force -Path $metamodDest | Out-Null

    # Copy Metamod files
    Copy-Item -Path "$metamodSource\*" -Destination $metamodDest -Recurse -Force
    Write-Host "   Metamod-r installed successfully!" -ForegroundColor Green
} else {
    Write-Host "   Metamod-r source not found. Please extract Metamod-r first." -ForegroundColor Red
}

# Update liblist.gam
Write-Host "`n3. Updating liblist.gam..." -ForegroundColor Cyan
$liblistPath = "$baseDir\hlds\cstrike\liblist.gam"

if (Test-Path $liblistPath) {
    $content = Get-Content $liblistPath -Raw

    # Backup original
    Copy-Item $liblistPath "$liblistPath.bak" -Force

    # Replace gamedll line
    $content = $content -replace 'gamedll\s+"[^"]*"', 'gamedll "addons\metamod\dlls\metamod.dll"'
    $content = $content -replace 'gamedll_linux\s+"[^"]*"', 'gamedll_linux "addons/metamod/dlls/metamod.so"'

    Set-Content -Path $liblistPath -Value $content
    Write-Host "   liblist.gam updated!" -ForegroundColor Green
} else {
    Write-Host "   liblist.gam not found!" -ForegroundColor Red
}

# Create Metamod plugins.ini
Write-Host "`n4. Creating Metamod plugins.ini..." -ForegroundColor Cyan
$pluginsDir = "$baseDir\hlds\cstrike\addons\metamod"
New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null

$pluginsContent = @"
win32 addons\amxmodx\dlls\amxmodx_mm.dll
; Add YaPB here later:
; win32 addons\yapb\bin\yapb.dll
"@

Set-Content -Path "$pluginsDir\plugins.ini" -Value $pluginsContent
Write-Host "   Metamod plugins.ini created!" -ForegroundColor Green

# Create server.cfg
Write-Host "`n5. Creating server.cfg..." -ForegroundColor Cyan
$serverCfg = @"
hostname "CS16 Zombie AI Lab"
rcon_password "zombie_ai_2024"
sv_lan 0
mp_autoteambalance 0
mp_limitteams 0
mp_timelimit 30
mp_roundtime 5
mp_freezetime 3
sv_maxspeed 320
sv_gravity 800

// Load AI Bridge settings
exec addons/amxmodx/configs/ai_bridge.cfg
"@

Set-Content -Path "$baseDir\hlds\cstrike\server.cfg" -Value $serverCfg
Write-Host "   server.cfg created!" -ForegroundColor Green

Write-Host "`n===== Installation complete! =====" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run download_amxmodx.ps1 to get AMX Mod X" -ForegroundColor Cyan
Write-Host "2. Download and install Zombie Plague and YaPB manually" -ForegroundColor Cyan
Write-Host "3. Copy ai_bridge.sma to scripting folder and compile" -ForegroundColor Cyan