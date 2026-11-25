#!/usr/bin/env bash
# Builds the release images and exports them to images/ so the bundle can be
# copied to a mini PC through a flashdisk and installed without internet.
#
# Usage: ./scripts/export-images.sh [version]
set -euo pipefail

VERSION="${1:-1.0.0}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGES_DIR="$ROOT/images"

mkdir -p "$IMAGES_DIR"

echo "==> Building backend image stayin/backend:${VERSION}"
docker build -t "stayin/backend:${VERSION}" "$ROOT/../Backend"

echo "==> Building web image stayin/web:${VERSION}"
docker build -t "stayin/web:${VERSION}" "$ROOT/../Frontend"

echo "==> Pulling postgres:16-alpine"
docker pull postgres:16-alpine

echo "==> Saving images"
docker save "stayin/backend:${VERSION}" -o "${IMAGES_DIR}/stayin-backend-${VERSION}.tar"
docker save "stayin/web:${VERSION}"     -o "${IMAGES_DIR}/stayin-web-${VERSION}.tar"
docker save postgres:16-alpine          -o "${IMAGES_DIR}/postgres-16-alpine.tar"

if [ -f "$ROOT/../TVApp/dist/stayin-tv.apk" ]; then
  cp "$ROOT/../TVApp/dist/stayin-tv.apk" "${IMAGES_DIR}/stayin-tv-${VERSION}.apk"
fi

echo
echo "Bundle siap di: $ROOT"
ls -lh "$IMAGES_DIR"
echo
echo "Salin seluruh folder POV ke flashdisk, lalu jalankan scripts/install.sh di mini PC."
