# Extract and install AMX Mod X from downloaded files
$baseDir = "C:\Projects\cs_zombie_ai"
$amxDir = "$baseDir\amxmod"
$targetDir = "$baseDir\hlds\cstrike"

Write-Host "Installing AMX Mod X from downloaded files..." -ForegroundColor Green

# Find and extract AMX Mod X zip files
$zipFiles = Get-ChildItem -Path $amxDir -Filter "*.zip"

foreach ($zip in $zipFiles) {
    Write-Host "Extracting $($zip.Name)..." -ForegroundColor Cyan
    try {
        Expand-Archive -Path $zip.FullName -DestinationPath $targetDir -Force
        Write-Host "  Extracted successfully!" -ForegroundColor Green
    } catch {
        Write-Host "  Failed to extract: $_" -ForegroundColor Red
    }
}

# Copy our custom AI Bridge files
Write-Host "`nCopying AI Bridge files..." -ForegroundColor Cyan

# Copy configs
$configSource = "$baseDir\addons\amxmodx\configs"
$configDest = "$targetDir\addons\amxmodx\configs"
if (Test-Path $configDest) {
    Copy-Item -Path "$configSource\*" -Destination $configDest -Force
    Write-Host "  Configs copied!" -ForegroundColor Green
}

# Copy scripting file
$scriptSource = "$baseDir\addons\amxmodx\scripting\ai_bridge.sma"
$scriptDest = "$targetDir\addons\amxmodx\scripting"
if (Test-Path $scriptDest) {
    Copy-Item -Path $scriptSource -Destination $scriptDest -Force
    Write-Host "  AI Bridge source copied!" -ForegroundColor Green
}

Write-Host "`nAMX Mod X installation complete!" -ForegroundColor Green