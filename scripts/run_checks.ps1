param(
  [ValidateSet('verify-docs','legal-clean','go-live','grand-open','all-features','ci')]
  [string]$Task = 'ci',

  [ValidateSet('advisory','strict')]
  [string]$Mode = 'advisory'
)

$ErrorActionPreference = 'Stop'

function Assert-Bash {
  if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
    throw "bash が見つかりません。Git Bash か WSL をインストールしてください。"
  }
}

function Invoke-BashScript([string]$ScriptPath, [string]$Arg = '') {
  Assert-Bash
  if ($Arg) {
    & bash $ScriptPath $Arg
  } else {
    & bash $ScriptPath
  }
  if ($LASTEXITCODE -ne 0) {
    throw "Script failed: $ScriptPath $Arg"
  }
}

function Test-RequiredDocs {
  $required = @(
    'docs/01_system_role.md',
    'docs/02_business_rules.md',
    'docs/03_state_machine.md',
    'docs/04_security_policy.md',
    'docs/05_api_contracts.md',
    'docs/06_ledger_rules.md',
    'docs/07_ops_runbook.md',
    'docs/08_ai_prompt_library.md',
    'docs/09_compliance_policy.md',
    'docs/10_ui_behavior.md',
    'docs/12_bank_license_original_acquisition.md',
    'docs/13_fin_os_unified_architecture.md',
    'docs/14_ui_ux_wireframes_and_nextjs_map.md',
    'docs/15_gateway_contracts_and_licensing_workflow.md',
    'docs/16_financial_infra_legal_uiux_ai_revenue_strengthening.md',
    'docs/17_cloudflare_sync.md',
    'docs/18_ai_operations_guardrails.md',
    'docs/19_license_register_index_21_countries.md',
    'docs/20_powershell_oneliners.md',
    'docs/21_license_and_registry_hardening.md',
    'docs/22_external_connectivity_grand_open_checklist.md',
    'docs/23_all_features_verification.md',
    'docs/FIN-OS_ORG_OPERATING_MODEL.md'
  )

  $missing = $required | Where-Object { -not (Test-Path $_) }
  if ($missing.Count -gt 0) {
    $missing | ForEach-Object { Write-Host "[missing] $_" -ForegroundColor Red }
    throw "verify-docs failed: required docs are missing."
  }

  Write-Host '[verify-docs] required docs are present.' -ForegroundColor Green
}

switch ($Task) {
  'verify-docs' {
    Test-RequiredDocs
  }
  'legal-clean' {
    Invoke-BashScript 'scripts/legal_clean_check.sh'
  }
  'go-live' {
    $arg = if ($Mode -eq 'strict') { '--strict' } else { '--advisory' }
    Invoke-BashScript 'scripts/go_live_check.sh' $arg
  }
  'grand-open' {
    $arg = if ($Mode -eq 'strict') { '--strict' } else { '--advisory' }
    Invoke-BashScript 'scripts/grand_open_check.sh' $arg
  }
  'all-features' {
    $arg = if ($Mode -eq 'strict') { '--strict' } else { '--advisory' }
    Invoke-BashScript 'scripts/all_features_check.sh' $arg
  }
  'ci' {
    Test-RequiredDocs
    Invoke-BashScript 'scripts/legal_clean_check.sh'
    Invoke-BashScript 'scripts/go_live_check.sh' '--advisory'
    Invoke-BashScript 'scripts/grand_open_check.sh' '--advisory'
    Invoke-BashScript 'scripts/all_features_check.sh' '--advisory'
  }
}
