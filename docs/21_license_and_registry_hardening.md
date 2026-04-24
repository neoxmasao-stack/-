# 21 ライセンス・登記簿 徹底強化ガイド（Production Hardening）

## 目的
- 金融ライセンス、会社登記、原本証憑を **提出→受理→公開→内部台帳反映→監査保全** まで一貫管理する。
- 「掲載確認だけ」で終わらせず、期限・更新・失効・差戻し・訴訟保全まで運用可能にする。
- 代理弁護士・司法書士・社内担当の責任境界をRACIで固定し、AIは補助に限定する。

## 適用範囲
- 全ライセンス（銀行、資金移動、決済、EMI/PI、カード関連、国別登録）
- 会社登記（履歴事項全部証明書、現在事項証明書、代表者事項証明書）
- 当局提出物、受理番号、公開ページ、更新期限
- 原本（PDF/公的CSV/XLS等）と監査エビデンス

## 1. 運用原則（Hard Rules）
1. **公式一次ソース優先**：当局公開ポータル、法務局/登記当局、公式APIのみ。
2. **原本優先**：スクリーンショットは補助。主証跡は原本ファイル + hash。
3. **番号一致優先**：照合は 番号一致 > 名称一致 > 住所一致。
4. **更新期限の先回り**：期限切れを発生させない（T-90/T-30/T-7/T-1 通知）。
5. **失効即時隔離**：失効・停止・取消時は対象業務を自動制限。
6. **AI最終決裁禁止**：AIは候補提示のみ。承認は人間責任者。

## 2. ライセンス・登記ライフサイクル
```text
DRAFT
  → LEGAL_REVIEW
  → DOCUMENT_COLLECTION
  → APPLICATION_SUBMITTED
  → RECEIPT_ACCEPTED
  → AUTHORITY_REVIEW
  → APPROVED / REJECTED / RETURNED
  → PUBLICATION_CONFIRMED
  → REGISTRY_EXTRACT_CONFIRMED
  → INTERNAL_LEDGER_SYNCED
  → EXPIRY_MONITORED
  → RENEWAL_IN_PROGRESS
  → RENEWED / LAPSED
```

### 異常系
- `MISMATCH_DETECTED`（公開情報と登記/台帳に差分）
- `EVIDENCE_MISSING`（原本欠損）
- `LEGAL_HOLD`（廃棄禁止・訴訟保全）

## 3. 登記簿強化チェックリスト（必須）
- 商号（現地語・英語）
- 本店所在地
- 会社法人等番号 / 登録番号
- 代表者
- 役員構成
- 発行日 / 証明書種別
- ライセンス対象法人との紐付け
- 変更履歴（いつ、誰が、何を変更したか）

## 4. RACI（責任分担）
| 項目 | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| 当局提出書類作成 | 法務担当 | CLO | 代理弁護士 | COO |
| 登記証明書取得 | 司法書士 | CLO | 法務担当 | 監査 |
| 公開掲載確認 | コンプラ担当 | CCO | 法務担当 | COO |
| 原本hash登録 | オペレーション担当 | CTO | 監査 | CCO |
| 更新期限管理 | コンプラ担当 | CCO | 法務担当 | CTO |
| 失効時業務制限 | SRE + Ops | CTO | CCO/CLO | 全関係者 |

## 5. D1推奨テーブル（強化版）
- `license_master`
- `license_jurisdiction_links`
- `license_application_events`
- `license_receipt_events`
- `license_publication_events`
- `corporate_registry_documents`
- `corporate_registry_change_log`
- `legal_evidence_hashes`
- `legal_hold_flags`
- `expiry_alert_queue`

### 必須カラム（最小）
- `entity_id`
- `country_code`
- `authority_name`
- `license_type`
- `license_number`
- `registry_number`
- `status`
- `effective_date`
- `expiry_date`
- `source_url`
- `source_format`
- `content_hash_sha256`
- `reviewed_by`
- `approved_by`
- `correlation_id`
- `audit_id`

## 6. SLA / KPI（ライセンス・登記）
- 期限超過件数: **0**
- 原本hash欠損件数: **0**
- 公開掲載確認遅延（受理後）: **3営業日以内**
- 登記差分未解消件数: **0**
- 失効検知〜業務制限反映: **30分以内**

## 7. 自動制御（必須）
- `expiry_date` が T-90/T-30/T-7/T-1 で通知キュー投入。
- `status in (LAPSED, REJECTED, REVOKED)` の場合、対象プロダクト操作をRBACで停止。
- `EVIDENCE_MISSING` は Strict Gate でデプロイブロック。
- `MISMATCH_DETECTED` は manual review + 二重承認必須。

## 8. 監査イベント（追加）
- `LICENSE_RENEWAL_ALERT_TRIGGERED`
- `LICENSE_STATUS_REVOKED`
- `CORPORATE_REGISTRY_EXTRACT_CONFIRMED`
- `CORPORATE_REGISTRY_MISMATCH_DETECTED`
- `LEGAL_EVIDENCE_HASH_REGISTERED`
- `LEGAL_HOLD_ENABLED`
- `LEGAL_HOLD_RELEASED`

## 9. Go-Live連携チェック
- D6: `CHECK_CORPORATE_REGISTRY_TRACKING=1`
- D7: `CHECK_LICENSE_EXPIRY_ALERTING=1`
- L12〜L15: 法務クリーンチェックで登記・期限・hash・保全運用を検証

## 10. 一言で定義
ライセンスと登記簿を「確認資料」ではなく、
**運用を停止/継続判断できる制御データ**として管理する。


## 法人登記簿 + 識別番号（SWIFT/BIC・IBAN・LEI・全銀）確認コマンド

```bash
make identifier-registry-check
# 本番判定
make identifier-registry-check-strict
```

- 実装: `scripts/identifier_registry_check.sh`
- レポート: `artifacts/identifier-registry-report.md`
- `docs/19` の 21カ国行数 / 主検索キー（免許・登録番号） / 公式HTTPSリンク数も同時に検証。
- フラグ: `.golive.env` の `CHECK_CORPORATE_REGISTRY_*` / `CHECK_SWIFT_BIC_IDENTIFIER` / `CHECK_IBAN_IDENTIFIER` / `CHECK_LEI_IDENTIFIER` / `CHECK_ZENGIN_IDENTIFIER` / `CHECK_IDENTIFIER_EVIDENCE_ARCHIVED`
