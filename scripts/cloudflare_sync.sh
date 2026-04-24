#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="staging"
DRY_RUN=0

usage() {
  cat <<USAGE
Usage: $0 [--staging|--production] [--dry-run]

Options:
  --staging      Sync to Cloudflare staging environment (default)
  --production   Sync to Cloudflare production environment
  --dry-run      Validate configuration only; do not execute wrangler deploy
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staging)
      ENVIRONMENT="staging"
      ;;
    --production)
      ENVIRONMENT="production"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required to run wrangler." >&2
  exit 1
fi

if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "CLOUDFLARE_API_TOKEN is not set." >&2
  exit 1
fi

if [[ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]]; then
  echo "CLOUDFLARE_ACCOUNT_ID is not set." >&2
  exit 1
fi

if [[ ! -f "wrangler.toml" ]]; then
  echo "wrangler.toml is missing. Add Cloudflare Worker config before sync." >&2
  exit 1
fi

echo "[cloudflare-sync] Environment: ${ENVIRONMENT}"

echo "[cloudflare-sync] Validating Worker configuration..."
npx wrangler deploy --env "${ENVIRONMENT}" --dry-run

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "[cloudflare-sync] Dry run only. Skipping deploy and migrations."
  exit 0
fi

if [[ -d "migrations" ]]; then
  echo "[cloudflare-sync] Applying D1 migrations..."
  npx wrangler d1 migrations apply fin_os --env "${ENVIRONMENT}" --remote
else
  echo "[cloudflare-sync] No ./migrations directory found; skipping D1 migration step."
fi

echo "[cloudflare-sync] Deploying Worker..."
npx wrangler deploy --env "${ENVIRONMENT}"

echo "[cloudflare-sync] Sync completed."
