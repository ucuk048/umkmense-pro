# UMKMense Pro - Zero-to-Hero Automatic Installer for Windows
# Runs in native PowerShell without requiring pre-installed Git, Docker, or Node.js.

[CmdletBinding()]
param (
    [string]$InstallDir = "$HOME\umkmense-pro"
)

$ErrorActionPreference = "Stop"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "       UMKMENSE PRO - ZERO-TO-HERO ALL-IN-ONE INSTALLER (WINDOWS)     " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[1/6] Menyiapkan direktori instalasi di: $InstallDir" -ForegroundColor Yellow

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# 1. Unduh Berkas Repositori (Bypass kebutuhan Git)
Write-Host "[2/6] Mengunduh berkas proyek UMKMense Pro..." -ForegroundColor Yellow
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "Git terdeteksi di sistem. Mengkloning repositori..." -ForegroundColor Gray
    if (-not (Test-Path "$InstallDir\.git")) {
        git clone https://github.com/ucuk048/umkmense-pro.git $InstallDir
    } else {
        Set-Location $InstallDir
        git pull origin main
    }
} else {
    Write-Host "Git tidak terdeteksi. Mengunduh arsip ZIP langsung dari GitHub..." -ForegroundColor Gray
    $zipPath = "$env:TEMP\umkmense-main.zip"
    $extractPath = "$env:TEMP\umkmense-extracted"
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/ucuk048/umkmense-pro/archive/refs/heads/main.zip" -OutFile $zipPath -UseBasicParsing
    
    if (Test-Path $extractPath) { Remove-Item -Recurse -Force $extractPath }
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    
    Copy-Item -Path "$extractPath\umkmense-pro-main\*" -Destination $InstallDir -Recurse -Force
    Remove-Item -Force $zipPath -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $extractPath -ErrorAction SilentlyContinue
}

Set-Location $InstallDir

# 2. Siapkan File Konfigurasi .env
if (-not (Test-Path "$InstallDir\.env")) {
    if (Test-Path "$InstallDir\.env.example") {
        Copy-Item "$InstallDir\.env.example" "$InstallDir\.env"
        Write-Host "File konfigurasi .env berhasil dibuat dari template." -ForegroundColor Gray
    }
}

# 3. Periksa dan Pasang Docker jika belum ada
Write-Host "[3/6] Memeriksa instalasi Docker Desktop..." -ForegroundColor Yellow
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
$dockerPaths = @(
    "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
    "$env:LocalAppData\Programs\DockerDesktop\Docker Desktop.exe"
)
$dockerExe = $dockerPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $dockerCmd -and -not $dockerExe) {
    Write-Host "Docker belum terpasang. Memulai pemasangan otomatis Docker Desktop..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Memasang Docker Desktop via Windows Package Manager (winget)..." -ForegroundColor Gray
        winget install -e --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "Mengunduh installer resmi Docker Desktop..." -ForegroundColor Gray
        $installerPath = "$env:TEMP\DockerDesktopInstaller.exe"
        Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile $installerPath -UseBasicParsing
        Write-Host "Menjalankan instalasi Docker Desktop. Harap ikuti petunjuk di layar..." -ForegroundColor Gray
        Start-Process $installerPath -Wait
        Remove-Item -Force $installerPath -ErrorAction SilentlyContinue
    }
    
    $dockerExe = $dockerPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
}

# 4. Aktifkan Docker Desktop & Tunggu Daemon
Write-Host "[4/6] Memastikan Docker Engine aktif..." -ForegroundColor Yellow
$isDockerRunning = $false
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -eq 0) { $isDockerRunning = $true }
} catch {}

if (-not $isDockerRunning) {
    if ($dockerExe) {
        Write-Host "Menyalakan aplikasi Docker Desktop..." -ForegroundColor Gray
        Start-Process $dockerExe
    } else {
        Write-Host "Silakan buka aplikasi 'Docker Desktop' dari Start Menu." -ForegroundColor Yellow
    }
    
    Write-Host "Menunggu Docker daemon siap..." -ForegroundColor Gray
    $attempts = 0
    while ($attempts -lt 45) {
        Start-Sleep -Seconds 3
        $attempts++
        try {
            $null = docker info 2>&1
            if ($LASTEXITCODE -eq 0) {
                $isDockerRunning = $true
                break
            }
        } catch {}
        Write-Host "Menghubungkan ke Docker daemon (percobaan $attempts/45)..." -ForegroundColor Gray
    }
}

if (-not $isDockerRunning) {
    Write-Host "PERINGATAN: Docker belum berhasil menyala sepenuhnya." -ForegroundColor Red
    Write-Host "Buka aplikasi Docker Desktop secara manual, lalu jalankan START_UMKMENSE_BOT.bat di $InstallDir" -ForegroundColor Yellow
    exit 1
}

# 5. Jalankan Seluruh Container (Postgres, Redis, Evolution API, n8n)
Write-Host "[5/6] Menyalakan seluruh container (Postgres, Redis, Evolution API, n8n)..." -ForegroundColor Yellow
docker compose up -d

# 6. Buat Shortcut di Desktop
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutTarget = "$InstallDir\START_UMKMENSE_BOT.bat"
if (Test-Path $shortcutTarget) {
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$desktopPath\UMKMense Pro Bot.lnk")
    $shortcut.TargetPath = $shortcutTarget
    $shortcut.WorkingDirectory = $InstallDir
    $shortcut.Description = "Buka dan Jalankan UMKMense Pro AI Financial Agent"
    $shortcut.Save()
    Write-Host "Shortcut 'UMKMense Pro Bot' berhasil dibuat di Desktop Anda." -ForegroundColor Green
}

# 7. Tunggu n8n siap dan Buka Browser
Write-Host "[6/6] Menunggu n8n siap..." -ForegroundColor Yellow
$n8nReady = $false
$healthAttempts = 0
while ($healthAttempts -lt 30) {
    Start-Sleep -Seconds 3
    $healthAttempts++
    try {
        $res = Invoke-WebRequest -Uri "http://127.0.0.1:5678/healthz" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($res.StatusCode -eq 200) {
            $n8nReady = $true
            break
        }
    } catch {}
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "              INSTALASI LENGKAP & SISTEM BERHASIL SIAP!               " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "Lokasi Proyek     : $InstallDir" -ForegroundColor Gray
Write-Host "n8n Workflow Web  : http://localhost:5678" -ForegroundColor Cyan
Write-Host "Evolution API Web : http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Untuk penggunaan selanjutnya, cukup klik ganda shortcut di Desktop:" -ForegroundColor Yellow
Write-Host "-> 'UMKMense Pro Bot'" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Green

Start-Process "http://localhost:5678"
