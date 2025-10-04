# Complete automated setup script for CS 1.6 Zombie AI Server
param(
    [switch]$SkipHLDS
)

$ErrorActionPreference = "Stop"
$baseDir = "C:\Projects\cs_zombie_ai"

function Write-Step {
    param($message)
    Write-Host "`n==== $message ====" -ForegroundColor Green
}

# Step 1: Install HLDS base files
if (-not $SkipHLDS) {
    Write-Step "Installing HLDS base files via SteamCMD"
    & C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir "$baseDir\hlds" +app_update 90 validate +quit

    # Also get Counter-Strike content
    & C:\steamcmd\steamcmd.exe +login anonymous +force_install_dir "$baseDir\hlds" +app_update 90 +app_set_config "90 mod cstrike" validate +quit
}

# Step 2: Download and extract all components
Write-Step "Creating download directory"
$downloadDir = "$baseDir\downloads"
New-Item -ItemType Directory -Force -Path $downloadDir

# Download URLs
$downloads = @{
    "ReHLDS" = "https://github.com/rehlds/ReHLDS/releases/download/3.13.0.788/rehlds-bin-3.13.0.788.zip"
    "Metamod-r" = "https://github.com/rehlds/Metamod-r/releases/download/1.3.0.138/metamod-bin-1.3.0.138.zip"
    "AMXModX" = "https://www.amxmodx.org/release/amxmodx-1.10.0-git5475-base-windows.zip"
    "AMXModX-CS" = "https://www.amxmodx.org/release/amxmodx-1.10.0-git5475-cstrike-windows.zip"
}

foreach ($component in $downloads.Keys) {
    Write-Step "Downloading $component"
    $url = $downloads[$component]
    $filename = "$component.zip"
    $filepath = "$downloadDir\$filename"

    try {
        Invoke-WebRequest -Uri $url -OutFile $filepath
        Write-Host "Downloaded $component successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download $component from: $url" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Step 3: Extract and install components
Write-Step "Extracting components"

# Extract ReHLDS
if (Test-Path "$downloadDir\ReHLDS.zip") {
    Expand-Archive -Path "$downloadDir\ReHLDS.zip" -DestinationPath "$downloadDir\ReHLDS" -Force
    Write-Host "ReHLDS extracted" -ForegroundColor Cyan
}

# Extract Metamod-r
if (Test-Path "$downloadDir\Metamod-r.zip") {
    Expand-Archive -Path "$downloadDir\Metamod-r.zip" -DestinationPath "$downloadDir\Metamod-r" -Force
    Write-Host "Metamod-r extracted" -ForegroundColor Cyan
}

# Extract AMX Mod X
if (Test-Path "$downloadDir\AMXModX.zip") {
    Expand-Archive -Path "$downloadDir\AMXModX.zip" -DestinationPath "$baseDir\hlds\cstrike" -Force
    Write-Host "AMX Mod X base extracted" -ForegroundColor Cyan
}

if (Test-Path "$downloadDir\AMXModX-CS.zip") {
    Expand-Archive -Path "$downloadDir\AMXModX-CS.zip" -DestinationPath "$baseDir\hlds\cstrike" -Force
    Write-Host "AMX Mod X CS addon extracted" -ForegroundColor Cyan
}

Write-Step "Setup downloads complete!"
Write-Host "`nNext manual steps required:" -ForegroundColor Yellow
Write-Host "1. Copy ReHLDS files from downloads\ReHLDS\bin\win32\ to hlds\" -ForegroundColor Cyan
Write-Host "2. Copy Metamod-r files from downloads\Metamod-r\ to hlds\cstrike\" -ForegroundColor Cyan
Write-Host "3. Edit liblist.gam to point to metamod.dll" -ForegroundColor Cyan
Write-Host "4. Download and install Zombie Plague and YaPB manually" -ForegroundColor Cyan