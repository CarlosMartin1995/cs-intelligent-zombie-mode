# Apply Server Configurations Script
# This script applies all necessary configurations after HLDS installation

param(
    [Parameter(Mandatory=$false)]
    [string]$HLDSPath = "C:\Projects\cs_zombie_ai\hlds"
)

$ErrorActionPreference = "Stop"
$configsPath = "C:\Projects\cs_zombie_ai\configs"

function Write-Step {
    param($message)
    Write-Host "`n===========================================" -ForegroundColor Cyan
    Write-Host " $message" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Cyan
}

Write-Step "Applying Server Configurations"

# 1. Copy liblist.gam (enables Metamod)
Write-Host "Configuring Metamod in liblist.gam..."
Copy-Item -Path "$configsPath\liblist.gam" -Destination "$HLDSPath\cstrike\" -Force

# 2. Copy server.cfg
Write-Host "Copying server configuration..."
Copy-Item -Path "$configsPath\server.cfg" -Destination "$HLDSPath\cstrike\" -Force

# 3. Configure Metamod plugins
Write-Host "Configuring Metamod plugins..."
Copy-Item -Path "$configsPath\metamod\plugins.ini" -Destination "$HLDSPath\cstrike\addons\metamod\" -Force

# 4. Configure AMX Mod X
Write-Host "Configuring AMX Mod X plugins..."
Copy-Item -Path "$configsPath\amxmodx\plugins.ini" -Destination "$HLDSPath\cstrike\addons\amxmodx\configs\" -Force
Copy-Item -Path "$configsPath\amxmodx\modules.ini" -Destination "$HLDSPath\cstrike\addons\amxmodx\configs\" -Force

# 5. Add YaPB configuration
Write-Host "Adding YaPB bot configuration..."
$yapbConfig = @'

// Zombie Mode Bot Configuration
// Auto-add bots when server starts
yb_quota 8
yb_quota_mode fill

// Bot difficulty (1-4, where 4 is hardest)
yb_difficulty 3

// Allow bots to use all weapons
yb_restricted_weapons ""

// Disable bot chat for cleaner testing
yb_chat 0

// Ignore enemies at spawn for Zombie Plague
yb_ignore_enemies_after_spawn_time 5
'@

Add-Content -Path "$HLDSPath\cstrike\addons\yapb\conf\yapb.cfg" -Value $yapbConfig -ErrorAction SilentlyContinue

Write-Step "Configuration Complete!"
Write-Host "All configurations have been applied successfully." -ForegroundColor Green