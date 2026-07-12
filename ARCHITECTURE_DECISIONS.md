# Zodian Architecture Decisions

**Document version:** 1.1  
**Effective date:** 2026-06-25  
**Owner:** Zodian Founder/CTO  
**Status:** Governing  
**Review cadence:** Quarterly and before any persistent data-model, backend-schema, synchronization, or migration change

This document is the durable Architecture Decision Record (ADR) log for Zodian. It governs [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md), which constrains [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md), which is implemented by [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md) and verified by [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md).

Accepted ADRs remain in this log permanently. A changed decision is marked `Superseded` and points to the replacing ADR; it is never deleted. Proposed ADRs do not authorize persistent implementation.

## Status definitions

- **Proposed:** Under review. Does not govern implementation.
- **Accepted:** Approved and binding.
- **Superseded:** Historical decision replaced by another ADR.

## Decision index

| ADR | Decision | Status |
|---|---|---|
| ADR-001 | Reflective product launches before the social ecosystem | Accepted |
| ADR-002 | Pattern Memory is local-first by default | Accepted |
| ADR-003 | Connect launches separately behind a feature flag | Accepted |
| ADR-004 | Threads are distinct from Messages | Accepted |
| ADR-005 | Premium extends time horizon, not psychological accuracy | Accepted |
| ADR-006 | Reflection comes before prediction | Accepted |
| ADR-007 | AI explains evidence rather than inventing evidence | Accepted |
| ADR-008 | Private Identity and Public Connect Profile are separate domains | Accepted |
| ADR-009 | Observations use shared provenance and evidence contracts | Accepted |
| ADR-010 | Generated social artifacts never become real-user records | Accepted |
| ADR-011 | Governing documents precede persistent architecture | Accepted |
| ADR-012 | Architecture changes are versioned and change-controlled | Accepted |
| ADR-013 | Canonical ownership, account bootstrap, and credential linking | Accepted |
| ADR-014 | Public-launch monetization mode | Proposed |
| ADR-015 | Optional Pattern Memory backup model | Proposed |
| ADR-016 | Connect age-eligibility policy | Proposed |

---

## ADR-001 — Reflective product launches before the social ecosystem

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Zodian's validated value is the reflective loop formed by Today’s Lens, Pattern, Pattern Memory, Archive, Notifications, Rewards, and Sharing. Public social discovery introduces a separate class of consent, moderation, safety, density, and operational requirements.

### Decision

The public reflective product launches independently of public real-person discovery. Public Connect is not a prerequisite for public launch.

### Consequences

- Launch scope is evaluated against reflective-product readiness.
- Social-system delays do not delay the reflective product.
- Connect may remain unavailable, editorial-only, or closed beta.
- Public-launch metrics prioritize reflective activation and retention.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Product mission; Social philosophy
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Today’s Lens; Pattern; Public Connect Profile; Connection
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Release boundaries; Feature flags
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Product; Launch Operations

---

## ADR-002 — Pattern Memory is local-first by default

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Pattern Memory contains intimate behavioral evidence and interpretations. Automatic cloud collection would change the privacy contract and create unnecessary exposure.

### Decision

Raw Memory Events and personal Observations remain canonical on the user's device by default. They leave the device only through a separately consented backup or explicitly initiated sharing flow.

### Consequences

- Reinstall, device loss, or local reset may destroy unbacked-up Memory.
- Product analytics must not receive raw reflection text or evidence payloads.
- Optional backup requires a separate accepted ADR and explicit consent.
- Connect ranking cannot consume Pattern Memory without a separate future decision and consent.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Privacy philosophy; Evidence before inference
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Memory Event; Observation
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Local storage; Security boundaries
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Privacy; Migration

---

## ADR-003 — Connect launches separately behind a feature flag

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Real-person discovery has safety and operational requirements beyond the reflective product. Availability must be controllable independently by environment and cohort.

### Decision

