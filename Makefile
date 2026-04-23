.PHONY: help up down health logs ci check-go-live check-go-live-advisory verify-docs legal-clean next-build-debug-local cloudflare-sync-staging cloudflare-sync-production cloudflare-sync-dry-run

help:
	@echo "Available targets:"
	@echo "  make up                     # Start local stack (placeholder)"
	@echo "  make down                   # Stop local stack (placeholder)"
	@echo "  make health                 # Run local health checks"
	@echo "  make logs                   # Show local logs (placeholder)"
	@echo "  make verify-docs            # Verify required high-quality docs (01-10 + 12/13/14 + operating model + gateway/licensing + infra/legal/uiux/ai/revenue + cloudflare + ai-guardrails + 18-country-license-index)"
	@echo "  make legal-clean            # Run legal/compliance clean checks and report"
	@echo "  make next-build-debug-local # Debug Next build (auto package manager detect)"
	@echo "  make ci                     # CI-safe checks (syntax + advisory gate)"
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
	@test -f docs/19_license_register_index_18_countries.md
	@echo "[verify-docs] required docs are present."

legal-clean:
	@bash scripts/legal_clean_check.sh

ci: verify-docs legal-clean
	@bash -n scripts/go_live_check.sh
	@bash scripts/go_live_check.sh --advisory

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
