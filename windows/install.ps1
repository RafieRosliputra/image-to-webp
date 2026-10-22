# image-to-webp (Windows) installer
# Downloads cwebp.exe and registers a "Convert to WebP" SendTo entry.
#
# Usage (one-liner in cmd/PowerShell, run as normal user):
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/RafieRosliputra/image-to-webp/main/windows/install.ps1 | iex"
#
# Or download & run manually:
#   powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = 'Stop'

$Repo      = 'RafieRosliputra/image-to-webp'
$Branch    = 'main'
$InstallDir = Join-Path $env:LOCALAPPDATA 'image-to-webp'
$SendToDir  = Join-Path $env:APPDATA 'Microsoft\Windows\SendTo'

# cwebp Windows binary — downloaded from the official Google libwebp release.
# The libwebp releases are mirrored on GitHub; pinning a known version.
$CwebpVersion = '1.4.0'
$CwebpZip     = "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$CwebpVersion-windows-x64.zip"

Write-Host "==> image-to-webp (Windows) installer" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Create install dir
# ---------------------------------------------------------------------------
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# ---------------------------------------------------------------------------
# 2. Download & extract cwebp.exe
# ---------------------------------------------------------------------------
$cwebpPath = Join-Path $InstallDir 'cwebp.exe'
if (-not (Test-Path $cwebpPath)) {
    Write-Host "==> Downloading cwebp.exe (libwebp $CwebpVersion)..." -ForegroundColor Yellow
    $zip = Join-Path $env:TEMP 'libwebp-windows-x64.zip'
    try {
        Invoke-WebRequest -Uri $CwebpZip -OutFile $zip -UseBasicParsing
    } catch {
        Write-Host "ERROR: Failed to download cwebp. Check your internet connection." -ForegroundColor Red
        Write-Host "       URL: $CwebpZip" -ForegroundColor Red
        exit 1
    }

    $extract = Join-Path $env:TEMP 'libwebp-extract'
    if (Test-Path $extract) { Remove-Item -Recurse -Force $extract }
    Expand-Archive -Path $zip -DestinationPath $extract -Force

    $srcCwebp = Get-ChildItem -Path $extract -Recurse -Filter 'cwebp.exe' | Select-Object -First 1
    if (-not $srcCwebp) {
        Write-Host "ERROR: cwebp.exe not found in the archive." -ForegroundColor Red
        exit 1
    }
    Copy-Item $srcCwebp.FullName $cwebpPath -Force
    Remove-Item -Recurse -Force $extract -ErrorAction SilentlyContinue
    Remove-Item -Force $zip -ErrorAction SilentlyContinue
    Write-Host "    [ok] cwebp.exe installed to $cwebpPath" -ForegroundColor Green
} else {
    Write-Host "    [ok] cwebp.exe already present" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 3. Download the PowerShell converter script
# ---------------------------------------------------------------------------
Write-Host "==> Downloading convert-to-webp.ps1..." -ForegroundColor Yellow
$ps1Url = "https://raw.githubusercontent.com/$Repo/$Branch/windows/convert-to-webp.ps1"
$ps1Path = Join-Path $InstallDir 'convert-to-webp.ps1'
Invoke-WebRequest -Uri $ps1Url -OutFile $ps1Path -UseBasicParsing
Write-Host "    [ok] convert-to-webp.ps1 -> $ps1Path" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 4. Register SendTo entry
# ---------------------------------------------------------------------------
Write-Host "==> Registering 'Send to' entry..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $SendToDir | Out-Null

$cmdContent = @"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "$ps1Path" %*
"@

$cmdPath = Join-Path $SendToDir 'Convert to WebP.cmd'
Set-Content -Path $cmdPath -Value $cmdContent -Encoding ASCII
Write-Host "    [ok] SendTo entry -> $cmdPath" -ForegroundColor Green

Write-Host ""
Write-Host "==> Done! ✓" -ForegroundColor Green
Write-Host "    Right-click any image -> Send to -> Convert to WebP"
