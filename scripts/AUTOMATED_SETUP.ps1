# CS 1.6 Zombie AI Server - Automated Setup Script
# This script assumes downloads folder contains all necessary files

param(
    [Parameter(Mandatory=$false)]
    [string]$HLDSPath = "",

    [Parameter(Mandatory=$false)]
    [switch]$SkipHLDS,

    [Parameter(Mandatory=$false)]
    [string]$DownloadsPath = "C:\Projects\cs_zombie_ai\downloads"
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

    # Check downloads folder
    if (-not (Test-Path $DownloadsPath)) {
        throw "Downloads folder not found at: $DownloadsPath"
    }

    # Check required files
    $requiredFiles = @(
        "$DownloadsPath\ReHLDS.zip",
        "$DownloadsPath\Metamod-r.zip",
        "$DownloadsPath\amxmod\amxmodx-1.9.0-git5294-base-windows.zip",
        "$DownloadsPath\amxmod\amxmodx-1.9.0-git5294-cstrike-windows.zip",
        "$DownloadsPath\yapb-4.5.1199-windows.zip",
        "$DownloadsPath\yapb-4.5.1199-extras.zip",
        "$DownloadsPath\zp_plugin_50_patched.zip",
        "$DownloadsPath\zp_resources.zip"
    )

    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            Write-Host "Missing: $file" -ForegroundColor Red
            throw "Required file missing"
        }
    }

    Write-Host "All required files found!" -ForegroundColor Green
}

function Install-HLDS {
    Write-Step "Installing HLDS"

    if ($SkipHLDS) {
        Write-Host "Skipping HLDS installation (assumed already installed)" -ForegroundColor Yellow
        return
    }

    if ($HLDSPath -and (Test-Path $HLDSPath)) {
        Write-Host "Copying existing HLDS from: $HLDSPath" -ForegroundColor Cyan
        Copy-Item -Path "$HLDSPath\*" -Destination "$baseDir\hlds" -Recurse -Force
    } else {
        Write-Host "Installing HLDS via SteamCMD..." -ForegroundColor Cyan
        $steamcmdPath = "$DownloadsPath\steamcmd.exe"

        if (-not (Test-Path $steamcmdPath)) {
            throw "SteamCMD not found. Please download it first."
        }

        & $steamcmdPath +login anonymous +force_install_dir "$baseDir\hlds" +app_update 90 validate +quit
    }

    if (-not (Test-Path "$baseDir\hlds\cstrike")) {
        throw "HLDS installation failed - cstrike folder not found"
    }
}

function Install-ReHLDS {
    Write-Step "Installing ReHLDS"

    # Extract ReHLDS
    Expand-Archive -Path "$DownloadsPath\ReHLDS.zip" -DestinationPath "$baseDir\temp\ReHLDS" -Force

    # Copy ReHLDS files
    $rehldsFiles = "$baseDir\temp\ReHLDS\bin\win32\*"
    Copy-Item -Path $rehldsFiles -Destination "$baseDir\hlds" -Recurse -Force

    Write-Host "ReHLDS installed successfully!" -ForegroundColor Green
}

function Install-Metamod {
    Write-Step "Installing Metamod-r"

    # Extract Metamod
    Expand-Archive -Path "$DownloadsPath\Metamod-r.zip" -DestinationPath "$baseDir\temp\Metamod" -Force

    # Copy Metamod files
    $metamodSource = "$baseDir\temp\Metamod\addons"
    $metamodDest = "$baseDir\hlds\cstrike\addons"

    New-Item -ItemType Directory -Force -Path $metamodDest | Out-Null
    Copy-Item -Path "$metamodSource\*" -Destination $metamodDest -Recurse -Force

    # Update liblist.gam
    $liblistPath = "$baseDir\hlds\cstrike\liblist.gam"
    if (Test-Path $liblistPath) {
        $content = Get-Content $liblistPath -Raw
        $content = $content -replace 'gamedll\s+"[^"]*"', 'gamedll "addons\metamod\dlls\metamod.dll"'
        Set-Content -Path $liblistPath -Value $content
    }

    Write-Host "Metamod-r installed successfully!" -ForegroundColor Green
}

function Install-AMXModX {
    Write-Step "Installing AMX Mod X"

    # Extract AMX Mod X Base
    Expand-Archive -Path "$DownloadsPath\amxmod\amxmodx-1.9.0-git5294-base-windows.zip" `
                   -DestinationPath "$baseDir\hlds\cstrike" -Force

    # Extract AMX Mod X CS addon
    Expand-Archive -Path "$DownloadsPath\amxmod\amxmodx-1.9.0-git5294-cstrike-windows.zip" `
                   -DestinationPath "$baseDir\hlds\cstrike" -Force

    # Create Metamod plugins.ini
    $pluginsContent = @"
win32 addons\amxmodx\dlls\amxmodx_mm.dll
win32 addons\yapb\bin\yapb.dll
"@
    Set-Content -Path "$baseDir\hlds\cstrike\addons\metamod\plugins.ini" -Value $pluginsContent

    Write-Host "AMX Mod X installed successfully!" -ForegroundColor Green
}

