# FIN-OS Go-Live Automation Scaffold

このリポジトリは、金融業務AI運用を「単一の巨大プロンプト」ではなく、
役割別ドキュメント + Go/No-Go 自動判定で安全に運用するための雛形です。

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

## Quick Start

```bash
make help
make ci
```

Strict判定（本番前）:

```bash
cp .golive.env.example .golive.env
# 値を0/1で更新
make check-go-live
```

## ドキュメント構成

- `docs/01_system_role.md`
- `docs/02_business_rules.md`
- `docs/03_state_machine.md`
- `docs/04_security_policy.md`
- `docs/05_api_contracts.md`
- `docs/06_ledger_rules.md`
- `docs/07_ops_runbook.md`
- `docs/08_ai_prompt_library.md`
- `docs/09_compliance_policy.md`
- `docs/10_ui_behavior.md`
- `docs/12_bank_license_original_acquisition.md`

## リカバリ確認

```powershell
Set-Location C:\Users\aiktn\fin-os-prod\docs; Get-ChildItem *.md | Select-Object Name
```
