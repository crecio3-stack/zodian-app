# Zodian Domain Contracts

**Document version:** 1.1  
**Effective date:** 2026-06-25  
**Owner:** Zodian Founder/CTO  
**Status:** Governing  
**Governed by:** [ARCHITECTURE_DECISIONS.md](ARCHITECTURE_DECISIONS.md)  
**Constrained by:** [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md)  
**Implemented by:** [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md)  
**Verified by:** [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md)

These contracts define ownership, privacy, lifecycle, authority, and boundaries. They do not define database tables, APIs, Swift models, or vendor-specific implementation.

## Contract conventions

- **Owner** means the accountable authority for the domain and its policy.
- **Source of truth** means the authoritative representation when copies disagree.
- **Local draft** means a device-created record that has not yet been promoted to account-backed authority.
- **Server canonical** means an account-authorized service is authoritative and the device holds a cache.
- **Device canonical** means the local record is authoritative and is not automatically synchronized.
- **Derived** means reproducible from canonical inputs and versioned rules; derived data must not silently replace its sources.
- **Disposable** means regenerable operational acceleration whose deletion cannot change ownership, authorization, entitlement, publication, or product meaning.
- **Publication** always requires explicit user action. Local visibility defaults are not publication consent.
- **Deletion** must cover canonical records, caches, media, derived records, and references according to each contract.
- **Contract changes** require an ADR and cross-document version update under ADR-011 and ADR-012.

## Domain relationship overview

```text
Account ── owns ── Private Identity
   │                    │
   │                    ├── derives ── Pattern
   │                    └── selects ── Today’s Lens
   │                                      │
   │                                      └── saved as ── Archive Entry
   │                                                        │
   ├── owns ── Reward / Entitlement                          │
   ├── owns ── Public Connect Profile                        │
   │                    │                                    │
   │                    └── participates in ── Connection     │
   │                                              │           │
   │                                              └── Message │
   └── owns ── Thread ────────────────────────────────────────┘

Memory Event ── evidence for ── Observation
Archive Entry ── evidence for ── Observation
Thread ───────── evidence for ── Observation

Analytics Event is operational telemetry, not a substitute for any product domain.
Moderation Case governs public/profile/message safety without owning private reflection.
Notification delivers reminders and system events; it does not own source content.
```

---

## 1. Account

**Purpose:** Establish stable user ownership, authentication linkage, lifecycle state, restore authority, and the root boundary for account-backed data.  
**Owner:** Zodian Account Platform; the user controls their account and deletion.  
**Source of truth:** Server-canonical Account service from anonymous bootstrap onward. Authentication providers prove access to the Account but never own its records.  
**Stable identifier:** Server-generated opaque Account ID that does not encode email, birthday, device, or provider identity.  
**Visibility:** Private. Authentication identifiers are never public profile identifiers.  
**Lifecycle:** Anonymous active, linked active, suspended, deletion pending, deleted. Credential links and sessions have independent lifecycles and do not replace the Account.  
**Offline behavior:** Existing valid sessions may use bounded cached state. Anonymous bootstrap, credential linking, recovery, migration finalization, publication, paid entitlement activation, and deletion confirmation require server availability. If first-run bootstrap fails, persistent onboarding waits behind a retryable ownership error.  
**Sync behavior:** Account state is server authoritative. Devices receive scoped session state; devices never reconcile ownership by name, birthday, sign pair, provider ID, or Installation ID.  
**Retention:** Retained while active and only as legally or operationally required after deletion. Retention exceptions must be documented.  
**Deletion:** User-initiated in app; cascades to account-backed private data, public profile, media, connections, entitlements where permitted, and server caches. Device-local Pattern Memory is handled separately and must be explained.  
**Versioning:** Account contract version, credential-link policy version, session-policy version, and deletion-policy version.  
**Analytics boundaries:** Analytics may use a pseudonymous Account ID after consent and policy review; authentication tokens, email, and provider identifiers are prohibited event properties.  
**Migration rules:** Local records attach only through an explicit, idempotent Migration ID associated with the canonical Account ID. Retries reuse the Migration ID. Local Record IDs map to canonical domain IDs and never become owner IDs. Migration finalization requires a linked recoverability credential. Never merge by display name, birthday, sign pair, provider ID, Installation ID, or device name.  
**Relationships:** Owns Private Identity, Public Connect Profile, Archive Entry, Thread, Connection participation, Reward, Entitlement, Notification preferences, and account-scoped Analytics identity.  
**Related ADRs:** ADR-008, ADR-011, ADR-013

