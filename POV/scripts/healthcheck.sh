#!/usr/bin/env bash
# Prints a one screen health summary of the running bundle.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

BACKEND_PORT="${BACKEND_PORT:-8080}"
DB_CONTAINER="$(docker compose ps -q postgres 2>/dev/null || true)"

echo "== containers =="
docker compose ps

echo
echo "== backend health =="
if ! curl -fsS -m 5 "http://127.0.0.1:${BACKEND_PORT}/healthz"; then
  echo "backend tidak merespons"
fi

echo
echo "== media =="
MEDIA_DIR="${MEDIA_HOST_DIR:-./storage}"
if [ -d "$MEDIA_DIR" ]; then
  du -sh "$MEDIA_DIR" 2>/dev/null || true
  find "$MEDIA_DIR/Movies" -maxdepth 3 -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.m3u8' \) 2>/dev/null | wc -l | awk '{print "file video: "$1}'
else
  echo "folder media tidak ditemukan: $MEDIA_DIR"
fi

echo
echo "== database =="
if [ -n "$DB_CONTAINER" ]; then
  docker exec "$DB_CONTAINER" psql -U "${POSTGRES_USER:-stayin}" -d "${POSTGRES_DB:-stayin}" -tAc \
    "select 'tenants='||(select count(*) from mst_tenants)||' rooms='||(select count(*) from mst_rooms)||' devices='||(select count(*) from mst_tv_devices)||' movies='||(select count(*) from mst_movies);" 2>/dev/null || echo "query gagal"
else
  echo "container postgres tidak berjalan"
fi
