.PHONY: help up down health logs ci check-go-live check-go-live-advisory verify-docs legal-clean next-build-debug-local cloudflare-sync-staging cloudflare-sync-production cloudflare-sync-dry-run grand-open-check grand-open-check-strict all-features-check all-features-check-strict official-grand-open-all-features official-grand-open-all-features-advisory external-bank-full-journey-check external-bank-full-journey-check-strict official-live-fire-list official-live-fire-run bank-full-journey-module-check bank-full-journey-module-check-strict portal-and-external-channel-check portal-and-external-channel-check-strict identifier-registry-check identifier-registry-check-strict detailed-report detailed-report-generate country-original-format-report country-original-format-report-strict system-overview-check system-overview-check-strict

help:
	@echo "Available targets:"
	@echo "  make up                     # Start local stack (placeholder)"
	@echo "  make down                   # Stop local stack (placeholder)"
	@echo "  make health                 # Run local health checks"
	@echo "  make logs                   # Show local logs (placeholder)"
	@echo "  make verify-docs            # Verify required high-quality docs (01-10 + 12..26 + operating model)"
	@echo "  make legal-clean            # Run legal/compliance clean checks and report"
	@echo "  make grand-open-check       # Advisory external connectivity grand-open check"
	@echo "  make grand-open-check-strict # Strict external connectivity grand-open check"
	@echo "  make all-features-check      # Advisory integrated all-feature verification"
	@echo "  make all-features-check-strict # Strict integrated all-feature verification"
	@echo "  make official-grand-open-all-features # Official full gate (strict)"
	@echo "  make official-grand-open-all-features-advisory # Official full gate (advisory)"
	@echo "  make external-bank-full-journey-check # 外部接続 銀行業務全行程 (advisory)"
	@echo "  make external-bank-full-journey-check-strict # 外部接続 銀行業務全行程 (strict)"
	@echo "  make bank-full-journey-module-check # 銀行業務全行程モジュール (advisory)"
	@echo "  make bank-full-journey-module-check-strict # 銀行業務全行程モジュール (strict)"
	@echo "  make portal-and-external-channel-check # 各国公式ポータル掲載 + 外部接続(送金/CARD/ATM) (advisory)"
	@echo "  make portal-and-external-channel-check-strict # 各国公式ポータル掲載 + 外部接続(送金/CARD/ATM) (strict)"
	@echo "  make identifier-registry-check # 法人登記簿 + SWIFT/IBAN/LEI/全銀 識別番号 (advisory)"
	@echo "  make identifier-registry-check-strict # 法人登記簿 + SWIFT/IBAN/LEI/全銀 識別番号 (strict)"
	@echo "  make detailed-report # 詳細レポートを統合表示"
	@echo "  make detailed-report-generate # CI実行後に詳細レポート表示"
	@echo "  make country-original-format-report # 各国原本フォーマット詳細レポート (advisory)"
	@echo "  make country-original-format-report-strict # 各国原本フォーマット詳細レポート (strict)"
	@echo "  make system-overview-check # システム概要こと細かく確認 (advisory)"
	@echo "  make system-overview-check-strict # システム概要こと細かく確認 (strict)"
	@echo "  make official-live-fire-list # 全機能一覧（本番公式実弾）"
	@echo "  make official-live-fire-run # 本番公式実弾 strict 実行（明示承認が必要）"
	@echo "  make next-build-debug-local # Debug Next build (auto package manager detect)"
	@echo "  make ci                     # CI-safe checks (syntax + advisory gates)"
	@echo "  make check-go-live          # Strict go-live gate (fails if any control is missing)"
	@echo "  make check-go-live-advisory # Advisory go-live gate (non-blocking)"
	@echo "  make cloudflare-sync-dry-run # Validate Cloudflare sync config"
	@echo "  make cloudflare-sync-staging # Sync Worker/D1 to Cloudflare staging"
	@echo "  make cloudflare-sync-production # Sync Worker/D1 to Cloudflare production"

up:
	@echo "[up] No runtime services are defined in this repository yet."
	@echo "[up] Add docker-compose.yml or runtime scripts, then wire this target."

down:
	@echo "[down] No runtime services are defined in this repository yet."

health:
	@bash scripts/go_live_check.sh --advisory

logs:
	@echo "[logs] No runtime services are defined in this repository yet."