Connect is optional and controlled by a server-authoritative feature flag. Real-profile discovery remains closed until publication consent, reporting, blocking, moderation, and operational response are verified.

### Consequences

- Connect can be disabled without an application release.
- Closed cohorts can be expanded gradually.
- A `Beta` label does not waive trust-and-safety requirements.
- The reflective experience must remain complete when Connect is unavailable.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Connect extends reflection
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Public Connect Profile; Connection; Moderation Case
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Feature flags; Failure behavior
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Moderation; Launch Operations

---

## ADR-004 — Threads are distinct from Messages

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Threads capture why a person, signal, or relationship remains meaningful. Messages are interpersonal communications. Combining them would reduce Threads to a generic inbox.

### Decision

Thread and Message remain separate domains with independent ownership, lifecycle, retention, and user experience.

### Consequences

- A Thread may exist without a Connection or Message.
- Messages require mutual authorization and social safety systems.
- Deleting a Message does not automatically delete its Thread.
- Threads remain private reflective artifacts.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Social philosophy
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Thread; Connection; Message
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Canonical sources; Security boundaries
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Product; Moderation

---

## ADR-005 — Premium extends time horizon, not psychological accuracy

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Charging for supposedly more accurate psychological insight would undermine trust and incentivize overstated claims.

### Decision

Premium value comes from longer perspective, deeper history, broader comparison windows, and durable access—not from claims of greater truth or accuracy.

### Consequences

- Safety, privacy, correction, blocking, reporting, and account controls remain free.
- Free insights must not be deliberately degraded.
- Premium messaging emphasizes time depth and continuity.
- Launch commerce remains blocked until ADR-014 is accepted.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Premium philosophy
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Entitlement; Archive Entry; Observation
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Entitlement authority
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Premium

---

## ADR-006 — Reflection comes before prediction

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Zodian's differentiation is recognizable identity reflection, not forecasting specific external events.

### Decision

Product content prioritizes identity, behavior, tension, and perspective. It does not present deterministic predictions as knowledge.

### Consequences

- Today’s Lens entries describe recognizable tendencies and grounded choices.
- Product claims remain calm, bounded, and non-deterministic.
- Predictive features require a new ADR.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Reflection philosophy
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Today’s Lens; Pattern; Observation
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Product

---

## ADR-007 — AI explains evidence rather than inventing evidence

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

AI-generated observations can sound persuasive even when unsupported. Trust requires separating evidence selection from language generation.

### Decision

AI may summarize, frame, or explain validated evidence. It may not create unsupported behavioral evidence, fabricate continuity, or state unmeasured user behavior as fact.

### Consequences

- Evidence and thresholds precede generated prose.
- Low-confidence observations are suppressed.
- Every evidence-derived Observation is inspectable.
- Prompt, editorial, validator, and model versions are recorded.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): AI philosophy
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Observation; Memory Event; Today’s Lens
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Derived data; Versioning
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Product; Analytics

---

## ADR-008 — Private Identity and Public Connect Profile are separate domains

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Exact birth data is sensitive and is collected to derive a Pattern. Public discovery requires a deliberately selected subset of user-authored fields.

### Decision

Private Identity and Public Connect Profile have separate records, permissions, lifecycles, and consent. Private Identity is never public by default and is never inferred to be publishable.

### Consequences

- Exact birthday, time, place, timezone, private Pattern history, and Memory remain private.
- Public fields require explicit review and publication.
- Hiding or deleting a public profile does not delete Private Identity.
- Beta visibility settings do not constitute public-launch consent.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Private before public
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Private Identity; Public Connect Profile
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Security boundaries
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Privacy; Migration

---

## ADR-009 — Observations use shared provenance and evidence contracts

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Memory insights, continuity, monthly reflections, Threads reflections, and shareable insights all need consistent provenance, deduplication, correction, and versioning.

### Decision

