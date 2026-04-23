# 20 PowerShell ワンライナー command 集

## 目的
Windows運用で「コピペ1行」で実行できるように、主要オペレーションを PowerShell ワンライナー化する。

## 0) PowerShell専用ラッパー（make不要）
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; .\run_checks.ps1 -Task ci -Mode advisory
```
- `scripts/run_checks.ps1` は `verify-docs / legal-clean / go-live / grand-open / all-features / ci` を PowerShell から直接実行可能。
- 内部で Bashスクリプトを呼ぶため、`bash`（Git Bash または WSL）が必要。
- ルートに `run_checks.ps1` ラッパーを追加したため、`.\scripts\...` ではなく `.\run_checks.ps1` で実行可能。

## 1) 前提確認（ルートで実行）
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; Get-Location; Get-ChildItem Makefile,README.md,docs -ErrorAction Stop | Select-Object Name
```

## 2) Advisory CI（法務クリーン + Go-Live）
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; make ci
```

## 3) 法務クリーン確認のみ
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; make legal-clean; Get-Content .\artifacts\legal-clean-report.md
```

## 4) ドキュメント完全性チェック
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; make verify-docs
```

## 5) Strict Gate（本番判定）
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; if (!(Test-Path .\.golive.env)) { Copy-Item .\.golive.env.example .\.golive.env }; make check-go-live
```

PowerShellラッパー版:
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; if (!(Test-Path .\.golive.env)) { Copy-Item .\.golive.env.example .\.golive.env }; .\run_checks.ps1 -Task go-live -Mode strict
```

## 6) Cloudflare同期 Dry-run
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; $env:CLOUDFLARE_API_TOKEN='***'; $env:CLOUDFLARE_ACCOUNT_ID='***'; make cloudflare-sync-dry-run
```

## 7) Cloudflare同期 Staging
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; $env:CLOUDFLARE_API_TOKEN='***'; $env:CLOUDFLARE_ACCOUNT_ID='***'; make cloudflare-sync-staging
```

## 8) Next.js build debug（pnpm not found対策）
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; make next-build-debug-local
```

## 9) 21カ国当局索引 + 法務クリーン + Advisory を連続実行
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; make verify-docs; make legal-clean; make check-go-live-advisory
```

## 10) レポート確認（Go-Live / Legal）
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; Get-Content .\artifacts\go-live-report.md; Get-Content .\artifacts\legal-clean-report.md
```

## 11) `gh` 認証エラー（401 Bad credentials）復旧
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; .\gh_auth_doctor.ps1 -ClearPersisted -Repo "neoxmasao-stack/-" -PrNumber 7
```
- `GITHUB_TOKEN` / `GH_TOKEN` の衝突をクリアし、`gh auth status` と `gh api user` で有効性を検証。
- 実行ディレクトリの `git root / HEAD / remote` も表示するため、「別リポジトリにいる」問題を先に検知できる。
- 復旧後の例:
```powershell
gh pr checkout 7 --repo neoxmasao-stack/-
gh pr view 7 --repo neoxmasao-stack/- --json number,title,url,headRefName,baseRefName,state
```

スクリプトが見つからない場合（`The term '.\run_checks.ps1' is not recognized`）は、現在位置と必須ファイルを確認:
```powershell
Get-Location; Get-ChildItem .\run_checks.ps1,.\gh_auth_doctor.ps1,.\.golive.env.example -ErrorAction Stop
```

## 12) MCP サーバー追加（Codex）
```powershell
codex mcp add context7 -- npx -y @upstash/context7-mcp
codex mcp list
```

環境変数付き STDIO サーバー例:
```powershell
codex mcp add my-docs --env DOCS_TOKEN=$env:DOCS_TOKEN -- npx -y @acme/docs-mcp
```

詳細: `docs/24_mcp_setup_guide.md`

## 13) ライセンス運用状態の確認（legal-canonicalize）
```powershell
Set-Location "C:\Users\aiktn\fin-os-prod"; .\scripts\license_readiness_check.ps1
```

手動で tail だけ見る場合:
```powershell
Set-Location "C:\Users\aiktn\fin-os-prod"; Get-Content .\ops-evidence\audit\legal-canonicalize.ndjson -Tail 5; Get-Content .\ops-evidence\status\legal-canonicalize-state.json
```

## 14) 最終採否チェック（ci/release-truth/d1-verify/evidence-export/0007）
```powershell
Set-Location "C:\Users\aiktn\fin-os-prod"; .\scripts\final_adoption_check.ps1
```

## 15) 送金 / ATM / CARD / 金融インフラ 強化ドキュメント確認
```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; Get-Content .\docs\25_transfer_atm_card_infra_hardening.md
```
