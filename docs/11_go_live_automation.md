# 11 Go-Live Automation

## Overview
本ドキュメントは、本番公式運用までの判定を自動化する手順を定義する。

- `Makefile`
- `.github/workflows/ci.yml`（Advisory）
- `.github/workflows/release-gate.yml`（Strict）
- `.github/workflows/cloudflare-sync.yml`（手動同期）
- `scripts/go_live_check.sh`
- `.golive.env.example`

## Commands

### 日常（開発・PR）
```bash
make ci
```
- Bash構文チェック
- Advisory判定（非ブロッキング）

### ドキュメント完全性チェック
```bash
make verify-docs
```
- 01〜10 + 12/13/14 + FIN-OS_ORG_OPERATING_MODEL + 15 + 16 + 17 の存在を確認

### 本番判定（厳格）
```bash
cp .golive.env.example .golive.env
# 各項目を 1 に更新
make check-go-live
```
- 1つでも未達なら終了コード 1
- レポート: `artifacts/go-live-report.md`


### Cloudflare同期（手動）
```bash
make cloudflare-sync-dry-run
make cloudflare-sync-staging
# 本番反映
make cloudflare-sync-production
```
- `wrangler.toml` と Cloudflare Secrets の設定を事前に確認する。

## Control model
判定項目は A〜E + R（Repository readiness）で管理。

- A. UI / Delivery
- B. API / Control
- C. Real-Money Readiness
- D. Legal / Regulatory
- E. Audit / Compliance
- R. Required docs / playbooks / operating model / gateway licensing / strengthening plan / cloudflare sync doc

## Operational recommendation
1. PRでは `make ci` を必須化。
2. リリース直前に Strict gate を手動実行。
3. Go/No-Go会議で `artifacts/go-live-report.md` を証跡保管。
4. 重大変更時は `docs/12` `docs/13` `docs/14` `docs/FIN-OS_ORG_OPERATING_MODEL.md` `docs/15_gateway_contracts_and_licensing_workflow.md` `docs/16_financial_infra_legal_uiux_ai_revenue_strengthening.md` `docs/17_cloudflare_sync.md` を同時更新。