Evidence-derived insights use a shared Observation contract and linked evidence references. Content artifacts such as Today’s Lens entries remain distinct domains and may be referenced as evidence.

### Consequences

- Observation is not a synonym for Today’s Lens, Memory Event, Archive Entry, or Thread.
- Evidence references remain inspectable where the source still exists.
- User dismissal and correction affect future presentation.
- Shared provenance supports debugging, experimentation, and export.

### Related documents

- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Observation; Memory Event; Archive Entry; Today’s Lens
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Derived data; Observation pipeline
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Product; Privacy

---

## ADR-010 — Generated social artifacts never become real-user records

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Closed beta uses generated profiles and simulated conversations. Those artifacts lack real-person consent and identity.

### Decision

Generated profiles, generated matches, generated replies, simulated conversations, and associated social actions never migrate into Public Connect Profiles, Connections, or Messages.

### Consequences

- Beta social history is reset or retained only in a clearly labeled private editorial archive.
- Generated content is never represented as a real person.
- Migration may preserve reflective annotations only when their editorial origin remains explicit.

### Related documents

- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Public Connect Profile; Thread; Connection; Message; Migration rules
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Migration strategy
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Migration

---

## ADR-011 — Governing documents precede persistent architecture

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Persistent schemas, synchronization, and migrations are expensive to reverse and can encode unresolved product assumptions.

### Decision

No persistent data model, backend schema, synchronization mechanism, or migration is implemented until the governing documents are internally consistent and all relevant ADRs are accepted.

### Consequences

- UI, copy, and disposable prototypes may continue when they do not commit persistent architecture.
- Proposed ADRs block affected persistent implementation.
- Architecture review is required before schema-changing work.

### Related documents

- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): All domains
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Implementation gates
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Architecture Governance

---

## ADR-012 — Architecture changes are versioned and change-controlled

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

The governance set must remain coherent as implementation and user evidence evolve.

### Decision

Architecture changes require an ADR update, affected-document updates, version increments, and a cross-document consistency audit. Accepted ADRs are superseded, never rewritten out of history.

### Consequences

- Architectural conflicts are identified before code changes.
- Documents have owners, versions, and review dates.
- New domains and product surfaces require explicit approval.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Governance rule
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Contract-change policy
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Change control
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Architecture Governance

---

## ADR-013 — Canonical ownership, account bootstrap, and credential linking

**Status:** Accepted  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Authentication answers who can prove control of an account. Ownership answers which durable records belong to that account. Zodian needs stable ownership before Private Identity, migration, analytics continuity, restore, entitlements, publication, and future synchronization can be implemented coherently.

Provider credentials, installations, sessions, devices, and migration attempts have different lifecycles. None may be used as a substitute for the permanent owner identifier.

### Decision

Zodian creates an anonymous, server-canonical Account before persisting onboarding identity data. The server-generated Account ID is the permanent owner of all account-backed records and never changes when authentication providers are linked, unlinked, or replaced.

The first-run ownership sequence is:

```text
Installation
    ↓
Anonymous canonical Account
    ↓
Private Identity and onboarding
    ↓
Pattern and Today’s Lens value
    ↓
Apple credential linked
    ↓
Recovery, multi-device access, migration finalization,
paid entitlement, and public-profile publication
```

Anonymous bootstrap must be acknowledged by the server before persistent account-backed onboarding data is created. If bootstrap is unavailable, Zodian presents a retryable ownership error rather than creating a competing local account authority.

Apple is the first approved recoverability credential. Linking Apple proves control of the existing Account; it does not create a replacement Account or change the Account ID. An Apple credential cannot be unlinked when it is the Account's only recoverability credential. Account deletion remains available.

An anonymous Account may receive reflective value on its originating installation, but it is not recoverable after installation loss until a recoverability credential is linked. Apple linking is required before:

- Cross-device restore
- Multi-device access
- Finalizing beta-local history migration
- Activating paid entitlement
- Publishing a Public Connect Profile

