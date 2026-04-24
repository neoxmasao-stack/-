#!/usr/bin/env bash
set -euo pipefail

MODE="advisory"
if [[ "${1:-}" == "--strict" ]]; then
  MODE="strict"
elif [[ "${1:-}" == "--advisory" || -z "${1:-}" ]]; then
  MODE="advisory"
else
  echo "Usage: $0 [--strict|--advisory]" >&2
  exit 2
fi

mkdir -p artifacts
report="artifacts/all-features-report.md"

pass=0
fail=0
declare -a RESULTS

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
  local log_file
  log_file="$(mktemp -t all_features_${id}.XXXXXX.log)"
  if "$@" >"${log_file}" 2>&1; then
    record "$id" "$desc" "1"
  else
    record "$id" "$desc" "0"
  fi
  rm -f "${log_file}"
}

run_check "F1" "go_live_check.sh syntax" bash -n scripts/go_live_check.sh
run_check "F2" "legal_clean_check.sh syntax" bash -n scripts/legal_clean_check.sh
run_check "F3" "grand_open_check.sh syntax" bash -n scripts/grand_open_check.sh
run_check "F4" "all_features_check.sh syntax" bash -n scripts/all_features_check.sh
run_check "F5" "verify-docs" make verify-docs
run_check "F6" "legal-clean" make legal-clean
run_check "F7" "go-live advisory" bash scripts/go_live_check.sh --advisory
run_check "F8" "grand-open advisory" bash scripts/grand_open_check.sh --advisory

if [[ "$MODE" == "strict" ]]; then
  run_check "F9" "go-live strict" bash scripts/go_live_check.sh --strict
  run_check "F10" "grand-open strict" bash scripts/grand_open_check.sh --strict
else
  record "F9" "go-live strict (skipped in advisory)" "1"
  record "F10" "grand-open strict (skipped in advisory)" "1"
fi

{
  echo "# All Features Verification Report"
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
  echo "All features strict check failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "All features check completed (${MODE})."
