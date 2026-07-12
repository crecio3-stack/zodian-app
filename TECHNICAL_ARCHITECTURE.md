# Zodian Technical Architecture

**Document version:** 1.1  
**Effective date:** 2026-06-25  
**Owner:** Zodian Founder/CTO  
**Status:** Governing architecture  
**Governed by:** [ARCHITECTURE_DECISIONS.md](ARCHITECTURE_DECISIONS.md)  
**Constrained by:** [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md)  
**Implements:** [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md)  
**Verified by:** [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md)

This document defines system boundaries, authority, synchronization, offline behavior, security, failure behavior, migration, and operations. It intentionally does not define database tables, SQL, Swift types, endpoint shapes, or vendor-specific code.

## 1. Architectural goals

1. Ship the reflective product independently of the social ecosystem. **ADR-001**
2. Preserve local-first privacy for raw Pattern Memory. **ADR-002**
3. Keep Connect optional and remotely controllable. **ADR-003**
4. Preserve the separation between private reflection and interpersonal communication. **ADR-004**
5. Make content and Observations attributable, inspectable, and versioned. **ADR-007, ADR-009**
6. Keep Private Identity separate from public social representation. **ADR-008**
7. Prevent beta simulations from entering real-user systems. **ADR-010**
8. Avoid persistent implementation while governing decisions remain unresolved. **ADR-011**

## 2. Implementation gates

No persistent data model, backend schema, synchronization mechanism, or migration may be implemented until:

- Its domain contract is accepted.
- All related ADRs are `Accepted`.
- Public/private classification is explicit.
- Canonical ownership is unambiguous.
- Deletion and retention behavior are defined.
- The affected governance documents pass a consistency audit.

Current blockers:

| Area | Blocking decision |
|---|---|
| Public-launch paid commerce | ADR-014 |
| Pattern Memory backup or synchronization | ADR-015 |
| Real-profile Connect eligibility | ADR-016 |

Disposable UI, copy, and interaction prototypes may continue when they do not commit persistent architecture or imply unavailable functionality.

## 3. System boundaries

### 3.1 Reflective product boundary

The public reflective product comprises:

- Account and Private Identity
- Today’s Lens
- Pattern
- local-first Memory Events and Observations
- Archive Entries
- private Threads
- Rewards
- Entitlements if ADR-014 approves commerce
- Notifications
- Sharing exports
- Product analytics and operations

This boundary must remain complete when Connect is disabled. **ADR-001, ADR-003**

### 3.2 Optional social boundary

The optional social ecosystem comprises:

- Public Connect Profiles
- Discovery and ranking
- Connections
- Messages
- Social moderation and enforcement

It is independently feature-flagged and cannot become public until its launch checklist gates pass. **ADR-003, ADR-016**

### 3.3 Trust and operations boundary

Account administration, moderation, analytics, entitlement verification, feature flags, monitoring, and support tooling are privileged operational systems. They receive only the data required for their purpose and never become general product-data access paths.

## 4. Canonical sources

| Domain | Canonical source | Device role |
|---|---|---|
| Account | Server-canonical anonymous or linked Account | Session and bounded cache |
| Private Identity | Server under the anonymous or linked Account | Offline cache and pending edits |
| Public Connect Profile | Server after explicit publication | Draft/cache and media staging |
| Today’s Lens | Published editorial service | Cache and explicit fallback |
| Pattern | Versioned editorial corpus and resolver | Bundled/cached released content |
| Memory Event | User device | Canonical local store |
| Observation | User device | Canonical local store and renderer |
| Archive Entry | Server for new account-owned records; beta-local source until migration | Offline cache and pending operations |
| Thread | Private server record for new account-owned Threads; beta-local source until migration | Offline cache and pending edits |
| Connection | Server | Read-only cache plus user requests |
| Message | Server if messaging is later approved | Ordered cache and pending sends |
| Reward | Server under the anonymous or linked Account | Provisional feedback and cache |
| Entitlement | Verified commerce/grant authority | Bounded verified cache |
| Moderation Case | Restricted server operations | Report submission and limited status |
| Notification | Split: OS authorization/device schedule locally; preferences server-side | Device token, authorization, local schedule |
| Analytics Event | Production analytics pipeline after ingestion | Bounded retry queue |

Canonical ownership follows [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md). A cache must never silently become authoritative after conflict.

### 4.1 Data classifications

Every persisted or cached record is classified as:

| Classification | Meaning | Examples | Governing rule |
|---|---|---|---|
| Canonical | Authoritative product truth | Account ownership, published Today’s Lens, Archive Entry, Connection, Entitlement | Conflict resolution preserves the canonical source |
| Derived | Reproducible meaning calculated from canonical inputs and versioned rules | Pattern resolution, Observation, analytics aggregate | Must retain provenance and never silently replace its sources |
| Disposable | Regenerable operational acceleration | Connect feed ordering, ranking scores, AI explanation cache, Today’s Lens prefetch, recommendation candidates, temporary media transformations | May be dropped or rebuilt without migration or product loss |

