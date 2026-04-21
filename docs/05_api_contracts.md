# 05 API Contracts

## 共通
- Request / Response を JSON で統一
- Error Code を固定化
- Timeout / Retry Policy を定義
- Idempotency-Key 必須
- Correlation-ID 必須
- Audit-ID 必須

## 外部連携
- External ACK の受領仕様を明文化
- Webhook 冪等処理を必須化
