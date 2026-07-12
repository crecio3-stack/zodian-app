# Zodian Public Launch Architecture Review

## Prompt for ChatGPT

Review the following product architecture plan for Zodian's transition from closed beta to public launch.

Please:

1. Challenge weak assumptions and identify missing launch requirements.
2. Evaluate whether the proposed phase order is correct.
3. Identify anything that should move into or out of the public-launch scope.
4. Recommend the smallest credible public-launch scope.
5. Highlight privacy, trust and safety, App Store, migration, scalability, and monetization risks.
6. End with a prioritized 30-, 60-, and 90-day plan.

Do not propose additional features unless they address a launch blocker or a clearly validated product need.

---

## Executive Recommendation

Do not launch real-person Connect by simply replacing generated profiles with beta profiles.

Zodian's reflective product is launchable sooner than its social ecosystem. The current social architecture is local-first, generated, and simulated:

- Core user and Connect profiles live in SwiftData on one device.
- Connect decks are generated locally.
- Threads are saved generated profiles.
- Chat stores local messages and generates automatic replies.
- Pattern Memory is device-local.
- Analytics currently writes only to console logs.
- Paid commerce is disabled.

The safest path is:

1. Publicly launch the reflective core.
2. Build account and trust infrastructure.
3. Introduce real-profile discovery as a controlled opt-in rollout.
4. Add real messaging only after moderation operations are proven.

Real users should never inherit assumptions created for generated profiles.

---

## Required Product Architecture

Separate data into explicit domains:

| Domain | Examples | Visibility |
|---|---|---|
| Account | Auth ID, email, account status | Private |
| Identity profile | Exact birthday, time, place, timezone | Strictly private |
| Public Connect profile | Display name, optional age, photo, prompts, intent, identity labels | Explicitly published |
| Discovery preferences | Visibility, age range, intentions, blocks | Private |
| Connections | Interest, mutual connection, status | Participants only |
| Threads | Saved people, private observations, prompts | Owner only |
| Messages | Conversation content, delivery/read state | Participants only |
| Pattern Memory | Events, evidence, observations, feedback | Owner only |
| Moderation | Reports, review state, sanctions | Internal |
| Commerce | Entitlements and transaction state | Owner/internal |

Exact birthday, birth time, birthplace, private Pattern history, saved reads, Memory observations, blocks, passes, and profile-view activity should never become public by default.

Use Supabase Auth as the canonical identity boundary, Postgres with row-level security as the data authority, and Storage for profile media. SwiftData should become an offline cache, not the social source of truth.

---

# Phase 1 — Public Launch Foundation

## Goal

Launch Zodian's reflective experience safely without pretending the social ecosystem is already real.

## Accounts and Lifecycle

- Add authentication, preferably Apple first.
- Assign every user an immutable server account ID.
- Support sign-in, sign-out, session recovery, and multi-device restore.
- Implement in-app account deletion and server-side cascading deletion.
- Add data export and access-request handling.
- Publish a privacy policy, terms, community standards, and support contact.
- Establish account states: active, suspended, deletion pending, and deleted.

Apple requires in-app account deletion when account creation exists. Social and user-generated-content products also require filtering, reporting, blocking, and responsive moderation before public UGC is enabled.

## Beta Migration

Do not automatically publish existing beta Connect cards.

On first authenticated launch:

- Import the private identity profile.
- Preserve saved Today’s Lens entries, Archive history, streak, and rewards where technically trustworthy.
- Import Pattern Memory events privately, marked with their original local source.
- Convert the existing Connect card into an unpublished draft.
- Ask the user to review every public field and explicitly publish.
- Upload the photo only after that confirmation.
- Discard generated likes, passes, matches, and simulated conversations as social records.
- Optionally retain saved generated profiles in a clearly labeled Beta Archive, separate from real users.

Migration must be versioned, idempotent, resumable, and auditable. Never use display name or birthday to merge accounts.

## Connect at Launch

Choose one:

