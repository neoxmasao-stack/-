# 18 AI運用ガードレール（本番金融向け）

## 目的
「AI などはどうなってる？」に対する運用答えを明文化する。
本番金融品質では、AIは**自動決裁者ではなく、判断補助 + 証跡生成 + 検知補助**に限定する。

## AIの担当領域
- AI-CUSTOMER: 顧客属性・KYC不足検出
- AI-PAYMENT: 送金状態追跡・ACK遅延検知
- AI-RISK: AML/制裁レビュー補助
- AI-LEGAL: ライセンス期限・提出不足検出
- AI-AUDIT: 監査証跡集約
- AI-SRE: 障害ログ要約・仮説提示
- AI-REVENUE: 収益差分分析

## 絶対禁止
- AI単独の `FINALIZED` 実行
- AI単独の凍結解除
- AI単独の権限変更
- AI単独の監査ログ削除/改変
- AI単独のKill Switch解除

## Human-in-the-loop 境界
以下は必ず人間承認（Maker-Checker）:
1. 高額送金承認
2. 送金再開/復旧
3. 顧客凍結解除
4. ライセンス申請提出
5. 保持年限に関わる破棄操作

## Go-Live AIチェック
`.golive.env` で以下を 1 に設定できた場合のみ、AI運用は本番準備完了とみなす。
- `CHECK_AI_ROLE_SEPARATION`
- `CHECK_AI_HUMAN_APPROVAL`
- `CHECK_AI_POLICY_GUARD`
- `CHECK_AI_AUDIT_TRACE`

## 証跡要件
AIが関与した判断には必ず次を記録する。
- `actor_type=AI`
- `ai_role`
- `model_version`
- `input_hash`
- `output_hash`
- `reviewer`
- `correlation_id`
- `audit_id`

## 運用KPI
- AI提案採用率
- AI提案差戻し率
- AI由来インシデント件数（目標 0）
- AI判断の人間レビュー完了率（目標 100%）
