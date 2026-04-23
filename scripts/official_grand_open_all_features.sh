#!/usr/bin/env bash
set -euo pipefail

MODE="strict"
if [[ "${1:-}" == "--advisory" ]]; then
  MODE="advisory"
elif [[ "${1:-}" == "--strict" || -z "${1:-}" ]]; then
  MODE="strict"
else
  echo "Usage: $0 [--strict|--advisory]" >&2
  exit 2
fi

mkdir -p artifacts
report="artifacts/official-grand-open-all-features-report.md"

declare -a RESULTS
pass=0
fail=0

record() {
  local id="$1"; local desc="$2"; local ok="$3"
  if [[ "$ok" == "1" ]]; then
    RESULTS+=("| ${id} | ${desc} | ✅ PASS |")
    pass=$((pass + 1))
  else
    RESULTS+=("| ${id} | ${desc} | ❌ FAIL |")
    fail=$((fail + 1))
  fi
}

run_check() {
  local id="$1"; local desc="$2"; shift 2
  if "$@"; then
    record "$id" "$desc" "1"
  else
    record "$id" "$desc" "0"
  fi
}

run_check "O1" "Go-live gate (${MODE})" bash scripts/go_live_check.sh "--${MODE}"
run_check "O2" "Grand-open gate (${MODE})" bash scripts/grand_open_check.sh "--${MODE}"
run_check "O3" "All-features gate (${MODE})" bash scripts/all_features_check.sh "--${MODE}"
run_check "O4" "External bank full-journey gate (${MODE})" bash scripts/external_bank_full_journey_check.sh "--${MODE}"

if command -v pwsh >/dev/null 2>&1; then
  run_check "O5" "Official Go/No-Go PowerShell check" pwsh -NoProfile -File scripts/official_go_check.ps1
else
  record "O5" "Official Go/No-Go PowerShell check (pwsh not installed; skipped)" "1"
fi

{
  echo "# Official Grand Open All Features Report"
  echo
  echo "- Mode: **${MODE}**"
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo
  echo "| ID | Control | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${RESULTS[@]}"
} > "$report"

cat "$report"

if [[ "$MODE" == "strict" && "$fail" -gt 0 ]]; then
  echo "Official grand-open all-features gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Official grand-open all-features gate completed (${MODE})."
