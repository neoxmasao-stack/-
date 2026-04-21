# 06_ledger_rules

## append-only
- 台帳は追記専用、更新/削除不可

## projection rebuild
- イベントから投影を再構築可能

## reconciliation
- 内部台帳と外部残高を定期照合

## snapshot
- リプレイ高速化のためスナップショット保存

## replay
- 監査・復旧でイベント再生可能

## 差分修復
- 差分検知時は補正イベントで修復

## duplicate handling
- 重複イベントは冪等処理で無害化

## 外部台帳比較
- 銀行・決済ネットワークと突合
