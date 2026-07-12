# Zodian Public Launch Checklist

**Document version:** 1.1  
**Effective date:** 2026-06-25  
**Owner:** Zodian Founder/CTO  
**Status:** Governing launch gate  
**Governed by:** [ARCHITECTURE_DECISIONS.md](ARCHITECTURE_DECISIONS.md)  
**Constrained by:** [PRODUCT_PRINCIPLES.md](PRODUCT_PRINCIPLES.md)  
**Verifies:** [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md) and [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md)

## Completion rules

- Every row is binary: incomplete or complete.
- A checkbox may be marked complete only when its required evidence exists and is linked or recorded.
- Completion date uses `YYYY-MM-DD`.
- An owner is accountable for evidence and remediation.
- Proposed ADRs block only the affected launch capability. ADR-014 blocks paid commerce; ADR-015 does not block local-first launch; ADR-016 blocks real-profile Connect, not the reflective launch.
- The reflective public launch may proceed with Connect disabled.
- Any material architecture change requires governance updates and a new consistency audit under ADR-012.

## Launch decision states

- **No-go:** Any required reflective-launch item is incomplete.
- **Conditional go:** All required items are complete, with documented non-critical warnings and owners.
- **Go:** All required items are complete; staged rollout and rollback controls are verified.

---

## Product

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Product vision and principles are approved as version 1.0 | Founder/CTO | Signed review record referencing `PRODUCT_PRINCIPLES.md` | — | ADR-001, ADR-006, ADR-012 | All |
| [ ] Reflective public-launch scope is frozen | Product | Approved scope listing Today’s Lens, Pattern, local-first Pattern Memory, Archive, Rewards, Notifications, Sharing, and private account | — | ADR-001, ADR-003 | Today’s Lens, Pattern, Memory Event, Observation, Archive Entry |
| [ ] Connect is disabled or clearly closed beta for public users | Product/Engineering | Production feature-flag screenshot and launch-build verification | — | ADR-001, ADR-003 | Public Connect Profile, Connection, Message |
| [ ] Generated profiles are clearly editorial or absent | Product/QA | Screenshots and content audit showing no generated profile is represented as a real person | — | ADR-010 | Public Connect Profile, Thread |
| [ ] Simulated conversations are inaccessible or clearly non-social | Product/QA | Launch-build flow audit | — | ADR-004, ADR-010 | Message, Thread |
| [ ] Today’s Lens follows reflection-before-prediction standards | Editorial | Approved quality rubric and sampled review results | — | ADR-006, ADR-007 | Today’s Lens |
| [ ] Every active evidence-derived Observation is inspectable | Product/QA | Test evidence showing source window, evidence access, dismissal, and correction behavior | — | ADR-007, ADR-009 | Observation, Memory Event |
| [ ] Pattern Memory local-first disclosure is visible and accurate | Product/Privacy | Launch screenshots and approved copy | — | ADR-002 | Memory Event, Observation |
| [ ] Editorial, prompt, validator, and model provenance is recorded | Editorial/Engineering | Artifact metadata audit across Today’s Lens and Observation paths | — | ADR-007, ADR-009, ADR-012 | Today’s Lens, Pattern, Observation |
| [ ] Sharing exports only user-selected content | Product/Privacy | Share-flow privacy test and screenshots | — | ADR-002, ADR-008, ADR-009 | Pattern, Observation, Archive Entry |
| [ ] Accessibility review is complete for critical launch flows | Product/QA | VoiceOver, Dynamic Type, contrast, motion, and control-label report | — | ADR-001 | All user-facing domains |

---

