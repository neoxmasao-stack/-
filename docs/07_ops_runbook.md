# 07_ops_runbook

## 障害時の手順
1. 影響範囲特定
2. Kill Switch判定
3. 取引停止/縮退運転
4. 復旧手順実行
5. 事後監査

## Kill Switch
- 高リスク異常時に新規処理を即時停止。

## Resume
- 復旧検証後、段階的に処理再開。

## Queue Replay
- 死亡キューを順序保証付きで再実行。

## Region Failover
- プライマリ障害時にセカンダリへ切替。

## Worker Redeploy
- 破損Workerをローリング再配置。

## D1 Restore
- スナップショットからの復元手順を定義。

## R2 Restore
- オブジェクトストア復元手順を定義。

## Secret Rotate
- 漏えい疑い時に即時ローテーション。

## インシデント対応
- タイムライン記録、根本原因分析、再発防止を実施。
