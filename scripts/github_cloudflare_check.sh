#!/usr/bin/env bash
set -euo pipefail

mkdir -p artifacts
report="artifacts/github-cloudflare-check.md"

pass=0
fail=0
warn=0
declare -a ROWS

record() {
  local id="$1" desc="$2" result="$3"
  ROWS+=("| ${id} | ${desc} | ${result} |")
}

pass_check() {
  local id="$1" desc="$2"
  pass=$((pass + 1))
  record "$id" "$desc" "✅ PASS"
}

fail_check() {
  local id="$1" desc="$2"
  fail=$((fail + 1))
  record "$id" "$desc" "❌ FAIL"
}

warn_check() {
  local id="$1" desc="$2"
  warn=$((warn + 1))
  record "$id" "$desc" "⚠️ WARN"
}

workflow=".github/workflows/cloudflare-sync.yml"

if [[ -f "$workflow" ]]; then
  pass_check "GC1" "Cloudflare sync workflow exists"
else
  fail_check "GC1" "Cloudflare sync workflow exists"
fi

if [[ -f "$workflow" ]] && grep -q "workflow_dispatch:" "$workflow"; then
  pass_check "GC2" "Workflow supports manual dispatch"
else
  fail_check "GC2" "Workflow supports manual dispatch"
fi

if [[ -f "$workflow" ]] && grep -q "CLOUDFLARE_API_TOKEN" "$workflow" && grep -q "CLOUDFLARE_ACCOUNT_ID" "$workflow"; then
  pass_check "GC3" "Workflow references required Cloudflare secrets"
else
  fail_check "GC3" "Workflow references required Cloudflare secrets"
fi

if [[ -f "scripts/cloudflare_sync.sh" ]]; then
  pass_check "GC4" "Cloudflare sync script exists"
else
  fail_check "GC4" "Cloudflare sync script exists"
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    pass_check "GC5" "GitHub CLI auth is configured"
  else
    warn_check "GC5" "GitHub CLI found, but auth is not configured in this environment"
  fi
else
  warn_check "GC5" "GitHub CLI is not installed in this environment"
fi

if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]] && [[ -n "${CLOUDFLARE_ACCOUNT_ID:-}" ]]; then
  pass_check "GC6" "Cloudflare environment variables are set in current shell"
else
  warn_check "GC6" "Cloudflare environment variables are not set in current shell"
fi

{
  echo "# GitHub × Cloudflare Check"
  echo
  echo "- Passed: **${pass}**"
  echo "- Failed: **${fail}**"
  echo "- Warnings: **${warn}**"
  echo
  echo "| ID | Check | Result |"
  echo "|---|---|---|"
  printf '%s\n' "${ROWS[@]}"
} > "$report"

cat "$report"

if [[ "$fail" -gt 0 ]]; then
  exit 1
fi

