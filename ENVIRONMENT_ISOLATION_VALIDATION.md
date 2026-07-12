# Sprint 2.5 Environment Isolation Validation

**Validation date:** 2026-06-25  
**Scope:** Supabase environment routing, client configuration safety, existing-beta preservation, Development provisioning validation, and prerequisites for future migration work  
**Governance:** `ARCHITECTURE_DECISIONS.md` v1.1, `PRODUCT_PRINCIPLES.md` v1.1, `DOMAIN_CONTRACTS.md` v1.1, `TECHNICAL_ARCHITECTURE.md` v1.1, `PUBLIC_LAUNCH_CHECKLIST.md` v1.1, and `SPRINT_2_PRODUCTION_READINESS_VALIDATION.md`

## Architecture compliance

Sprint 2.5 implements environment separation and operational safety already required by Accepted ADR-011 and ADR-012. It preserves ADR-013 Account ownership behavior without adding migration behavior.

No migration, migration record, commerce, Connect activation, Memory backup, messaging, StoreKit, premium, or new UI was introduced. No beta or production user data was copied. Sprint 2.6 added only Development project provisioning and a minimal synthetic Development Today’s Lens content contract required to validate first-run onboarding without the shared beta backend.

## Environment plan

| Build configuration | Intended Supabase project | Current state | Default behavior |
|---|---|---|---|
| Debug | Development | Project `wlsewblvpyeanfganbkc` configured through ignored local override | Uses isolated Development Supabase for local validation |
| Beta | Staging/Beta | Existing shared beta project `xyyahrqfmdblvonnaifi` | Preserved intentionally for existing beta users |
| Release | Production | Project not yet created/configured | Fails closed; no Supabase client is created |

The Supabase CLI account currently exposes two projects in the `Zodian-App` organization:

- Development: `Zodian Development`, reference `wlsewblvpyeanfganbkc`, region `us-west-2`, status `ACTIVE_HEALTHY`.
- Staging/Beta: `crecio3-stack's Project`, reference `xyyahrqfmdblvonnaifi`, region `us-west-2`, status `ACTIVE_HEALTHY`.

The existing beta project remains the Staging/Beta project until a deliberate replacement is provisioned and validated.

Development must contain synthetic/test accounts only. Do not restore, clone, seed, or branch beta/production user data into Development.

## Implementation

- Added configuration-specific xcconfig files for Development, Beta, and Production.
- Added ignored local overrides and committed examples for public client values.
- Added `SUPABASE_PROJECT_REF` to the app configuration envelope.
- Validated that the configured HTTPS hostname matches the project reference.
- Allowed only Supabase publishable keys or legacy JWTs whose role is `anon`.
- Rejected `sb_secret_` and legacy `service_role` keys in the client.
- Changed Account bootstrap to create a Supabase client only from a fully validated configuration.
- Added a DEBUG-only isolation validation harness.
- Created the isolated Development Supabase project `wlsewblvpyeanfganbkc`.
- Stored the generated Development database password in the local macOS Keychain, not in the repository.
- Configured `Configurations/Development.local.xcconfig` with Development public client values; the file is gitignored and untracked.
- Enabled anonymous sign-ins in Development.
- Deployed the existing `get-daily-ritual` Edge Function to Development.
- Added a minimal synthetic Development `daily_rituals` table and Aries × Horse rows for 2026-06-25 and 2026-06-26 to validate first-run Today’s Lens rendering without beta data.

## Validation matrix

| Validation | Result | Evidence |
|---|---|---|
| Scope fits Accepted ADRs only | Pass | Configuration and operational isolation only; no Proposed ADR behavior or new product capability added |
| Debug resolves Development | Pass | Build settings and built `Info.plist` resolve `development` |
| Debug resolves isolated Development project | Pass | Build settings resolve `SUPABASE_PROJECT_REF = wlsewblvpyeanfganbkc` and `SUPABASE_URL = https://wlsewblvpyeanfganbkc.supabase.co` through the ignored local override |
| Beta resolves Staging/Beta | Pass | Build settings and built `Info.plist` resolve `beta` and project `xyyahrqfmdblvonnaifi` |
| Release resolves Production | Pass | Build settings and built `Info.plist` resolve `production` |
| Development has no production/beta token by default | Pass | Debug artifact contains `MISSING`, which normalizes to no configuration |
| Release has no placeholder backend fallback | Pass | Release artifact contains `MISSING`, which normalizes to no configuration |
| Missing configuration fails safely | Pass | DEBUG runtime harness reached `AccountOwnershipState.failed(.configuration)` and retained no analytics Account ID |
| Project reference and URL cannot disagree | Pass | DEBUG harness rejected a mismatched `<project-ref>.supabase.co` hostname |
| Secret/service-role key cannot initialize app client | Pass | Static guard rejects `sb_secret_`; DEBUG harness rejected a legacy `service_role` JWT |
| Publishable and legacy anon keys remain supported | Pass | DEBUG harness accepted both permitted public client formats |
| DEBUG isolation harness | Pass | 6/6 checks passed on an isolated iPhone Simulator app container |
| Debug build | Pass | iOS Simulator build succeeded |
| Beta build | Pass | iOS Simulator build succeeded and generated a dSYM |
| Release build | Pass | iOS Simulator build succeeded |
| Anonymous bootstrap in Development | Pass | Clean-install Debug simulator validation acknowledged an anonymous Account against Development before account-backed onboarding persistence |
| Onboarding persistence waits for server acknowledgment | Pass | Runtime log showed `AccountPersistenceGate` waited for server Account acknowledgment before SwiftData persistence completed |
| Pattern renders after Development bootstrap | Pass | Runtime clean-install validation resolved identity content and Pattern content |
| Today’s Lens renders from Development | Pass | Development `get-daily-ritual` endpoint returned a structured Supabase row; runtime validation logged `Today’s Lens source: structured Supabase row` and passed |
| Existing beta users remain intact | Pass by configuration/non-interference | Beta endpoint and public anon key are unchanged; no beta backend write, schema operation, user-data copy, app uninstall, or migration run was performed |
| Development/Beta/Production backend isolation | Partial | Development and Beta are separate live projects; Release still fails closed until Production is provisioned |
| Service-role keys absent from client configuration | Pass | Repository scan found environment-variable references in server functions and negative test fixtures only; no service-role value is committed |