## Accounts

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [x] ADR-013 ownership, account bootstrap, and linking model is Accepted | Founder/CTO | `ARCHITECTURE_DECISIONS.md` v1.1 | 2026-06-25 | ADR-011, ADR-013 | Account |
| [x] Anonymous Account bootstrap completes before persistent onboarding data | Engineering/QA | Clean-install runtime trace and SwiftData row-count evidence in `SPRINT_1_ACCOUNT_VALIDATION.md` | 2026-06-25 | ADR-013 | Account, Private Identity |
| [ ] Canonical Account ID is stable and provider-independent | Engineering | Architecture test demonstrating provider link does not change Account ID | — | ADR-013 | Account |
| [ ] Installation ID and Account ID remain distinct across reinstall and recovery scenarios | Engineering/QA | Identifier lifecycle test matrix | — | ADR-013 | Account |
| [ ] Account creation/linking flow is production-ready | Engineering/QA | End-to-end test across new install, link, restart, and second device where supported | — | ADR-013 | Account |
| [ ] Apple links to the existing anonymous Account without duplicate ownership | Engineering/QA | Transactional link, retry, collision, and duplicate-account test | — | ADR-013 | Account |
| [ ] Sole recoverability credential cannot be unlinked | Engineering/QA | Credential unlink policy test | — | ADR-013 | Account |
| [ ] Anonymous account-loss limitations are clearly disclosed | Product/Privacy | Approved UI copy and launch-build screenshot | — | ADR-013 | Account |
| [ ] Session recovery and expiration behavior is verified | Engineering/QA | Test report covering valid, expired, revoked, and offline sessions | — | ADR-013 | Account |
| [ ] Sign-out preserves or clears local data according to contract | Engineering/Privacy | Signed behavior matrix and device test | — | ADR-002, ADR-008, ADR-013 | Account, Memory Event, Observation |
| [ ] In-app account deletion is easy to find and complete | Product/Engineering | End-to-end deletion evidence and App Store review notes | — | ADR-008, ADR-013 | Account |
| [ ] Account deletion propagation is verified | Engineering/Privacy | Deletion report covering private records, public profile, media, caches, and retained exceptions | — | ADR-008, ADR-013 | Account, Private Identity, Public Connect Profile, Archive Entry, Thread |
| [ ] Device-local Pattern Memory behavior during account deletion is explicit | Privacy/Product | Approved copy and test showing local clear choice/behavior | — | ADR-002 | Memory Event, Observation |
| [ ] Account recovery and support process is documented | Support/Engineering | Runbook and tested support scenario | — | ADR-013 | Account |

---

## Privacy

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Public/private data classification is approved | Privacy/Engineering | Reviewed classification mapped to every Domain Contract | — | ADR-002, ADR-008 | All |
| [ ] Exact birth data is isolated from public profile access | Security/Engineering | Authorization test proving public/social paths cannot access exact birth inputs | — | ADR-008 | Private Identity, Public Connect Profile |
| [ ] Raw Memory Events never leave the device by default | Security/QA | Network inspection and automated privacy test | — | ADR-002, ADR-015 | Memory Event |
| [ ] Personal Observations never leave the device by default | Security/QA | Network inspection and automated privacy test | — | ADR-002, ADR-015 | Observation |
| [x] Analytics excludes prohibited private payloads | Privacy/Data | Event-schema audit, injected prohibited-property test, and sampled metadata-only logs in `SPRINT_2_PRODUCTION_READINESS_VALIDATION.md` | 2026-06-25 | ADR-002, ADR-007, ADR-008 | Analytics Event |
| [ ] Logs and crash reports exclude prohibited private payloads | Security/Engineering | Redaction test and sampled crash/log audit | — | ADR-002, ADR-008 | Private Identity, Memory Event, Observation, Thread, Message |
| [ ] Local data-clear controls behave independently by domain | Product/QA | Test report for Memory clear, Archive removal, Thread deletion, and account deletion | — | ADR-002, ADR-004, ADR-009 | Memory Event, Observation, Archive Entry, Thread |
| [ ] Retention schedule is approved and implemented | Privacy/Legal | Retention matrix with technical verification | — | ADR-008, ADR-012 | Account, Analytics Event, Moderation Case, Entitlement |
| [ ] Privacy policy matches actual production behavior | Privacy/Legal | Final policy mapped to data-flow inventory | — | ADR-002, ADR-008 | All |
| [ ] App Store privacy disclosures match production behavior | Privacy/Product | App Store Connect export or screenshots and internal sign-off | — | ADR-002, ADR-008 | All |
| [ ] Third-party vendor and SDK inventory is complete | Security/Privacy | Vendor register, purpose, data classes, retention, and contracts | — | ADR-012 | Analytics Event, Account, Entitlement |

---