---

## 2. Private Identity

**Purpose:** Hold the private inputs and derived identity keys required to produce Pattern and select Today’s Lens entries.  
**Owner:** The user; Zodian Identity domain enforces privacy and derivation rules.  
**Source of truth:** Server canonical under the anonymous or linked Account. Persistent Private Identity is created only after anonymous Account bootstrap succeeds. Exact birth inputs must not be inferred from public profile data.  
**Stable identifier:** Identity Record ID scoped to one Account, plus versioned derived identity keys.  
**Visibility:** Strictly private. Exact birthday, birth time, place, timezone, and private identity history are not public.  
**Lifecycle:** Draft, active, updated, superseded, deleted. Historical versions may be retained only when required to explain existing artifacts and according to retention policy.  
**Offline behavior:** The active identity and released derivation rules may be cached for offline Pattern access. Edits made offline remain pending until safely reconciled.  
**Sync behavior:** Private, account-scoped synchronization. Public Connect Profile never reads exact birth inputs.  
**Retention:** Active while the account exists; superseded versions retained only as necessary for artifact provenance or user history.  
**Deletion:** Deleted with the Account or through a supported identity reset. Deletion invalidates or re-derives dependent future content without rewriting historical artifacts silently.  
**Versioning:** Input schema version, astrology-calculation version, identity-content version, and update timestamp.  
**Analytics boundaries:** Analytics may record coarse derived identity keys only when approved; never exact birth date, time, place, or free-form location.  
**Migration rules:** Existing local identity imports privately after account association. Import preserves original creation source and does not publish any field.  
**Relationships:** Derives Pattern; selects Today’s Lens; may provide an explicitly approved public identity label to Public Connect Profile without exposing source inputs.  
**Related ADRs:** ADR-006, ADR-008, ADR-013

---

## 3. Public Connect Profile

**Purpose:** Represent the user-authored information a person explicitly chooses to publish for optional Connect discovery.  
**Owner:** The user controls content and visibility; Zodian Social Platform controls eligibility and moderation state.  
**Source of truth:** Server canonical after publication. Before publication, a local or server draft is not discoverable.  
**Stable identifier:** Public Profile ID distinct from Account ID and Private Identity ID.  
**Visibility:** Draft is private. Published fields are visible only to eligible Connect cohorts under discovery rules. Moderation metadata remains internal.  
**Lifecycle:** Draft, pending review, published, hidden by user, restricted, suspended, deleted. Eligibility policy is blocked by Proposed ADR-016.  
**Offline behavior:** Draft editing may be cached. Publication, unpublication confirmation, moderation status, and discovery require server availability.  
**Sync behavior:** Explicit field-level synchronization. Public identity labels are derived outputs approved for publication, never exact private birth inputs.  
**Retention:** Drafts and published profiles remain until deletion or account lifecycle policy removes them. Moderation retention follows safety policy.  
**Deletion:** Unpublication removes discovery immediately. Deletion removes profile data and media subject to moderation/legal retention. It does not delete Private Identity.  
**Versioning:** Profile schema version, content revision, moderation-policy version, and publication-consent version.  
**Analytics boundaries:** Profile completion, publication, impressions, saves, reports, and blocks may be measured. Photos, bio text, prompts, exact age, and moderation notes are not analytics payloads.  
**Migration rules:** Beta Connect cards import only as unpublished drafts. Photos upload only after explicit review and publication consent. Generated profiles never migrate.  
**Relationships:** Belongs to Account; may expose an approved identity label from Private Identity; appears in discovery; may participate in Connection; may be referenced privately by Thread; may create Moderation Cases.  
**Related ADRs:** ADR-001, ADR-003, ADR-008, ADR-010, ADR-016

---

## 4. Today’s Lens