Disposable data:

- Never establishes Account ownership.
- Never grants entitlement, publication, moderation status, Connection, or Message authorization.
- Is not migrated as user history.
- Carries enough source/version metadata to detect staleness.
- May be removed during deployment, recovery, or cache pressure without changing canonical product meaning.

## 5. Local storage

### 5.1 Device-canonical private storage

Raw Memory Events and personal Observations are stored locally by default. They are:

- Excluded from automatic account synchronization.
- Excluded from general analytics.
- Excluded from Connect ranking.
- Independently clearable by the user.
- Subject to explicit local retention and pruning rules.
- Vulnerable to loss on reinstall, reset, or device loss until ADR-015 approves a backup model.

The UI must clearly explain this privacy and durability contract. **ADR-002, ADR-015**

### 5.2 Offline cache

Account-backed content may be cached for availability:

- Active Private Identity
- Pattern content and resolution
- Today’s Lens entries
- Archive Entries
- Threads
- Rewards and verified Entitlements
- Notification preferences
- Feature-flag snapshot

Cached records include canonical IDs, revisions, and source versions. Cache deletion must not delete server-canonical records unless the user explicitly performs the domain deletion action.

### 5.3 Pending local operations

Permitted offline mutations are represented as idempotent pending operations rather than silent local truth. Examples include:

- Save or unsave Archive Entry
- Edit a private Thread
- Update permitted account-backed preferences
- Record eligible Reward activity

Account creation, provider linking, publication, moderation actions, Connection authorization, entitlement purchase, and account deletion require server acknowledgment.

### 5.4 Installation and credential state

- Installation ID identifies one installation and may change after reinstall.
- Account ID is received from anonymous server bootstrap and never changes.
- Session ID authorizes temporary access and owns no data.
- Apple Subject ID is stored only as a linked credential reference.
- Device Registration ID is scoped to push and device operations.
- None of these identifiers may be substituted for another.

## 6. Server storage

Server storage holds only account-backed or operational domains approved by the contracts:

- Account and session authority
- Private Identity
- Published Today’s Lens entries and editorial provenance
- Account-backed Archive Entries and Threads
- Rewards and Entitlements
- Notification preferences and device associations
- Public Connect Profiles when approved
- Connections and Messages when approved
- Moderation Cases
- Feature-flag configuration
- Production analytics in a purpose-specific pipeline

Raw Memory Events and personal Observations are explicitly excluded unless ADR-015 is superseded by an accepted backup decision.

Server environments are separated into development, staging/beta, and production. Production data is never copied into lower environments without approved minimization or synthetic replacement.

## 7. Derived data

Derived data is reproducible from canonical inputs and versioned rules.

### 7.1 Pattern

Pattern is derived from Private Identity and versioned editorial/resolution rules. The derived result records its source versions so historical artifacts remain explainable.

### 7.2 Today’s Lens selection and presentation

Today’s Lens content is a canonical editorial artifact selected by date and identity context. Presentation may derive display sections from the artifact but may not rewrite canonical meaning without a new content version.

### 7.3 Observations

The Observation pipeline is:

```text
Canonical source artifact or local Memory Event
        ↓
Evidence eligibility and semantic validation
        ↓
Minimum threshold and contradiction checks
        ↓
Candidate Observation
        ↓
Editorial or AI explanation
        ↓
Validation and provenance attachment
        ↓
Active local Observation
```

AI operates after evidence selection. A failed model call cannot create evidence and must not block access to canonical sources. **ADR-007, ADR-009**

### 7.4 Analytics aggregates

Funnels, retention, and operational dashboards are derived from validated Analytics Events. Aggregates never write back into Account, Reward, Entitlement, Observation, or other product truth.

## 8. Synchronization

### 8.1 Ownership bootstrap and credential linking

First-run persistent ownership follows ADR-013:

1. Generate an Installation ID.
2. Request anonymous Account bootstrap.
3. Receive the immutable Account ID and bounded session.
4. Persist Private Identity and other account-backed records only after acknowledgment.
5. Deliver reflective value without requiring Apple linking.
6. Link Apple to the existing Account before recovery, multi-device access, migration finalization, paid entitlement activation, or Public Connect Profile publication.

If bootstrap fails, Zodian does not create an alternative local Account authority. It presents a retryable ownership error. Apple linking is transactional: a partial or duplicate link cannot create a second Account or transfer ownership silently.

### 8.2 General rules