function Install-ZombiePlague {
    Write-Step "Installing Zombie Plague"

    # Extract Zombie Plague plugin
    Expand-Archive -Path "$DownloadsPath\zp_plugin_50_patched.zip" `
                   -DestinationPath "$baseDir\temp\zp" -Force

    # Extract resources (models, sounds, sprites)
    Expand-Archive -Path "$DownloadsPath\zp_resources.zip" `
                   -DestinationPath "$baseDir\hlds\cstrike" -Force

    # Copy plugin files
    $zpPlugin = Get-ChildItem -Path "$baseDir\temp\zp" -Filter "*.amxx" -Recurse
    if ($zpPlugin) {
        Copy-Item -Path $zpPlugin.FullName -Destination "$baseDir\hlds\cstrike\addons\amxmodx\plugins\" -Force
    }

    # Update plugins.ini
    $pluginsIniPath = "$baseDir\hlds\cstrike\addons\amxmodx\configs\plugins.ini"
    $pluginsContent = Get-Content $pluginsIniPath -Raw
    if ($pluginsContent -notmatch "zombie_plague") {
        Add-Content -Path $pluginsIniPath -Value "`n; Zombie Plague`nzombie_plague50.amxx"
    }

    Write-Host "Zombie Plague installed successfully!" -ForegroundColor Green
}

function Install-YaPB {
    Write-Step "Installing YaPB"

    # Extract YaPB main
    Expand-Archive -Path "$DownloadsPath\yapb-4.5.1199-windows.zip" `
                   -DestinationPath "$baseDir\hlds\cstrike\addons\yapb" -Force

    # Extract YaPB extras (waypoints)
    Expand-Archive -Path "$DownloadsPath\yapb-4.5.1199-extras.zip" `
                   -DestinationPath "$baseDir\hlds\cstrike\addons\yapb" -Force

    Write-Host "YaPB installed successfully!" -ForegroundColor Green
}

function Install-AIBridge {
    Write-Step "Installing AI Bridge Plugin"

    # Copy AI Bridge source
    $aiBridgeSource = "$baseDir\addons\amxmodx\scripting\ai_bridge.sma"
    $aiBridgeDest = "$baseDir\hlds\cstrike\addons\amxmodx\scripting"

    if (Test-Path $aiBridgeSource) {
        Copy-Item -Path $aiBridgeSource -Destination $aiBridgeDest -Force

        # Compile plugin
        $compilerPath = "$aiBridgeDest\compile.exe"
        if (Test-Path $compilerPath) {
            Push-Location $aiBridgeDest
            & $compilerPath "ai_bridge.sma"
            Pop-Location

            # Copy compiled plugin
            $compiledPlugin = "$aiBridgeDest\compiled\ai_bridge.amxx"
            if (Test-Path $compiledPlugin) {
                Copy-Item -Path $compiledPlugin -Destination "$baseDir\hlds\cstrike\addons\amxmodx\plugins\" -Force
            }
        }
    }

    # Copy AI Bridge configs
    $configSource = "$baseDir\addons\amxmodx\configs"
    $configDest = "$baseDir\hlds\cstrike\addons\amxmodx\configs"

    if (Test-Path $configSource) {
        Copy-Item -Path "$configSource\*" -Destination $configDest -Force
    }

    # Update plugins.ini
    $pluginsIniPath = "$baseDir\hlds\cstrike\addons\amxmodx\configs\plugins.ini"
    $pluginsContent = Get-Content $pluginsIniPath -Raw
    if ($pluginsContent -notmatch "ai_bridge") {
        Add-Content -Path $pluginsIniPath -Value "`n; AI Bridge`nai_bridge.amxx"
    }

    Write-Host "AI Bridge installed successfully!" -ForegroundColor Green
}

function Create-ServerConfig {
    Write-Step "Creating Server Configuration"

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
sv_airaccelerate 10

// Zombie Plague Settings
zp_delay 10
zp_zombie_first_hp 2000
zp_human_damage_reward 500

// Bot Settings
yb_quota 10
yb_difficulty 2
yb_chat 0

// Load AI Bridge settings
exec addons/amxmodx/configs/ai_bridge.cfg
"@

    Set-Content -Path "$baseDir\hlds\cstrike\server.cfg" -Value $serverCfg
    Write-Host "Server configuration created!" -ForegroundColor Green
}

function Setup-Python {
    Write-Step "Setting up Python Environment"

    $pythonDir = "$baseDir\python_sidecar"
    if (Test-Path $pythonDir) {
        Push-Location $pythonDir

        # Create virtual environment
        python -m venv .venv

        # Activate and install packages
        & .\.venv\Scripts\Activate.ps1
        pip install -r requirements.txt

        Pop-Location
        Write-Host "Python environment setup complete!" -ForegroundColor Green
    } else {
        Write-Host "Python sidecar directory not found, skipping..." -ForegroundColor Yellow
    }
}

function Cleanup {
    Write-Step "Cleaning up temporary files"

    if (Test-Path "$baseDir\temp") {
        Remove-Item -Path "$baseDir\temp" -Recurse -Force
    }

    Write-Host "Cleanup complete!" -ForegroundColor Green
}

# Main execution
try {
    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host "  CS 1.6 ZOMBIE AI SERVER SETUP" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Magenta

    Test-Prerequisites
    Install-HLDS
    Install-ReHLDS
    Install-Metamod
    Install-AMXModX
    Install-ZombiePlague
    Install-YaPB
    Install-AIBridge
    Create-ServerConfig
    Setup-Python
    Cleanup

    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  INSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Start Python AI: scripts\start_python_sidecar.bat" -ForegroundColor Cyan
    Write-Host "2. Start CS Server: scripts\start_server.bat" -ForegroundColor Cyan
    Write-Host "3. Connect: launch CS 1.6 and type 'connect localhost'" -ForegroundColor Cyan

} catch {
    Write-Host "`nERROR: $_" -ForegroundColor Red
    exit 1
}