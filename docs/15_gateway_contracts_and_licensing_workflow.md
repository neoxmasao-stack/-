# 15 API / 送金 / 決済 / ATM / CARD ゲートウェイ契約 + ライセンス申請運用

## 1. 対象スコープ
- API Gateway 契約
- 送金（Transfer）
- 決済（Settlement / Finality）
- スマホATM
- Card / Virtual Card
- ライセンス等の **申請 → 受理 → 公開/掲載**
- 代理弁護士・司法書士との委任契約と作業分担
- 登記簿（会社法人等番号、履歴事項、代表者、所在地）

## 2. ゲートウェイ契約（共通）
### 2.1 必須ヘッダー
- `Idempotency-Key`
- `Correlation-ID`
- `Audit-ID`
- `X-Actor-Role`

### 2.2 セキュリティ
- JWT + MFA 前提
- RBAC による操作制御
- 重要操作は reason 必須
- 署名検証・リプレイ防止を有効化

### 2.3 SLA/SLO
- API availability: 99.99%
- P95 latency: 300ms 以下（内部API目標）
- 重要エンドポイントは timeout / retry / circuit breaker 必須

## 3. ドメイン別 API 契約要点
### 3.1 送金 API
- `INIT → VALIDATING → AML_REVIEW → APPROVAL_REQUIRED → APPROVED → EXTERNAL_ACK → FINALIZED`
- 外部ACK未受領で `FINALIZED` 禁止
- 重複送信は idempotency で拒否

### 3.2 決済 API
- rail別（RTGS/BANK/CBDC）に pending 状態を分離
- settlement lock を実装
- finality確定前に監査証跡を固定化

### 3.3 ATM API
- ワンタイムトークン短命化
- トークン再利用禁止
- `FAILED/EXPIRED` は自動reversal判定へ

### 3.4 CARD API
- PAN 等機微情報の直接保持禁止
- processor token を利用
- 発行・停止・再開・再発行は監査対象
- 不正利用アラートはriskエンジンへ連携

## 4. ライセンス等ワークフロー（申請→受理→公開）
```text
DRAFT
  → LEGAL_REVIEW
  → APPLICATION_SUBMITTED
  → RECEIPT_ACCEPTED
  → AUTHORITY_REVIEW
  → APPROVED / REJECTED
  → PUBLICATION_CONFIRMED
  → LISTING_VERIFIED
  → REGISTRY_EXTRACT_CONFIRMED
```

### 4.1 状態定義
- `APPLICATION_SUBMITTED`: 当局提出完了
- `RECEIPT_ACCEPTED`: 受理番号取得
- `PUBLICATION_CONFIRMED`: 公開ページ掲載確認
- `LISTING_VERIFIED`: 社内台帳との突合完了
- `REGISTRY_EXTRACT_CONFIRMED`: 登記原本との一致確認完了

## 5. 代理弁護士・司法書士 契約/申請分担
### 5.1 代理弁護士
- 行政文書開示・当局照会・法的意見整理
- 申請文面/委任状レビュー
- 差戻し時の法的修正対応

### 5.2 司法書士
- 登記事項証明書・履歴事項全部証明書の取得
- 会社法人等番号・商号・所在地・代表者の整合確認
- 登記変更手続きの実行支援

### 5.3 社内担当（Compliance + Ops）
- 法人番号・LEI・BIC・全銀コード照合
- 申請トラッキング、公開確認、台帳反映
- 監査証跡の保管・エクスポート

## 6. 必須エビデンス項目
- `source`
- `date`
- `method`
- `holder`
- `evidence_hash`
- `correlation_id`
- `audit_id`
- `next_action`
- `registry_number`
- `expiry_date`

## 7. D1 推奨テーブル
- `gateway_contracts`
- `transfer_contract_controls`
- `settlement_contract_controls`
- `atm_contract_controls`
- `card_contract_controls`
- `license_applications`
- `license_receipts`
- `license_publications`
- `corporate_registry_documents`
- `corporate_registry_changes`
- `legal_representative_engagements`
- `evidence_registry`

## 8. 監査イベント名（最小）
- `GATEWAY_CONTRACT_UPDATED`
- `TRANSFER_API_CONTROL_VERIFIED`
- `SETTLEMENT_FINALITY_VERIFIED`
- `ATM_TOKEN_POLICY_VERIFIED`
- `CARD_PROCESSOR_TOKEN_VERIFIED`
- `LICENSE_APPLICATION_SUBMITTED`
- `LICENSE_RECEIPT_ACCEPTED`
- `LICENSE_PUBLICATION_CONFIRMED`
- `LEGAL_REPRESENTATIVE_ASSIGNED`
- `JUDICIAL_SCRIVENER_DOCUMENT_CONFIRMED`
- `CORPORATE_REGISTRY_EXTRACT_CONFIRMED`
- `LICENSE_EXPIRY_ALERT_TRIGGERED`

## 9. 強化運用ルール（追加）
- 期限管理は T-90/T-30/T-7/T-1 で通知し、期限超過件数 0 を維持する。
- `APPROVED` 後に公開掲載が確認できない場合、`LISTING_VERIFIED` へ遷移禁止。
- 登記差分（商号/所在地/代表者/番号）検知時は `MISMATCH_DETECTED` として二重承認レビュー。
- 失効/取消ステータス検知時は対象業務APIを緊急制限し、監査ログへ即時記録する。

## 10. 一言で定義
API/送金/決済/ATM/CARD の契約統制と、ライセンス申請の **申請→受理→公開→登記一致** を同じ監査基盤で追跡し、
代理弁護士・司法書士の責任境界まで含めて管理する。
