# Architecture decision records

Initial evidence-backed records, inspected 2026-08-06. Historical dates and rationale are not reconstructed.

## ADR-001 — Immutable publication

- **Status:** Accepted in repository schema. **Date:** historical date unresolved.
- **Context:** published content must remain auditable.
- **Decision:** guard published/superseded batch metadata and rows; replace through supersession.
- **Evidence:** `supabase/migrations/20260503090000_daily_rituals_baseline.sql`.
- **Affected components:** batch tables, row guards, manager/publication paths.
- **Trade-offs:** safer history; corrective publication is more involved.
- **Alternatives:** undocumented. **Reconsider when:** audit/history requirements change.
- **Supersedes:** none evidenced. **Superseded by:** none evidenced.

## ADR-002 — One published batch per environment/date

- **Status:** Accepted. **Date:** historical date unresolved.
- **Context:** readers need deterministic dated content.
- **Decision:** partial unique index plus 144/144 validation before publication.
- **Evidence:** publication migration and batch contract.
- **Affected components:** database, manager, reader.
- **Trade-offs:** requires explicit corrective/supersession flow.
- **Alternatives:** undocumented. **Reconsider when:** product permits multiple active publications.
- **Supersedes/superseded-by:** none evidenced.

## ADR-003 — Separate generation, validation, and publication

- **Status:** Accepted by current architecture. **Date:** historical date unresolved.
- **Context:** generation completion must not itself expose content.
- **Decision:** separate generator, validators, manager, publication, and reader paths.
- **Evidence:** Edge Functions, lifecycle contract, migrations.
- **Affected components:** Supabase functions and iOS reader.
- **Trade-offs:** more coordination and version metadata.
- **Alternatives:** undocumented. **Reconsider when:** a new atomic pipeline is evidenced.
- **Supersedes/superseded-by:** none evidenced.

## ADR-004 — Provider authorization boundary

- **Status:** Accepted for verified paths; full live boundary unresolved. **Date:** historical date unresolved.
- **Context:** provider calls require controlled secrets and scope.
- **Decision:** provider calls remain server-side and authorized by configured secrets in the inspected functions.
- **Evidence:** provider-facing Edge Functions and config.
- **Affected components:** generators, shadow/candidate paths, operations.
- **Trade-offs:** local tests need fixtures or explicit canaries.
- **Alternatives:** undocumented. **Reconsider when:** provider architecture changes.
- **Supersedes/superseded-by:** none evidenced.

## ADR-005 — Time-windowed generation/publication

- **Status:** Accepted in scheduler code; live trigger unresolved. **Date:** historical date unresolved.
- **Context:** generation stages the next date while publication occurs at the boundary.
- **Decision:** use Los Angeles schedule context and a midnight publication gate.
- **Evidence:** `supabase/functions/_shared/daily-ritual-batches/midnight_scheduler.ts` and tests.
- **Affected components:** scheduler, manager, batch lifecycle.
- **Trade-offs:** timezone/DST sensitivity.
- **Alternatives:** a legacy scheduler also exists; historical selection rationale unresolved.
- **Reconsider when:** timezone or publication timing changes. **Supersedes/superseded-by:** none evidenced.

## ADR-006 — Prompt-validator alignment and opening diversity

- **Status:** Current operating practice; exact historical decision unresolved. **Date:** historical date unresolved.
- **Context:** prompt drift, repetitive openings, and validator weakening reduce quality.
- **Decision:** review prompts, validators, fixtures, and corpus diversity together; retain version-specific opening/ending checks.
- **Evidence:** sky-led writer/tests and development assignment tests.
- **Affected components:** writers, validators, editorial review, canaries.
- **Trade-offs:** false positives may reject natural copy.
- **Alternatives:** undocumented. **Reconsider when:** active writer/version changes.
- **Supersedes/superseded-by:** none evidenced.
