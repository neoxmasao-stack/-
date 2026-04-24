# FIN-OS Go-Live Automation Scaffold

このリポジトリは、金融業務AI運用を「単一巨大プロンプト」ではなく、
**分掌ドキュメント + Go/No-Go 自動判定**で運用するための雛形です。

## システム概要（会話用クイック版）

このリポジトリは、**Go-Live / Grand-Open 判定を自動化する運用ゲート基盤**です。

- **目的**: リリース前に「法務・ドキュメント・外部接続・運用証跡」の不足を機械的に検出する。
- **実行入口**: `make ci`（日常確認） / `make official-grand-open-all-features`（公式判定） / `make detailed-report`（詳細レポート表示）。
- **判定モード**: `--advisory`（継続）と `--strict`（未達で失敗終了）。
- **出力**: すべて `artifacts/*.md` にレポート化。
- **主な構成**:
  - `scripts/` … 判定ロジック
  - `.github/workflows/` … CI/手動ワークフロー
  - `docs/` … 運用・法務・設計の基準文書
  - `.golive.env` … 厳格判定のフラグ入力

会話的に言うと、
**「本番に出してよいかを、チェックリストではなく実行可能なゲートで判断する仕組み」**です。


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
- `docs/19_license_register_index_21_countries.md`
- `docs/20_powershell_oneliners.md`
- `docs/21_license_and_registry_hardening.md`
- `docs/22_external_connectivity_grand_open_checklist.md`
- `docs/23_all_features_verification.md`
- `docs/25_transfer_atm_card_infra_hardening.md`
- `docs/26_fin_os_final_architecture_compendium.md`

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

詳細は `docs/19_license_register_index_21_countries.md` を参照。



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



## 公式グランドオープン全機能チェック

```bash
make official-grand-open-all-features
```

- 厳格モードで `go_live_check` / `grand_open_check` / `all_features_check` を順番に実行します。
- `pwsh` が利用可能な環境では `scripts/official_go_check.ps1` も続けて実行します。
- レポートは `artifacts/official-grand-open-all-features-report.md` に出力されます。
- 外部接続の銀行業務全行程だけを確認する場合は `make external-bank-full-journey-check`（厳格判定は `make external-bank-full-journey-check-strict`）。
- 銀行業務全行程モジュール観点の公式判定は `make bank-full-journey-module-check`（厳格判定は `make bank-full-journey-module-check-strict`）。
- 各国公式ポータル掲載確認 + 外部接続（送金/CARD/ATM）: `make portal-and-external-channel-check`（厳格判定は `make portal-and-external-channel-check-strict`）。
- 法人登記簿 + 識別番号（SWIFT/BIC・IBAN・LEI・全銀）確認: `make identifier-registry-check`（厳格判定は `make identifier-registry-check-strict`）。
- 法人名一致 + 免許/登録番号一致の検証は `make identifier-registry-check` に統合（`CHECK_ENTITY_NAME_MATCH_VERIFIED` / `CHECK_LICENSE_NUMBER_MATCH_VERIFIED`）。
- 詳細レポートをここでまとめて確認: `make detailed-report`（必要なら `make detailed-report-generate` で再生成後に表示）。
- 法人登記簿・ライセンス原本フォーマット各国詳細: `make country-original-format-report`（厳格判定は `make country-original-format-report-strict`）。
- システム概要こと細かく確認: `make system-overview-check`（厳格判定は `make system-overview-check-strict`）。
- 全機能一覧（本番公式実弾）を生成: `make official-live-fire-list`（`artifacts/official-live-fire-feature-list.md`）
- 本番公式実弾 strict 実行: `OFFICIAL_LIVE_FIRE_APPROVED=YES make official-live-fire-run`
- PowerShellワンライナー（全機能公式グランドオープン）: `Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; .\run_checks.ps1 -Task official-grand-open -Mode strict`
- PowerShellワンライナー（銀行業務全行程モジュール）: `Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; .\run_checks.ps1 -Task bank-full-journey -Mode strict; .\run_checks.ps1 -Task bank-module -Mode strict`

## PowerShell ワンライナー

```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; make verify-docs; make legal-clean; make check-go-live-advisory
```

詳細: `docs/20_powershell_oneliners.md`
MCP設定ガイド: `docs/24_mcp_setup_guide.md`
ライセンス運用状態確認: `scripts/license_readiness_check.ps1`
最終採否チェック: `scripts/final_adoption_check.ps1`
本番公式運用判定: `scripts/official_go_check.ps1`

PowerShell専用ラッパー（`make` 非依存）:

```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; .\run_checks.ps1 -Task ci -Mode advisory
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; .\run_checks.ps1 -Task go-live -Mode strict
```

`gh` で `HTTP 401: Bad credentials` が出る場合:

```powershell
Set-Location C:\Users\aiktn\Documents\Codex\2026-04-23-cloud; .\gh_auth_doctor.ps1 -ClearPersisted -Repo "neoxmasao-stack/-" -PrNumber 7
```


CIでは `advisory-quality-gate` に加え、`grand-open-external-connectivity` ジョブで外部接続グランドオープン確認を実行します。
