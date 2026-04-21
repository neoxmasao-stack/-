# 07_ops_runbook

## 障害時の手順
1. 影響範囲確認
2. Kill Switch判断
3. 代替処理または復旧
4. 監査記録作成

## Kill Switch
- 重大障害時に新規処理停止

## Resume
- 検証後に段階的再開

## Queue Replay
- 保留キューを順序維持で再実行

## Region Failover
- DRリージョンへ切替

## Worker Redeploy
- 不健全ワーカーをローリング再配置

## D1 Restore
- バックアップ世代から復元

## R2 Restore
- オブジェクトストア復元と整合チェック

## Secret Rotate
- 侵害疑い時に即時ローテート

## インシデント対応
- 連絡、封じ込め、根本原因分析、再発防止