## Legal

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Terms of Service are published and linked in app | Legal/Product | Public URL and launch-build link test | — | ADR-001, ADR-008 | Account |
| [ ] Privacy Policy is published and linked in app | Legal/Product | Public URL and launch-build link test | — | ADR-002, ADR-008 | All |
| [ ] Support contact information is published | Support/Product | Public support channel and response ownership | — | ADR-003 | Account, Moderation Case |
| [ ] Reflection and astrology claims are legally reviewed | Legal/Editorial | Claims review and approved disclaimer strategy | — | ADR-006, ADR-007 | Today’s Lens, Pattern, Observation |
| [ ] Account-deletion policy meets App Store requirements | Legal/Engineering | Legal sign-off and tested in-app flow | — | ADR-008, ADR-013 | Account |
| [ ] Connect age policy is resolved before real-profile beta | Founder/Legal | ADR-016 Accepted and policy published | — | ADR-016 | Public Connect Profile, Moderation Case |
| [ ] Community standards exist before real-profile beta | Legal/Trust and Safety | Published standards and enforcement taxonomy | — | ADR-003, ADR-016 | Public Connect Profile, Connection, Message, Moderation Case |
| [ ] Profile-photo rights and consent language are approved | Legal/Product | Upload consent copy and policy sign-off | — | ADR-008, ADR-016 | Public Connect Profile |

---

## Migration

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Migration inventory maps every beta-local record to an approved outcome | Engineering/Product | Signed source-to-target migration matrix | — | ADR-010, ADR-011, ADR-013 | All migratable domains |
| [ ] Migration is versioned, idempotent, resumable, and auditable | Engineering/QA | Repeated-run, interruption, retry, and receipt tests | — | ADR-011, ADR-012, ADR-013 | Account, Private Identity, Archive Entry, Thread |
| [ ] Migration ID is immutable and reused for retries of the same operation | Engineering/QA | Retry and deliberate-new-operation test | — | ADR-013 | Account |
| [ ] Local Record IDs map to canonical domain IDs without becoming owner IDs | Engineering/QA | Migration mapping audit | — | ADR-013 | Account, Private Identity, Archive Entry, Thread |
| [ ] Private Identity imports without publication | Engineering/Privacy | End-to-end migration privacy test | — | ADR-008 | Private Identity |
| [ ] Saved Today’s Lens entries deduplicate without losing provenance | Engineering/QA | Fixture-based migration report | — | ADR-009, ADR-013 | Today’s Lens, Archive Entry |
| [ ] Raw Memory Events remain local | Engineering/Privacy | Network and storage verification during migration | — | ADR-002, ADR-015 | Memory Event |
| [ ] Existing Observations remain local or are locally reconstructed | Engineering/QA | Migration behavior test with provenance review | — | ADR-002, ADR-009, ADR-015 | Observation |
| [ ] Beta Connect card becomes an unpublished draft only | Engineering/Product | Migration test and post-migration screenshot | — | ADR-008, ADR-010, ADR-016 | Public Connect Profile |
| [ ] Beta photos are not uploaded without explicit consent | Engineering/Privacy | Network test and consent-flow evidence | — | ADR-008, ADR-010 | Public Connect Profile |
| [ ] Generated profiles and matches never become real social records | Engineering/QA | Database/domain audit after migration fixtures | — | ADR-010 | Public Connect Profile, Connection |
| [ ] Simulated conversations never become Messages | Engineering/QA | Migration audit and fixture results | — | ADR-004, ADR-010 | Message, Thread |
| [ ] Local premium flags never become paid Entitlements | Engineering/Commerce | Migration audit across premium fixtures | — | ADR-005, ADR-014 | Entitlement |
| [ ] Migration rollback/support procedure is tested | Engineering/Support | Runbook and staged failure exercise | — | ADR-011, ADR-013 | Account |

---

