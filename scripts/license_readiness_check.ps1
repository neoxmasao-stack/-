param(
  [string]$RepoPath = '.'
)

$ErrorActionPreference = 'Stop'

Set-Location $RepoPath

$auditPath = Join-Path (Get-Location) 'ops-evidence/audit/legal-canonicalize.ndjson'
$statusPath = Join-Path (Get-Location) 'ops-evidence/status/legal-canonicalize-state.json'

if (-not (Test-Path $auditPath)) {
  throw "Missing audit evidence: $auditPath"
}
if (-not (Test-Path $statusPath)) {
  throw "Missing status file: $statusPath"
}

$status = Get-Content $statusPath -Raw | ConvertFrom-Json
$tail = Get-Content $auditPath -Tail 5

Write-Host '=== License Canonicalize Readiness ===' -ForegroundColor Cyan

$fields = @(
  'success',
  'state',
  'status',
  'queries',
  'rows_written',
  'fin_licenses_seeded',
  'legal_documents_seeded',
  'fin_certificates_seeded',
  'fin_regulatory_submissions_seeded',
  'fin_portal_verifications_seeded'
)

foreach ($f in $fields) {
  if ($null -ne $status.PSObject.Properties[$f]) {
    Write-Host ("{0} = {1}" -f $f, $status.$f)
  }
}

Write-Host "\n--- audit tail (last 5) ---" -ForegroundColor Yellow
$tail | ForEach-Object { Write-Host $_ }

Write-Host "\nHint: 失効/期限管理は docs/21 と docs/22 の次フェーズ要件を確認してください。" -ForegroundColor Green
