#!/usr/bin/env bash
# UMKMense Pro - Zero-to-Hero Automatic Installer for Linux / macOS
# Can be run with: curl -fsSL https://raw.githubusercontent.com/ucuk048/umkmense-pro/main/install.sh | bash

set -e

INSTALL_DIR="$HOME/umkmense-pro"

echo "======================================================================"
echo "       UMKMENSE PRO - ZERO-TO-HERO ALL-IN-ONE INSTALLER (LINUX/MAC)   "
echo "======================================================================"
echo ""

# 1. Menyiapkan direktori
echo "[1/5] Menyiapkan direktori di $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# 2. Mengunduh kode sumber
echo "[2/5] Mengunduh berkas proyek..."
if command -v git >/dev/null 2>&1; then
    if [ ! -d "$INSTALL_DIR/.git" ]; then
        git clone https://github.com/ucuk048/umkmense-pro.git "$INSTALL_DIR"
    else
        cd "$INSTALL_DIR" && git pull origin main
    fi
else
    echo "Git tidak terdeteksi. Mengunduh arsip ZIP..."
    ZIP_TMP="/tmp/umkmense-main.zip"
    EXTRACT_TMP="/tmp/umkmense-extract"
    curl -fsSL "https://github.com/ucuk048/umkmense-pro/archive/refs/heads/main.zip" -o "$ZIP_TMP"
    mkdir -p "$EXTRACT_TMP"
    unzip -q "$ZIP_TMP" -d "$EXTRACT_TMP"
    cp -r "$EXTRACT_TMP/umkmense-pro-main/"* "$INSTALL_DIR/"
    rm -rf "$ZIP_TMP" "$EXTRACT_TMP"
fi

cd "$INSTALL_DIR"

# 3. Menyiapkan .env
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
fi

# 4. Memeriksa dan Memasang Docker
echo "[3/5] Memeriksa instalasi Docker..."
if ! command -v docker >/dev/null 2>&1; then
    if [ "$(uname)" = "Linux" ]; then
        echo "Docker belum terpasang. Memasang Docker resmi..."
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER" 2>/dev/null || true
        sudo systemctl enable --now docker 2>/dev/null || sudo service docker start 2>/dev/null || true
    else
        echo "Untuk macOS, silakan pasang Docker Desktop: https://www.docker.com/products/docker-desktop/"
        exit 1
    fi
fi

if ! docker info >/dev/null 2>&1; then
    echo "Menjalankan service Docker..."
    sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null || true
    sleep 3
fi

# 5. Menjalankan container
echo "[4/5] Menyalakan seluruh container (Postgres, Redis, Evolution API, n8n)..."
docker compose up -d

# 6. Menunggu n8n siap
echo "[5/5] Menunggu n8n siap..."
until curl -fsS http://127.0.0.1:5678/healthz >/dev/null 2>&1; do
    sleep 3
done

echo ""
echo "======================================================================"
echo "          SEMUA LAYANAN BERHASIL DIJALANKAN DARI NOL!                 "
echo "======================================================================"
echo "Lokasi Folder     : $INSTALL_DIR"
echo "n8n Workflow Web  : http://localhost:5678"
echo "Evolution API Web : http://localhost:8080"
echo "======================================================================"