**Purpose:** Provide a versioned daily reflective content artifact for an identity context and date.  
**Owner:** Zodian Editorial System.  
**Source of truth:** Published Today’s Lens content is server canonical. A released local fallback is explicitly marked as fallback and never overwrites the published artifact.  
**Stable identifier:** Today’s Lens ID plus date, identity-context key, and content version.  
**Visibility:** Private in the user's experience until explicitly shared. The underlying editorial artifact may be shared across users with the same identity context.  
**Lifecycle:** Generated, validated, published, superseded for correction, unavailable, archived. Published historical content is immutable except through a versioned correction.  
**Offline behavior:** Last valid fetched artifacts may be cached. Offline fallback must identify its source and preserve content boundaries.  
**Sync behavior:** Content synchronizes from server to device. User actions such as opening, saving, or completing are separate events or domain relationships.  
**Retention:** Published artifacts are retained long enough to support Archive provenance, debugging, and user history.  
**Deletion:** Editorial artifacts are not deleted through account deletion. User-specific cached copies and links are removed according to Account and Archive deletion.  
**Versioning:** Editorial version, prompt version, validator version, model/provider version where applicable, content schema version, generation timestamp, and fallback source.  
**Analytics boundaries:** Read ID/version, open, reveal, completion, save, share, error, and fallback state may be measured. Read body text and private user notes are excluded.  
**Migration rules:** Saved beta reads may migrate through Archive Entry with preserved source/version when available. Generated social history does not affect Today’s Lens migration.  
**Relationships:** Selected by Private Identity; may produce Archive Entry; may be evidence for Observation; may trigger Reward; may be delivered by Notification.  
**Related ADRs:** ADR-001, ADR-006, ADR-007, ADR-009

---

## 5. Pattern

**Purpose:** Express the user's enduring identity synthesis and provide the stable interpretive frame for Today’s Lens and Pattern Memory.  
**Owner:** Zodian Editorial System; the user owns their private instance and sharing choice.  
**Source of truth:** Versioned editorial corpus and deterministic resolution rules are canonical. The user's resolved Pattern is derived from active Private Identity and those versions.  
**Stable identifier:** Pattern Identity ID plus editorial version.  
**Visibility:** Private by default. Sharing produces an explicit export artifact; it does not publish Private Identity.  
**Lifecycle:** Resolved, viewed, updated when identity or editorial version changes, historically referenced, deleted with private account data.  
**Offline behavior:** Released Pattern content may be bundled or cached for complete offline reading.  
**Sync behavior:** Editorial updates synchronize by version. User reveal/view state may synchronize as account state but does not alter Pattern content.  
**Retention:** Active and historically referenced versions remain available as required to explain saved/shared artifacts.  
**Deletion:** User-specific resolution and state are removed with Account deletion. Shared exports already sent outside Zodian cannot be recalled.  
**Versioning:** Identity-content version, resolver version, share-template version, and resolved timestamp.  
**Analytics boundaries:** Pattern ID/version and interaction events may be measured; exact birth inputs and full private copy are excluded.  
**Migration rules:** Existing resolved identity is revalidated against imported Private Identity and current approved resolver. Historical shares remain historical artifacts.  
**Relationships:** Derived from Private Identity; frames Today’s Lens and Observations; may be shared; may provide an approved label to Public Connect Profile.  
**Related ADRs:** ADR-001, ADR-006, ADR-008

---

## 6. Memory Event

**Purpose:** Record a bounded, factual user action that may later contribute evidence to Pattern Memory.  
**Owner:** The user; Zodian Memory domain defines event semantics.  
**Source of truth:** Device canonical by default. Raw Memory Events do not automatically synchronize.  
**Stable identifier:** Device-generated opaque Event ID with event-schema version and occurrence timestamp.  
**Visibility:** Private to the user. Not public, not available to Connect, and not copied into general analytics payloads.  
**Lifecycle:** Recorded, deduplicated, retained, excluded by user/system policy, deleted. Memory Events are immutable facts; corrections create exclusion metadata rather than rewriting history silently.  
**Offline behavior:** Fully functional offline.  
**Sync behavior:** None by default. Any future backup is blocked by Proposed ADR-015 and requires explicit consent.  
**Retention:** Local bounded retention sufficient for supported observation windows, with transparent pruning rules.  
**Deletion:** User can clear Memory independently. Account deletion must explain that device-local Memory may remain until locally cleared or app data is removed.  
**Versioning:** Event schema version, event semantic version, source-artifact version, and capture-app version.  
**Analytics boundaries:** Aggregate feature usage may be measured through separate Analytics Events. Raw source IDs, reflection text, Thread content, and evidence payloads do not enter analytics.  
**Migration rules:** Existing events may remain local through app upgrade. Import into any approved backup must preserve source, schema, timestamps, and deduplication state.  
**Relationships:** References actions involving Today’s Lens, Archive Entry, Thread, Pattern, or Connect lens without owning those domains; provides evidence to Observation.  
**Related ADRs:** ADR-002, ADR-007, ADR-009, ADR-015

