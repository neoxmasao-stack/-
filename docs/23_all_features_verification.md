# 23 その他全機能確認（統合チェック）

## 目的
- リポジトリ内の運用機能を一括で確認し、**見落としなく**状況を把握する。
- CI/手動確認の双方で同じコマンドを使えるようにする。

## 確認対象
1. 必須ドキュメント存在（verify-docs）
2. 法務クリーン（legal-clean）
3. Go-Live判定（advisory / strict）
4. 外部接続グランドオープン判定（advisory / strict）
5. スクリプト構文健全性（bash -n）
6. レポート出力（artifacts配下）

## 実行コマンド
```bash
# 日常確認（非ブロッキング）
make all-features-check

# 本番前確認（ブロッキング）
make all-features-check-strict
```

## 出力物
- `artifacts/all-features-report.md`
- `artifacts/go-live-report.md`
- `artifacts/grand-open-report.md`
- `artifacts/legal-clean-report.md`

## 判定ルール
- Advisory: 実行完了を優先（未設定フラグはFAIL表示でも継続）
- Strict: Go-Live/Grand-Open いずれか未達で終了コード1

## 一言で定義
運用機能を個別に見るのではなく、
**一つの入口で全機能の健全性を確認する統合点検**。


## 公式グランドオープン全機能（新設）

- 実行コマンド: `make official-grand-open-all-features`
- 実行スクリプト: `scripts/official_grand_open_all_features.sh`
- 内容: `go_live_check --strict` → `grand_open_check --strict` → `all_features_check --strict` を連続実行し、可能であれば `official_go_check.ps1` も実行。
- 出力: `artifacts/official-grand-open-all-features-report.md`

> `pwsh` が無い Linux 環境では PowerShell 判定は自動でスキップされます（レポートに明記）。


## 一全機能一覧・本番公式実弾

- 一覧生成: `make official-live-fire-list`
- 実行: `OFFICIAL_LIVE_FIRE_APPROVED=YES make official-live-fire-run`
- 一覧レポート: `artifacts/official-live-fire-feature-list.md`
- 実行レポート: `artifacts/official-live-fire-execution.md`

> `official-live-fire-run` は確認用環境変数が無い場合、誤実行防止のため終了コード2で停止。