## Analytics

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Production analytics provider is enabled | Data/Engineering | Staging-to-production ingestion verification | — | ADR-001, ADR-012 | Analytics Event |
| [ ] Event taxonomy and schemas are versioned | Data/Product | Approved taxonomy and schema registry | — | ADR-007, ADR-012 | Analytics Event |
| [ ] Event ingestion is idempotent | Data/Engineering | Duplicate-event test using stable Event IDs | — | ADR-012 | Analytics Event |
| [x] Offline queue is bounded and non-blocking | Engineering/QA | Explicit 1,000-event cap plus unreachable-provider queue test in `SPRINT_2_PRODUCTION_READINESS_VALIDATION.md` | 2026-06-25 | ADR-001 | Analytics Event |
| [ ] Activation funnel events pass end-to-end validation | Data/QA | Test-account event trace and funnel output | — | ADR-001 | Account, Today’s Lens, Analytics Event |
| [ ] Funnel identity is stable across anonymous-to-linked account transition | Data/Engineering | Identity-linking analytics test under accepted ADR-013 | — | ADR-013 | Account, Analytics Event |
| [ ] Retention calculations use approved definitions | Data/Product | Query review and reproducible sample calculation | — | ADR-001 | Analytics Event |
| [x] Product analytics cannot mutate product state | Engineering/Security | One-way provider architecture audit in `SPRINT_2_PRODUCTION_READINESS_VALIDATION.md`; analytics has no product-state dependency or write-back interface | 2026-06-25 | ADR-007, ADR-012 | Analytics Event |
| [ ] Analytics failure monitoring and alerting exist | Data/Operations | Alert test and runbook | — | ADR-012 | Analytics Event |

---

## Operations

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Development, staging/beta, and production are isolated | Engineering/Security | Partial: Debug validates against isolated Development project `wlsewblvpyeanfganbkc`, Beta still resolves existing beta project `xyyahrqfmdblvonnaifi`, and Release fails closed; Production Supabase project and access review remain incomplete (`ENVIRONMENT_ISOLATION_VALIDATION.md`) | — | ADR-011, ADR-012 | All server-backed domains |
| [ ] Production backup and restore are tested | Engineering/Operations | Successful restore exercise and recovery-time record | — | ADR-012 | Account-backed domains |
| [ ] Crash reporting is production-ready | Engineering/Operations | Test crash, symbolication proof, and privacy audit | — | ADR-012 | Operational |
| [ ] Backend error monitoring and alerting are production-ready | Engineering/Operations | Synthetic failure and alert receipt | — | ADR-012 | Account-backed domains |
| [ ] Critical service dashboards exist | Engineering/Operations | Dashboard links for account, content, migration, deletion, analytics, and notifications | — | ADR-012 | Account, Today’s Lens, Analytics Event, Notification |
| [ ] Incident-response runbook is approved | Founder/Operations | Runbook with severity, ownership, communication, and rollback steps | — | ADR-003, ADR-012 | All |
| [ ] Support escalation process is operational | Support/Operations | Ticket routing test and ownership schedule | — | ADR-012 | Account, Entitlement, Moderation Case |
| [ ] Data-access roles follow least privilege | Security/Operations | Access-control review and audit export | — | ADR-002, ADR-008 | All private domains |
| [ ] Production secrets are isolated and rotated | Security/Engineering | Partial: client rejects secret/service-role keys and local overrides are ignored; production project and rotation evidence remain unavailable (`ENVIRONMENT_ISOLATION_VALIDATION.md`) | — | ADR-012 | Account-backed domains |

---

## Moderation

The reflective launch may mark this category `Not Applicable — Connect disabled` only when production feature flags prevent real-profile publication, discovery, Connections, and Messages. Each social capability still requires these items before activation.

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Public profile publication is disabled until moderation gates pass | Engineering/Product | Production feature-flag proof | — | ADR-003, ADR-016 | Public Connect Profile |
| [ ] Text and image screening policy is defined | Trust and Safety/Legal | Approved policy and test corpus results | — | ADR-003, ADR-016 | Public Connect Profile |
| [ ] Report flow is complete and acknowledged server-side | Product/Engineering | End-to-end report test and case creation evidence | — | ADR-003 | Moderation Case |
| [ ] Block takes immediate local effect and server-wide effect | Engineering/QA | Offline/online block enforcement tests | — | ADR-003 | Account, Connection, Moderation Case |
| [ ] Moderator queue and restricted access exist | Trust and Safety/Engineering | Role-based access test and queue demonstration | — | ADR-003, ADR-016 | Moderation Case |
| [ ] Enforcement states affect discovery and interaction | Engineering/QA | Suspension and restriction test matrix | — | ADR-003, ADR-016 | Public Connect Profile, Connection, Message |
| [ ] Appeals and support process are defined | Trust and Safety/Support | Published process and runbook | — | ADR-003, ADR-016 | Moderation Case |
| [ ] Response targets and escalation ownership are staffed | Founder/Trust and Safety | On-call schedule and service-level targets | — | ADR-003 | Moderation Case |
| [ ] Repeat-abuse monitoring exists | Trust and Safety/Data | Detection dashboard and test cases | — | ADR-003 | Account, Moderation Case |

