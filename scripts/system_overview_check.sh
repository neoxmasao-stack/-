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
report='artifacts/system-overview-report.md'

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

required_docs=(
  docs/01_system_role.md
  docs/02_business_rules.md
  docs/03_state_machine.md
  docs/04_security_policy.md
  docs/05_api_contracts.md
  docs/06_ledger_rules.md
  docs/07_ops_runbook.md
  docs/10_ui_behavior.md
  docs/13_fin_os_unified_architecture.md
  docs/14_ui_ux_wireframes_and_nextjs_map.md
  docs/15_gateway_contracts_and_licensing_workflow.md
  docs/FIN-OS_ORG_OPERATING_MODEL.md
  docs/26_fin_os_final_architecture_compendium.md
)

for f in "${required_docs[@]}"; do
  check "D-$(basename "$f" .md)" "Required overview doc exists: ${f}" "$([[ -f "$f" ]] && echo 1 || echo 0)"
done

check "K1" "Architecture doc includes system blueprint keyword" "$([[ -f docs/13_fin_os_unified_architecture.md ]] && rg -qi 'architecture|blueprint|gateway' docs/13_fin_os_unified_architecture.md && echo 1 || echo 0)"
check "K2" "Operating model includes role/accountability keyword" "$([[ -f docs/FIN-OS_ORG_OPERATING_MODEL.md ]] && rg -qi 'role|responsibility|approval' docs/FIN-OS_ORG_OPERATING_MODEL.md && echo 1 || echo 0)"
check "K3" "Final compendium includes integration keyword" "$([[ -f docs/26_fin_os_final_architecture_compendium.md ]] && rg -qi 'integration|end-to-end|architecture|compendium|final' docs/26_fin_os_final_architecture_compendium.md && echo 1 || echo 0)"

{
  echo "# System Overview Detailed Check Report"
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
  echo "System overview strict check failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "System overview check completed (${MODE})."
