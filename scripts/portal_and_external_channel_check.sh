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
report="artifacts/portal-and-external-channel-report.md"

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

index_file='docs/19_license_register_index_21_countries.md'
has_index=0
[[ -f "$index_file" ]] && has_index=1
row_count=0
link_count=0
if [[ "$has_index" == "1" ]]; then
  row_count=$(rg -n '^\|\s*[0-9]+\s*\|' "$index_file" | wc -l | tr -d ' ')
  link_count=$(rg -No 'https://[^) ]+' "$index_file" | wc -l | tr -d ' ')
fi

check "P1" "21-country official portal index exists" "$has_index"
check "P2" "21-country table rows listed" "$([[ "$row_count" -ge 21 ]] && echo 1 || echo 0)"
check "P3" "Official HTTPS portal links listed (21+)" "$([[ "$link_count" -ge 21 ]] && echo 1 || echo 0)"

check "E1" "External connectivity: Transfer implementation confirmed" "$(is_true "${CHECK_EXTERNAL_TRANSFER_IMPLEMENTED:-0}" && echo 1 || echo 0)"
check "E2" "External connectivity: CARD implementation confirmed" "$(is_true "${CHECK_EXTERNAL_CARD_IMPLEMENTED:-0}" && echo 1 || echo 0)"
check "E3" "External connectivity: ATM implementation confirmed" "$(is_true "${CHECK_EXTERNAL_ATM_IMPLEMENTED:-0}" && echo 1 || echo 0)"
check "E4" "External connectivity: Transfer/CARD/ATM E2E evidence captured" "$(is_true "${CHECK_EXTERNAL_CHANNEL_E2E_EVIDENCE:-0}" && echo 1 || echo 0)"

{
  echo "# Portal Listing + External Channel Report"
  echo
  echo "- Mode: **${MODE}**"
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo "- Country rows detected: **${row_count}**"
  echo "- HTTPS links detected: **${link_count}**"
  echo
  echo "| ID | Control | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${RESULTS[@]}"
} > "$report"

cat "$report"

if [[ "$MODE" == "strict" && "$fail" -gt 0 ]]; then
  echo "Portal/external-channel strict gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Portal/external-channel gate completed (${MODE})."
