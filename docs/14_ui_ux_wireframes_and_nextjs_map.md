# 14 ハイクオリティ UI/UX 設計 + Next.js 構成マップ

## 1. 共通レイアウト（App Shell）
```text
Header (Logo / Search / Alerts / Realtime / User Menu)
Sidebar (Dashboard, Customers, Accounts, Groups, Revenue, Infra, Cards, Transfers, ATM, Risk, Audit, Legal, Filings, Admin, Recovery)
Main Workspace (Page Header, KPI, Filters, Table/Chart, Drawer, Modal)
Right Context Panel
Footer Status Bar (latency, queue depth, stream health, incident count)
```

## 2. 主要ページワイヤー
- Dashboard: KPI + Rail status + Incident summary + Liquidity + Risk + Queue/Stream health
- Customers: 検索/絞込、顧客テーブル、KYC/Riskチップ、詳細Drawer、Freeze/Restrict
- Accounts: KPI、残高系、ステータス、イベントタイムライン、Freeze/Resume
- Transfers: テーブル、Status stepper、ACK panel、Retry/Escalate、Audit trail
- Cards: Virtual発行、Limit/MCC、Auth timeline、Freeze/Resume、Fraud alerts
- Mobile ATM: Reservation、QR/Token、拠点統計、Expired/Failed/Reversed
- Risk/AML: Case table、Rule match、Manual review drawer
- Audit/Compliance: Operator action、Ledger event、Export/Evidence
- Infra/SRE: API latency、Error rate、Queue depth、D1/KV/R2/DO health、Kill switch
- Legal/Licenses: ライセンス、登記、契約、証書/原本、手続き、提出物
- Recovery/DR: Backup、Snapshot、Replay、Projection rebuild、Queue replay、Runbook

## 3. Next.js App Router 構成（実装ガイド）
```text
src/app/(public): login, mfa, access-denied, session-expired
src/app/(protected): dashboard, customers, accounts, groups, revenue, infra, cards, transfers, atm, risk, audit, legal, filings, admin, recovery
src/components: shell, auth, dashboard, customers, accounts, transfers, cards, atm, risk, audit, infra, legal, recovery, shared
src/providers: auth/session/tenant/realtime/toast
src/hooks: domain hooks (use-transfers, use-risk, use-recovery ...)
src/stores: state stores
src/lib: api/auth/rbac/realtime/validation/constants
src/types: domain types
```

## 4. 設計原則
- KPI → 一覧 → 詳細 → 操作 の導線を全ページで統一
- 危険操作は二重確認 + 理由入力
- リアルタイム変化は平滑反映（ちらつき抑制）
- 監査性をUIに埋め込む（actor/reason/correlation_id可視化）
- 復旧操作まで同一体験で一貫化

## 5. 一言でまとめると
Pages = 判断する場所  
Components = 操作部品  
Stores = 状態の頭脳  
Providers = 全体基盤  
Hooks = 振る舞い再利用  
Lib = 共通ロジック
