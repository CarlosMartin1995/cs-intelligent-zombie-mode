# Complete CS 1.6 Zombie AI Server Setup
# This script performs a complete installation from scratch

param(
    [Parameter(Mandatory=$false)]
    [string]$HLDSPath = "C:\Projects\cs_zombie_ai\hlds",

    [Parameter(Mandatory=$false)]
    [string]$DownloadsPath = "C:\Projects\cs_zombie_ai\downloads",

    [Parameter(Mandatory=$false)]
    [switch]$SkipHLDS,

    [Parameter(Mandatory=$false)]
    [switch]$SkipDownloadExtraction
)

$ErrorActionPreference = "Stop"
$baseDir = "C:\Projects\cs_zombie_ai"

function Write-Step {
    param($message)
    Write-Host "`n===========================================" -ForegroundColor Cyan
    Write-Host " $message" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Cyan
}

function Test-Prerequisites {
    Write-Step "Checking Prerequisites"

    # Check Python
    try {
        $pythonVersion = python --version 2>&1
        Write-Host "✓ Python installed: $pythonVersion" -ForegroundColor Green
    } catch {
        Write-Warning "Python not found. Please install Python 3.10+"
    }

    # Check downloads folder
    if (-not (Test-Path $DownloadsPath)) {
        Write-Warning "Downloads folder not found at: $DownloadsPath"
        Write-Host "Please ensure you have extracted the resource pack there."
        return $false
    }

    return $true
}

# Main Installation Process
Write-Host @"
=========================================
 CS 1.6 ZOMBIE AI SERVER - COMPLETE SETUP
=========================================
"@ -ForegroundColor Cyan

if (-not (Test-Prerequisites)) {
    Write-Error "Prerequisites check failed. Please fix the issues and try again."
    exit 1
}

# Step 1: Install HLDS (if needed)
if (-not $SkipHLDS) {
    Write-Step "Installing HLDS"

    # Check if SteamCMD exists
    if (-not (Test-Path "$DownloadsPath\steamcmd.exe")) {
        Write-Host "Downloading SteamCMD..."
        & "$baseDir\scripts\download_steamcmd.ps1"
    }

    # Install HLDS
    Write-Host "Installing HLDS (this may take 10-15 minutes)..."
    & "$baseDir\scripts\install_hlds.bat"
}

# Step 2: Extract downloaded resources (if needed)
if (-not $SkipDownloadExtraction) {
    Write-Step "Extracting Resource Files"

    $zipFiles = @(
        "ReHLDS.zip",
        "Metamod-r.zip",
        "yapb-4.5.119-windows.zip",
        "yapb-4.5.1199-extras.zip",
        "zp_plugin_50_patched.zip",
        "zp_resources.zip"
    )

    foreach ($zip in $zipFiles) {
        $zipPath = "$DownloadsPath\$zip"
        if (Test-Path $zipPath) {
            Write-Host "Extracting $zip..."
            $destName = [System.IO.Path]::GetFileNameWithoutExtension($zip)
            Expand-Archive -Path $zipPath -DestinationPath "$DownloadsPath\$destName" -Force -ErrorAction SilentlyContinue
        }
    }
}

# Step 3: Install ReHLDS
Write-Step "Installing ReHLDS"
if (Test-Path "$DownloadsPath\ReHLDS") {
    Write-Host "Copying ReHLDS files..."
    Copy-Item -Path "$DownloadsPath\ReHLDS\*" -Destination $HLDSPath -Recurse -Force
    Write-Host "✓ ReHLDS installed" -ForegroundColor Green
}

# Step 4: Install Metamod-r
Write-Step "Installing Metamod-r"
if (Test-Path "$DownloadsPath\Metamod-r") {
    Write-Host "Installing Metamod-r..."

    # Copy metamod files
    if (-not (Test-Path "$HLDSPath\cstrike\addons")) {
        New-Item -ItemType Directory -Path "$HLDSPath\cstrike\addons" -Force
    }

    Copy-Item -Path "$DownloadsPath\Metamod-r\addons\*" `
              -Destination "$HLDSPath\cstrike\addons\" `
              -Recurse -Force

    Write-Host "✓ Metamod-r installed" -ForegroundColor Green
}

# Step 5: Install AMX Mod X
Write-Step "Installing AMX Mod X"
$amxPath = "$DownloadsPath\amxmod"

