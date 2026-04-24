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

index_file='docs/19_license_register_index_21_countries.md'
mkdir -p artifacts
report='artifacts/country-original-format-report.md'

pass=0
fail=0
declare -a RESULTS

action() {
  local id="$1"; local desc="$2"; local ok="$3"
  if [[ "$ok" == "1" ]]; then
    RESULTS+=("| ${id} | ${desc} | ✅ PASS |")
    pass=$((pass + 1))
  else
    RESULTS+=("| ${id} | ${desc} | ❌ FAIL |")
    fail=$((fail + 1))
  fi
}

row_count=0
source_format_field=0
hash_field=0
if [[ -f "$index_file" ]]; then
  row_count=$(awk -F'|' '/^\|\s*[0-9]+\s*\|/ {c++} END {print c+0}' "$index_file")
  rg -q 'source_format' "$index_file" && source_format_field=1 || true
  rg -q 'content_hash_sha256' "$index_file" && hash_field=1 || true
fi

action "F1" "21-country original-source table rows are present" "$([[ "$row_count" -ge 21 ]] && echo 1 || echo 0)"
action "F2" "source_format evidence field is defined" "$source_format_field"
action "F3" "content_hash_sha256 evidence field is defined" "$hash_field"

declare -a COUNTRY_ROWS
if [[ -f "$index_file" ]]; then
  while IFS=$'\t' read -r no country url; do
    [[ -z "$no" ]] && continue
    url_ok="OK"
    [[ "$url" =~ ^https:// ]] || url_ok="INVALID"
    COUNTRY_ROWS+=("| ${no} | ${country} | ${url} | PDF/CSV/XLS/XLSX/HTML | ${url_ok} |")
  done < <(awk -F'|' '/^\|\s*[0-9]+\s*\|/ {no=$2; c=$3; u=$6; gsub(/^[ \t]+|[ \t]+$/, "", no); gsub(/^[ \t]+|[ \t]+$/, "", c); gsub(/^[ \t]+|[ \t]+$/, "", u); printf "%s\t%s\t%s\n", no,c,u }' "$index_file")
fi

{
  echo "# Country Original Format Report"
  echo
  echo "- Mode: **${MODE}**"
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo "- Country rows detected: **${row_count}**"
  echo
  echo "| ID | Control | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${RESULTS[@]}"
  echo
  echo "## Country original-source expectation"
  echo
  echo "| No | Country | Official URL | Required Original Formats | URL |"
  echo "|---|---|---|---|---|"
  if [[ "${#COUNTRY_ROWS[@]}" -gt 0 ]]; then
    printf '%s\n' "${COUNTRY_ROWS[@]}"
  fi
} > "$report"

cat "$report"

if [[ "$MODE" == "strict" && "$fail" -gt 0 ]]; then
  echo "Country original-format strict gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Country original-format gate completed (${MODE})."
