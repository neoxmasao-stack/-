# 19 交付金融ライセンス（21カ国）当局公式掲載 詳細一覧 + インデックス検索設計

## 目的
- 21カ国の**交付ライセンス確認先（当局公式）**を、監査可能な1つの参照台帳として固定化する。
- AI/ブラウザー検索運用時に、国別の「どこを見ればよいか」「何を証跡化すべきか」を明確化する。
- 追加要件として **リトアニア / ケイマン / エストニア** を索引へ組み込む。

## 21カ国 詳細一覧（公式一次ソース）
| No | 国 | 主管当局 | ライセンス種別（例） | 公式掲載URL | 主検索キー | 必須証跡 |
|---:|---|---|---|---|---|---|
| 1 | 日本 | 金融庁 (FSA) | 銀行/資金移動/金商/貸金 | https://www.fsa.go.jp/en/regulated/licensed/index.html | 法人名/登録区分 | URL・取得日時・掲載名ハッシュ |
| 2 | 米国 | FDIC | Insured Bank | https://banks.data.fdic.gov/bankfind-suite/ | Bank Name/FDIC Cert | Cert番号・画面スナップハッシュ |
| 3 | 英国 | FCA | Authorized Firm/EMI/PI | https://www.fca.org.uk/firms/financial-services-register | FRN/Firm Name | FRN・Status・有効日 |
| 4 | アイルランド | Central Bank of Ireland | Authorized Firms | https://registers.centralbank.ie/ | Firm Name/Register | 登録ID・カテゴリ |
| 5 | フランス | ACPR (REGAFI) | Bank/Payment Institution | https://www.regafi.fr/ | RCS/Nom | REGAFI結果・ステータス |
| 6 | ドイツ | BaFin | Credit/Payment/E-money | https://www.bafin.de/EN/PublikationenDaten/Datenbanken/datenbanken_artikel_en.html | Company/Register | 登録DB名・照合結果 |
| 7 | オランダ | DNB | Financial Institutions | https://www.dnb.nl/en/public-register/ | Institution Name | レジスタ種別・状態 |
| 8 | スペイン | Banco de España | Entidades de crédito | https://www.bde.es/wbe/en/punto-informacion/contenidos/registros/registros-entidades/ | Entidad/Código | コード・掲載区分 |
| 9 | イタリア | Banca d'Italia | Albi/Elenchi intermediari | https://www.bancaditalia.it/compiti/vigilanza/albi-elenchi/ | Intermediario/Albo | Albo番号・カテゴリ |
|10 | スイス | FINMA | Authorized Institutions | https://www.finma.ch/en/finma-public/authorised-institutions-individuals-and-products/ | Institution/Category | FINMA掲載状態 |
|11 | オーストラリア | APRA | ADI/Financial Entity | https://www.apra.gov.au/registers | Entity Name | Register名・Entity抽出 |
|12 | シンガポール | MAS | Financial Institution/License | https://eservices.mas.gov.sg/fid | Institution/Licence Type | FID結果・ライセンス区分 |
|13 | 香港 | HKMA | Authorized Institutions | https://apps.hkma.gov.hk/ | Institution/Register | 掲載画面ID・状態 |
|14 | インド | RBI | Scheduled/Commercial Banks | https://rbi.org.in/CommonPerson/english/scripts/banksinindia.aspx | Bank Name/Category | 掲載カテゴリ・名称一致 |
|15 | サウジアラビア | SAMA | Licensed Banks/Finance | https://www.sama.gov.sa/en-US/LicenseEntities/Pages/LicensedBanks.aspx | Licensed Entity | ライセンス区分・掲載名 |
|16 | UAE | CBUAE | Licensed Financial Institutions | https://www.centralbank.ae/en/licensing/ | Institution Name | 登録区分・掲載根拠URL |
|17 | ブラジル | Banco Central do Brasil | Instituições em funcionamento | https://dadosabertos.bcb.gov.br/dataset/relacao-de-instituicoes-em-funcionamento-no-pais | CNPJ/Institution | CNPJ一致・データ日付 |
|18 | メキシコ | CNBV | Entidades supervisadas | https://www.cnbv.gob.mx/Paginas/InfoPES.aspx | Entidad/Sector | セクター・掲載状況 |
|19 | リトアニア | Bank of Lithuania | Payment/E-money/Bank licenses | https://www.lb.lt/en/sfi-financial-market-participants | Name/License number | 番号・カテゴリ・掲載日 |
|20 | ケイマン諸島 | Cayman Islands Monetary Authority (CIMA) | Licensed entities | https://www.cima.ky/regulated-entities | Entity/License type | 登録種別・掲載名・取得日時 |
|21 | エストニア | Estonian Financial Supervision and Resolution Authority (Finantsinspektsioon) | Supervised entities | https://www.fi.ee/en/supervision/supervised-entities | Name/Register code | 監督区分・登録番号 |

