# Alertlity By.JustSense - One-line installer
# Usage: irm https://raw.githubusercontent.com/koonpeeza211-hub/Alertlity/main/install.ps1 | iex
# PowerShell 5.1 compatible (no &&, TLS 1.2 forced)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo    = 'koonpeeza211-hub/Alertlity'
$asset   = 'Alertlity.zip'
$destDir = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Alertlity'
$zipPath = Join-Path $env:TEMP 'Alertlity-download.zip'

Write-Host ''
Write-Host '  Alertlity By.JustSense - Installer' -ForegroundColor Yellow
Write-Host '  ----------------------------------' -ForegroundColor DarkGray

# 1) Download latest release
Write-Host '  [1/3] Downloading latest version...' -ForegroundColor Cyan
$url = "https://github.com/$repo/releases/latest/download/$asset"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
$ProgressPreference = 'Continue'

# 2) Extract (preserve data\ if updating over an existing install)
Write-Host "  [2/3] Extracting to $destDir ..." -ForegroundColor Cyan
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }

# Stop running launcher so the exe is not locked
Get-Process -Name 'SenseLauncher' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 500

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    foreach ($entry in $zip.Entries) {
        if ($entry.FullName -match '/$' -or $entry.Name -eq '') { continue }
        $target = Join-Path $destDir $entry.FullName
        $parent = Split-Path $target -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
    }
} finally {
    $zip.Dispose()
}
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# Remove Mark-of-the-Web so SmartScreen does not block the exe/dlls
Get-ChildItem $destDir -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

# 3) Launch
Write-Host '  [3/3] Starting Alertlity...' -ForegroundColor Cyan
Start-Process (Join-Path $destDir 'SenseLauncher.exe') -WorkingDirectory $destDir

Write-Host ''
Write-Host '  Done! Alertlity installed at:' -ForegroundColor Green
Write-Host "  $destDir" -ForegroundColor White
Write-Host ''