verify-docs:
	@test -f docs/01_system_role.md
	@test -f docs/02_business_rules.md
	@test -f docs/03_state_machine.md
	@test -f docs/04_security_policy.md
	@test -f docs/05_api_contracts.md
	@test -f docs/06_ledger_rules.md
	@test -f docs/07_ops_runbook.md
	@test -f docs/08_ai_prompt_library.md
	@test -f docs/09_compliance_policy.md
	@test -f docs/10_ui_behavior.md
	@test -f docs/12_bank_license_original_acquisition.md
	@test -f docs/13_fin_os_unified_architecture.md
	@test -f docs/14_ui_ux_wireframes_and_nextjs_map.md
	@test -f docs/FIN-OS_ORG_OPERATING_MODEL.md
	@test -f docs/15_gateway_contracts_and_licensing_workflow.md
	@test -f docs/16_financial_infra_legal_uiux_ai_revenue_strengthening.md
	@test -f docs/17_cloudflare_sync.md
	@test -f docs/18_ai_operations_guardrails.md
	@test -f docs/19_license_register_index_21_countries.md
	@test -f docs/20_powershell_oneliners.md
	@test -f docs/21_license_and_registry_hardening.md
	@test -f docs/22_external_connectivity_grand_open_checklist.md
	@test -f docs/23_all_features_verification.md
	@test -f docs/25_transfer_atm_card_infra_hardening.md
	@test -f docs/26_fin_os_final_architecture_compendium.md
	@echo "[verify-docs] required docs are present."

legal-clean:
	@bash scripts/legal_clean_check.sh

grand-open-check:
	@bash scripts/grand_open_check.sh --advisory

grand-open-check-strict:
	@bash scripts/grand_open_check.sh --strict

all-features-check:
	@bash scripts/all_features_check.sh --advisory

all-features-check-strict:
	@bash scripts/all_features_check.sh --strict

official-grand-open-all-features:
	@bash scripts/official_grand_open_all_features.sh --strict

official-grand-open-all-features-advisory:
	@bash scripts/official_grand_open_all_features.sh --advisory

external-bank-full-journey-check:
	@bash scripts/external_bank_full_journey_check.sh --advisory

external-bank-full-journey-check-strict:
	@bash scripts/external_bank_full_journey_check.sh --strict

bank-full-journey-module-check:
	@bash scripts/bank_full_journey_module_check.sh --advisory

bank-full-journey-module-check-strict:
	@bash scripts/bank_full_journey_module_check.sh --strict

portal-and-external-channel-check:
	@bash scripts/portal_and_external_channel_check.sh --advisory

portal-and-external-channel-check-strict:
	@bash scripts/portal_and_external_channel_check.sh --strict

identifier-registry-check:
	@bash scripts/identifier_registry_check.sh --advisory

identifier-registry-check-strict:
	@bash scripts/identifier_registry_check.sh --strict

detailed-report:
	@bash scripts/detailed_report.sh

detailed-report-generate:
	@bash scripts/detailed_report.sh --generate

country-original-format-report:
	@bash scripts/country_original_format_report.sh --advisory

country-original-format-report-strict:
	@bash scripts/country_original_format_report.sh --strict

system-overview-check:
	@bash scripts/system_overview_check.sh --advisory

system-overview-check-strict:
	@bash scripts/system_overview_check.sh --strict

official-live-fire-list:
	@bash scripts/official_live_fire.sh list

official-live-fire-run:
	@bash scripts/official_live_fire.sh run

ci: verify-docs legal-clean
	@bash -n scripts/go_live_check.sh
	@bash -n scripts/grand_open_check.sh
	@bash -n scripts/all_features_check.sh
	@bash -n scripts/official_grand_open_all_features.sh
	@bash -n scripts/external_bank_full_journey_check.sh
	@bash -n scripts/bank_full_journey_module_check.sh
	@bash -n scripts/portal_and_external_channel_check.sh
	@bash -n scripts/identifier_registry_check.sh
	@bash -n scripts/official_live_fire.sh
	@bash -n scripts/detailed_report.sh
	@bash -n scripts/country_original_format_report.sh
	@bash -n scripts/system_overview_check.sh
	@bash scripts/go_live_check.sh --advisory
	@bash scripts/grand_open_check.sh --advisory
	@bash scripts/all_features_check.sh --advisory
	@bash scripts/portal_and_external_channel_check.sh --advisory

check-go-live:
	@bash scripts/go_live_check.sh --strict

check-go-live-advisory:
	@bash scripts/go_live_check.sh --advisory

cloudflare-sync-dry-run:
	@bash scripts/cloudflare_sync.sh --staging --dry-run

cloudflare-sync-staging:
	@bash scripts/cloudflare_sync.sh --staging

cloudflare-sync-production:
	@bash scripts/cloudflare_sync.sh --production

next-build-debug-local:
	@bash scripts/next_build_debug.sh