## コピペ用CSV（日本語名 + 当局名 + URL）
```csv
日本,金融庁 (FSA),https://www.fsa.go.jp/en/regulated/licensed/index.html
米国,FDIC,https://banks.data.fdic.gov/bankfind-suite/
英国,FCA,https://www.fca.org.uk/firms/financial-services-register
アイルランド,Central Bank of Ireland,https://registers.centralbank.ie/
フランス,ACPR (REGAFI),https://www.regafi.fr/
ドイツ,BaFin,https://www.bafin.de/EN/PublikationenDaten/Datenbanken/datenbanken_artikel_en.html
オランダ,DNB,https://www.dnb.nl/en/public-register/
スペイン,Banco de España,https://www.bde.es/wbe/en/punto-informacion/contenidos/registros/registros-entidades/
イタリア,Banca d'Italia,https://www.bancaditalia.it/compiti/vigilanza/albi-elenchi/
スイス,FINMA,https://www.finma.ch/en/finma-public/authorised-institutions-individuals-and-products/
オーストラリア,APRA,https://www.apra.gov.au/registers
シンガポール,MAS,https://eservices.mas.gov.sg/fid
香港,HKMA,https://apps.hkma.gov.hk/
インド,RBI,https://rbi.org.in/CommonPerson/english/scripts/banksinindia.aspx
サウジアラビア,SAMA,https://www.sama.gov.sa/en-US/LicenseEntities/Pages/LicensedBanks.aspx
UAE,CBUAE,https://www.centralbank.ae/en/licensing/
ブラジル,Banco Central do Brasil,https://dadosabertos.bcb.gov.br/dataset/relacao-de-instituicoes-em-funcionamento-no-pais
メキシコ,CNBV,https://www.cnbv.gob.mx/Paginas/InfoPES.aspx
リトアニア,Bank of Lithuania,https://www.lb.lt/en/sfi-financial-market-participants
ケイマン諸島,CIMA,https://www.cima.ky/regulated-entities
エストニア,Finantsinspektsioon,https://www.fi.ee/en/supervision/supervised-entities
```

## PDF / 原本 / 各国公式フォーマット保存ルール
- 原本は「当局公式サイトで提供される形式」を優先し、**PDF/CSV/XLS/XLSX/HTML** を区別して保存する。
- 保存時メタデータ（必須）:
  - `source_url`
  - `source_format`（PDF/CSV/XLS/XLSX/HTML）
  - `downloaded_at`
  - `content_hash_sha256`
  - `issuer_authority`
  - `country_code`
  - `reviewed_by`
- PDF原本は可能な限り改ざん耐性のため `content_hash_sha256` を監査テーブルへ保存。
- スクリーンショットは補助証跡とし、原本ファイル（PDF/CSV等）を主証跡として扱う。

## 国別照合手順（共通）
1. 法人名（現地語/英語）を正規化。
2. 国コードから当局URLを引く。
3. 公式掲載で「番号一致 > 名称一致 > 住所一致」の順で照合。
4. 一致結果を証跡保存（必須証跡カラム）。
5. AIは候補提示のみ、最終確定は人間承認。

## ブラウザー検索 / インデックスエンジン要件
- **Index Source of Truth**: 本ドキュメントの21カ国テーブル。
- **検索モード**:
  - exact: 免許番号/登録番号
  - normalized: 法人格除去・全半角変換
  - alias: 英語名/ブランド名
- **ランキング**:
  - score = 番号一致(0.7) + 正規化名称一致(0.2) + 住所一致(0.1)
- **採用閾値**:
  - score >= 0.85: strong match
  - 0.60〜0.84: manual review
  - <0.60: reject

## AI運用（掲載確認）
- AI入力: `entity_name`, `country_code`, `known_ids`(license/LEI/BIC)
- AI出力: `matched_authority_url`, `candidate_records[]`, `confidence`, `reason`
- 人間承認: `approved_by`, `approved_at`, `approval_reason`

## D1保存フィールド（最小）
- `country_code`
- `authority_name`
- `authority_registry_url`
- `license_category`
- `entity_name_input`
- `entity_name_matched`
- `license_number`
- `source_format`
- `source_captured_at`
- `evidence_hash`
- `reviewer_role`
- `correlation_id`
- `audit_id`

## 運用ルール
- 月次で21URLの生存確認（HTTP 200 / 301 / 302）
- 四半期で当局サイト構造変更を差分点検
- 変更時は `docs/19` → 実装/クローラ設定 の順で更新


## 掲載確認コマンド（公式ポータル一覧）

```bash
make portal-and-external-channel-check
# 本番判定
make portal-and-external-channel-check-strict
```

- このチェックは `docs/19` の 21カ国行数と HTTPS 公式ポータルリンク数を検査。
- あわせて外部接続の `送金 / CARD / ATM` 実装フラグと E2E 証跡フラグを確認。
- レポート: `artifacts/portal-and-external-channel-report.md`
