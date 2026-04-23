param(
  [switch]$ClearPersisted
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$Message) {
  Write-Host "[gh-auth-doctor] $Message" -ForegroundColor Cyan
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI (gh) が見つかりません。https://cli.github.com/ からインストールしてください。"
}

Write-Step "Clearing current-process token variables (GITHUB_TOKEN/GH_TOKEN)."
Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
Remove-Item Env:GH_TOKEN -ErrorAction SilentlyContinue
$env:GITHUB_TOKEN = $null
$env:GH_TOKEN = $null

if ($ClearPersisted) {
  Write-Step "Clearing persisted user/machine GH_TOKEN + GITHUB_TOKEN."
  [Environment]::SetEnvironmentVariable('GH_TOKEN', $null, 'User')
  [Environment]::SetEnvironmentVariable('GH_TOKEN', $null, 'Machine')
  [Environment]::SetEnvironmentVariable('GITHUB_TOKEN', $null, 'User')
  [Environment]::SetEnvironmentVariable('GITHUB_TOKEN', $null, 'Machine')
}

Write-Step "Checking gh auth status."
$null = & gh auth status
if ($LASTEXITCODE -ne 0) {
  throw "gh auth status に失敗。'gh auth login' を実行してください。"
}

Write-Step "Validating API access (gh api user)."
$null = & gh api user --jq '.login'
if ($LASTEXITCODE -ne 0) {
  throw "API認証に失敗。'gh auth login --web -s repo,workflow,read:org,gist' を再実行してください。"
}

Write-Step "Authentication looks healthy."
Write-Host "次に実行: gh pr checkout 7 --repo neoxmasao-stack/-" -ForegroundColor Green
