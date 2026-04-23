#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-list}"
mkdir -p artifacts

write_list_report() {
  cat > artifacts/official-live-fire-feature-list.md <<'MD'
# Official Live-Fire Full Feature List

## Core gates
- `make check-go-live` (strict)
- `make grand-open-check-strict` (strict)
- `make all-features-check-strict` (strict)
- `make official-grand-open-all-features` (strict orchestrator)

## External connectivity (bank full journey)
- `make external-bank-full-journey-check-strict`
- `make bank-full-journey-module-check-strict`
- Report: `artifacts/external-bank-full-journey-report.md`
- Report: `artifacts/bank-full-journey-module-report.md`

## Legal and docs prerequisites
- `make verify-docs`
- `make legal-clean`

## Cloudflare / deployment helpers
- `make cloudflare-sync-dry-run`
- `make cloudflare-sync-staging`
- `make cloudflare-sync-production`

## Primary reports
- `artifacts/go-live-report.md`
- `artifacts/grand-open-report.md`
- `artifacts/all-features-report.md`
- `artifacts/official-grand-open-all-features-report.md`
- `artifacts/external-bank-full-journey-report.md`
MD

  cat artifacts/official-live-fire-feature-list.md
}

run_live_fire() {
  if [[ "${OFFICIAL_LIVE_FIRE_APPROVED:-}" != "YES" ]]; then
    echo "Refusing to run official live-fire strict checks." >&2
    echo "Set OFFICIAL_LIVE_FIRE_APPROVED=YES to confirm production official live-fire execution." >&2
    exit 2
  fi

  {
    echo "# Official Live-Fire Execution"
    echo
    echo "- Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Approved: OFFICIAL_LIVE_FIRE_APPROVED=YES"
  } > artifacts/official-live-fire-execution.md

  if make official-grand-open-all-features; then
    echo "- Result: PASS" >> artifacts/official-live-fire-execution.md
  else
    echo "- Result: FAIL" >> artifacts/official-live-fire-execution.md
    cat artifacts/official-live-fire-execution.md
    exit 1
  fi

  echo "- Finished: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> artifacts/official-live-fire-execution.md
  cat artifacts/official-live-fire-execution.md
}

case "$ACTION" in
  list)
    write_list_report
    ;;
  run)
    run_live_fire
    ;;
  *)
    echo "Usage: $0 [list|run]" >&2
    exit 2
    ;;
esac
