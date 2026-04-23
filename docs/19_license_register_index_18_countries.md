# 19 交付金融免許番号（18カ国）当局公式サイト掲載一覧 + インデックス検索設計

## 目的
- 18カ国について、**当局公式サイトの免許/登録確認ページ**を単一インデックスで検索可能にする。
- AIオペレーションが「どの当局で、どのURLを、どう照合したか」を証跡化できるようにする。

## 18カ国 公式掲載先（一次ソース）
| No | 国 | 主管当局 | 公式掲載URL（免許/登録照会） | 検索キー例 |
|---:|---|---|---|---|
| 1 | 日本 | 金融庁 (FSA) | https://www.fsa.go.jp/en/regulated/licensed/index.html | 法人名 / 登録区分 |
| 2 | 米国 | FDIC | https://banks.data.fdic.gov/bankfind-suite/ | Bank Name / FDIC Cert |
| 3 | 英国 | FCA | https://www.fca.org.uk/firms/financial-services-register | FRN / Firm Name |
| 4 | アイルランド | Central Bank of Ireland | https://registers.centralbank.ie/ | Firm Name / Register Type |
| 5 | フランス | ACPR (REGAFI) | https://www.regafi.fr/ | RCS / Nom |
| 6 | ドイツ | BaFin | https://www.bafin.de/EN/PublikationenDaten/Datenbanken/datenbanken_artikel_en.html | Company / Register |
| 7 | オランダ | DNB | https://www.dnb.nl/en/public-register/ | Institution Name |
| 8 | スペイン | Banco de España | https://www.bde.es/wbe/en/punto-informacion/contenidos/registros/registros-entidades/ | Entidad / Código |
| 9 | イタリア | Banca d'Italia | https://www.bancaditalia.it/compiti/vigilanza/albi-elenchi/ | Intermediario / Albo |
|10 | スイス | FINMA | https://www.finma.ch/en/finma-public/authorised-institutions-individuals-and-products/ | Institution / Category |
|11 | オーストラリア | APRA | https://www.apra.gov.au/registers | Entity Name |
|12 | シンガポール | MAS | https://eservices.mas.gov.sg/fid | Institution / Licence Type |
|13 | 香港 | HKMA | https://apps.hkma.gov.hk/ | Institution / Register Type |
|14 | インド | RBI | https://rbi.org.in/CommonPerson/english/scripts/banksinindia.aspx | Bank Name / Category |
|15 | サウジアラビア | SAMA | https://www.sama.gov.sa/en-US/LicenseEntities/Pages/LicensedBanks.aspx | Licensed Entity Name |
|16 | UAE | CBUAE | https://www.centralbank.ae/en/licensing/ | Institution Name |
|17 | ブラジル | Banco Central do Brasil | https://dadosabertos.bcb.gov.br/dataset/relacao-de-instituicoes-em-funcionamento-no-pais | CNPJ / Institution |
|18 | メキシコ | CNBV | https://www.cnbv.gob.mx/Paginas/InfoPES.aspx | Entidad / Sector |

## AI運用（確認フロー）
1. 入力された法人名・英語表記・既知ID（LEI/BIC等）を正規化。
2. 上記18カ国インデックスから対象国の当局URLを決定。
3. ブラウザーで公式掲載ページを検索（社名、番号、支店名）。
4. 一致結果を `source_url`, `captured_at`, `raw_name`, `license_id` で記録。
5. 手動レビュー者が `verified=true/false` を確定。

## ブラウザー掲載・インデックス検索エンジン要件
- **Index Source**: `docs/19_license_register_index_18_countries.md` のテーブルを正とする。
- **Search Mode**:
  - exact match（免許番号/登録番号）
  - normalized name match（全角半角・法人格揺れ吸収）
  - alias match（英語名/ブランド名）
- **Evidence**:
  - `country`, `authority`, `source_url`, `query`, `result_snapshot_hash`, `reviewer`, `audit_id`
- **Safety**:
  - 公式ドメイン以外を証跡として採用しない。
  - AI単独で最終確定しない（human approval 必須）。

## D1 保存フィールド（最小）
- `country_code`
- `authority_name`
- `authority_registry_url`
- `entity_name_input`
- `entity_name_matched`
- `license_number`
- `match_confidence`
- `source_captured_at`
- `evidence_hash`
- `reviewer_role`
- `correlation_id`
- `audit_id`

## 運用ルール
- 月次でURL生存確認（HTTP 200 / リダイレクト妥当性）
- 四半期で当局サイト仕様変更を点検
- 仕様変更時は `docs/19` を先に更新し、次に実装を更新
