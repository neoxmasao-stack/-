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

if [[ -f .golive.env ]]; then
  # shellcheck disable=SC1091
  source .golive.env
fi

is_true() {
  local v="${1:-0}"
  [[ "$v" == "1" || "$v" == "true" || "$v" == "TRUE" || "$v" == "yes" || "$v" == "YES" ]]
}

mkdir -p artifacts
report="artifacts/identifier-registry-report.md"

pass=0
fail=0
declare -a RESULTS

check() {
  local id="$1"; local desc="$2"; local ok="$3"
  if [[ "$ok" == "1" ]]; then
    RESULTS+=("| ${id} | ${desc} | ✅ PASS |")
    pass=$((pass + 1))
  else
    RESULTS+=("| ${id} | ${desc} | ❌ FAIL |")
    fail=$((fail + 1))
  fi
}

check "I1" "Corporate registry verification completed" "$(is_true "${CHECK_CORPORATE_REGISTRY_VERIFIED:-0}" && echo 1 || echo 0)"
check "I2" "SWIFT/BIC identifier is verified" "$(is_true "${CHECK_SWIFT_BIC_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I3" "IBAN identifier is verified" "$(is_true "${CHECK_IBAN_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I4" "LEI identifier is verified" "$(is_true "${CHECK_LEI_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I5" "全銀( Zengin ) identifier is verified" "$(is_true "${CHECK_ZENGIN_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I6" "Identifier evidence (registry/SWIFT/IBAN/LEI/Zengin) archived" "$(is_true "${CHECK_IDENTIFIER_EVIDENCE_ARCHIVED:-0}" && echo 1 || echo 0)"

{
  echo "# Registry + Identifier Verification Report"
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
  echo "Identifier/registry strict gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Identifier/registry gate completed (${MODE})."
