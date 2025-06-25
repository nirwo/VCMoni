<#
 PowerShell installation script for VCMoni on Windows.
 Usage (run in an elevated PowerShell window if npm/global installs require it):
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   .\install.ps1
#>

$ErrorActionPreference = 'Stop'

Write-Host "[1/2] Installing and building frontend (Vite + Vue)" -ForegroundColor Cyan
Push-Location frontend
npm install
npm run build --if-present
Pop-Location

Write-Host "[2/2] Moving built assets into backend static folder" -ForegroundColor Cyan
if (Test-Path static) { Remove-Item static -Recurse -Force }
New-Item -ItemType Directory -Path static | Out-Null
Copy-Item -Path frontend\dist\* -Destination static -Recurse

Write-Host "`n✅ Installation complete. To start the server:" -ForegroundColor Green
Write-Host "   .\\start.ps1" -ForegroundColor Yellow
Write-Host "PowerCLI modules will auto-install on first server start if missing."