---

## Performance

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Cold launch meets approved target on supported devices | Engineering/QA | Performance report; target placeholder resolved before RC | — | ADR-001 | Application |
| [ ] Home and Today’s Lens render without blocking network dependency | Engineering/QA | Offline and degraded-network test | — | ADR-001 | Today’s Lens, Pattern |
| [ ] Cached Pattern, Today’s Lens, Archive, Memory, and Threads remain usable offline as contracted | Engineering/QA | Offline behavior matrix | — | ADR-002, ADR-004 | Pattern, Today’s Lens, Archive Entry, Memory Event, Observation, Thread |
| [ ] Content endpoint latency and availability meet approved targets | Engineering/Operations | Load test and production-like SLO report | — | ADR-001 | Today’s Lens |
| [x] Analytics failure cannot degrade user flows | Engineering/QA | Unreachable PostHog endpoint test with queued events and usable Home/Today’s Lens in `SPRINT_2_PRODUCTION_READINESS_VALIDATION.md` | 2026-06-25 | ADR-001 | Analytics Event |
| [ ] Migration performs within approved time and memory limits | Engineering/QA | Large-fixture migration benchmark | — | ADR-011, ADR-013 | Migration |
| [ ] Local Memory retention remains within storage budget | Engineering/QA | Maximum-history storage test and pruning verification | — | ADR-002 | Memory Event, Observation |
| [ ] Social and commerce code paths remain dormant when flagged off | Engineering/QA | Launch-build runtime and network audit | — | ADR-003, ADR-014 | Public Connect Profile, Connection, Message, Entitlement |

---

## Premium

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] ADR-014 public-launch monetization mode is Accepted | Founder/CTO | Accepted ADR and scope update | — | ADR-014 | Entitlement |
| [ ] Launch build matches the accepted monetization mode | Product/QA | Feature audit showing fully disabled or fully operational commerce | — | ADR-005, ADR-014 | Entitlement |
| [ ] Premium copy sells longer perspective, not accuracy | Product/Legal | Paywall and marketing copy audit | — | ADR-005 | Entitlement, Archive Entry, Observation |
| [ ] Free insight quality is not deliberately degraded | Editorial/Product | Free/premium content-quality review | — | ADR-005, ADR-007 | Today’s Lens, Pattern, Observation |
| [ ] Safety and account controls are never paywalled | Product/QA | Entitlement matrix test | — | ADR-005, ADR-008 | Account, Moderation Case |
| [ ] If commerce is enabled, purchase and restore pass sandbox and review-account tests | Commerce/QA | StoreKit test evidence and App Review notes | — | ADR-014 | Entitlement |
| [ ] If commerce is enabled, server entitlement reconciliation is verified | Commerce/Engineering | Purchase, renewal, expiration, refund, revoke, and restore tests | — | ADR-005, ADR-014 | Entitlement |
| [ ] If commerce is disabled, unavailable purchase claims and controls are removed | Product/QA | Launch-build audit | — | ADR-014 | Entitlement |
| [ ] Subscription support and cancellation guidance are published if applicable | Support/Commerce | In-app flow and support article | — | ADR-014 | Entitlement, Account |

---

