# 12 Bank License Original Acquisition Playbook

## ① 完成コード（運用ドキュメント分離）
金融業務をAIでフルオート化する場合、必要なのは1個の長いプロンプトではなく、役割別ドキュメント群。
最適構成は以下の通り。

- 01_system_role.md
- 02_business_rules.md
- 03_state_machine.md
- 04_security_policy.md
- 05_api_contracts.md
- 06_ledger_rules.md
- 07_ops_runbook.md
- 08_ai_prompt_library.md
- 09_compliance_policy.md
- 10_ui_behavior.md

## ② ワンライナー（PowerShell）
```powershell
$P = Join-Path (Get-Location) 'docs'; New-Item -ItemType Directory -Force $P | Out-Null; "01_system_role.md","02_business_rules.md","03_state_machine.md","04_security_policy.md","05_api_contracts.md","06_ledger_rules.md","07_ops_runbook.md","08_ai_prompt_library.md","09_compliance_policy.md","10_ui_behavior.md" | ForEach-Object { New-Item -ItemType File -Force (Join-Path $P $_) | Out-Null }; Write-Host "DOCS READY: $P" -ForegroundColor Green
```

## ③ 最小アーキテクチャ説明
```text
[AI Role]
  ↓
[Business Rule]
  ↓
[State Machine]
  ↓
[Security / Audit / Recovery]
```
これを分離しないと、AIが曖昧判断を始めて事故率が上がる。

## ④ リカバリ手順
```powershell
Get-ChildItem .\docs\*.md | Select-Object Name
```

## ⑤ リスクポイント
- 1個の巨大プロンプトに全内容を詰め込むと管理不能になる
- 業務ルールと状態遷移を分離しないと誤判断が増える
- API仕様と監査仕様を別管理しないと整合性が崩れる
- Runbook不在だと障害時の人手対応が破綻する
- Compliance後付けは本番運用不可

## ⑥ 改善余地
- 各mdをGit管理
- 変更履歴を保存
- 監査承認フロー追加
- Prompt Libraryを職種別に分割
- 業務別状態遷移図をMermaid化
- Runbookを自動テスト化

## ⑦ 実務フロー要約（適法取得専用）
- 金融庁: 免許・許可・登録の公表確認
- 法務局: 登記事項証明書（原本）
- 国税庁: 法人番号確認
- GLEIF: LEI照合
- GLEIF/SWIFT系: BIC存在確認（接続性は別証跡）
- 必要時 e-Gov: 行政文書開示請求

最短順序: 金融庁確認 → 法務局原本取得 → 国税庁番号確認 → GLEIF照合 → 必要時e-Gov。

## ⑧ 法務・銀行免許番号・BIC・LEI 申請/取得手続き（日本拠点想定）

### 1. 法務（法人実在性）の取得手続き
- 法務局で登記事項証明書（履歴事項全部証明書）を取得
- 代表者事項証明書、印鑑証明書、定款、株主名簿（要求時）を準備
- 国税庁法人番号公表サイトで法人番号と商号/所在地一致を確認

### 2. 銀行免許番号（銀行業免許）の確認/証跡化
- 日本では「銀行業の免許」は金融庁・財務局公表情報で確認する
- 実務上は「免許番号そのもの」だけでなく、免許主体・営業所・有効性をセットで証跡化
- 証跡は公表画面PDF、取得日時、URL、ハッシュ値、担当者署名を監査台帳へ保存

### 3. BIC（SWIFT/BIC）の取得手続き
- SWIFT参加要件を確認し、接続方式（Service Bureau / Alliance）を選定
- 申請主体の法的情報（登記、規制ライセンス、運用責任者）を提出
- 発番後はBICと接続疎通証跡（RMA/テストメッセージ）を別管理

### 4. LEI（Legal Entity Identifier）の取得手続き
- LOU（発番機関）経由でLEIを申請（法人登記情報・代表者情報を提出）
- 発番後は毎年更新（renewal）を実施し、LAPSED化を防止
- GLEIF検索結果を監査ログに保存し、KYC/AML判定に連携

### 5. 申請〜取得の推奨順序
1) 法務局資料取得
2) 規制当局ライセンス確認（銀行業免許）
3) LEI申請・発番
4) SWIFT/BIC申請
5) API契約・台帳連携・監査証跡固定

### 6. 監査で必須になる保存物
- 申請書類控え（版管理付き）
- 当局/発番機関からの受領通知
- 公表情報スナップショット（日時・URL・ハッシュ）
- 更新期限一覧（LEI更新、証明書更新、接続証明更新）

### 7. 運用上の注意点
- BICは「取得済み」でも実接続可否は別審査になるため、運用判定を分離
- LEIは更新失効で取引先審査に影響するため、Runbookに更新ジョブを明記
- 免許確認は定期再照合（最低四半期）を実行し、差分を法務承認フローへ回す
