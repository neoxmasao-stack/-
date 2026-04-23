param(
  [string]$RepoPath = '.'
)

$ErrorActionPreference = 'Stop'
Set-Location $RepoPath

$checks = @(
  @{ id = 'C1'; path = '.github/workflows/ci.yml'; label = 'CI workflow' },
  @{ id = 'C2'; path = 'release-truth.ts'; label = 'release-truth.ts' },
  @{ id = 'C3'; path = 'scripts/d1-verify.ps1'; label = 'd1-verify.ps1' },
  @{ id = 'C4'; path = 'scripts/evidence-export.ps1'; label = 'evidence-export.ps1' },
  @{ id = 'C5'; path = 'scripts/finos-status-command.ps1'; label = 'finos-status-command.ps1' }
)

Write-Host '=== Final Adoption Check ===' -ForegroundColor Cyan
foreach ($c in $checks) {
  if (Test-Path $c.path) {
    Write-Host ("[{0}] PASS {1} ({2})" -f $c.id, $c.label, $c.path) -ForegroundColor Green
  } else {
    Write-Host ("[{0}] MISS {1} ({2})" -f $c.id, $c.label, $c.path) -ForegroundColor Yellow
  }
}

$migration = Get-ChildItem -Path 'migrations' -Filter '*0007*' -ErrorAction SilentlyContinue
if ($migration) {
  Write-Host ("[C6] PASS 0007 migration ({0})" -f ($migration.Name -join ', ')) -ForegroundColor Green
} else {
  Write-Host '[C6] MISS 0007 migration (migrations/*0007*)' -ForegroundColor Yellow
}