---

## 7. Observation

**Purpose:** Express an evidence-derived insight about what has repeated, changed, disappeared, or attracted attention over a defined window.  
**Owner:** The user; Zodian Observation System governs evidence thresholds and presentation.  
**Source of truth:** Device canonical for personal Observations under local-first Memory. An Observation is derived but persisted for provenance, user feedback, and display history.  
**Stable identifier:** Opaque Observation ID independent of source IDs.  
**Visibility:** Private by default. Sharing creates an explicit export and does not expose underlying private evidence unless separately selected.  
**Lifecycle:** Candidate, validated, active, shown, dismissed, corrected, expired, superseded, deleted. Candidates below threshold never become active.  
**Offline behavior:** Generation from locally available evidence and viewing are available offline when required rules/content are present.  
**Sync behavior:** None by default. Optional backup remains blocked by ADR-015. Explicit share export is not synchronization.  
**Retention:** Active and historical Observations retained according to supported time windows, correction history, and local storage policy.  
**Deletion:** Deleting an Observation removes the statement and feedback record locally. Deleting source evidence invalidates dependent Observations or marks evidence unavailable.  
**Versioning:** Observation schema, category, editorial version, evidence-rule version, prompt version, validator version, model/provider version, and creation time.  
**Analytics boundaries:** Zodian may measure that an Observation was shown, dismissed, or rated using a non-content category/version. Statement text, source evidence, and private corrections remain local.  
**Migration rules:** Existing monthly reflection lines are not automatically treated as durable Observations unless reconstructed with valid evidence and provenance.  
**Relationships:** Links to one or more Memory Events, Today’s Lens entries, Archive Entries, or Threads as evidence. May contribute to monthly reflection, continuity, or sharing without becoming those artifacts.  
**Related ADRs:** ADR-002, ADR-007, ADR-009, ADR-015

---

## 8. Archive Entry

**Purpose:** Preserve a user-selected snapshot or reference to a meaningful Today’s Lens for later return.  
**Owner:** The user; Zodian Archive domain manages persistence and restoration.  
**Source of truth:** Server canonical for new account-owned entries, with a local cache. Existing beta-local entries remain local migration sources until an idempotent migration is finalized. This does not include raw Memory Events.  
**Stable identifier:** Archive Entry ID plus referenced Today’s Lens ID/version.  
**Visibility:** Private. Explicit sharing exports selected content but does not publish the Archive.  
**Lifecycle:** Saved, revisited, annotated in future if approved, unsaved, deleted.  
**Offline behavior:** Cached saved content remains readable offline. Offline save/unsave queues reconcile idempotently after account authority exists.  
**Sync behavior:** Account-scoped synchronization is permitted because Archive is distinct from local-first Pattern Memory.  
**Retention:** Retained until unsaved, account deletion, or a documented retention limit chosen by the user.  
**Deletion:** Unsave removes the canonical entry and caches. Account deletion removes server entries. Today’s Lens editorial source may remain independently.  
**Versioning:** Archive schema version, saved Today’s Lens version, save timestamp, migration source.  
**Analytics boundaries:** Save, unsave, revisit, and share events may be measured without read body or private annotation text.  
**Migration rules:** Existing saved reads import idempotently using source date, identity context, and content fingerprint/version. Duplicates collapse without losing earliest save provenance.  
**Relationships:** References Today’s Lens; supplies evidence to Memory Event and Observation; may be navigated from Pattern Memory.  
**Related ADRs:** ADR-001, ADR-002, ADR-005, ADR-009, ADR-013

---

## 9. Thread

