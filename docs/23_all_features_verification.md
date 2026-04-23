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
