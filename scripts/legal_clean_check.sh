#!/usr/bin/env bash
set -euo pipefail

mkdir -p artifacts
report="artifacts/legal-clean-report.md"

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

required_file() {
  [[ -f "$1" ]]
}

contains_text() {
  local file="$1"
  local pattern="$2"
  rg -q "$pattern" "$file"
}

# L1-L5: 必須法務文書
check "L1" "Compliance policy exists" "$(required_file docs/09_compliance_policy.md && echo 1 || echo 0)"
check "L2" "Bank license acquisition playbook exists" "$(required_file docs/12_bank_license_original_acquisition.md && echo 1 || echo 0)"
check "L3" "Gateway and licensing workflow exists" "$(required_file docs/15_gateway_contracts_and_licensing_workflow.md && echo 1 || echo 0)"
check "L4" "AI legal guardrails exists" "$(required_file docs/18_ai_operations_guardrails.md && echo 1 || echo 0)"
check "L5" "21-country official index exists" "$(required_file docs/19_license_register_index_18_countries.md && echo 1 || echo 0)"

# L6-L9: 禁止事項 / 人間承認の明記
check "L6" "No unauthorized legal agency statement exists" "$(contains_text docs/08_ai_prompt_library.md '無資格代理行為禁止' && echo 1 || echo 0)"
check "L7" "AI cannot finalize alone statement exists" "$(contains_text docs/18_ai_operations_guardrails.md 'AI単独' && echo 1 || echo 0)"
check "L8" "Human approval boundary is documented" "$(contains_text docs/18_ai_operations_guardrails.md '人間承認' && echo 1 || echo 0)"
check "L9" "Official-source-only policy is documented" "$(contains_text docs/19_license_register_index_18_countries.md '当局公式' && echo 1 || echo 0)"

# L10-L11: 21カ国インデックスの最低整合
country_count=$(awk 'BEGIN{count=0} /^\|[ ]*[0-9]+[ ]*\|/{count++} END{print count}' docs/19_license_register_index_18_countries.md)
if [[ "${country_count}" -eq 21 ]]; then
  check "L10" "21-country rows are present" "1"
else
  check "L10" "21-country rows are present" "0"
fi

https_count=$(rg -o 'https://[^ )|]+' docs/19_license_register_index_18_countries.md | wc -l | tr -d ' ')
if [[ "${https_count}" -ge 21 ]]; then
  check "L11" "Official HTTPS source links are present (21+)" "1"
else
  check "L11" "Official HTTPS source links are present (21+)" "0"
fi

# L12-L15: 登記簿/期限/保全の強化運用
check "L12" "License/registry hardening guide exists" "$(required_file docs/21_license_and_registry_hardening.md && echo 1 || echo 0)"
check "L13" "Registry extract confirmation is documented" "$(contains_text docs/15_gateway_contracts_and_licensing_workflow.md 'REGISTRY_EXTRACT_CONFIRMED' && echo 1 || echo 0)"
check "L14" "License expiry alert operation is documented" "$(contains_text docs/21_license_and_registry_hardening.md 'T-90/T-30/T-7/T-1' && echo 1 || echo 0)"
check "L15" "Legal hold handling is documented" "$(contains_text docs/21_license_and_registry_hardening.md 'LEGAL_HOLD' && echo 1 || echo 0)"
check "L16" "External connectivity grand-open checklist exists" "$(required_file docs/22_external_connectivity_grand_open_checklist.md && echo 1 || echo 0)"
check "L17" "All-features verification runbook exists" "$(required_file docs/23_all_features_verification.md && echo 1 || echo 0)"

{
  echo "# Legal Clean Report"
  echo
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo
  echo "| ID | Control | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${RESULTS[@]}"
} > "${report}"

cat "${report}"

if [[ "${fail}" -gt 0 ]]; then
  echo "Legal clean check failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Legal clean check passed."
