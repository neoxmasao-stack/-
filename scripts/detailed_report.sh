#!/usr/bin/env bash
set -euo pipefail

GENERATE=0
if [[ "${1:-}" == "--generate" ]]; then
  GENERATE=1
elif [[ -n "${1:-}" ]]; then
  echo "Usage: $0 [--generate]" >&2
  exit 2
fi

if [[ "$GENERATE" == "1" ]]; then
  make ci
fi

mkdir -p artifacts
out="artifacts/detailed-report.md"

reports=(
  artifacts/legal-clean-report.md
  artifacts/go-live-report.md
  artifacts/grand-open-report.md
  artifacts/all-features-report.md
  artifacts/portal-and-external-channel-report.md
  artifacts/identifier-registry-report.md
  artifacts/external-bank-full-journey-report.md
  artifacts/bank-full-journey-module-report.md
  artifacts/official-grand-open-all-features-report.md
)

{
  echo "# Detailed Readiness Report"
  echo
  echo "- Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  for r in "${reports[@]}"; do
    echo "## ${r}"
    if [[ -f "$r" ]]; then
      echo
      cat "$r"
      echo
    else
      echo
      echo "_Missing report: ${r}_"
      echo
    fi
  done
} > "$out"

cat "$out"
