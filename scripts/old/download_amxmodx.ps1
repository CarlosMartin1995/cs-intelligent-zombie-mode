# Download AMX Mod X with correct URLs
$baseDir = "C:\Projects\cs_zombie_ai"
$downloadDir = "$baseDir\downloads"

Write-Host "Downloading AMX Mod X..." -ForegroundColor Green

# Updated URLs for AMX Mod X
$amxUrls = @{
    "base" = "https://www.amxmodx.org/release/amxmodx-1.10.0-git5475-base-windows.zip"
    "cstrike" = "https://www.amxmodx.org/release/amxmodx-1.10.0-git5475-cstrike-windows.zip"
}

foreach ($type in $amxUrls.Keys) {
    $url = $amxUrls[$type]
    $filename = "amxmodx-$type.zip"
    $filepath = "$downloadDir\$filename"

    try {
        Write-Host "Downloading AMX Mod X $type..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $filepath

        Write-Host "Extracting to HLDS..." -ForegroundColor Cyan
        Expand-Archive -Path $filepath -DestinationPath "$baseDir\hlds\cstrike" -Force

        Write-Host "AMX Mod X $type installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download from: $url" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

Write-Host "`nAMX Mod X installation complete!" -ForegroundColor Green