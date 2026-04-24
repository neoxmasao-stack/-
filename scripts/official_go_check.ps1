param(
  [string]$RepoPath = '.',
  [switch]$FailOnNoGo
)

$ErrorActionPreference = 'Stop'
Set-Location $RepoPath

$buildPath = 'ops-evidence/status/build-state.json'
$truthPath = 'ops-evidence/status/release-truth-state.json'
$judgeCandidates = @(
  'ops-evidence/status/judge-verdict.json',
  'ops-evidence/status/final-operation-judge-state.json'
)

foreach ($p in @($buildPath, $truthPath)) {
  if (-not (Test-Path $p)) {
    throw "Missing required status file: $p"
  }
}

$build = Get-Content $buildPath -Raw | ConvertFrom-Json
$truth = Get-Content $truthPath -Raw | ConvertFrom-Json
$judge = $null
foreach ($jp in $judgeCandidates) {
  if (Test-Path $jp) {
    $judge = Get-Content $jp -Raw | ConvertFrom-Json
    break
  }
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

$truthState = 'UNKNOWN'
foreach ($field in @('state', 'status', 'overall_state', 'release_truth_state')) {
  if ($truth.PSObject.Properties[$field] -and $truth.$field) {
    $truthState = [string]$truth.$field
    break
  }
}
$truthReason = if ($truth.PSObject.Properties['reason']) { $truth.reason } else { '' }
Write-Host ("RELEASE_TRUTH state={0} reason={1}" -f $truthState, $truthReason)

$blockingItems = @()
if ($truth.PSObject.Properties['blocking'] -and $truth.blocking) {
  $blockingItems = @($truth.blocking)
} elseif ($truth.PSObject.Properties['blocking_reasons'] -and $truth.blocking_reasons) {
  $blockingItems = @($truth.blocking_reasons)
}

if ($blockingItems.Count -gt 0) {
  Write-Host "--- blocking items ---" -ForegroundColor Yellow
  foreach ($b in $blockingItems) {
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
    'ATM:atm_tokens_missing',
    'release_truth_fetch_failed'
  )
  Write-Host "--- priority fixes ---" -ForegroundColor Cyan
  foreach ($p in $priority) {
    if ($blockingItems -contains $p) {
      Write-Host ("* {0}" -f $p) -ForegroundColor Red
    }
  }
}

if ($judge) {
  $verdict = if ($judge.PSObject.Properties['verdict']) { $judge.verdict } else { 'UNKNOWN' }
  $reason = if ($judge.PSObject.Properties['reason']) { $judge.reason } else { '' }
  Write-Host ("FINAL_JUDGE verdict={0} reason={1}" -f $verdict, $reason)
}

$truthReady = @('GO', 'RELEASE_TRUTH_READY', 'READY') -contains $truthState
$noGo = (-not $webOk) -or (-not $truthReady)
if ($noGo) {
  Write-Host 'RESULT: NO_GO (BUILD_VERIFIED or RELEASE_TRUTH_READY is unmet)' -ForegroundColor Red
  if (-not $webOk) {
    Write-Host 'Next #1: npm run build で Web build failure を解消' -ForegroundColor Yellow
  }
  if (-not $truthReady) {
    Write-Host 'Next #2: release truth の blocking を解消（API応答 schema / データ欠損 / 接続失敗）' -ForegroundColor Yellow
  }
  if ($FailOnNoGo) {
    exit 1
  }
} else {
  Write-Host 'RESULT: GO' -ForegroundColor Green
}