The fresh simulator emitted an initial Core Data parent-directory warning and recovered automatically. It did not affect the 6/6 environment harness result and is unrelated to Supabase routing.

## Manual Supabase setup

Production project creation still requires an authorized human choice of organization, billing plan, database password, and region. Do not guess these values.

### 1. Create Development

Completed for Sprint 2.6:

1. Created `Zodian Development` in the `Zodian-App` Supabase organization.
2. Reference: `wlsewblvpyeanfganbkc`.
3. Region: `us-west-2`.
4. Stored the generated database password in the local macOS Keychain entry `zodian-development-supabase-db-password`.
5. Did not restore or copy beta/production user data.
6. Enabled anonymous sign-ins.
7. Used only the Development publishable client key in `Configurations/Development.local.xcconfig`.
8. Kept `Configurations/Development.local.xcconfig` ignored and untracked.
9. Deployed only the existing `get-daily-ritual` function to Development.
10. Added synthetic Development Today’s Lens content only; no beta data was copied.

### 2. Keep or replace Staging/Beta deliberately

The committed Beta configuration remains pointed at `xyyahrqfmdblvonnaifi`. This avoids breaking installed beta users.

If a replacement Staging/Beta project is later required:

1. Create it as a separate project.
2. Do not switch the committed Beta configuration immediately.
3. Copy `Configurations/Beta.local.xcconfig.example` to the ignored `Configurations/Beta.local.xcconfig`.
4. Validate anonymous bootstrap, account continuity policy, required server contracts, and provider configuration.
5. Change the committed Beta endpoint only through a reviewed release plan.

### 3. Create Production

1. Create a separate project named clearly as Production, for example `Zodian Production`.
2. Use the approved production organization, plan, region, database password, access roles, and recovery controls.
3. Enable anonymous sign-ins only when production account bootstrap is ready for controlled validation.
4. Copy the project reference, Project URL, and publishable key only.
5. Create the ignored local override:

   ```sh
   cp Configurations/Production.local.xcconfig.example \
      Configurations/Production.local.xcconfig
   ```

6. Replace the placeholders with Production public client values.
7. Keep the project data-empty until the approved backend deployment and validation plan exists.
8. Validate Release in a controlled environment before distributing it.

Supabase references:

- Project setup: <https://supabase.com/docs/guides/getting-started/quickstarts/nextjs>
- Anonymous sign-ins: <https://supabase.com/docs/guides/auth/auth-anonymous>
- API key types and client-safe keys: <https://supabase.com/docs/guides/getting-started/api-keys>
- Service-role/secret handling: <https://supabase.com/docs/guides/functions/secrets>
- Data-less branching guidance: <https://supabase.com/docs/guides/deployment/branching>

## Launch checklist disposition

Advanced with partial evidence:

- Development, staging/beta, and production are isolated: Development and Beta are separate live Supabase projects, Debug and Beta resolve correctly, Release still fails closed until Production is provisioned.
- Production secrets are isolated and rotated: client-side secret rejection and ignored local overrides are complete; production provisioning and rotation evidence are not.

No checklist item was marked complete because a separate Production Supabase project, access review, backup/restore evidence, and secret rotation evidence do not yet exist.

## Remaining blockers before migration may begin

1. Confirm the approved Development backend contracts needed by migration planning without copying beta user data.
2. Approve the migration inventory, exclusions, consent boundaries, idempotency plan, and rollback/support procedure under ADR-011 and ADR-013.
3. Define the Development schema-management path for future work without relying on ad hoc SQL.
4. Decide whether Development Auth defaults changed by `supabase config push` should be hardened before broader team use.

Production project creation is required before Release Candidate, but not before isolated migration development if all migration work is confined to the verified Development project.

## Recommendation

**Migration planning may begin; migration implementation should wait for the approved migration plan and Development schema-management path.**

The app-side isolation foundation is ready, Development first-run bootstrap is proven, and Beta users remain protected. Migration planning and local fixture design may proceed against Development. Do not start migration implementation, write migration records, upload beta data, or run beta-user migration flows until the migration plan is approved and Development schema management is explicit.
