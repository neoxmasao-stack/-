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
$P="C:\Users\aiktn\fin-os-prod\docs"; New-Item -ItemType Directory -Force $P | Out-Null; "01_system_role.md","02_business_rules.md","03_state_machine.md","04_security_policy.md","05_api_contracts.md","06_ledger_rules.md","07_ops_runbook.md","08_ai_prompt_library.md","09_compliance_policy.md","10_ui_behavior.md" | ForEach-Object { New-Item -ItemType File -Force "$P\$_" | Out-Null }; Write-Host "DOCS READY: $P" -ForegroundColor Green
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
Set-Location C:\Users\aiktn\fin-os-prod\docs; Get-ChildItem *.md | Select-Object Name
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