**Purpose:** Hold private reflection about why a person, profile, signal, or relationship remains meaningful.  
**Owner:** The user.  
**Source of truth:** Private server canonical for new account-owned Threads, with a local cache. Existing beta-local Threads remain migration sources until accepted or discarded. Thread content is not public profile content.  
**Stable identifier:** Thread ID independent of Public Profile, Connection, and Message IDs.  
**Visibility:** Owner-only unless a future explicit sharing decision is accepted. The other person does not automatically see a Thread.  
**Lifecycle:** Created, active, revisited, archived, detached from deleted source, deleted.  
**Offline behavior:** Existing cached Threads remain readable and editable offline; pending edits reconcile idempotently when server-backed.  
**Sync behavior:** Private account synchronization is permitted. Thread does not synchronize into Message or Public Connect Profile.  
**Retention:** Retained until user deletion or account lifecycle removal. Detached Threads may preserve user-authored reflection while removing unavailable public-profile data.  
**Deletion:** Deleting a Thread does not delete a Connection, Message, Public Connect Profile, or other person's records. Account deletion removes owned Threads.  
**Versioning:** Thread schema version, source-type version, editorial prompt version for guided reflection, and update revision.  
**Analytics boundaries:** Creation, revisit, archive, and deletion may be measured. Thread titles, notes, prompts answered, and referenced private evidence are excluded.  
**Migration rules:** Threads based on generated profiles may migrate only into a clearly labeled private Beta Archive with editorial origin, or be discarded. They never create Connections or Messages.  
**Relationships:** May reference Public Connect Profile, editorial profile, Connection, Archive Entry, or Observation; may exist without Messages.  
**Related ADRs:** ADR-001, ADR-004, ADR-009, ADR-010, ADR-013

---

## 10. Connection

**Purpose:** Represent server-verified mutual authorization between eligible real users for defined social capabilities.  
**Owner:** Both participating users; Zodian Social Platform enforces state and safety policy.  
**Source of truth:** Server canonical.  
**Stable identifier:** Opaque Connection ID with two participant Account IDs; never inferred from local saves.  
**Visibility:** Participants and authorized moderation operations only. A connection may expose limited status to each participant.  
**Lifecycle:** Interest pending, mutual/active, declined, blocked, disconnected, suspended, deleted. Exact interaction rollout remains behind Connect feature flags.  
**Offline behavior:** Cached status may display offline but cannot authorize new social actions.  
**Sync behavior:** Server-authoritative state updates to participant devices. Blocks and suspensions override stale caches immediately upon reconnection.  
**Retention:** Active relationship state retained while needed; safety-relevant records follow moderation retention.  
**Deletion:** Disconnection removes active authorization. Blocking terminates relevant interaction. Account deletion removes or tombstones participation according to safety policy.  
**Versioning:** Connection-state schema and social-policy version.  
**Analytics boundaries:** Interest, mutual connection, disconnect, and block counts may be measured with pseudonymous IDs. No private Thread or Message content.  
**Migration rules:** Beta saves, generated matches, and simulated chats never create Connections.  
**Relationships:** Connects Accounts/Public Connect Profiles; may authorize Messages; may be referenced privately by each user's Thread; may create Moderation Cases.  
**Related ADRs:** ADR-003, ADR-004, ADR-010, ADR-016

---

## 11. Message

**Purpose:** Carry user-authored interpersonal communication within an authorized Connection.  
**Owner:** Participating users; Zodian Messaging Platform manages delivery and safety obligations.  
**Source of truth:** Server canonical if and when messaging is approved and launched. Current simulated local chat is not this domain.  
**Stable identifier:** Server-generated Message ID scoped to a Connection.  
**Visibility:** Connection participants and authorized moderation operations under published policy.  
**Lifecycle:** Pending send, sent, delivered if supported, read if supported, user-deleted where supported, moderated, retained, deleted. Product mechanics such as typing state require separate scope approval.  
**Offline behavior:** Outgoing messages may queue locally only after authorization is confirmed. Cached history may display according to retention policy.  
**Sync behavior:** Server-authoritative ordered synchronization with idempotent sends and authorization checks.  
**Retention:** Defined before launch, including deletion behavior, moderation holds, and backup expiration.  
**Deletion:** User deletion semantics must distinguish local hiding from service deletion. Account deletion and moderation retention must be transparent.  
**Versioning:** Message schema version, content-policy version, and encryption/transport version.  
**Analytics boundaries:** Delivery health and aggregate counts may be measured. Message text is not general analytics data.  
**Migration rules:** Simulated replies and beta local chat never migrate into Messages.  
**Relationships:** Requires Connection; may be linked to Moderation Case; remains separate from Thread.  
**Related ADRs:** ADR-003, ADR-004, ADR-010

---

## 12. Reward

