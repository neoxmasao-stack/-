# 05_api_contracts

## API一覧
- /customers
- /accounts
- /transfers
- /approvals
- /audit-logs

## Request
- 必須項目、認証トークン、冪等キーを定義

## Response
- 結果、状態、監査ID、相関IDを返却

## Error Code
- 業務エラー、認証エラー、外部連携エラーを分類

## Retry Policy
- 再試行可否とバックオフ条件をエラー別に定義

## Timeout
- API/外部接続ごとに上限時間を設定

## Idempotency Key
- POST系エンドポイントで必須

## Correlation ID
- 全リクエストに採番し横断追跡

## Audit ID
- 監査ログとの紐付けIDを返却

## External ACK仕様
- 非同期ACK受信時の状態更新規則を定義

## Webhook仕様
- 署名検証、再送、順序保証の要件を定義
