param(
  [string]$RepoPath = '.',
  [switch]$FailOnNoGo
)

$ErrorActionPreference = 'Stop'
Set-Location $RepoPath

$buildPath = 'ops-evidence/status/build-state.json'
$truthPath = 'ops-evidence/status/release-truth-state.json'
$judgePath = 'ops-evidence/status/final-operation-judge-state.json'

foreach ($p in @($buildPath, $truthPath)) {
  if (-not (Test-Path $p)) {
    throw "Missing required status file: $p"
  }
}

$build = Get-Content $buildPath -Raw | ConvertFrom-Json
$truth = Get-Content $truthPath -Raw | ConvertFrom-Json
$judge = $null
if (Test-Path $judgePath) {
  $judge = Get-Content $judgePath -Raw | ConvertFrom-Json
}

Write-Host '=== Official Go/No-Go Check ===' -ForegroundColor Cyan

$webOk = $false
if ($build.PSObject.Properties['web'] -and $build.web.PSObject.Properties['ok']) {
  $webOk = [bool]$build.web.ok
}
$apiOk = $false
if ($build.PSObject.Properties['api'] -and $build.api.PSObject.Properties['ok']) {
  $apiOk = [bool]$build.api.ok
}

Write-Host ("BUILD web.ok={0} api.ok={1}" -f $webOk, $apiOk)
if ($build.PSObject.Properties['web'] -and $build.web.PSObject.Properties['reason']) {
  Write-Host ("BUILD reason: {0}" -f $build.web.reason) -ForegroundColor Yellow
}

$truthState = if ($truth.PSObject.Properties['state']) { $truth.state } else { 'UNKNOWN' }
$truthReason = if ($truth.PSObject.Properties['reason']) { $truth.reason } else { '' }
Write-Host ("RELEASE_TRUTH state={0} reason={1}" -f $truthState, $truthReason)

if ($truth.PSObject.Properties['blocking'] -and $truth.blocking) {
  Write-Host "--- blocking items ---" -ForegroundColor Yellow
  foreach ($b in $truth.blocking) {
    Write-Host ("- {0}" -f $b)
  }

  $priority = @(
    'TRANSFERS:transfer_projection_empty',
    'TRANSFERS:finalized_transfer_missing',
    'CARD:card_records_missing',
    'CARD:card_events_missing',
    'FILINGS:filings_missing',
    'FILINGS:regulatory_submissions_missing',
    'ATM:atm_transactions_missing',
    'ATM:atm_tokens_missing'
  )
  Write-Host "--- priority fixes ---" -ForegroundColor Cyan
  foreach ($p in $priority) {
    if ($truth.blocking -contains $p) {
      Write-Host ("* {0}" -f $p) -ForegroundColor Red
    }
  }
}

if ($judge) {
  $verdict = if ($judge.PSObject.Properties['verdict']) { $judge.verdict } else { 'UNKNOWN' }
  $reason = if ($judge.PSObject.Properties['reason']) { $judge.reason } else { '' }
  Write-Host ("FINAL_JUDGE verdict={0} reason={1}" -f $verdict, $reason)
}

$noGo = (-not $webOk) -or (-not $apiOk) -or ($truthState -ne 'GO')
if ($noGo) {
  Write-Host 'RESULT: NO_GO (WEB/API build verification or RELEASE_TRUTH_READY is unmet)' -ForegroundColor Red
  Write-Host 'Summary: 本質は Web/API build failure または release truth blockers.' -ForegroundColor Red
  Write-Host 'Next #1: web/api build failure を解消' -ForegroundColor Yellow
  Write-Host 'Next #2: release truth の blocking を埋める (transfer/card/filings/ATM/license coverage)' -ForegroundColor Yellow
  if ($FailOnNoGo) {
    exit 1
  }
} else {
  Write-Host 'RESULT: GO' -ForegroundColor Green
}
