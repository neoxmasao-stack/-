# Cloudflare同期運用（Workers / D1）

## 目的
本番運用前提で、Cloudflare Workers と D1 の反映手順を標準化する。

## 前提
- `wrangler.toml` が存在すること。
- `CLOUDFLARE_API_TOKEN` が設定されていること。
- `CLOUDFLARE_ACCOUNT_ID` が設定されていること。
- D1 を使う場合は `migrations/` が存在すること。

## 実行コマンド
```bash
make cloudflare-sync-dry-run
make cloudflare-sync-staging
make cloudflare-sync-production
```

## 実行内容
`scripts/cloudflare_sync.sh` は以下を実行する。
1. 環境変数と `wrangler.toml` の存在確認。
2. `wrangler deploy --dry-run` で事前検証。
3. `migrations/` がある場合、`wrangler d1 migrations apply` を実行。
4. Workers を `wrangler deploy` で反映。

## 運用ルール
- `production` 同期は、`staging` 成功後に実行する。
- すべての同期は監査ログ（実行者、時刻、対象環境、コミットID）を残す。
- 失敗時は `docs/07_ops_runbook.md` の復旧手順に従う。

## CI/CD 連携
- `.github/workflows/cloudflare-sync.yml` で手動同期を実行可能。
- `workflow_dispatch` 入力で `staging` / `production` を選択する。
- 同期の実体は `scripts/cloudflare_sync.sh`（`wrangler deploy` / `wrangler d1 migrations apply`）。
- Cloudflare 認証は GitHub Secrets（`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`）から注入する。
- 常時自動同期ではなく、**GitHub 側で明示実行したときのみ反映**される。
