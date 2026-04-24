param(
  [string]$RepoPath = '.'
)

$ErrorActionPreference = 'Stop'
Set-Location $RepoPath

$requiredChecks = @(
  @{ id = 'C1'; path = '.github/workflows/ci.yml'; label = 'CI workflow' },
  @{ id = 'C2'; path = 'Makefile'; label = 'Makefile entrypoint' },
  @{ id = 'C3'; path = 'scripts/go_live_check.sh'; label = 'go_live_check.sh' },
  @{ id = 'C4'; path = 'scripts/grand_open_check.sh'; label = 'grand_open_check.sh' },
  @{ id = 'C5'; path = 'scripts/legal_clean_check.sh'; label = 'legal_clean_check.sh' }
)

$optionalChecks = @(
  @{ id = 'O1'; path = 'release-truth.ts'; label = 'release-truth.ts' },
  @{ id = 'O2'; path = 'scripts/d1-verify.ps1'; label = 'd1-verify.ps1' },
  @{ id = 'O3'; path = 'scripts/evidence-export.ps1'; label = 'evidence-export.ps1' },
  @{ id = 'O4'; path = 'scripts/finos-status-command.ps1'; label = 'finos-status-command.ps1' }
)

Write-Host '=== Final Adoption Check ===' -ForegroundColor Cyan

$requiredMissing = 0
foreach ($c in $requiredChecks) {
  if (Test-Path $c.path) {
    Write-Host ("[{0}] PASS {1} ({2})" -f $c.id, $c.label, $c.path) -ForegroundColor Green
  } else {
    Write-Host ("[{0}] FAIL {1} ({2})" -f $c.id, $c.label, $c.path) -ForegroundColor Red
    $requiredMissing += 1
  }
}

Write-Host "--- Optional integrations (repo-dependent) ---" -ForegroundColor Cyan
foreach ($c in $optionalChecks) {
  if (Test-Path $c.path) {
    Write-Host ("[{0}] PASS {1} ({2})" -f $c.id, $c.label, $c.path) -ForegroundColor Green
  } else {
    Write-Host ("[{0}] SKIP {1} ({2})" -f $c.id, $c.label, $c.path) -ForegroundColor Yellow
  }
}

$migration = Get-ChildItem -Path 'migrations' -Filter '*0007*' -ErrorAction SilentlyContinue
if ($migration) {
  Write-Host ("[O5] PASS 0007 migration ({0})" -f ($migration.Name -join ', ')) -ForegroundColor Green
} else {
  Write-Host '[O5] SKIP 0007 migration (migrations/*0007*)' -ForegroundColor Yellow
}

if ($requiredMissing -gt 0) {
  Write-Host ("Result: FAIL (required missing={0})" -f $requiredMissing) -ForegroundColor Red
  exit 1
}

Write-Host 'Result: PASS (all required adoption checks are present)' -ForegroundColor Green