- Server-canonical domains use revision-aware, account-scoped synchronization.
- Client operations have idempotent identifiers.
- Deletes are explicit operations with tombstone or acknowledgment behavior appropriate to the domain.
- Conflict resolution follows domain authority, not last-write-wins by default.
- Device clock is not trusted for entitlement, account, moderation, or connection authority.
- Sync failure never grants visibility, publication, payment access, or messaging permission.

### 8.3 Promotion from local draft

A beta-local migration source becomes server-backed only through an explicit promotion:

1. Establish canonical Account ownership.
2. Validate domain schema and source version.
3. Assign or confirm canonical server ID.
4. Upload permitted fields only.
5. Receive server acknowledgment and revision.
6. Mark the local copy as cache rather than canonical.

Promotion is not permitted for raw Memory Events or Observations under ADR-002.

### 8.4 Feature-specific rules

- **Private Identity:** Private account sync; public profile consumes only approved derived labels.
- **Archive Entry:** Idempotent save/unsave and content-version preservation.
- **Thread:** Private owner-only sync; no automatic sharing with referenced people.
- **Public Connect Profile:** Draft and publication are distinct; publication requires server acknowledgment and eligibility.
- **Connection:** Server authorization overrides all local state.
- **Message:** Ordered, idempotent, connection-authorized delivery if later approved.
- **Reward:** Server reconciliation prevents duplicate grants.
- **Entitlement:** Verified provider state overrides local flags.
- **Notification:** Preferences sync; OS permission remains per device.
- **Analytics:** One-way append; product state never depends on success.

## 9. Offline behavior

The application should preserve the reflective experience during ordinary network loss:

- Pattern remains readable from released content.
- Previously fetched Today’s Lens entries and Archive Entries remain readable.
- Device-canonical Memory and Observations remain available.
- Existing Threads remain readable and locally editable.
- Eligible local reminders continue where already scheduled.

The application must clearly distinguish:

- Cached canonical content
- Pending local mutation
- Local fallback
- Server-confirmed state
- Unavailable network-only operation

Offline state may not imply:

- A profile was published
- A report was submitted
- A block was enforced server-wide
- A connection exists
- A message was delivered
- A purchase succeeded
- An account was deleted

## 10. Failure behavior

### 10.1 Fail private

When authorization, visibility, moderation, or profile state is uncertain:

- Do not publish.
- Do not disclose private data.
- Do not authorize messaging.
- Do not show a blocked or suspended profile from stale cache.

### 10.2 Fail without fabrication

When evidence, content generation, or AI explanation fails:

- Use a clearly identified valid cached artifact or approved fallback.
- Do not manufacture continuity.
- Do not convert weak evidence into an Observation.
- Preserve source provenance and expose recoverable retry behavior.

### 10.3 Fail without false commerce

When entitlement verification is unavailable:

- Use only a bounded previously verified state.
- Do not grant paid access based on mutable local flags.
- Preserve restore and support pathways.

### 10.4 Fail operationally visible

Migration, sync, moderation, analytics, notification, and content-delivery failures produce monitored operational signals without logging prohibited private content.

## 11. Security boundaries

### 11.1 Account and authorization

- Every account-backed request is authorized against canonical Account identity.
- Anonymous and Apple-linked sessions refer to the same immutable Account ID.
- Provider credentials, Installation IDs, Session IDs, Migration IDs, Device Registration IDs, and Public Profile IDs never replace Account ownership.
- The sole recoverability credential cannot be unlinked without another approved recoverability credential.
- Access is denied by default.
- Public Profile ID is not an authorization credential.
- Client-provided Account IDs, entitlement flags, moderation states, and connection states are untrusted.

### 11.2 Private Identity

- Exact birth data is isolated from public profile queries and discovery.
- Logs and analytics exclude exact date, time, place, and timezone.
- Derived public identity labels cannot be reversed through application interfaces into private inputs.

### 11.3 Local-first Memory

- Raw Memory Events and Observations remain in the app's protected local storage boundary.
- No background upload or diagnostic attachment includes them.
- Explicit sharing contains only user-selected output, not hidden evidence.

### 11.4 Social and moderation

- Public discovery returns only published, eligible, moderation-approved profiles.
- Blocks and suspensions are enforced server-side.
- Reports enter restricted operational storage.
- Message access, if introduced, is participant-scoped and connection-authorized.

### 11.5 Media

- Public media is uploaded only after explicit profile review and publication intent.
- Media access and deletion follow Public Connect Profile lifecycle.
- Staged and orphaned media have cleanup rules.
- Beta local photos are not uploaded automatically.

### 11.6 Secrets and environments

- Service credentials remain server-side.
- Client-distributed public keys have only intended public scope.
- Production secrets, logs, and data are isolated from development.

## 12. Feature flags

Feature flags are server authoritative, environment-aware, and safe by default.

Required flag classes:

