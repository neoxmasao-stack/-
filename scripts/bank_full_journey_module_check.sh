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
report="artifacts/bank-full-journey-module-report.md"

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

check "BM1" "Module: Customer onboarding + identity" "$(is_true "${CHECK_BANK_MODULE_ONBOARDING_IDENTITY:-0}" && echo 1 || echo 0)"
check "BM2" "Module: Compliance (KYC/AML/Sanctions)" "$(is_true "${CHECK_BANK_MODULE_COMPLIANCE:-0}" && echo 1 || echo 0)"
check "BM3" "Module: Ledger + account lifecycle" "$(is_true "${CHECK_BANK_MODULE_LEDGER_ACCOUNT:-0}" && echo 1 || echo 0)"
check "BM4" "Module: Transfer E2E + external confirmation" "$(is_true "${CHECK_BANK_MODULE_TRANSFER_E2E:-0}" && echo 1 || echo 0)"
check "BM5" "Module: ATM + card channel operations" "$(is_true "${CHECK_BANK_MODULE_CHANNELS_ATM_CARD:-0}" && echo 1 || echo 0)"
check "BM6" "Module: Regulatory filing + legal evidence" "$(is_true "${CHECK_BANK_MODULE_REGULATORY_EVIDENCE:-0}" && echo 1 || echo 0)"
check "BM7" "Module: Settlement + reconciliation" "$(is_true "${CHECK_BANK_MODULE_SETTLEMENT_RECON:-0}" && echo 1 || echo 0)"
check "BM8" "Module: Incident / recovery / DR" "$(is_true "${CHECK_BANK_MODULE_RECOVERY_DR:-0}" && echo 1 || echo 0)"
check "BM9" "Module: Executive sign-off package" "$(is_true "${CHECK_BANK_MODULE_EXEC_SIGNOFF:-0}" && echo 1 || echo 0)"

{
  echo "# Bank Full Journey Module Report"
  echo
  echo "- Mode: **${MODE}**"
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo
  echo "| ID | Module | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${RESULTS[@]}"
} > "$report"

cat "$report"

if [[ "$MODE" == "strict" && "$fail" -gt 0 ]]; then
  echo "Bank full-journey module strict gate failed: ${fail} modules are not satisfied." >&2
  exit 1
fi

echo "Bank full-journey module gate completed (${MODE})."