- Keep curated Connect clearly described as an editorial preview.
- Temporarily make Connect invite-only.

Do not present generated profiles or generated replies as real people after public launch.

## Operational Foundations

- Production analytics rather than console logging.
- Crash reporting and backend error monitoring.
- Release health dashboard.
- Database backups and restore testing.
- API rate limiting and abuse controls.
- Separate development, beta/staging, and production environments.
- Remote feature flags and emergency kill switches.
- App Store privacy disclosures and privacy manifest review.

## Premium Decision

Choose one:

- Launch free and remove unavailable purchase expectations.
- Complete StoreKit subscriptions, restore purchases, entitlement synchronization, subscription management, and App Store Server Notifications.

Do not launch a half-enabled premium system.

---

# Phase 2 — Controlled Real-Profile Connect

## Goal

Introduce a trustworthy discovery ecosystem without adding messaging complexity.

## Publishing Lifecycle

Profiles should have explicit states:

`draft → pending review → published → hidden/suspended/deleted`

Publication requirements:

- Confirm that the user is eligible for social discovery.
- Review public fields before publishing.
- Obtain explicit consent for photo, identity labels, age, and prompts.
- Default visibility off for migrated beta profiles.
- Keep moderation state independent from user visibility.
- Provide immediate unpublish control.

Given Connect's relational language and photos, an 18+ policy is the simplest launch posture. Supporting minors would materially increase safety and compliance complexity.

## Discovery Architecture

Server-side discovery must enforce:

- Published and moderation-approved profiles only.
- Exclusion of self, blocked users, and previous hard passes.
- Visibility and preference rules.
- Cursor pagination.
- Exposure limits and diversity constraints.
- Stable profile IDs.
- Server-side rate limits.
- Explainable ranking inputs.

Keep unchanged:

- The three lenses.
- Lens-specific editorial framing.
- Generated reasons.
- Limited daily selection.
- Calm, intentional presentation.
- Threads as the place users keep meaningful profiles.

Change before rollout:

- Replace endless generation with a hybrid pool.
- Clearly distinguish real profiles from editorial examples.
- Compute ranking from structured public attributes.
- Treat reasons as interpretive suggestions, not factual claims about another person.
- Add report, block, hide, and "Why am I seeing this?" controls.

## Interaction Model

Start with:

- Save privately.
- Express interest.
- Mutual interest creates a connection.
- A connection receives guided Thread prompts.

This tests whether users want interaction before assuming they need unrestricted chat.

---

# Phase 3 — Memory and Relationship Intelligence

## Goal

Make Zodian attentive without making unsupported claims.

## Pattern Memory Foundation

Before adding more AI, create a durable evidence system:

- Immutable, versioned event schema.
- Server timestamps and stable entity IDs.
- Clear distinction between exposure, opening, saving, revisiting, and acting.
- Source references for every observation.
- Observation confidence and minimum evidence thresholds.
- Algorithm, prompt, and model version attached to generated observations.
- Suppression rules for weak or contradictory evidence.
- User feedback: Accurate, Not Quite, and Don't Use This.
- Export and deletion support.
- An explicit rule that Memory remains private and is not used for public discovery without separate consent.

## Evidence Presentation

Every meaningful observation should answer:

- What did Zodian notice?
- Over what period?
- Based on which reads or actions?
- How strong is the pattern?
- Can the user inspect or dismiss the evidence?

Example:

> Boundaries appeared in three of the five reads you saved this month.

Tapping the observation should reveal those three reads.

Avoid opaque statements such as "You are avoiding ambition" without strong comparative evidence.

## Memory Evolution

Over the next year:

1. Reliable synchronization and evidence.
2. Seven-, 30-, and 90-day comparisons.
3. Today’s Lens continuity using prior evidence.
4. Monthly reflection with inspectable sources.
5. User-correctable themes and exclusions.
6. Carefully constrained AI synthesis.
7. Memory-derived sharing.
8. Optional personalized Connect ranking with separate consent.

