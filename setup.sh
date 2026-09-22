#!/usr/bin/env bash
set -e

echo "======================================================================"
echo "          UMKMENSE PRO - ALL-IN-ONE AUTOMATIC LAUNCHER (LINUX/MAC)    "
echo "======================================================================"
echo ""

# 1. Periksa Docker daemon
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon belum berjalan. Silakan jalankan Docker terlebih dahulu."
    exit 1
fi

# 2. Siapkan file .env jika belum ada
if [ ! -f ".env" ]; then
    echo "Menyiapkan file .env dari .env.example..."
    cp .env.example .env
fi

# 3. Jalankan docker compose
echo "[1/3] Menjalankan seluruh container (Postgres, Redis, Evolution API, n8n)..."
docker compose up -d

# 4. Tunggu n8n siap
echo "[2/3] Menunggu n8n siap (health check)..."
until curl -fsS http://127.0.0.1:5678/healthz >/dev/null 2>&1; do
    sleep 3
done

# 5. Import dan aktifkan workflow
echo "[3/3] Mengimpor workflow UMKMense Pro..."
if [ -f "workflow_tidied.json" ]; then
    docker cp workflow_tidied.json n8n:/tmp/workflow_tidied.json
    docker exec n8n n8n import:workflow --input=/tmp/workflow_tidied.json || true
fi

echo ""
echo "======================================================================"
echo "   SEMUA LAYANAN SIAP DAN BERJALAN."
echo "   - n8n Editor: http://127.0.0.1:5678"
echo "   - Evolution API: http://127.0.0.1:8080"
echo "======================================================================"
