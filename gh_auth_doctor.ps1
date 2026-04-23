$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path $PSScriptRoot 'scripts/gh_auth_doctor.ps1'
if (-not (Test-Path $scriptPath)) {
  throw "Missing: $scriptPath. リポジトリを最新化してください (git pull)."
}
& $scriptPath @args
exit $LASTEXITCODE
