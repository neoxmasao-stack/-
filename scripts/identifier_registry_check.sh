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
declare -a COUNTRY_ROWS

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
row_count=0
key_nonempty_count=0
portal_link_count=0
country_detail_fail=0
d1_entity_field=0
d1_license_field=0
if [[ -f "$index_file" ]]; then
  row_count=$(awk -F'|' '/^\|\s*[0-9]+\s*\|/ {c++} END {print c+0}' "$index_file")
  key_nonempty_count=$(awk -F'|' '
    /^\|\s*[0-9]+\s*\|/ {
      key=$7
      gsub(/^[ \t]+|[ \t]+$/, "", key)
      if (length(key) > 0) c++
    }
    END {print c+0}
  ' "$index_file")
  portal_link_count=$(rg -No 'https://[^) ]+' "$index_file" | wc -l | tr -d ' ')
  rg -q 'entity_name_matched' "$index_file" && d1_entity_field=1 || true
  rg -q 'license_number' "$index_file" && d1_license_field=1 || true

  while IFS=$'\t' read -r no country url key; do
    [[ -z "${no}" ]] && continue
    key_state="OK"
    url_state="OK"
    if [[ -z "${key}" ]]; then
      key_state="MISSING"
      country_detail_fail=$((country_detail_fail + 1))
    fi
    if [[ ! "${url}" =~ ^https:// ]]; then
      url_state="INVALID"
      country_detail_fail=$((country_detail_fail + 1))
    fi
    COUNTRY_ROWS+=("| ${no} | ${country} | ${url} | ${key_state} | ${url_state} |")
  done < <(
    awk -F'|' '
      /^\|\s*[0-9]+\s*\|/ {
        no=$2; country=$3; url=$6; key=$7
        gsub(/^[ \t]+|[ \t]+$/, "", no)
        gsub(/^[ \t]+|[ \t]+$/, "", country)
        gsub(/^[ \t]+|[ \t]+$/, "", url)
        gsub(/^[ \t]+|[ \t]+$/, "", key)
        printf "%s\t%s\t%s\t%s\n", no, country, url, key
      }
    ' "$index_file"
  )
fi

check "I1" "21-country registry table rows are listed" "$([[ "$row_count" -ge 21 ]] && echo 1 || echo 0)"
check "I2" "Country-level license/registration search keys are filled" "$([[ "$key_nonempty_count" -ge 21 ]] && echo 1 || echo 0)"
check "I3" "Official portal references are listed (HTTPS 21+)" "$([[ "$portal_link_count" -ge 21 ]] && echo 1 || echo 0)"
check "I4" "21-country detail rows have valid URL + search-key coverage" "$([[ "$country_detail_fail" -eq 0 && "$row_count" -ge 21 ]] && echo 1 || echo 0)"
check "I5" "Corporate registry verification completed" "$(is_true "${CHECK_CORPORATE_REGISTRY_VERIFIED:-0}" && echo 1 || echo 0)"
check "I6" "SWIFT/BIC identifier is verified" "$(is_true "${CHECK_SWIFT_BIC_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I7" "IBAN identifier is verified" "$(is_true "${CHECK_IBAN_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I8" "LEI identifier is verified" "$(is_true "${CHECK_LEI_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I9" "全銀( Zengin ) identifier is verified" "$(is_true "${CHECK_ZENGIN_IDENTIFIER:-0}" && echo 1 || echo 0)"
check "I10" "Identifier evidence (registry/SWIFT/IBAN/LEI/Zengin) archived" "$(is_true "${CHECK_IDENTIFIER_EVIDENCE_ARCHIVED:-0}" && echo 1 || echo 0)"
check "I11" "Docs define 法人名(entity_name_matched) and 番号(license_number) fields" "$([[ "$d1_entity_field" -eq 1 && "$d1_license_field" -eq 1 ]] && echo 1 || echo 0)"
check "I12" "法人名一致 (entity name match) is verified" "$(is_true "${CHECK_ENTITY_NAME_MATCH_VERIFIED:-0}" && echo 1 || echo 0)"
check "I13" "免許/登録番号一致 is verified" "$(is_true "${CHECK_LICENSE_NUMBER_MATCH_VERIFIED:-0}" && echo 1 || echo 0)"

{
  echo "# Registry + Identifier Verification Report"
  echo
  echo "- Mode: **${MODE}**"
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo "- Country rows detected: **${row_count}**"
  echo "- Search keys detected: **${key_nonempty_count}**"
  echo "- HTTPS links detected: **${portal_link_count}**"
  echo
  echo "| ID | Control | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${RESULTS[@]}"
  echo
  echo "## 21-country detail coverage"
  echo
  echo "| No | Country | Official URL | Key | URL |"
  echo "|---|---|---|---|---|"
  if [[ "${#COUNTRY_ROWS[@]}" -gt 0 ]]; then
    printf '%s\n' "${COUNTRY_ROWS[@]}"
  fi
} > "$report"

cat "$report"

if [[ "$MODE" == "strict" && "$fail" -gt 0 ]]; then
  echo "Identifier/registry strict gate failed: ${fail} controls are not satisfied." >&2
  exit 1
fi

echo "Identifier/registry gate completed (${MODE})."