AI should explain validated evidence, not manufacture the evidence itself.

---

# Phase 4 — Real Conversation and Monetization

## Goal

Add ongoing interpersonal value after trust systems are operational.

## Threads vs Chat

Threads is the more differentiated product. It owns:

- People the user wants to revisit.
- Why they mattered.
- Signals and recurring attraction patterns.
- Guided questions.
- Private relationship reflection.
- Connection history.

Real conversation should be a distinct capability inside a mutual connection. Threads should not become synonymous with a message inbox.

Real chat is not required before the initial public launch. It should wait until Zodian has:

- Mutual consent.
- Report and block.
- Content filtering.
- Rate limits.
- Spam prevention.
- Push delivery.
- Read and delivery state.
- Message deletion and retention policy.
- Moderation tooling.
- User suspension enforcement.
- Operational response procedures.

The existing simulated auto-reply experience must not survive as apparent person-to-person chat.

## Monetization

Once retention is demonstrated, premium can reasonably own:

- Full Pattern Archive.
- Deeper Memory windows.
- Monthly and seasonal reflections.
- Additional continuity.
- Advanced private relationship insights.

Do not paywall safety, blocking, reporting, deletion, basic account controls, or the ability to hide a profile.

---

# Features Not to Build Before Launch

- Real-time chat.
- Read receipts, typing indicators, or presence.
- Compatibility percentages.
- Location-based discovery.
- Global profile search.
- Public follower/following counts.
- Comments or public posting.
- AI-generated messages sent automatically to another user.
- Advanced recommendation machine learning.
- Multiple premium tiers.
- Profile verification badges beyond basic moderation status.
- Video profiles.
- Group conversations.
- Public Memory observations.
- Cross-user relationship analysis based on private behavior.
- More reward systems, badges, or currencies.
- A dedicated moderation AI before basic human review tooling exists.

---

# Public Launch Blockers

## Backend

- Authentication and canonical user IDs.
- Production relational schema.
- Row-level security tests.
- Media storage and deletion.
- Idempotent migration.
- Rate limiting.
- Backups and disaster recovery.
- Staging environment.
- Feature flags.
- Admin and moderation interface.

## Safety and Moderation

- Terms and community standards.
- Automated text and image screening.
- User report flow.
- Block flow.
- Immediate profile hiding.
- Moderator queue.
- Enforcement states.
- Appeals and support process.
- Defined response targets.
- Repeat-abuse detection.

## Account Lifecycle

- Sign-in and recovery.
- Profile editing and unpublishing.
- Account deletion.
- Data-deletion propagation.
- Subscription cancellation explanation.
- Export or access-request process.
- Suspended-user behavior.
- Deleted-user treatment in existing connections.

## Privacy

- Public/private field separation.
- Consent ledger for profile publication.
- Retention policy.
- Exact birth-data protection.
- Photo-deletion guarantees.
- Privacy policy.
- App Store privacy labels.
- Vendor inventory.
- Secure logs without birth details or message content.

## Analytics and Operations

Measure:

- Onboarding completion.
- Day-1, day-7, and day-30 retention.
- Today’s Lens opens and completions.
- Memory eligibility and engagement.
- Connect profile completion and publication.
- Discovery impressions and saves.
- Mutual connections.
- Reports and blocks per active user.
- Migration success and failure.
- Account-deletion completion.
- API latency and failure rate.

## Scalability

Supabase and Postgres are sufficient. Do not introduce microservices yet.

Priorities:

- Correct indexes.
- Cursor pagination.
- Row-level-security performance testing.
- Server-side feed generation.
- Storage and CDN usage.
- Background jobs for moderation and notifications.
- No synchronous AI calls during feed rendering.
- Cache generated explanations by user, profile, lens, and version.
- Establish AI and media cost limits.

---

# Primary Risks

## Technical Risks

