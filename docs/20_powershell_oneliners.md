# 20 PowerShell ワンライナー command 集

## 目的
Windows運用で「コピペ1行」で実行できるように、主要オペレーションを PowerShell ワンライナー化する。

## 1) 前提確認（ルートで実行）
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; Get-Location; Get-ChildItem Makefile,README.md,docs -ErrorAction Stop | Select-Object Name
```

## 2) Advisory CI（法務クリーン + Go-Live）
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; make ci
```

## 3) 法務クリーン確認のみ
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; make legal-clean; Get-Content .\artifacts\legal-clean-report.md
```

## 4) ドキュメント完全性チェック
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; make verify-docs
```

## 5) Strict Gate（本番判定）
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; if (!(Test-Path .\.golive.env)) { throw ".golive.env がありません。テンプレートをコピーして各 CHECK_* を設定してください。" }; make check-go-live
```

## 6) Internal Gate Token を安全に自動投入 + 即検証（対話入力あり）
```powershell
Set-Location "C:\Users\aiktn\fin-os-prod"; $ErrorActionPreference="Stop"; if([string]::IsNullOrWhiteSpace($env:INTERNAL_GATE_TOKEN)){ $sec=Read-Host "INTERNAL_GATE_TOKEN" -AsSecureString; $env:INTERNAL_GATE_TOKEN=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)) }; $gate="https://fin-os-internal-gate.tsukayamacenturybank.workers.dev"; curl.exe -s -o NUL -w "internal_auth:%{http_code}`n" -H "Authorization: Bearer $env:INTERNAL_GATE_TOKEN" "$gate/api/internal/noc"
```
- 未設定時のみ入力要求（idempotent）。
- SecureString で受け取り、直後に Gate `/api/internal/noc` へ検証。
- トークン文字列をコマンド履歴に直接残さない。

## 7) Internal Gate Token を完全自動投入 + 即検証（ローカル保存済み）
```powershell
Set-Location "C:\Users\aiktn\fin-os-prod"; $env:INTERNAL_GATE_TOKEN = Get-Content .\.wrangler\readiness-token.local; curl.exe -s -o NUL -w "internal_auth:%{http_code}`n" -H "Authorization: Bearer $env:INTERNAL_GATE_TOKEN" "https://fin-os-internal-gate.tsukayamacenturybank.workers.dev/api/internal/noc"
```
- 401: トークン不正または Gate 側設定不備。
- 000: ネットワーク到達性または URL 誤り。
- 空レスポンス/未出力: 入力未完了や前段失敗を確認。

## 8) Cloudflare同期 Dry-run
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; $env:CLOUDFLARE_API_TOKEN='***'; $env:CLOUDFLARE_ACCOUNT_ID='***'; make cloudflare-sync-dry-run
```

## 9) Cloudflare同期 Staging
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; $env:CLOUDFLARE_API_TOKEN='***'; $env:CLOUDFLARE_ACCOUNT_ID='***'; make cloudflare-sync-staging
```

## 10) Next.js build debug（pnpm not found対策）
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; make next-build-debug-local
```

## 11) 18カ国当局索引 + 法務クリーン + Advisory を連続実行
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; make verify-docs; make legal-clean; make check-go-live-advisory
```

## 12) レポート確認（Go-Live / Legal）
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; Get-Content .\artifacts\go-live-report.md; Get-Content .\artifacts\legal-clean-report.md
```

## 13) 公式グランドオープン（一括実行）
```powershell
Set-Location C:\Users\aiktn\fin-os-prod; $env:OFFICIAL_LAUNCH_APPROVED='1'; make grand-open
```
