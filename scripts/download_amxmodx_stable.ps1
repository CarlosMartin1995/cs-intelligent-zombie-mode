# Download AMX Mod X stable version 1.9.0
$baseDir = "C:\Projects\cs_zombie_ai"
$downloadDir = "$baseDir\downloads"

Write-Host "Downloading AMX Mod X stable version 1.9.0..." -ForegroundColor Green

# Use stable 1.9.0 release which is always available
$amxUrls = @{
    "base" = "https://www.amxmodx.org/release/amxmodx-1.9.0-git5271-base-windows.zip"
    "cstrike" = "https://www.amxmodx.org/release/amxmodx-1.9.0-git5271-cstrike-windows.zip"
}

# Alternative: try latest dev build
$amxUrlsDev = @{
    "base" = "https://www.amxmodx.org/amxxdrop/1.10/amxmodx-latest-base-windows.zip"
    "cstrike" = "https://www.amxmodx.org/amxxdrop/1.10/amxmodx-latest-cstrike-windows.zip"
}

foreach ($type in $amxUrls.Keys) {
    $url = $amxUrls[$type]
    $filename = "amxmodx-$type.zip"
    $filepath = "$downloadDir\$filename"

    try {
        Write-Host "Trying stable version for $type..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $filepath

        Write-Host "Extracting to HLDS..." -ForegroundColor Cyan
        Expand-Archive -Path $filepath -DestinationPath "$baseDir\hlds\cstrike" -Force

        Write-Host "AMX Mod X $type installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Stable version failed, trying dev build..." -ForegroundColor Yellow

        # Try dev build
        $urlDev = $amxUrlsDev[$type]
        try {
            Invoke-WebRequest -Uri $urlDev -OutFile $filepath
            Expand-Archive -Path $filepath -DestinationPath "$baseDir\hlds\cstrike" -Force
            Write-Host "AMX Mod X $type (dev) installed successfully!" -ForegroundColor Green
        } catch {
            Write-Host "Both versions failed. Please download manually from:" -ForegroundColor Red
            Write-Host "https://www.amxmodx.org/downloads.php" -ForegroundColor Yellow
        }
    }
}

# Copy our custom configs
Write-Host "`nCopying AI Bridge configs..." -ForegroundColor Cyan
$configSource = "$baseDir\addons\amxmodx\configs"
$configDest = "$baseDir\hlds\cstrike\addons\amxmodx\configs"

if (Test-Path $configDest) {
    Copy-Item -Path "$configSource\*" -Destination $configDest -Force
    Write-Host "Configs copied successfully!" -ForegroundColor Green
}

Write-Host "`nAMX Mod X installation attempt complete!" -ForegroundColor Green