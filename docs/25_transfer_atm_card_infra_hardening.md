# 25 送金 / ATM / CARD / 金融インフラ 強化計画

## 目的
- 送金・ATM・カード・基盤（SRE/Infra）の運用を、**事故予防 + 監査証跡 + 復旧性**の観点で強化する。
- 「運用可能」から「統制自動化」へ移行するための必須コントロールを定義する。

## 1) 送金（Transfer）強化
- `INIT -> VALIDATING -> AML_REVIEW -> ... -> EXTERNAL_ACK -> FINALIZED` の遷移逸脱を自動検知。
- `FINALIZED` には外部 ACK 必須（ACK 欠落時は `RECONCILIATION_REQUIRED`）。
- 高額・高リスク国・高頻度を自動エスカレーション（maker-checker 強制）。
- 失敗時は retry policy（指数バックオフ）+ DLQ + manual review を必須化。

### KPI
- 重複送金件数 = 0
- ACK未着でのFINALIZED件数 = 0
- reconciliation break 対応SLA

## 2) ATM 強化
- ワンタイムトークン短命化（TTL）と再利用禁止を強制。
- `FAILED` / `EXPIRED` は自動で reversal 判定へ送る。
- ATMネットワーク障害時の fallback と復旧イベントを監査記録。
- ATM拠点異常（急増/急減/不正疑い）をアラート。

### KPI
- reversal 処理時間
- トークン再利用件数 = 0
- ATM障害時の復旧時間（MTTR）

## 3) CARD 強化
- 発行・オーソリ・精算のイベント完全性を検証（欠損検知）。
- MCC / merchant lock / limit をポリシーで強制。
- 不正利用スコア連携で即時 freeze / manual review へ遷移可能にする。
- tokenized PAN 前提（機微情報を直接保存しない）。

### KPI
- 不正利用率
- 誤停止率
- オーソリ遅延P95

## 4) 金融インフラ（SRE）強化
- API latency / error rate / queue depth / stream lag / dependency health を常時監視。
- kill switch / replay / projection rebuild / region failover の訓練を定期実施。
- DR drill のRPO/RTOを定義し、月次で達成可否を記録。
- インシデントは必ず postmortem と再発防止策まで記録。

### KPI
- 可用性 99.99%
- Error Budget 消費率
- Queue Lag
- DR drill 合格率

## 5) Go-Live 追加コントロール（推奨）
- `CHECK_TRANSFER_GUARDRAILS`
- `CHECK_ATM_GUARDRAILS`
- `CHECK_CARD_GUARDRAILS`
- `CHECK_INFRA_SRE_GUARDRAILS`

これらは `.golive.env` で 0/1 管理し、Strict gate では全て 1 を要求する。
