# Install and Configure Zombie Plague 5.0
# This script installs ZP50 and compiles necessary plugins

param(
    [Parameter(Mandatory=$false)]
    [string]$HLDSPath = "C:\Projects\cs_zombie_ai\hlds",

    [Parameter(Mandatory=$false)]
    [string]$DownloadsPath = "C:\Projects\cs_zombie_ai\downloads"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param($message)
    Write-Host "`n===========================================" -ForegroundColor Cyan
    Write-Host " $message" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Cyan
}

Write-Step "Installing Zombie Plague 5.0"

# 1. Extract Zombie Plague files
Write-Host "Extracting Zombie Plague files..."
$zpPath = "$DownloadsPath\zp_plugin_50_patched"
if (Test-Path "$zpPath.zip") {
    Expand-Archive -Path "$zpPath.zip" -DestinationPath $DownloadsPath -Force
}

if (Test-Path $zpPath) {
    # Copy ZP files to server
    Write-Host "Copying Zombie Plague files to server..."
    Copy-Item -Path "$zpPath\addons\amxmodx\*" `
              -Destination "$HLDSPath\cstrike\addons\amxmodx\" `
              -Recurse -Force
}

# 2. Extract ZP Resources
Write-Host "Extracting Zombie Plague resources..."
$zpResources = "$DownloadsPath\zp_resources.zip"
if (Test-Path $zpResources) {
    Expand-Archive -Path $zpResources -DestinationPath "$HLDSPath\cstrike" -Force
}

# 3. Compile essential ZP50 plugins
Write-Step "Compiling Zombie Plague Plugins"

$scriptingPath = "$HLDSPath\cstrike\addons\amxmodx\scripting"
Set-Location $scriptingPath

# Create compiled directory if it doesn't exist
if (-not (Test-Path "$scriptingPath\zp50\compiled")) {
    New-Item -ItemType Directory -Path "$scriptingPath\zp50\compiled" -Force
}

# List of essential plugins to compile
$plugins = @(
    "zp50_core",
    "zp50_gamemodes",
    "zp50_ammopacks",
    "zp50_items",
    "zp50_class_human",
    "zp50_class_zombie",
    "zp50_class_human_classic",
    "zp50_class_zombie_classic",
    "zp50_gamemode_infection",
    "zp50_gamemode_nemesis",
    "zp50_gamemode_survivor",
    "zp50_gamemode_swarm",
    "zp50_gamemode_multi",
    "zp50_gamemode_plague",
    "zp50_class_nemesis",
    "zp50_class_survivor",
    "zp50_zombie_features",
    "zp50_human_armor",
    "zp50_zombie_sounds",
    "zp50_hud_info",
    "zp50_effects_infect",
    "zp50_effects_cure",
    "zp50_knockback",
    "zp50_leap",
    "zp50_nightvision",
    "zp50_flashlight",
    "zp50_deathmatch",
    "zp50_spawn_protection",
    "zp50_buy_menus",
    "zp50_admin_menu",
    "zp50_main_menu"
)

foreach ($plugin in $plugins) {
    Write-Host "Compiling $plugin.sma..."
    & ".\compile.exe" "zp50\$plugin.sma" 2>&1 | Out-Null
}

# 4. Copy compiled plugins to plugins folder
Write-Host "Installing compiled plugins..."
$compiledPlugins = Get-ChildItem "$scriptingPath\zp50\compiled\*.amxx" -ErrorAction SilentlyContinue
if ($compiledPlugins) {
    Copy-Item -Path "$scriptingPath\zp50\compiled\*.amxx" `
              -Destination "$HLDSPath\cstrike\addons\amxmodx\plugins\" `
              -Force
    Write-Host "Installed $($compiledPlugins.Count) Zombie Plague plugins" -ForegroundColor Green
}

Write-Step "Zombie Plague Installation Complete!"
Write-Host @"
Zombie Plague 5.0 has been installed with the following features:
- Core system and API
- Multiple game modes (Infection, Nemesis, Survivor, Swarm, Multi, Plague)
- Human and Zombie classes
- Special effects and features
- Admin and player menus

To enable Zombie Plague:
1. Make sure these plugins are listed in plugins.ini:
   - zp50_core.amxx
   - zp50_gamemode_infection.amxx (minimum)
2. Restart the server
"@ -ForegroundColor Yellow