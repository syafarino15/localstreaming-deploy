#!/usr/bin/env bash
# Installs the StayIn Local Side bundle on the mini PC (CasaOS or plain Docker).
# Idempotent: safe to re-run after copying a new bundle through a flashdisk.
#
# Usage: sudo ./scripts/install.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=============================================================="
echo " StayIn Local Side — DLU X ALFATEVE"
echo "=============================================================="

# --- 1. Preconditions -------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker tidak ditemukan. Pasang Docker/CasaOS terlebih dahulu."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: plugin docker compose tidak tersedia."
  exit 1
fi

# --- 2. Load images ---------------------------------------------------------
if compgen -G "images/*.tar" > /dev/null; then
  for image in images/*.tar; do
    echo "==> Loading $image"
    docker load -i "$image"
  done
else
  echo "PERINGATAN: tidak ada file .tar di images/. Compose akan mencoba menarik image."
fi

# --- 3. Environment ---------------------------------------------------------
if [ ! -f .env ]; then
  echo "==> Membuat .env dari contoh"
  cp .env.example .env
  if command -v openssl >/dev/null 2>&1; then
    SECRET="$(openssl rand -hex 32)"
    sed -i "s|replace-with-64-hex-characters-generated-by-openssl-rand-hex-32|${SECRET}|" .env
  fi
  echo "    Silakan ubah password bootstrap pada .env sebelum dipakai produksi."
fi

# shellcheck disable=SC1091
set -a
source .env
set +a

# --- 4. Storage -------------------------------------------------------------
MEDIA_DIR="${MEDIA_HOST_DIR:-./storage}"
mkdir -p "$MEDIA_DIR"/{Movies,Banners,Posters,Apk}
# The container runs as UID 10001; the bind mount must be writable by it.
if [ "$(id -u)" = "0" ]; then
  chown -R 10001:10001 "$MEDIA_DIR" || true
else
  echo "PERINGATAN: jalankan sebagai root agar kepemilikan $MEDIA_DIR dapat diatur."
fi

# --- 5. Start ---------------------------------------------------------------
echo "==> Menjalankan stack"
docker compose up -d

# --- 6. Health --------------------------------------------------------------
echo "==> Menunggu backend siap"
for attempt in $(seq 1 30); do
  if curl -fsS -m 3 "http://127.0.0.1:${BACKEND_PORT:-8080}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
if [ -z "${IP:-}" ]; then
  IP="<ip-mini-pc>"
fi

echo
echo "=============================================================="
echo " Selesai"
echo "--------------------------------------------------------------"
echo " CMS          : http://${IP}/"
echo " API          : http://${IP}/api/v1"
echo " Health       : http://${IP}/healthz"
echo " Storage      : ${MEDIA_DIR}  (Movies, Banners, Posters, Apk)"
echo
echo " Login awal   : ${BOOTSTRAP_TENANT_ADMIN_EMAIL:-admin@dlu-alfateve.local}"
echo " Super admin  : ${BOOTSTRAP_SUPER_ADMIN_EMAIL:-owner@stayin.local}"
echo "=============================================================="
echo
echo "Langkah berikutnya:"
echo "  1. Salin film ke ${MEDIA_DIR}/Movies (boleh dari flashdisk)."
echo "  2. Buka CMS, login sebagai admin mitra, buka menu Management."
echo "  3. Klik 'Scan Storage' atau tunggu pemindaian otomatis berjalan."
echo "  4. Daftarkan TV dengan kode pairing dari menu Devices."
