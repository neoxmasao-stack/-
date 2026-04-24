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
report="artifacts/external-bank-full-journey-report.md"

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

check "BJ1" "Customer onboarding API external connectivity" "$(is_true "${CHECK_BANK_ONBOARDING_CONNECTIVITY:-0}" && echo 1 || echo 0)"
check "BJ2" "eKYC + AML/Sanctions external verification flow" "$(is_true "${CHECK_BANK_KYC_AML_FLOW:-0}" && echo 1 || echo 0)"
check "BJ3" "Account creation + core ledger bootstrap" "$(is_true "${CHECK_BANK_ACCOUNT_LEDGER_BOOTSTRAP:-0}" && echo 1 || echo 0)"
check "BJ4" "Domestic transfer full lifecycle (init→auth→post→notify)" "$(is_true "${CHECK_BANK_TRANSFER_FULL_LIFECYCLE:-0}" && echo 1 || echo 0)"
check "BJ5" "ATM withdrawal end-to-end flow" "$(is_true "${CHECK_BANK_ATM_FULL_LIFECYCLE:-0}" && echo 1 || echo 0)"
check "BJ6" "Card authorization/capture/reversal lifecycle" "$(is_true "${CHECK_BANK_CARD_FULL_LIFECYCLE:-0}" && echo 1 || echo 0)"
check "BJ7" "Regulatory filing submission + acknowledgement" "$(is_true "${CHECK_BANK_REGULATORY_FILING_ACK:-0}" && echo 1 || echo 0)"
check "BJ8" "Settlement + reconciliation + discrepancy handling" "$(is_true "${CHECK_BANK_SETTLEMENT_RECON:-0}" && echo 1 || echo 0)"
check "BJ9" "Incident + replay/recovery + DR failover validation" "$(is_true "${CHECK_BANK_RECOVERY_DR_FLOW:-0}" && echo 1 || echo 0)"
check "BJ10" "Executive go-live evidence package completed" "$(is_true "${CHECK_BANK_EXEC_SIGNOFF_PACKAGE:-0}" && echo 1 || echo 0)"

{
  echo "# External Connectivity Bank Full Journey Report"
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
  echo "External bank full-journey strict gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "External bank full-journey gate completed (${MODE})."
