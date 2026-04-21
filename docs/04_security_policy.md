# 04_security_policy

## RBAC
- ロールごとの操作可能範囲を明示

## JWT
- 短寿命トークン + 署名検証必須

## MFA
- 承認操作・高リスク操作で必須

## Device Trust
- 管理対象端末のみ重要操作許可

## IP制限
- 管理画面は許可IP帯のみ

## IdP
- SSO統合 + 強制プロビジョニング

## Zero Trust
- すべてのリクエストを都度検証

## Secret管理
- Secret Managerで一元管理

## Key Rotation
- 期限付き鍵 + 自動ローテーション

## 監査ログ
- 参照/更新/承認を完全記録

## 改ざん防止
- 監査ログは追記専用 + チェックサム
