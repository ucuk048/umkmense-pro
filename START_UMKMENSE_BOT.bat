@echo off
setlocal EnableExtensions EnableDelayedExpansion
title UMKMense Pro - Secure Automatic Startup
color 0A

echo ======================================================================
echo           UMKMENSE PRO - ALL-IN-ONE AUTOMATIC LAUNCHER
echo ======================================================================
echo.

:: 1. Periksa apakah Docker Engine berjalan
echo [1/4] Memeriksa status Docker Desktop...
docker info >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Docker Desktop sudah aktif.
    goto docker_ready
)

echo Docker Desktop belum menyala. Memulai Docker Desktop...
start "" "C:\Users\Administrator\AppData\Local\Programs\DockerDesktop\Docker Desktop.exe"
echo Menunggu Docker siap...

:wait_docker
ping -n 6 127.0.0.1 >nul
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Sedang menghubungkan ke Docker daemon...
    goto wait_docker
)
echo Docker Desktop berhasil aktif!

:docker_ready

:: 2. Menyalakan seluruh container (Otomatis pasang & unduh jika belum ada)
echo.
echo [2/4] Memastikan seluruh container aktif (Postgres, Redis, Evolution API, n8n)...
if exist "%~dp0docker-compose.yml" (
    docker compose -f "%~dp0docker-compose.yml" up -d >nul 2>&1
)
for %%C in (evo_postgres evo_redis evolution_api n8n) do (
    docker inspect -f "{{.State.Running}}" %%C >"%TEMP%\umkmense_%%C.state" 2>nul
    set /p CONTAINER_RUNNING=<"%TEMP%\umkmense_%%C.state"
    del /q "%TEMP%\umkmense_%%C.state" >nul 2>&1
    if /I not "!CONTAINER_RUNNING!"=="true" docker start %%C >nul 2>&1
    set "CONTAINER_RUNNING="
)
for %%C in (evo_postgres evo_redis evolution_api n8n) do (
    docker inspect -f "{{.State.Running}}" %%C 2>nul | findstr /I "true" >nul
    if errorlevel 1 (
        echo ERROR: container %%C tidak dapat dijalankan.
        docker ps -a --filter "name=evo" --filter "name=n8n"
        pause
        exit /b 1
    )
)

:: 3. Memastikan n8n terhubung ke jaringan internal Docker
docker network connect evo_net n8n >nul 2>&1

:: 4. Health check layanan (maksimum 150 detik)
echo.
echo [3/5] Menunggu n8n dan Evolution API siap...
set /a health_attempts=0
:wait_health
set /a health_attempts+=1
if %health_attempts% GTR 30 (
    echo ERROR: layanan tidak sehat setelah 150 detik.
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=evo" --filter "name=n8n"
    pause
    exit /b 1
)
curl.exe -fsS http://127.0.0.1:5678/healthz >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto health_sleep
curl.exe -fsS http://127.0.0.1:8080 >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto health_sleep
goto services_ready
:health_sleep
timeout /t 5 /nobreak >nul
goto wait_health
:services_ready
echo n8n dan Evolution API sehat.

:: Pemeliharaan database otomatis (hapus log eksekusi usang agar database tetap ramping)
if exist "%~dp0tools\optimize-n8n-db.ps1" powershell -ExecutionPolicy Bypass -File "%~dp0tools\optimize-n8n-db.ps1" >nul 2>&1
if exist "%~dp0tools\migrate-structured-transaction-metadata.ps1" powershell -ExecutionPolicy Bypass -File "%~dp0tools\migrate-structured-transaction-metadata.ps1" >nul 2>&1
if exist "%~dp0tools\backup-umkmense.ps1" powershell -ExecutionPolicy Bypass -File "%~dp0tools\backup-umkmense.ps1" >nul 2>&1
if exist "%~dp0tools\verify-backup.ps1" powershell -ExecutionPolicy Bypass -File "%~dp0tools\verify-backup.ps1" >nul 2>&1
if exist "%~dp0tools\collect-n8n-errors.ps1" powershell -ExecutionPolicy Bypass -File "%~dp0tools\collect-n8n-errors.ps1" >nul 2>&1
if exist "%~dp0tools\deploy-remediated-v3.ps1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0tools\deploy-remediated-v3.ps1"
    if errorlevel 1 (
        echo ERROR: workflow v35 Ultimate Dewa gagal di-deploy.
        pause
        exit /b 1
    )
)
docker exec n8n node -e "const s = require('/usr/local/lib/node_modules/n8n/node_modules/sqlite3'); const db = new s.Database('/home/node/.n8n/database.sqlite'); db.run('DELETE FROM execution_data WHERE executionId IN (SELECT id FROM execution_entity ORDER BY id DESC LIMIT -1 OFFSET 500)', () => { db.run('DELETE FROM execution_entity WHERE id NOT IN (SELECT executionId FROM execution_data) AND id NOT IN (SELECT id FROM execution_entity ORDER BY id DESC LIMIT 500)', () => db.close()); });" >nul 2>&1

:: 5. Tampilkan status container
echo.
echo [4/5] Status Layanan Aktif:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=evo" --filter "name=n8n"

:: 6. Buka n8n di Browser
echo.
echo [5/5] Membuka n8n di peramban (http://127.0.0.1:5678)...
start http://127.0.0.1:5678

echo.
echo ======================================================================
echo    SEMUA LAYANAN SIAP DAN HEALTH CHECK LULUS.
echo    - Bot WhatsApp: AKTIF (Terkoneksi internal ke n8n)
echo    - Workflow: UMKMense Pro - AI Financial Agent (WhatsApp Edition V35)
echo    - n8n Editor: http://127.0.0.1:5678
echo.
echo    Jendela ini boleh Anda tutup sekarang.
echo ======================================================================
timeout /t 5 >nul 2>&1
endlocal