**Purpose:** Acknowledge meaningful reflective engagement without becoming the product's primary motivation.  
**Owner:** Zodian Engagement System; the user owns earned status.  
**Source of truth:** Server canonical under the anonymous or linked Account; local state may provide provisional offline feedback.  
**Stable identifier:** Reward Grant ID plus versioned Reward Definition ID.  
**Visibility:** Private to the user unless a future sharing decision is accepted.  
**Lifecycle:** Eligible, granted, redeemed where applicable, expired where explicitly defined, revoked only for correction/fraud with auditability.  
**Offline behavior:** Provisional grants may appear offline but reconcile against idempotent server rules.  
**Sync behavior:** Account-scoped. Server prevents duplicate grants across devices.  
**Retention:** Grant history retained for account history and entitlement provenance.  
**Deletion:** Removed with Account deletion subject to transaction/legal retention.  
**Versioning:** Reward definition version, eligibility-rule version, and grant source.  
**Analytics boundaries:** Eligibility, grant, redemption, and engagement outcomes may be measured. No private reflection content.  
**Migration rules:** Beta rewards may migrate when rule provenance is trustworthy; otherwise convert through an explicit founder-approved policy rather than silently trusting local totals.  
**Relationships:** May be triggered by Today’s Lens completion or other approved reflective milestones; may grant Entitlement preview but is not itself an Entitlement.  
**Related ADRs:** ADR-001, ADR-005, ADR-013

---

## 13. Entitlement

**Purpose:** Authorize access to premium time horizons or features based on verified purchase, trial, reward, or administrative grant.  
**Owner:** Zodian Commerce System; purchase authority remains the platform commerce provider.  
**Source of truth:** Server-validated entitlement state derived from authoritative transaction/grant sources. Public-launch mode is blocked by Proposed ADR-014.  
**Stable identifier:** Entitlement Grant ID plus Account ID and product/feature key.  
**Visibility:** Private to the user and support operations.  
**Lifecycle:** Pending, active, grace period if applicable, expired, revoked, restored.  
**Offline behavior:** Last verified entitlement may be honored for a bounded grace period; irreversible purchase assumptions cannot be made from local flags.  
**Sync behavior:** Transaction updates and restore results reconcile server-side and propagate to devices.  
**Retention:** Transaction and entitlement provenance retained as legally and operationally required.  
**Deletion:** Account deletion removes app account access while platform subscription cancellation remains separately explained. Required financial records may be retained.  
**Versioning:** Product catalog version, entitlement-policy version, and transaction-verification version.  
**Analytics boundaries:** Product key, paywall source, purchase result, restore result, and active state may be measured. Payment instrument data is never collected by Zodian analytics.  
**Migration rules:** Local premium flags do not become paid entitlement. Founder-approved beta grants may migrate as explicit non-purchase grants with expiration and provenance.  
**Relationships:** Belongs to Account; gates approved premium capabilities such as longer Archive or Observation horizons; may be granted by Reward under explicit rules.  
**Related ADRs:** ADR-005, ADR-013, ADR-014

---

## 14. Moderation Case

**Purpose:** Track reports, safety review, evidence, enforcement, and appeal for public social content or behavior.  
**Owner:** Zodian Trust and Safety.  
**Source of truth:** Server canonical and access-restricted.  
**Stable identifier:** Moderation Case ID with immutable audit references.  
**Visibility:** Internal authorized reviewers; reporter receives limited status where appropriate. Reported users do not receive private reporter identity.  
**Lifecycle:** Submitted, triaged, under review, actioned, dismissed, appealed, closed, retained.  
**Offline behavior:** Reports may queue briefly but are not considered submitted until acknowledged by server. Blocking should take immediate local effect and reconcile server-side.  
**Sync behavior:** Server-only operational workflow with scoped status updates.  
**Retention:** Defined by safety, legal, and appeal requirements.  
**Deletion:** User account deletion does not automatically erase safety records that must be retained; retained data is minimized and access-controlled.  
**Versioning:** Community-standard version, moderation-policy version, enforcement taxonomy version.  
**Analytics boundaries:** Aggregate report volumes, categories, response time, and outcomes may be measured. Report narrative and evidence remain in restricted systems.  
**Migration rules:** No beta local social artifact creates a moderation history unless an actual safety report was submitted under a published process.  
**Relationships:** May reference Public Connect Profile, Account, Connection, or Message; can alter publication and connection state. It never owns Private Identity, Memory Event, Observation, or Thread content.  
**Related ADRs:** ADR-003, ADR-008, ADR-016

