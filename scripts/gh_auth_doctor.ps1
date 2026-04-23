param(
  [switch]$ClearPersisted,
  [string]$Repo = '',
  [int]$PrNumber = 0
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$Message) {
  Write-Host "[gh-auth-doctor] $Message" -ForegroundColor Cyan
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI (gh) が見つかりません。https://cli.github.com/ からインストールしてください。"
}

if (Get-Command git -ErrorAction SilentlyContinue) {
  Write-Step "Repository context check."
  $gitRoot = & git rev-parse --show-toplevel 2>$null
  if ($LASTEXITCODE -eq 0 -and $gitRoot) {
    Write-Host "git root: $gitRoot"
    $head = & git rev-parse --short HEAD 2>$null
    if ($LASTEXITCODE -eq 0 -and $head) {
      Write-Host "git HEAD: $head"
    }
    & git remote -v
  } else {
    Write-Host "git repository is not detected in current directory." -ForegroundColor Yellow
  }
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

if ($Repo -and $PrNumber -gt 0) {
  Write-Step "Validating pull request access: $Repo#$PrNumber"
  $null = & gh pr view $PrNumber --repo $Repo --json number,title,state
  if ($LASTEXITCODE -ne 0) {
    throw "PR参照に失敗。repo指定/権限/トークンを確認してください。例: gh pr view $PrNumber --repo $Repo"
  }
}

Write-Step "Authentication looks healthy."
if ($Repo -and $PrNumber -gt 0) {
  Write-Host "次に実行: gh pr checkout $PrNumber --repo $Repo" -ForegroundColor Green
} else {
  Write-Host "次に実行: gh pr checkout <PR番号> --repo <owner/repo>" -ForegroundColor Green
}