## App Store

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] App name, subtitle, description, keywords, and screenshots match launch scope | Product/Marketing | App Store Connect review export | — | ADR-001, ADR-003 | Product |
| [ ] App Review notes explain Connect availability and test paths | Product/Engineering | Final review notes | — | ADR-003 | Public Connect Profile |
| [ ] Privacy Policy URL is public and valid | Legal/Product | URL verification | — | ADR-002, ADR-008 | All |
| [ ] Support URL and contact path are public and valid | Support/Product | URL and response test | — | ADR-003 | Account, Moderation Case |
| [ ] Privacy nutrition labels match production data collection | Privacy/Product | App Store Connect sign-off | — | ADR-002, ADR-008 | Analytics Event, Account |
| [ ] In-app account deletion is included if account creation is enabled | Product/QA | Launch-build test and screenshots | — | ADR-013 | Account |
| [ ] Required purpose strings match actual feature use | Privacy/Engineering | Info-property audit and device permission tests | — | ADR-008 | Public Connect Profile, Notification |
| [ ] Export compliance, content rights, and age rating are reviewed | Legal/Product | App Store submission checklist | — | ADR-006, ADR-016 | Product |
| [ ] If UGC/social features are enabled, filtering, report, block, and contact requirements pass | Trust and Safety/Product | Moderation checklist evidence | — | ADR-003, ADR-016 | Public Connect Profile, Connection, Message, Moderation Case |
| [ ] If purchases are enabled, products and review configuration are complete | Commerce/Product | App Store product status and review-account test | — | ADR-014 | Entitlement |
| [ ] Release candidate passes full manual regression | QA | Signed regression report | — | ADR-001, ADR-012 | All launch domains |

---

## Metrics

### Activation funnel definitions

| Metric | Definition | Denominator | Measurement window | Success threshold | Review cadence | Evidence query placeholder | Related ADR | Related domain |
|---|---|---|---|---|---|---|---|---|
| Onboarding Completion | New eligible users who emit a validated onboarding-completed event | Anonymous canonical Accounts entering onboarding | Same session and within 24 hours | `TBD before RC` | Weekly; daily during rollout | `QUERY:onboarding_completion_v1` | ADR-001, ADR-013 | Account, Private Identity, Analytics Event |
| Read 1 Complete | New users completing their first valid Today’s Lens | Users who completed onboarding in the cohort | Within 24 hours of onboarding completion | `TBD before RC` | Daily during rollout; weekly afterward | `QUERY:read_1_completion_v1` | ADR-001 | Today’s Lens, Analytics Event |
| Read 2 Complete | Users completing a second Today’s Lens on a distinct eligible date | Users who completed Read 1 | Within 72 hours of Read 1 | `TBD before RC` | Weekly | `QUERY:read_2_within_72h_v1` | ADR-001 | Today’s Lens, Analytics Event |
| Read 5 Complete | Users completing five Today’s Lens entries on distinct eligible dates | Users who completed Read 1 | Within 7 calendar days of Read 1 | `TBD before RC` | Weekly | `QUERY:read_5_within_7d_v1` | ADR-001 | Today’s Lens, Analytics Event |
| Day-30 Retention | Users with a qualifying reflective action around day 30 | Users who completed onboarding 30 days earlier | Activity on day 30, using an approved tolerance window of days 28–32 | `TBD before staged launch expansion` | Monthly cohort review | `QUERY:day_30_retention_v1` | ADR-001 | Account, Today’s Lens, Pattern, Archive Entry, Observation, Analytics Event |

### Metric implementation checks

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Every funnel metric has one approved event definition | Product/Data | Metric specification and event mapping | — | ADR-001, ADR-012 | Analytics Event |
| [ ] Every funnel metric has a resolved numeric threshold before its stated gate | Founder/Product | Signed threshold decision | — | ADR-001 | Analytics Event |
| [ ] Distinct eligible Today’s Lens dates are defined consistently | Product/Data | Query tests covering timezone and duplicate completion | — | ADR-001 | Today’s Lens, Analytics Event |
| [ ] Day-30 qualifying reflective actions are explicitly enumerated | Product/Data | Approved metric specification | — | ADR-001 | Today’s Lens, Pattern, Archive Entry, Observation |
| [ ] Funnel queries are validated against fixture users | Data/QA | Expected-versus-actual query test | — | ADR-012 | Analytics Event |
| [ ] Account linking does not double-count funnel users | Data/Engineering | Before/after linking identity test | — | ADR-013 | Account, Analytics Event |
| [ ] Launch dashboard includes funnel and guardrails | Data/Product | Dashboard link and review | — | ADR-001 | Analytics Event |

