# FIN-OS 組織分掌・金融業務・システム全般指示
Version: PROD-SSSS  
Owner: CTO / FIN-OS Control Tower  
Purpose: 金融業務・システム・法務・監査・運用を分掌し、責任境界を明確化する。

## 1. 基本原則
### 1.1 優先順位
1. 法令遵守
2. 顧客資産保全
3. 台帳整合性
4. 決済確定性
5. 可用性
6. 収益性
7. 業務効率

### 1.2 絶対禁止
- 外部ACK未受領で `FINALIZED` 遷移
- idempotencyなし再送
- 監査ログなし状態変更
- 権限外ユーザーによる承認/停止/復旧
- 法務・保存義務書類の無断削除

### 1.3 共通必須要件
- 重要操作に `actor`, `role`, `reason`, `correlation_id`, `ts` を記録
- 更新系APIは `idempotency-key` 必須
- 例外は `retryable / non_retryable / manual_review` に分類
- 本番変更はロールバック手順先行

## 2. 役割定義
- CTO: 本番変更承認、可用性/監査/セキュリティ最終判断
- COO: 業務要件承認、SLA判断
- CCO: AML/KYC/当局対応承認
- CLO: 契約・原本・証書・ライセンス・登記管理責任

## 3. 分野別担当
### 3.1 顧客管理
責任: 顧客プロファイル、KYC、制限/凍結、関連資産紐付け。  
KPI: KYC完了率、変更処理時間、制限誤判定件数。

### 3.2 口座管理
責任: 口座状態・残高・制限管理。  
必須: 手動残高更新禁止、凍結/解放は二重承認。  
状態: `ACTIVE / PENDING / FROZEN / SUSPENDED / CLOSED / BLOCKED`。

### 3.3 送金・決済
責任: 送金作成、承認、外部ACK、確定、照合。  
必須: `FINALIZED` は外部ACK必須。ACK不一致は `RECONCILIATION_REQUIRED`。

標準遷移:
```text
INIT → VALIDATING → AML_REVIEW → LIQUIDITY_CHECK → APPROVAL_REQUIRED → APPROVED
→ BANK_PENDING / RTGS_PENDING / CBDC_PENDING → EXTERNAL_ACK → FINALIZED
```
異常系: `FAILED / RETRYING / MANUAL_REVIEW / RECONCILIATION_REQUIRED / BLOCKED / HALTED`

### 3.4 カード/バーチャルカード
責任: 発行、制限、オーソリ、停止/再開。  
必須: PAN直接保持禁止、processor token利用、高リスク加盟店は既定拒否。

### 3.5 スマホATM
責任: トークン発行、ATM照合、出金/入金、reversal。  
必須: トークン短命・再利用禁止。

### 3.6 リスク/AML
責任: AMLルール、sanctions/PEP、手動審査。  
必須: block理由記録、ルール版管理。

### 3.7 法務・ライセンス・原本
責任: 契約、ライセンス、登記、原本、保存年限、訴訟保全。  
必須: 原本所在管理、期限超過即アラート、廃棄禁止フラグ尊重。

### 3.8 監査
責任: 操作監査、台帳監査、証跡出力。  
必須: 監査ログ欠損0、改ざん不可前提。

### 3.9 収益
責任: 収益集計、採算、配賦、Treasuryビュー。  
必須: 台帳再計算可能性、手数料ルール版管理。

### 3.10 SRE
責任: Workers/D1/KV/R2/Queue/DO運用、監視、DR。  
必須: canary/rollback前提、Queue滞留閾値監視、replay/rebuild訓練。

## 4. AI担当分け
- AI-CUSTOMER, AI-PAYMENT, AI-RISK, AI-LEGAL, AI-AUDIT, AI-SRE, AI-REVENUE

### AI禁止事項
- AI単独で送金確定しない
- AI単独で凍結解除しない
- AI単独で法務文書削除しない
- AI単独で本番権限変更しない

## 5. 全システム指示
- API: idempotency/correlation/actor監査必須、timeout/circuit breaker/fallback
- 台帳: append-only、projection再構築、ledger/projection分離
- UI: 危険操作二重確認、kill switchはadmin/sreのみ
- 運用: 日次health、週次queue/audit/license review、月次DR drill
- セキュリティ: secret manager、key rotation、tenant越境禁止

## 6. 優先実装順
- P0: 認証/RBAC/idempotency/監査ログ/ACK-finalized/Kill Switch
- P1: Retry/DLQ/lock/reconciliation/manual review/approval workflow
- P2: legal/license/original documents/revenue/card/ATM/compliance automation
- P3: multi-region/DR automation/SIEM/SOC/advanced fraud

## 7. 最終定義
- 顧客管理 = 顧客の真実
- 口座管理 = 残高の真実
- 送金管理 = 決済の真実
- 法務管理 = 権利義務の真実
- 監査管理 = 証明の真実
- SRE運用 = 継続稼働の真実
- AI = 判断補助、人間責任者 = 最終決裁
