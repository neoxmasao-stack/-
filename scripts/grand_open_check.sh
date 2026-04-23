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

[[ -f .golive.env ]] && source .golive.env

mkdir -p artifacts
report="artifacts/grand-open-report.md"

is_true() {
  local v="${1:-0}"
  [[ "$v" == "1" || "$v" == "true" || "$v" == "TRUE" || "$v" == "yes" || "$v" == "YES" ]]
}

required_file() {
  [[ -f "$1" ]]
}

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

check "G1" "Bank API connectivity validated" "$(is_true "${CHECK_BANK_API_CONNECTIVITY:-0}" && echo 1 || echo 0)"
check "G2" "RTGS/CBDC connectivity validated" "$(is_true "${CHECK_RTGS_CBDC_CONNECTIVITY:-0}" && echo 1 || echo 0)"
check "G3" "External ACK finality control validated" "$(is_true "${CHECK_EXTERNAL_ACK_FINALITY:-0}" && echo 1 || echo 0)"
check "G4" "Card processor E2E validated" "$(is_true "${CHECK_CARD_PROCESSOR_E2E:-0}" && echo 1 || echo 0)"
check "G5" "ATM network E2E validated" "$(is_true "${CHECK_ATM_NETWORK_E2E:-0}" && echo 1 || echo 0)"
check "G6" "AML/Sanctions blocking path validated" "$(is_true "${CHECK_AML_SANCTIONS_PATH:-0}" && echo 1 || echo 0)"
check "G7" "eKYC fallback/retry validated" "$(is_true "${CHECK_EKYC_FALLBACK:-0}" && echo 1 || echo 0)"
check "G8" "Critical notification delivery validated" "$(is_true "${CHECK_NOTIFICATION_DELIVERY:-0}" && echo 1 || echo 0)"
check "G9" "SIEM forwarding validated" "$(is_true "${CHECK_SIEM_FORWARDING:-0}" && echo 1 || echo 0)"
check "G10" "Replay/recovery run validated" "$(is_true "${CHECK_REPLAY_RECOVERY_DRILL:-0}" && echo 1 || echo 0)"
check "G11" "DR failover drill validated" "$(is_true "${CHECK_DR_FAILOVER_DRILL:-0}" && echo 1 || echo 0)"
check "G12" "Executive go-live signoff captured" "$(is_true "${CHECK_EXECUTIVE_SIGNOFF:-0}" && echo 1 || echo 0)"

check "R22" "External connectivity grand-open checklist exists" "$(required_file docs/22_external_connectivity_grand_open_checklist.md && echo 1 || echo 0)"

{
  echo "# Grand Open External Connectivity Report"
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
  echo "Grand-open strict gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Grand-open gate completed (${MODE})."