- Connect availability
- Real-profile discovery cohort
- Profile publication
- Mutual-interest/Connection capability
- Messaging capability
- Premium commerce availability
- Observation-generation version rollout
- Today’s Lens editorial version rollout
- Migration availability and cohort
- Emergency content or social kill switch

A stale or unavailable flag service falls back to the safest state:

- Reflective core remains available where safe.
- Public social capabilities default off.
- Unverified commerce defaults unavailable.
- Previously valid local content remains readable.

Flags control availability, not data ownership. Enabling a flag cannot bypass consent, moderation, or domain lifecycle.

## 13. Analytics pipeline

### 13.1 Event flow

```text
Versioned application event
        ↓
Local validation and privacy filtering
        ↓
Bounded offline queue
        ↓
Authenticated or pseudonymous ingestion
        ↓
Schema validation and deduplication
        ↓
Purpose-limited event storage
        ↓
Funnels, retention, reliability, and launch dashboards
```

### 13.2 Required properties

Each event includes:

- Event ID
- Event name and schema version
- Occurred timestamp
- Application version
- Environment
- Relevant non-content domain ID/version
- Experiment or feature-flag cohort where applicable
- Pseudonymous account identifier where permitted

### 13.3 Prohibited properties

Analytics must not include:

- Exact birth date, time, place, or timezone
- Authentication tokens or provider identity
- Today’s Lens body text
- Pattern private copy
- Raw Memory Event evidence
- Observation statement or correction text
- Archive content
- Thread content
- Message content
- Profile photos or free-form profile text
- Moderation narratives or evidence

### 13.4 Activation funnel

The governing activation funnel is:

```text
Onboarding Complete
        ↓
Read 1 Complete
        ↓
Read 2 Complete within approved window
        ↓
Read 5 Complete within 7 days
        ↓
Day-30 Retained
```

Metric definitions and threshold placeholders are governed by [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md).

## 14. Migration strategy

### 14.1 Principles

- Versioned
- Idempotent
- Resumable
- Auditable
- Consent-aware
- Domain-specific
- Reversible before destructive cleanup
- Safe under interruption and retry

### 14.2 Migration sequence

1. Establish anonymous canonical Account ownership under ADR-013.
2. Link Apple before migration finalization.
3. Create an immutable Migration ID for the operation.
4. Inventory eligible local records without uploading.
5. Present user-facing migration and publication choices.
6. Import Private Identity privately.
7. Import eligible Archive Entries with provenance and deduplication.
8. Import trustworthy Reward state only under an approved conversion policy.
9. Preserve raw Memory Events and Observations locally.
10. Import Threads only according to source classification.
11. Convert the beta Connect card to an unpublished draft.
12. Upload public profile fields and media only after explicit review and consent.
13. Exclude generated profiles, simulated matches, and simulated conversations from real social domains.
14. Verify server acknowledgment before marking local account-backed copies as caches.
15. Retain migration receipts and local-to-canonical ID mappings sufficient for support and retry without storing prohibited content.

### 14.3 Domain migration outcomes

| Local beta data | Approved outcome |
|---|---|
| User identity | Private Identity import |
| Saved Today’s Lens entries | Archive Entry import when provenance is valid |
| Pattern Memory events | Remain local |
| Personal Observations | Remain local or reconstruct locally |
| Connect card | Unpublished Public Connect Profile draft |
| Connect photo | Remains local until explicit upload consent |
| Generated profiles | Do not migrate as real profiles |
| Generated saves/matches | Optional labeled private Beta Archive or discard |
| Simulated chat/replies | Do not migrate as Messages |
| Rewards/points | Import only under approved provenance policy |
| Local premium flag | Never becomes paid Entitlement |
| Notification settings | Preference import; OS authorization remains device-local |

## 15. Release and operational architecture

- Development, staging/beta, and production are separate environments.
- Schema and content changes are versioned and promoted through controlled release.
- Production has backup, restore, monitoring, and incident procedures.
- Critical social and commerce capabilities have remote kill switches.
- Moderation operations have role-based access and auditability.
- Account deletion and migration have observable completion states.
- Content generation and delivery have latency, availability, fallback, and quality monitoring.
- Launch uses staged rollout with hold criteria defined in the checklist.

## 16. Change control

Before implementation, Codex and engineers must:

1. Identify affected ADRs and domains.
2. State whether the request fits the accepted architecture.
3. Stop before persistent changes if a conflict or Proposed ADR is involved.
4. Update governance first when an architectural change is explicitly approved.
5. Preserve superseded ADR history.
6. Re-run the cross-document consistency audit.

Operating instruction:

> Zodian product architecture is governed by the approved architecture documents. Unless explicitly instructed otherwise, do not introduce new systems, domains, product surfaces, or architectural concepts. Optimize within the accepted architecture. Before changing code, identify any conflict with governing principles, domain contracts, or accepted ADRs. Architectural conflicts require an explicit decision before implementation.
