# FINAL GRAND OPEN ARCHITECTURE

## Goal
正式グランドオープンの条件は、単なるUI公開ではなく、以下3点の同時成立です。

- 実弾取引が安全に流れる
- 監督当局への提出・受領・掲載が追跡できる
- 公開ポータル掲載と内部ライセンス台帳が一致する

## Architecture Overview

```text
[Users / Operators]
    ↓
[Cloudflare Pages: Static UI]
    ↓
[Workers Gateway API]
    ↓
[D1 / Queue / Audit / Control Tables]
    ↓
[Internal Operational Flows]
    ├─ Legal license master
    ├─ Authority submission / acknowledgment / listing
    ├─ External portal verification
    ├─ Real-money transaction / ledger / settlement
    └─ Kill Switch / Manual Review / DLQ / Replay
```

## Layer Design

### 1. UI Layer

- Cloudflare Pages
- Static export only
- No dynamic Next.js API routes
- `/legal` fetches Workers Gateway directly

### 2. API / Control Layer

- Cloudflare Workers Gateway
- Public read APIs
- Internal admin APIs
- Admin token authentication required
- Audit logging required
- Idempotency required
- Kill Switch enforcement required

### 3. Data Layer

Primary D1 tables:

- legal_documents
- regulatory_submissions
- license_origin_registry
- external_registry_specs
- external_portal_checks
- authority_update_requests
- transactions
- ledger_entries
- settlement_records
- audit_trail

### 4. Supervisory / External Layer

- Supervisory authority submission/update path
- Acknowledgement tracking
- Public registry listing tracking
- Portal content verification
- Manual vs machine verification separation

## Required State Machines

### Authority Update

AUTHORITY_UPDATE_REQUIRED
→ AUTHORITY_SUBMITTED
→ AUTHORITY_ACKNOWLEDGED
→ PORTAL_LISTED
→ PORTAL_VERIFIED

### External Verification

PENDING_EXTERNAL
→ REACHABLE
→ HTML_CAPTURED
→ POSSIBLE_MATCH
→ PORTAL_VERIFIED_MANUAL / PORTAL_VERIFIED_MACHINE

### Transaction Safety

RECEIVED
→ AUTHORIZED
→ CAPTURED
→ SETTLED
→ COMPLETED

Exception path:

RECEIVED
→ REVIEW_REQUIRED
→ RETRY_QUEUED / REJECTED

## Grand Open Requirements

### A. UI / Delivery

- Pages build succeeds
- `output: export` only
- No `app/api/**` dynamic routes in Next.js
- UI uses Workers Gateway as API source of truth

### B. API / Control

- `/api/internal/*` protected by admin token
- Replay / Retry / DLQ / Manual Review hooks wired
- Audit hook required for all state-changing operations

### C. Real-Money Readiness

- Ledger posting completed
- Settlement flow completed
- Idempotency enforced
- Duplicate event prevention enabled
- Rollback target fixed
- Production smoke test passed
- Kill Switch tested

### D. Legal / Regulatory

- Authority update requests tracked
- Receipt / acknowledgement tracked
- Public listing tracked
- Official portal references maintained
- Original document hash and verification tracked

### E. Audit / Compliance

- All state transitions logged
- Correlation / request IDs tracked
- Manual and machine verification separated
- Recovery path documented

## Current Position

### Already Advanced

- D1 operational
- UI reachable
- Gateway API reachable
- 18-country portal specification registry created
- Portal reachability checks stored
- 5-country authority update flow tracked
- Audit trail extended

### Remaining Final Blockers

- Remove Next-side `/api/legal/licenses`
- Use Workers Gateway as sole legal API
- Finalize `/api/internal/*` admin auth
- Complete static export build and Pages deploy success
- Finalize audit hooks wiring for internal admin flows

## Final Operational Model

```text
[Pages UI]
  └─ Read-only frontend
[Workers Gateway]
  ├─ Public API
  ├─ Internal Admin API
  ├─ Auth / Token Validation
  ├─ Idempotency Guard
  ├─ Kill Switch
  ├─ Manual Review Trigger
  └─ Audit Logger
[D1]
  ├─ Legal registry
  ├─ Regulatory submission tracking
  ├─ External portal verification
  ├─ Authority update requests
  ├─ Transaction / ledger / settlement
  └─ Audit trail
[Supervisory Authorities / Public Registries]
  ├─ Submission
  ├─ Acknowledgement
  ├─ Listing
  └─ Verification
```

## Final Decision Rule

正式グランドオープンは、以下が全て完了した時のみ許可。

- PUBLIC OPERATION = GREEN
- FORMAL GO-LIVE CLOSEOUT = DONE
- Real-money safety controls active
- Supervisory update flow tracked
- Audit trail complete
- Rollback path fixed
