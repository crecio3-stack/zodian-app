# Sprint 2 Production Readiness Validation

**Validation date:** 2026-06-25  
**Scope:** Analytics, crash reporting, environment configuration, feature flags, backend-service boundaries, and launch operations  
**Governance:** `ARCHITECTURE_DECISIONS.md` v1.1, `PRODUCT_PRINCIPLES.md` v1.1, `DOMAIN_CONTRACTS.md` v1.1, `TECHNICAL_ARCHITECTURE.md` v1.1, and `PUBLIC_LAUNCH_CHECKLIST.md` v1.1

## Architecture compliance

Sprint 2 remains within Accepted ADRs:

- ADR-001: reflective launch operations and activation measurement
- ADR-002, ADR-008: privacy boundaries for analytics, logs, and crash reports
- ADR-003: remote-capable, fail-closed social feature flags
- ADR-007, ADR-009: versioned provenance and non-content operational telemetry
- ADR-012: production operations, monitoring, environment separation, and change control
- ADR-013: Account ID is the canonical analytics identity after server acknowledgment

No migration, commerce, StoreKit, paid entitlement, Pattern Memory backup, public Connect activation, Connection, or Message implementation was introduced. Flags for blocked capabilities are declarations only, default to `false`, and are not authorization or ownership mechanisms.

## Validation matrix

| Area | Result | Evidence |
|---|---|---|
| Governing-document consistency | Pass | Sprint 2 implements operational systems already named in Technical Architecture sections 11–15. |
| Proposed ADR behavior | Pass | No persistent migration, Memory synchronization, public-profile publication, messaging, or commerce path was added. |
| PostHog configuration scope | Partial | `POSTHOG_PROJECT_TOKEN` is a per-build-configuration setting and resolves empty in Development, Beta, and Production. Live ingestion cannot be verified without a provider token. |
| Autocapture and replay | Pass | Lifecycle autocapture, screen capture, element capture, swizzling, and session replay are disabled in `AnalyticsService`. |
| Analytics envelope | Pass | DEBUG harness verified event ID, schema version, taxonomy version, environment, and account authority. |
| Analytics identity | Pass | Clean-install trace emitted anonymous-authority telemetry before bootstrap, then promoted to Account authority only after server acknowledgment. No Installation ID enters the analytics provider. |
| Analytics privacy filter | Pass | Harness injected prohibited birth, Memory, Thread, Today’s Lens body, and profile properties; all were removed. Diagnostic analytics output contains event metadata only. |
| Analytics outage behavior | Pass | PostHog was pointed to `127.0.0.1:1`; remote config and ingestion failed, events queued, flags remained off, and Home/Today’s Lens remained usable. |
| Analytics queue | Pass | Explicit `flushAt = 20` and `maxQueueSize = 1000`; SDK uses a file-backed queue and the outage test showed queued events without blocking product flow. |
| Event ingestion idempotency | Blocked | Stable event IDs are present, but duplicate-ingestion behavior has not been verified against a real PostHog project. |
| Sentry configuration scope | Partial | `SENTRY_DSN` is environment-scoped and empty in all committed configurations. SDK transport is therefore intentionally disabled. |
| Sentry privacy configuration | Pass by configuration | Default PII, screenshots, view hierarchy, failed-request capture, network breadcrumbs, and automatic performance tracing are disabled. Captured operational errors contain classification codes, not underlying error messages. |
| Test crash and symbolication | Blocked | No Sentry DSN, organization, project, or auth token is available. A crash cannot reach Sentry, so symbolication cannot be proven. |
| dSYM generation | Pass | Release uses `dwarf-with-dsym`; the validated simulator Release produced `Zodian.app.dSYM` with arm64 UUID `4EA311A9-7BCD-3193-8771-A65224EB7476`. |
| Development/Beta/Production resolution | Pass | Built Info plists resolved `development`, `beta`, and `production` respectively. DEBUG-only overrides were absent from the Release binary. |
| Environment isolation | Partial | Sprint 2.5 moved Supabase settings into configuration-specific xcconfig files. Debug and Release now fail closed with no committed backend; Beta alone preserves the existing shared beta project. Separate Development and Production projects are not yet provisioned. See `ENVIRONMENT_ISOLATION_VALIDATION.md`. |
| Feature-flag fallback | Pass | Sensitive, social, commerce, observation rollout, migration, and kill-switch flags default off. Provider failure test passed with remote configuration unavailable. |
| Operational logs | Partial | Sprint 2 analytics, account, content, and crash paths were redacted. Legacy raw `print(error)` calls remain outside the centralized operational layer and should be removed before claiming a complete app-wide log audit. |
| Clean-install anonymous bootstrap | Pass | Separate simulator app container started with zero profiles and received a canonical anonymous Account. |
| Onboarding persistence gate | Pass | Real `OnboardingFlowViewModel.completeOnboarding` persisted exactly one profile only after `AccountBackedPersistenceGate` received server acknowledgment. |
| Pattern regression | Pass | Pattern rendered for the clean-install test identity. |
| Today’s Lens regression | Pass | A structured Today’s Lens resolved and rendered after clean-install onboarding. |

