# 05_api_contracts

## API一覧
- 顧客管理API
- 口座管理API
- 送金API
- 承認API
- 監査API

## Request
- JSON Schemaを厳格適用。
- `Idempotency-Key` ヘッダ必須。
- `Correlation-ID` ヘッダ必須。

## Response
- 機械可読な結果コード。
- `Audit-ID` を全レスポンスに付与。

## Error Code
- `VALIDATION_ERROR`
- `AML_BLOCKED`
- `APPROVAL_REQUIRED`
- `INSUFFICIENT_FUNDS`
- `TIMEOUT`
- `EXTERNAL_ACK_TIMEOUT`

## Retry Policy
- 再試行対象: ネットワーク失敗/タイムアウトのみ。
- 非再試行: バリデーション失敗/規制違反。

## Timeout
- 同期APIは短時間タイムアウト。
- 長時間処理は非同期 + Webhook通知。

## Idempotency Key
- キー衝突時は初回結果を再返却。

## Correlation ID
- すべての内部/外部呼び出しで伝播。

## Audit ID
- 監査検索の一意キーとして利用。

## External ACK仕様
- ACK受領までは `EXTERNAL_ACK` 状態を維持。

## Webhook仕様
- 署名検証必須。
- 再送時も冪等処理。
