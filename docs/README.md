# 金融業務AIフルオート化 ドキュメント（正式グランドオープン）

## 目的
金融業務をAIでフルオート化する際に、**1個の巨大プロンプトではなく、役割ごとに分離した運用ドキュメント群**で本番運用する。

## 最小アーキテクチャ
```text
[AI Role]
   ↓
[Business Rule]
   ↓
[State Machine]
   ↓
[Security / Audit / Recovery]
```

この4層を分離しない場合、AIの曖昧判断による事故率上昇リスクが高まる。

## ドキュメント一覧
1. `01_system_role.md`
2. `02_business_rules.md`
3. `03_state_machine.md`
4. `04_security_policy.md`
5. `05_api_contracts.md`
6. `06_ledger_rules.md`
7. `07_ops_runbook.md`
8. `08_ai_prompt_library.md`
9. `09_compliance_policy.md`
10. `10_ui_behavior.md`

## Windowsワンライナー（初期作成）
```powershell
$P="C:\Users\aiktn\fin-os-prod\docs"; New-Item -ItemType Directory -Force $P | Out-Null; "01_system_role.md","02_business_rules.md","03_state_machine.md","04_security_policy.md","05_api_contracts.md","06_ledger_rules.md","07_ops_runbook.md","08_ai_prompt_library.md","09_compliance_policy.md","10_ui_behavior.md" | ForEach-Object { New-Item -ItemType File -Force "$P\$_" | Out-Null }; Write-Host "DOCS READY: $P" -ForegroundColor Green
```

## リカバリ手順（存在確認）
```powershell
Set-Location C:\Users\aiktn\fin-os-prod\docs; Get-ChildItem *.md | Select-Object Name
```

## リスクポイント
- 1個の巨大プロンプトに全部詰め込むと管理不能。
- 業務ルールと状態遷移を分離しないと誤判断。
- API仕様と監査仕様を別管理しないと整合性崩壊。
- Runbook不在だと障害時の人手復旧が困難。
- Compliance後付けでは本番運用不可。

## 改善余地
- 各mdをGit管理。
- 変更履歴と承認履歴を保存。
- 監査承認フロー追加。
- Prompt Libraryを職種別に分割。
- 状態遷移図をMermaid化。
- Runbookを自動テスト化。