## Runtime evidence

The DEBUG validation harness passed 7/7:

1. Development environment resolution
2. Crash-service initialization
3. Account analytics identity promotion
4. Versioned, account-scoped analytics envelope
5. Prohibited-property removal
6. Sensitive feature flags default off
7. Bounded retry behavior

The clean-install regression passed 4/4:

1. Anonymous bootstrap acknowledged
2. Onboarding persisted after acknowledgment
3. Pattern content resolved and rendered
4. Today’s Lens resolved and rendered

## dSYM upload path

Do not add an unauthenticated build phase. Once Sentry provisioning exists, CI should provide:

- `SENTRY_AUTH_TOKEN`
- `SENTRY_ORG`
- `SENTRY_PROJECT`

Then validate and upload the archive dSYMs:

```sh
xcrun dwarfdump --uuid "$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME"
sentry-cli debug-files upload \
  --org "$SENTRY_ORG" \
  --project "$SENTRY_PROJECT" \
  --include-sources \
  "$DWARF_DSYM_FOLDER_PATH"
```

The Release archive must retain `DEBUG_INFORMATION_FORMAT = dwarf-with-dsym`. Add the upload to CI or the archive workflow only after the Sentry project and scoped auth token exist.

## Launch checklist disposition

Completed with evidence:

- Analytics excludes prohibited private payloads
- Offline analytics queue is bounded and non-blocking
- Product analytics cannot mutate product state
- Analytics failure cannot degrade user flows

Partial:

- Event taxonomy/schema code is versioned, but Data/Product approval is not recorded.
- Crash privacy configuration is complete, but no real Sentry event has been sampled.
- Build configurations resolve independently, but backend environments are not isolated.
- Operational logging is hardened in Sprint 2 paths, but legacy raw errors remain elsewhere.

Blocked:

- Production PostHog ingestion and dashboard evidence
- Duplicate-event/idempotency verification
- Activation-funnel trace in PostHog
- Sentry test crash, upload receipt, and symbolication
- Fully isolated Development, Beta, and Production Supabase projects
- Analytics/crash alerting and operational dashboards

## Release Candidate blockers

1. Provision environment-specific PostHog projects/tokens and verify staging-to-production ingestion.
2. Provision Sentry DSN, organization, project, and scoped auth token; upload dSYMs and symbolicate a test crash.
3. Provision isolated Development and Production Supabase projects, validate anonymous bootstrap in Development, and retain the current project as Staging/Beta until a deliberate replacement is validated.
4. Remove or route remaining raw `print(error)` calls through the classified logger.
5. Validate event deduplication, funnel queries, alerting, dashboards, retention, and deletion behavior.

## Sprint 3 migration recommendation

**Do not begin migration implementation against the currently shared beta backend.**

ADR-013 permits migration architecture, but Sprint 3 should begin only after the separate Development Supabase project exists, anonymous bootstrap passes there, and the migration inventory, consent boundaries, and domain exclusions are approved. Local fixtures and planning may proceed; backend schema changes, uploads, or beta-user migration runs should not.