- Local/server divergence during migration.
- Weak row-level security exposing private birth or Memory data.
- Duplicate accounts or imported records.
- Orphaned media after profile or account deletion.
- Ranking latency caused by per-card generation.
- Unbounded event storage.
- Moderation jobs failing silently.
- Entitlement drift between device and App Store.
- Client-controlled visibility or eligibility rules.
- Generated explanations changing unpredictably between sessions.

## Product Risks

- Users believing generated psychological claims are factual.
- Connect feeling like dating when product positioning is ambiguous.
- Publishing profiles without a meaningful interaction endpoint.
- Empty-feed problems at low launch density.
- Curated profiles creating false expectations about real users.
- Safety tooling damaging the calm premium tone if added reactively.
- Pattern Memory becoming surveillance-like.
- Threads losing its differentiated reflective role by becoming a generic inbox.
- Too many major systems launching simultaneously.

## Migration Risks

- Current visibility defaults cannot be treated as public consent.
- Beta photos were saved for local use, not server publication.
- Simulated conversations cannot become real relationship history.
- Local IDs have no trustworthy relationship to future authentication IDs.
- Streak and reward state may be manipulated locally.
- Pattern Memory events may be incomplete or duplicated.
- Some users may reinstall before linking an account.
- A forced reset may destroy the strongest beta-user retention evidence.

Recommendation: migrate private reflective history, import the Connect card as a draft, and reset social interaction history.

---

# Recommended Implementation Order

1. Finalize the launch model: reflective public launch first, real Connect later.
2. Define public/private data contracts and retention rules.
3. Implement authentication and canonical account lifecycle.
4. Design the production database, Storage layout, and row-level-security policies.
5. Build idempotent local-to-account migration.
6. Add account deletion, export, privacy, terms, and support.
7. Add production analytics, crash reporting, monitoring, and feature flags.
8. Resolve premium: fully free or complete StoreKit.
9. Build profile draft, publish, and unpublish lifecycle.
10. Build report, block, moderation queue, and enforcement.
11. Launch real profiles to a small opt-in cohort.
12. Tune hybrid discovery and density handling.
13. Add mutual interest and guided Thread invitations.
14. Move Pattern Memory to server-backed evidence.
15. Add real messaging only after safety operations prove reliable.

---

# Impact vs Implementation Cost

| Initiative | Impact | Cost | Recommendation |
|---|---:|---:|---|
| Authentication and account lifecycle | Critical | High | Immediate |
| Public/private profile separation | Critical | Medium | Immediate |
| Beta migration | High | High | Immediate |
| Account deletion and privacy compliance | Critical | Medium | Immediate |
| Production analytics and monitoring | Critical | Medium | Immediate |
| Profile publishing workflow | High | Medium | Before real discovery |
| Reporting, blocking, and moderation | Critical | High | Before real discovery |
| Real-profile discovery | Very high | High | Controlled Phase 2 |
| Hybrid curated and real feed | High | Medium | Phase 2 |
| Mutual-interest connection | High | Medium | Phase 2–3 |
| Evidence-backed Pattern Memory | Very high | High | Phase 3 |
| Monthly reflection improvement | High | Medium | After evidence foundation |
| Real chat | Medium initially | Very high | Phase 4 |
| StoreKit premium | Medium | High | Launch free or finish completely |
| Advanced recommendation ML | Unproven | Very high | Post-launch |
| Memory-derived sharing | High | Medium | After Memory reliability |

---

# Core Decision

Treat public-profile publication as a new, explicit contract, not as a migration of existing beta visibility.

The reflective product and the social ecosystem should have separate launch gates:

- The reflective product is gated by stability, privacy, analytics, account lifecycle, and App Store readiness.
- The social ecosystem is additionally gated by consent, moderation, reporting, blocking, discovery integrity, and operational trust and safety.

---

# Reference Sources

- [Apple App Review Guidelines: User-Generated Content](https://developer.apple.com/app-store/review/guidelines/)
- [Apple account deletion requirements](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
- [Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Apple subscription guidance](https://developer.apple.com/app-store/subscriptions/)