### Required guardrails

| Guardrail | Definition | Threshold | Review cadence | Evidence query placeholder |
|---|---|---|---|---|
| Today’s Lens unavailable rate | Eligible read requests resulting in unavailable/error state | `TBD before RC` | Daily | `QUERY:daily_read_unavailable_rate_v1` |
| Crash-free users | Users without a crash in the measurement window | `TBD before RC` | Daily | `QUERY:crash_free_users_v1` |
| Migration failure rate | Migration attempts not reaching verified completion | `TBD before migration rollout` | Daily during migration | `QUERY:migration_failure_rate_v1` |
| Account deletion completion | Valid deletion requests completed within policy window | `TBD before RC` | Weekly | `QUERY:account_deletion_completion_v1` |
| Notification opt-out after prompt | Users disabling notifications after Zodian prompt/permission flow | `TBD before rollout expansion` | Weekly | `QUERY:notification_opt_out_v1` |
| Observation dismissal/correction rate | Shown Observations dismissed or marked inaccurate | `TBD before expanding AI observations` | Weekly | `QUERY:observation_feedback_rate_v1` |

---

## Launch Operations

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] Release candidate build is immutable and identified | Engineering/QA | Build number, commit, configuration, and artifact checksum | — | ADR-012 | All |
| [ ] Staged rollout plan is approved | Founder/Product/Operations | Cohort percentages, timing, owners, and expansion gates | — | ADR-001, ADR-003 | All |
| [ ] Go/no-go meeting is scheduled with accountable owners | Founder/Operations | Calendar record and decision template | — | ADR-012 | All |
| [ ] Rollback and feature-disable paths are tested | Engineering/Operations | Exercise showing reflective core preserved and optional systems disabled | — | ADR-003, ADR-012 | Public Connect Profile, Entitlement, Observation |
| [ ] Launch-day monitoring coverage is assigned | Operations | Named coverage schedule and escalation contacts | — | ADR-012 | Operational |
| [ ] User-support launch responses are prepared | Support/Product | Response library for account, privacy, migration, Today’s Lens, and premium issues | — | ADR-001, ADR-013, ADR-014 | Account, Today’s Lens, Entitlement |
| [ ] Known issues are documented with severity and workaround | QA/Product | Approved known-issues register | — | ADR-012 | All |
| [ ] Launch communications describe reflective scope accurately | Product/Marketing | Final announcement and website copy | — | ADR-001, ADR-003 | Product |
| [ ] Connect status is communicated accurately | Product/Marketing | Launch copy showing unavailable, editorial, or closed-beta state | — | ADR-003 | Public Connect Profile |
| [ ] First 72-hour review cadence is scheduled | Founder/Product/Data | Review calendar and dashboard links | — | ADR-001 | Analytics Event |
| [ ] Rollout expansion requires funnel and guardrail review | Founder/Product | Signed expansion criteria | — | ADR-001 | Analytics Event |
| [ ] Post-launch feature freeze remains active for 60 days unless a launch-critical ADR is approved | Founder/CTO | Backlog policy and exception process | — | ADR-001, ADR-012 | All |

---

## Final public-launch sign-off

| Check | Owner | Required evidence | Completion date | Related ADR | Related domain |
|---|---|---|---|---|---|
| [ ] All reflective-launch required items are complete | Founder/CTO | Completed checklist export | — | ADR-001 | All reflective domains |
| [ ] All remaining warnings have owner, severity, and deadline | Founder/Operations | Accepted risk register | — | ADR-012 | All |
| [ ] Proposed ADRs are either resolved or confirmed non-blocking for chosen scope | Founder/CTO | ADR review record | — | ADR-014, ADR-015, ADR-016 | Entitlement, Memory Event, Public Connect Profile |
| [ ] Governance consistency audit passes | Founder/CTO | Audit report for all five documents | — | ADR-011, ADR-012 | All |
| [ ] Final launch decision is recorded | Founder/CTO | Dated go/no-go decision and approvers | — | ADR-012 | All |
