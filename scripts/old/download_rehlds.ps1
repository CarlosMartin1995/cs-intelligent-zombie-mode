# Download and install ReHLDS (optimized HLDS replacement)
$rehldsUrl = "https://github.com/rehlds/ReHLDS/releases/download/3.13.0.788/rehlds-bin-3.13.0.788.zip"
$downloadPath = "C:\Projects\cs_zombie_ai\temp\rehlds.zip"
$extractPath = "C:\Projects\cs_zombie_ai\temp\rehlds"

# Create temp directory
New-Item -ItemType Directory -Force -Path "C:\Projects\cs_zombie_ai\temp"

Write-Host "Downloading ReHLDS..." -ForegroundColor Green
Invoke-WebRequest -Uri $rehldsUrl -OutFile $downloadPath

Write-Host "Extracting ReHLDS..." -ForegroundColor Green
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

Write-Host "ReHLDS downloaded. Now you need to:" -ForegroundColor Yellow
Write-Host "1. First run install_hlds.bat to get base HLDS files" -ForegroundColor Cyan
Write-Host "2. Copy files from $extractPath\bin\win32 to C:\Projects\cs_zombie_ai\hlds\" -ForegroundColor Cyan
Write-Host "3. Copy swds.dll and other DLLs to overwrite HLDS files" -ForegroundColor Cyan