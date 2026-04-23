# FIN-OS Go-Live Automation Scaffold

このリポジトリは、金融業務AI運用を「単一巨大プロンプト」ではなく、
**分掌ドキュメント + Go/No-Go 自動判定**で運用するための雛形です。

## 最小アーキテクチャ

```text
[経営 / 統括]
  ↓
[分野別責任者]
  ↓
[AI補助]
  ↓
[Security / Audit / Recovery]
```

## Quick Start

```bash
make help
make legal-clean
make ci
```

Strict判定（本番前）:

```bash
cp .golive.env.example .golive.env
# 値を0/1で更新
make check-go-live
```

## 主要ドキュメント
- `docs/01_system_role.md` ～ `docs/10_ui_behavior.md`
- `docs/11_go_live_automation.md`
- `docs/12_bank_license_original_acquisition.md`
- `docs/13_fin_os_unified_architecture.md`
- `docs/14_ui_ux_wireframes_and_nextjs_map.md`
- `docs/FIN-OS_ORG_OPERATING_MODEL.md`
- `docs/15_gateway_contracts_and_licensing_workflow.md`
- `docs/16_financial_infra_legal_uiux_ai_revenue_strengthening.md`
- `docs/17_cloudflare_sync.md`
- `docs/18_ai_operations_guardrails.md`
- `docs/19_license_register_index_18_countries.md`
- `docs/20_powershell_oneliners.md`
- `docs/21_license_and_registry_hardening.md`
- `docs/22_external_connectivity_grand_open_checklist.md`
- `docs/23_all_features_verification.md`

## リカバリ確認（PowerShell）

```powershell
$P="C:\Users\aiktn\Documents\Codex\2026-04-23-cloud\docs\FIN-OS_ORG_OPERATING_MODEL.md"; if (!(Test-Path $P)) { Write-Host "MISSING: $P" -ForegroundColor Red } else { Get-Content $P }
```

## Cloudflare同期

```bash
make cloudflare-sync-dry-run
# 実反映
make cloudflare-sync-staging
make cloudflare-sync-production
```

詳細は `docs/17_cloudflare_sync.md` を参照。


## AI運用ガードレール

```bash
# advisory で AI ガードレール項目(F1-F4)も確認
make ci
```

詳細は `docs/18_ai_operations_guardrails.md` を参照。


## 21カ国当局インデックス

```bash
# ドキュメント整合 + インデックス存在確認
make verify-docs
make ci
```

詳細は `docs/19_license_register_index_18_countries.md` を参照。



## 外部接続グランドオープン確認

```bash
make grand-open-check
# 本番判定
make grand-open-check-strict
```

レポート: `artifacts/grand-open-report.md`


## その他全機能確認

```bash
make all-features-check
# 本番前
make all-features-check-strict
```

レポート: `artifacts/all-features-report.md`

## 法務クリーン確認

```bash
make legal-clean
```

レポート: `artifacts/legal-clean-report.md`


## Next.js build debug（pnpm not found対策）

```bash
make next-build-debug-local
```

- `scripts/next_build_debug.sh` は package manager を自動判定し、`pnpm` が必要な場合は `corepack` で有効化してから `next build` を実行します。
- `npx next info` は情報取得失敗で全体を止めないよう `|| true` で実行します。
- GitHub Actions 手動実行: `.github/workflows/next-build-debug.yml`。


## PowerShell ワンライナー

```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; make verify-docs; make legal-clean; make check-go-live-advisory
```

詳細: `docs/20_powershell_oneliners.md`
