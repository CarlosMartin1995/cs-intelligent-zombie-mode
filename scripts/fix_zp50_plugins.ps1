# PowerShell script to add ZP50 plugins to plugins.ini

$pluginsIni = "C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\configs\plugins.ini"
$zp50Plugins = "C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\configs\plugins-zp50_ammopacks.ini"

# Read current plugins.ini
$currentContent = Get-Content $pluginsIni

# Check if ZP50 already added
if ($currentContent -match "zp50_core.amxx") {
    Write-Host "ZP50 plugins already in plugins.ini" -ForegroundColor Yellow
    exit
}

# Read ZP50 plugins (filter out comments and empty lines)
$zp50Content = Get-Content $zp50Plugins | Where-Object {
    $_ -and $_ -notmatch '^;' -and $_ -match '\.amxx$'
}

# Append ZP50 plugins to plugins.ini
Add-Content $pluginsIni "`n`n; ============================================"
Add-Content $pluginsIni "; Zombie Plague 5.0 Plugins"
Add-Content $pluginsIni "; ============================================"
Add-Content $pluginsIni ""

foreach ($plugin in $zp50Content) {
    Add-Content $pluginsIni $plugin
    Write-Host "Added: $plugin" -ForegroundColor Green
}

Write-Host "`nSuccessfully added $($zp50Content.Count) ZP50 plugins to plugins.ini!" -ForegroundColor Cyan
Write-Host "Now restart the server to test." -ForegroundColor Yellow