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

load_env_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    # shellcheck disable=SC1090
    source "$file"
  fi
}

load_env_file ".golive.env"

mkdir -p artifacts
report="artifacts/go-live-report.md"

required_file() {
  local path="$1"
  [[ -f "$path" ]]
}

is_true() {
  local v="${1:-0}"
  [[ "$v" == "1" || "$v" == "true" || "$v" == "TRUE" || "$v" == "yes" || "$v" == "YES" ]]
}

pass=0
fail=0

declare -a RESULTS

check() {
  local id="$1"
  local desc="$2"
  local ok="$3"

  if [[ "$ok" == "1" ]]; then
    RESULTS+=("| ${id} | ${desc} | ✅ PASS |")
    pass=$((pass + 1))
  else
    RESULTS+=("| ${id} | ${desc} | ❌ FAIL |")
    fail=$((fail + 1))
  fi
}

# A. UI / Delivery
check "A1" "Static export + Pages delivery confirmed" "$(is_true "${CHECK_UI_STATIC_EXPORT:-0}" && echo 1 || echo 0)"
check "A2" "Workers Gateway is sole legal API source" "$(is_true "${CHECK_UI_GATEWAY_SOT:-0}" && echo 1 || echo 0)"

# B. API / Control
check "B1" "Internal APIs protected by admin token" "$(is_true "${CHECK_ADMIN_AUTH:-0}" && echo 1 || echo 0)"
check "B2" "Replay / Retry / DLQ / Manual Review wired" "$(is_true "${CHECK_EXCEPTION_CONTROLS:-0}" && echo 1 || echo 0)"
check "B3" "Audit hook required on all state-changing ops" "$(is_true "${CHECK_AUDIT_HOOKS:-0}" && echo 1 || echo 0)"

# C. Real-Money Readiness
check "C1" "Ledger posting completed" "$(is_true "${CHECK_LEDGER_POSTING:-0}" && echo 1 || echo 0)"
check "C2" "Settlement flow completed" "$(is_true "${CHECK_SETTLEMENT_FLOW:-0}" && echo 1 || echo 0)"
check "C3" "Idempotency + duplicate prevention enabled" "$(is_true "${CHECK_IDEMPOTENCY:-0}" && echo 1 || echo 0)"
check "C4" "Rollback target fixed + smoke test passed" "$(is_true "${CHECK_ROLLBACK_AND_SMOKE:-0}" && echo 1 || echo 0)"
check "C5" "Kill Switch tested" "$(is_true "${CHECK_KILL_SWITCH:-0}" && echo 1 || echo 0)"

# D. Legal / Regulatory
check "D1" "Authority update requests tracked" "$(is_true "${CHECK_AUTHORITY_TRACKING:-0}" && echo 1 || echo 0)"
check "D2" "Receipt / acknowledgement tracked" "$(is_true "${CHECK_ACK_TRACKING:-0}" && echo 1 || echo 0)"
check "D3" "Public listing + official portal refs maintained" "$(is_true "${CHECK_PORTAL_LISTING:-0}" && echo 1 || echo 0)"
check "D4" "Original document hash verification tracked" "$(is_true "${CHECK_DOC_HASH_VERIFICATION:-0}" && echo 1 || echo 0)"

# E. Audit / Compliance
check "E1" "All state transitions logged" "$(is_true "${CHECK_ALL_TRANSITIONS_AUDITED:-0}" && echo 1 || echo 0)"
check "E2" "Correlation/request IDs tracked" "$(is_true "${CHECK_CORRELATION_IDS:-0}" && echo 1 || echo 0)"
check "E3" "Manual vs machine verification separated" "$(is_true "${CHECK_MANUAL_MACHINE_SEPARATION:-0}" && echo 1 || echo 0)"
check "E4" "Recovery path documented" "$(is_true "${CHECK_RECOVERY_PATH:-0}" && echo 1 || echo 0)"

# Repository readiness checks
check "R1" "Runbook exists" "$(required_file docs/07_ops_runbook.md && echo 1 || echo 0)"
check "R2" "Security policy exists" "$(required_file docs/04_security_policy.md && echo 1 || echo 0)"
check "R3" "API contract exists" "$(required_file docs/05_api_contracts.md && echo 1 || echo 0)"

# High-quality doc set enforcement (01-10)
check "R4" "System role doc exists" "$(required_file docs/01_system_role.md && echo 1 || echo 0)"
check "R5" "Business rules doc exists" "$(required_file docs/02_business_rules.md && echo 1 || echo 0)"
check "R6" "State machine doc exists" "$(required_file docs/03_state_machine.md && echo 1 || echo 0)"
check "R7" "Ledger rules doc exists" "$(required_file docs/06_ledger_rules.md && echo 1 || echo 0)"
check "R8" "Prompt library doc exists" "$(required_file docs/08_ai_prompt_library.md && echo 1 || echo 0)"
check "R9" "Compliance policy doc exists" "$(required_file docs/09_compliance_policy.md && echo 1 || echo 0)"
check "R10" "UI behavior doc exists" "$(required_file docs/10_ui_behavior.md && echo 1 || echo 0)"
check "R11" "Bank license original acquisition playbook exists" "$(required_file docs/12_bank_license_original_acquisition.md && echo 1 || echo 0)"
check "R12" "Unified architecture blueprint exists" "$(required_file docs/13_fin_os_unified_architecture.md && echo 1 || echo 0)"
check "R13" "UI/UX + Next.js mapping exists" "$(required_file docs/14_ui_ux_wireframes_and_nextjs_map.md && echo 1 || echo 0)"
check "R14" "Org operating model exists" "$(required_file docs/FIN-OS_ORG_OPERATING_MODEL.md && echo 1 || echo 0)"

{
  echo "# Go-Live Gate Report"
  echo
  echo "- Mode: **${MODE}**"
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo
  echo "| ID | Control | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${RESULTS[@]}"
} > "$report"

echo "Go-Live report written to: ${report}"
cat "$report"

if [[ "$MODE" == "strict" && "$fail" -gt 0 ]]; then
  echo "Strict gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Go-Live gate completed (${MODE})."
