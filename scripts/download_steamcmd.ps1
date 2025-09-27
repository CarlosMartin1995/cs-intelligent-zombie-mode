# PowerShell script to download and extract SteamCMD
$steamcmdUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$downloadPath = "C:\steamcmd\steamcmd.zip"
$extractPath = "C:\steamcmd"

# Create directory if it doesn't exist
Write-Host "Creating SteamCMD directory..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $extractPath | Out-Null

Write-Host "Downloading SteamCMD..." -ForegroundColor Green
Invoke-WebRequest -Uri $steamcmdUrl -OutFile $downloadPath

Write-Host "Extracting SteamCMD..." -ForegroundColor Green
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

Write-Host "Cleaning up..." -ForegroundColor Green
Remove-Item $downloadPath

Write-Host "SteamCMD installed successfully!" -ForegroundColor Green