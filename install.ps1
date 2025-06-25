<#
 PowerShell installation script for VCMoni on Windows.
 Usage (run in an elevated PowerShell window if npm/global installs require it):
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   .\install.ps1
#>

$ErrorActionPreference = 'Stop'

Write-Host "[1/4] Creating Python venv (.venv)" -ForegroundColor Cyan
python -m venv .venv

Write-Host "[2/4] Activating venv & installing Python dependencies" -ForegroundColor Cyan
& .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host "[3/4] Installing and building frontend (Vite + Vue)" -ForegroundColor Cyan
Push-Location frontend
npm install
npm run build --if-present
Pop-Location

Write-Host "[4/4] Moving built assets into backend static folder" -ForegroundColor Cyan
if (Test-Path static) { Remove-Item static -Recurse -Force }
New-Item -ItemType Directory -Path static | Out-Null
Copy-Item -Path frontend\dist\* -Destination static -Recurse

Write-Host "`n✅ Installation complete. To start the server:" -ForegroundColor Green
Write-Host "   .\\start.ps1" -ForegroundColor Yellow