---

## 15. Notification

**Purpose:** Deliver user-authorized reminders and system events that support reflective return or account safety.  
**Owner:** The user controls permission and preferences; Zodian Notification System controls scheduling intent and delivery content.  
**Source of truth:** OS authorization is device canonical. Account-scoped notification preferences are server canonical after anonymous bootstrap; device scheduling state is local operational state.  
**Stable identifier:** Notification Intent ID plus device delivery identifier; no identifier is reused as an Account ID.  
**Visibility:** Private to the recipient. Lock-screen content follows privacy-safe copy rules.  
**Lifecycle:** Eligible, scheduled, delivered where known, opened, cancelled, expired.  
**Offline behavior:** Approved local reminders may schedule and fire offline. Remote system notifications require server connectivity.  
**Sync behavior:** Preferences synchronize by account; each device maintains its own token, authorization, and schedule.  
**Retention:** Delivery telemetry retained only as required for reliability and measurement. Device tokens are removed when invalid or account/device association ends.  
**Deletion:** Account deletion removes server preferences and device associations. Local pending notifications are cancelled by the app when possible.  
**Versioning:** Notification taxonomy, copy/editorial version, scheduling-rule version, and destination version.  
**Analytics boundaries:** Schedule, permission, delivery where available, open, and destination may be measured. Notification body and private source content are excluded.  
**Migration rules:** Existing local preferences may import to the account, but OS permission is never inferred or synchronized.  
**Relationships:** May point to Today’s Lens, Account action, or approved Connection event; does not own destination content.  
**Related ADRs:** ADR-001, ADR-013

---

## 16. Analytics Event

**Purpose:** Measure product behavior, reliability, activation, retention, and launch health without becoming a product-record substitute.  
**Owner:** Zodian Product Analytics; privacy policy governs collection.  
**Source of truth:** Append-only production analytics pipeline after acknowledged ingestion. Client logs are diagnostic copies, not canonical analytics.  
**Stable identifier:** Event ID plus event-name/version, pseudonymous subject ID where permitted, and occurred timestamp.  
**Visibility:** Internal authorized product/engineering access. Not user-facing except through privacy/export obligations.  
**Lifecycle:** Created, queued, ingested, validated, aggregated, expired/deleted under retention policy. Invalid events are quarantined rather than silently reinterpreted.  
**Offline behavior:** A bounded local queue retries with backoff. Product functionality does not depend on analytics success.  
**Sync behavior:** One-way append with idempotent Event IDs. Analytics never writes back into product domain truth.  
**Retention:** Event-level and aggregate retention are documented by purpose and minimized.  
**Deletion:** Account-linked events follow applicable deletion policy; aggregate de-identified metrics may remain. The process must be documented and testable.  
**Versioning:** Event taxonomy version, event schema version, experiment assignment version, and application version.  
**Analytics boundaries:** Prohibited payloads include exact birth data, authentication credentials, private reflection text, Memory evidence, Thread content, Message content, photos, and moderation narratives.  
**Migration rules:** Console-only beta logs are not retroactively promoted to production analytics. Funnel baselines begin only after validated event ingestion.  
**Relationships:** References domain IDs and non-content metadata only. It measures Account, Today’s Lens, Pattern, Archive Entry, Observation, Connect, Reward, Entitlement, Notification, and operations without replacing them.  
**Related ADRs:** ADR-001, ADR-002, ADR-007, ADR-008, ADR-009, ADR-012, ADR-013

---

## Explicit domain distinctions

| Domain | What it is | What it is not |
|---|---|---|
| Today’s Lens | A versioned editorial content artifact for a date and identity context | A record that the user saved or agreed with it |
| Archive Entry | A user-owned saved reference or snapshot of a Today’s Lens | A behavioral inference or raw Memory Event |
| Memory Event | A factual local action record that may become evidence | An insight, interpretation, or analytics event |
| Observation | A validated, evidence-derived statement with confidence and provenance | A Today’s Lens, raw event, generic copy block, or unsupported AI claim |

## Contract-level implementation gates

The following remain blocked until their ADRs are accepted:

- Paid commerce at public launch: ADR-014
- Raw Memory Event or personal Observation backup: ADR-015
- Public real-profile Connect eligibility and discovery: ADR-016
