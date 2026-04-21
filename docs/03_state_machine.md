# 03_state_machine

## 状態遷移
`INIT` → `VALIDATING` → (`AML_REVIEW` | `APPROVAL_REQUIRED` | `APPROVED`) → `RTGS_PENDING` → `EXTERNAL_ACK` → `FINALIZED`

異常系:
- `FAILED`
- `RETRYING`
- `MANUAL_REVIEW`
- `RECONCILIATION_REQUIRED`

## 状態一覧
- `INIT`: 取引受付直後
- `VALIDATING`: フォーマット/残高/口座属性検証
- `AML_REVIEW`: AML/KYC/制裁照合
- `APPROVAL_REQUIRED`: 閾値超過による承認待ち
- `APPROVED`: 承認完了
- `RTGS_PENDING`: 決済ネットワーク送信待ち
- `EXTERNAL_ACK`: 外部ACK待ち
- `FINALIZED`: 台帳確定
- `FAILED`: 処理失敗
- `RETRYING`: 自動再試行中
- `MANUAL_REVIEW`: 人手審査
- `RECONCILIATION_REQUIRED`: 台帳差異検出

## 遷移原則
- すべての遷移はイベント駆動。
- 遷移ごとに監査イベントを必須出力。
- 失敗時はロールバックではなく補正イベントで整合性維持。