Migration is an explicit, idempotent ownership operation. Each migration operation has an immutable Migration ID. Retries reuse the same Migration ID; a deliberately new migration operation receives a new Migration ID. Local record IDs are mapped to canonical domain IDs and never become Account IDs.

### Identifier authority

| Identifier | Purpose | Authority | Can change? | Ownership rule |
|---|---|---|---|---|
| Installation ID | Identifies one app installation | Device-generated; registered with server | Yes; reinstall creates a new value | Never owns durable account-backed data |
| Account ID | Canonical owner of account-backed data | Server | No | Permanent ownership root |
| Apple Subject ID | Credential proving access to an Account | Apple identity linked by server | Link can be replaced only under approved recovery policy | Never used as Account ID |
| Session ID | Authorizes a bounded authenticated session | Authentication service | Yes | Grants temporary access; owns nothing |
| Migration ID | Identifies one idempotent migration operation | Server | No | Retries reuse it; it does not identify the user |
| Device Registration ID | Associates a device with push and device-scoped state | Server | Yes | Device-scoped; owns nothing |
| Local Record ID | Identifies a device-local source record | Device | Stable only within its local source | Mapped during migration; never reused as Account ID |
| Public Profile ID | Identifies the user's public Connect representation | Server | Stable while retained | Separate from Account and Private Identity IDs |

### Consequences

- Account-dependent architecture may proceed against this ownership model.
- First persistent use requires network availability for anonymous bootstrap.
- New users receive value before being asked to link Apple.
- Anonymous users are warned that unlinked accounts cannot be recovered after installation loss.
- Authentication providers can evolve without re-keying owned data.
- Account linking must be transactional and must never create duplicate ownership.
- Analytics continuity uses a pseudonymous mapping to Account ID, not provider or installation identity.
- Migration, entitlement, publication, and restore must verify both Account ownership and required credential state.
- Account deletion applies to anonymous and linked Accounts.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Private before public; operating rules
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Account
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Identity and session boundary
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Accounts; Migration

---

## ADR-014 — Public-launch monetization mode

**Status:** Proposed  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Public launch can either be free with commerce disabled or include completed StoreKit commerce. A partially functional purchase system is not acceptable.

### Decision

Pending founder approval between:

- Public launch with commerce intentionally disabled and unavailable purchase claims removed.
- Public launch with completed purchase, restore, entitlement, management, and support flows.

### Consequences

- Commerce-dependent launch work is blocked.
- Premium product principles remain accepted regardless of launch mode.

### Related documents

- [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md): Premium philosophy
- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Entitlement
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Premium

---

## ADR-015 — Optional Pattern Memory backup model

**Status:** Proposed  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Local-first Memory creates a deliberate privacy boundary but leaves unbacked-up data vulnerable to device loss or reinstall. Any backup changes the threat model and recovery contract.

### Decision

No automatic Memory synchronization is approved. A future backup model requires a separate decision covering encryption, recovery, consent, deletion, and metadata exposure.

### Consequences

- Public launch may proceed without Memory backup.
- UI must clearly explain device-local persistence.
- No server schema for raw Memory Events or personal Observations is authorized.

### Related documents

- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Memory Event; Observation
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Local-first Memory boundary
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Privacy

---

## ADR-016 — Connect age-eligibility policy

**Status:** Proposed  
**Date:** 2026-06-25  
**Owner:** Zodian Founder/CTO

### Context

Real-person discovery with photos and relationship-oriented prompts requires an explicit age policy. Supporting minors materially changes moderation, consent, privacy, and App Store obligations.

### Decision

Pending founder and legal approval. Real-profile Connect remains closed until age eligibility, verification expectations, and enforcement are defined.

### Consequences

- Reflective public launch is not blocked.
- Public Connect Profile publication and discovery are blocked.

### Related documents

- [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md): Public Connect Profile; Moderation Case
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md): Security boundaries
- [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md): Moderation; Legal
