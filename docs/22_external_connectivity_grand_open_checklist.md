# 22 外部接続・銀行業務 全行程 グランドオープン確認

## 目的
- 銀行業務の本番開始前に、**外部接続を含む全行程**（受付〜最終確定〜監査証跡）を一括で確認する。
- Go-Live判定（A〜F + R）に対し、外部接続の実運用準備を追加で可視化する。

## 対象スコープ
- Bank API / RTGS / CBDC
- Card Processor
- ATM Network
- eKYC / AML / Sanctions
- Notification / SIEM
- 最終確定（External ACK）
- 障害復旧（DR/Failover/Replay）

## グランドオープン判定（G系）
| ID | 判定項目 | 合格基準 |
|---|---|---|
| G1 | Bank API疎通 | 認証付きヘルス + sandbox送信/応答成功 |
| G2 | RTGS/CBDC接続 | 片系停止を含む疎通試験成功 |
| G3 | 外部ACK確定性 | ACK未受領でFINALIZED不可を検証済み |
| G4 | Card Processor連携 | 発行/オーソリ/取消/精算の一連成功 |
| G5 | ATM Network連携 | トークン発行〜払出〜reversal確認済み |
| G6 | AML/Sanctions連携 | HIT時にBLOCK/MANUAL_REVIEWへ遷移 |
| G7 | eKYC連携 | 失敗時のフォールバックと再試行確認 |
| G8 | Notification連携 | 重要イベント通知（成功/失敗）配信確認 |
| G9 | SIEM転送 | 監査・セキュリティイベントの転送確認 |
| G10 | Replay/Recovery | Queue replay + projection rebuild成功 |
| G11 | DR訓練 | Region failover演習でRTO/RPO内 |
| G12 | 運用承認 | CTO/CCO/CLO/COO のGoサイン取得 |

## E2Eシナリオ（銀行業務）
1. 顧客作成・KYC完了
2. 口座開設・残高初期化
3. 送金起票（高額/通常の2系統）
4. AML/制裁チェック
5. 承認（Maker/Checker）
6. Bank/RTGS/CBDC送信
7. 外部ACK受領
8. FINALIZED反映
9. 台帳照合（reconciliation）
10. 監査ログ・証跡エクスポート

## 必須証跡
- `scenario_id`
- `external_system`
- `request_id`
- `correlation_id`
- `audit_id`
- `result`
- `started_at` / `ended_at`
- `evidence_hash`
- `approved_by`

## ブロッカー定義
以下が1件でも未達の場合、グランドオープンは **NO-GO**:
- G3（確定性）
- G6（AML/Sanctions）
- G9（SIEM）
- G10（Replay/Recovery）
- G11（DR訓練）
- G12（経営承認）

## 実行コマンド
```bash
make grand-open-check
# 本番判定
make grand-open-check-strict
```

## 一言で定義
外部接続の「つながる」を確認するだけでなく、
**銀行業務が安全に完了し、復旧まで回ること**を確認して初めてグランドオープンとする。


## 銀行業務全行程の外部接続チェック（公式グランドオープン向け）

```bash
make external-bank-full-journey-check
# 本番判定
make external-bank-full-journey-check-strict
```

- 実装: `scripts/external_bank_full_journey_check.sh`
- レポート: `artifacts/external-bank-full-journey-report.md`
- 確認項目: onboarding / KYC-AML / account+ledger / transfer / ATM / card / filing ack / settlement-recon / recovery-DR / executive signoff
- 変数: `.golive.env` の `CHECK_BANK_*` 系フラグで判定


## 銀行業務全行程モジュール公式グランドオープン

```bash
make bank-full-journey-module-check
# 本番判定
make bank-full-journey-module-check-strict
```

- 実装: `scripts/bank_full_journey_module_check.sh`
- レポート: `artifacts/bank-full-journey-module-report.md`
- 変数: `.golive.env` の `CHECK_BANK_MODULE_*` フラグ
- 用途: 全行程を機能別モジュールで監査し、公式グランドオープン判定の説明責任を高める


## 各国公式ポータル掲載確認 + 外部接続（送金/CARD/ATM）

```bash
make portal-and-external-channel-check
# 本番判定
make portal-and-external-channel-check-strict
```

- 実装: `scripts/portal_and_external_channel_check.sh`
- レポート: `artifacts/portal-and-external-channel-report.md`
- 検査: 21カ国公式ポータル掲載数 / HTTPSリンク数 / 送金実装 / CARD実装 / ATM実装 / E2E証跡