if (Test-Path $amxPath) {
    # Extract AMX Mod X base
    $baseZip = Get-ChildItem "$amxPath\*base*.zip" | Select-Object -First 1
    $cstrikeZip = Get-ChildItem "$amxPath\*cstrike*.zip" | Select-Object -First 1

    if ($baseZip -and $cstrikeZip) {
        Write-Host "Extracting AMX Mod X base..."
        Expand-Archive -Path $baseZip.FullName -DestinationPath "$HLDSPath\cstrike" -Force

        Write-Host "Extracting AMX Mod X Counter-Strike addon..."
        Expand-Archive -Path $cstrikeZip.FullName -DestinationPath "$HLDSPath\cstrike" -Force

        Write-Host "✓ AMX Mod X installed" -ForegroundColor Green
    } else {
        Write-Warning "AMX Mod X files not found in $amxPath"
    }
}

# Step 6: Install YaPB
Write-Step "Installing YaPB Bots"
$yapbPath = "$DownloadsPath\yapb-4.5.119-windows"

if (Test-Path $yapbPath) {
    Write-Host "Installing YaPB..."
    Copy-Item -Path "$yapbPath\addons" -Destination "$HLDSPath\cstrike" -Recurse -Force
    Write-Host "✓ YaPB installed" -ForegroundColor Green
}

# Step 7: Install Zombie Plague
Write-Step "Installing Zombie Plague 5.0"
& "$baseDir\scripts\install_zombie_plague.ps1" -HLDSPath $HLDSPath -DownloadsPath $DownloadsPath

# Step 8: Apply configurations
Write-Step "Applying Server Configurations"
& "$baseDir\scripts\apply_configurations.ps1" -HLDSPath $HLDSPath

# Step 9: Copy AI Bridge files
Write-Step "Installing AI Bridge Plugin"
$aiBridgeSource = "$baseDir\addons\amxmodx\scripting\ai_bridge.sma"
$aiBridgeConfigs = "$baseDir\addons\amxmodx\configs"

if (Test-Path $aiBridgeSource) {
    Write-Host "Copying AI Bridge source..."
    Copy-Item -Path $aiBridgeSource `
              -Destination "$HLDSPath\cstrike\addons\amxmodx\scripting\" `
              -Force

    # Compile AI Bridge
    Write-Host "Compiling AI Bridge plugin..."
    Set-Location "$HLDSPath\cstrike\addons\amxmodx\scripting"
    & ".\compile.exe" "ai_bridge.sma" 2>&1 | Out-Null

    if (Test-Path "compiled\ai_bridge.amxx") {
        Copy-Item -Path "compiled\ai_bridge.amxx" `
                  -Destination "$HLDSPath\cstrike\addons\amxmodx\plugins\" `
                  -Force
        Write-Host "✓ AI Bridge compiled and installed" -ForegroundColor Green
    }
}

if (Test-Path $aiBridgeConfigs) {
    Write-Host "Copying AI Bridge configs..."
    Copy-Item -Path "$aiBridgeConfigs\*" `
              -Destination "$HLDSPath\cstrike\addons\amxmodx\configs\" `
              -Recurse -Force
}

# Step 10: Setup Python environment
Write-Step "Setting up Python Environment"
Set-Location "$baseDir\python_sidecar"

if (-not (Test-Path ".venv")) {
    Write-Host "Creating Python virtual environment..."
    python -m venv .venv
}

Write-Host "Installing Python dependencies..."
& ".\.venv\Scripts\pip.exe" install -r requirements.txt -q

Write-Step "Installation Complete!"

Write-Host @"

✅ SERVER SETUP COMPLETE!

Installed Components:
- HLDS with Counter-Strike
- ReHLDS (optimized engine)
- Metamod-r (plugin system)
- AMX Mod X (scripting platform)
- Zombie Plague 5.0 (zombie mod)
- YaPB (bot system)
- AI Bridge (Python integration)

To start the server:

1. Basic Zombie Mode (no AI):
   .\scripts\start_server.bat

2. With AI Features:
   Terminal 1: .\scripts\start_python_sidecar.bat
   Terminal 2: .\scripts\start_server.bat

   Then enable ai_bridge.amxx in plugins.ini

Server Details:
- Name: CS16 Zombie AI Lab
- Port: 27015
- RCON: zombie_ai_2024
- Bots: Auto-add 8 bots

Connect: In CS 1.6 console type 'connect localhost:27015'

"@ -ForegroundColor Green

Set-Location $baseDir