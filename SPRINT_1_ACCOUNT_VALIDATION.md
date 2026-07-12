# Zodian Sprint 1 Account Validation

**Date:** 2026-06-25  
**Scope:** ADR-013 canonical Account hardening only  
**Governing documents:** `ARCHITECTURE_DECISIONS.md` → `PRODUCT_PRINCIPLES.md` → `DOMAIN_CONTRACTS.md` → `TECHNICAL_ARCHITECTURE.md` → `PUBLIC_LAUNCH_CHECKLIST.md`

## Compliance audit

Sprint 1 remains within accepted ADR-008, ADR-011, ADR-012, and ADR-013.

- Supabase Auth remains the only server-canonical Account authority.
- The Supabase user UUID remains the immutable Account ID.
- Installation ID, Device Registration ID, Session ID, and Migration ID remain non-owner identifiers.
- Private Identity persistence uses one shared gate that requires Account acknowledgment first.
- Apple links to the active Account and verifies that the Account ID did not change.
- A stored but invalid session never falls back to creating a competing anonymous Account.
- Apple-link retry checks existing provider state before issuing another link.
- No credential-unlink operation is exposed.
- Existing local beta records are neither uploaded, deleted, nor re-keyed.
- No raw Memory Event or Observation is transmitted.

No behavior governed by Proposed ADR-014, ADR-015, or ADR-016 was introduced. Commerce, Memory backup, real-profile Connect, and migration remain unimplemented.

## Validation matrix

| Requirement | Coverage | Evidence | Result |
|---|---|---|---|
| Anonymous bootstrap success | DEBUG deterministic auth harness; live clean-install launch | Supabase acknowledged Account `6508b940…0553` before onboarding persistence | Pass |
| Bootstrap failure and retry | DEBUG deterministic auth harness | First request fails, state becomes retryable, second request succeeds, exactly two bootstrap calls | Pass |
| Persistence blocked before acknowledgment | Shared production persistence gate exercised by DEBUG harness | Persistence closure remains uncalled when acknowledgment fails | Pass |
| Account ID stability | DEBUG deterministic auth harness | Account ID before and after Apple link is identical | Pass |
| Installation ID distinct from Account ID | DEBUG deterministic auth harness | Explicit inequality assertion against server Account ID | Pass |
| Device Registration ID distinct from Account ID | DEBUG deterministic auth harness | Explicit inequality assertion against server Account ID | Pass |
| Apple linking preserves Account ID | DEBUG deterministic auth harness | Existing anonymous Account transitions to Apple-linked state without owner change | Pass |
| Apple linking retry avoids duplicate Account/link | DEBUG deterministic auth harness | One anonymous bootstrap and one provider-link call after two link attempts | Pass |
| Apple provider unavailable or misconfigured | DEBUG deterministic auth harness; simulator Apple sheet | Failure is classified as retryable Apple-link failure and existing Account remains unchanged; simulator correctly requests Apple Account configuration | Pass locally; live backend failure evidence pending |
| Existing beta data remains untouched | Existing-install simulator inspection | Existing name, Today’s Lens, Pattern entry points, points, streak, and saved-read count remained present | Pass |
| Clean reinstall behavior | Separate simulator uninstall/install | App returned to onboarding; installation-scoped identifiers regenerated | Pass |
| Live onboarding persistence ordering | Clean-install runtime trace plus SwiftData inspection | `ZUSERPROFILE` remained `0` through reveal; gate logged acknowledgment before persistence; completion produced exactly `1` profile | Pass |
| Account ID stability across restart | Stop/relaunch runtime trace | Account `6508b940…0553` was unchanged after restart | Pass |
| Installation and Device Registration distinction | Clean-install and restart runtime traces | Installation `fb306d5c…4299` and Device Registration `e58ed8f2…45c4` were distinct from each other and the Account ID, and remained stable across restart | Pass |
| Real Apple credential completion | Native authorization flow only | Simulator has no signed-in Apple Account | Blocked by device/provider evidence |
| Session expiration/revocation/offline matrix | Not added in Sprint 1 hardening | Requires controlled auth/backend scenarios | Not started |

The DEBUG harness runs only when the process argument `-zodianRunAccountValidationHarness` is supplied. It does not change production behavior or create product UI.

### Live operational trace

Anonymous sign-in was enabled through the Supabase Management API on 2026-06-25. The setting was verified as `false` before the update and `true` afterward.

Clean-install validation against project `xyyahrqfmdblvonnaifi` produced this ordering:

1. Supabase acknowledged anonymous Account `6508b940…0553`.
2. Installation ID was `fb306d5c…4299`.
3. Device Registration ID was `e58ed8f2…45c4`.
4. All three identifiers were distinct.
5. `zodian.onboardingComplete` was `false` and `ZUSERPROFILE` contained zero rows before completion.
6. The reveal rendered without persisting Private Identity.
7. The runtime logged `Waiting for server Account acknowledgment`.
8. The runtime logged `Account acknowledged; persistence may begin`.
9. The runtime logged `Account-backed persistence completed`.
10. `zodian.onboardingComplete` became `true`.
11. `ZUSERPROFILE` contained exactly one `Live Test | aries | horse` row.
12. After app termination and relaunch, the Account, Installation, and Device Registration IDs were unchanged and the profile count remained one.

The DEBUG validation harness was rerun after the live validation and passed `7/7`.

## Launch checklist — Accounts

Checklist boxes in `PUBLIC_LAUNCH_CHECKLIST.md` remain unchanged unless their stated evidence standard is fully met.

| Checklist item | Status | Rationale |
|---|---|---|
| ADR-013 ownership model Accepted | Complete | Governing ADR v1.1 is accepted and dated |
| Anonymous bootstrap before onboarding persistence | Complete | Live clean-install trace proves server acknowledgment precedes the first `UserProfile` row |
| Canonical Account ID stable and provider-independent | Blocked by device/backend evidence | Deterministic Apple-link proof passes; real Apple credential evidence remains |
| Installation ID and Account ID remain distinct across reinstall and recovery | Partially satisfied | Distinctness and reinstall pass; recovery scenario is not implemented |
| Account creation/linking production-ready | Blocked by device/backend evidence | Restart, real link, second-device, collision, and revoked-session evidence remain |
| Apple links without duplicate ownership | Blocked by device/backend evidence | Deterministic retry proof passes; live transactional/collision evidence remains |
| Sole recoverability credential cannot be unlinked | Partially satisfied | No unlink API or UI exists; explicit policy test remains |
| Anonymous account-loss limitation disclosed | Partially satisfied | Launch UI copy and simulator evidence exist; Product/Privacy approval remains |
| Session recovery and expiration verified | Not started | Valid, expired, revoked, and offline matrix remains |
| Sign-out local-data behavior verified | Not started | Sign-out policy and implementation are outside Sprint 1 |
| In-app account deletion | Not started | Deletion is outside Sprint 1 |
| Account deletion propagation | Not started | Deletion is outside Sprint 1 |
| Device-local Memory behavior during deletion | Not started | Requires deletion policy and implementation |
| Account recovery and support process | Not started | Runbook and tested support scenario remain |

## Remaining evidence gates

Before the Account capability can be considered launch-ready:

1. Configure and verify Apple provider credentials in the intended Supabase environment.
2. Complete real-device Apple linking and prove the Account ID is unchanged.
3. Repeat Apple linking after an interrupted response and test credential collision.
4. Verify valid, expired, revoked, and offline session behavior.
5. Verify restart and second-device recovery after Apple linking.
6. Define sign-out behavior for local Private Identity and local-first Pattern Memory.
7. Implement and validate account deletion in its separately authorized scope.

## Sprint 2 gate recommendation

Sprint 2 may begin. The live anonymous bootstrap blocker is resolved, the production persistence gate is proven, restart stability is verified, and the deterministic harness remains green. Sprint 2 must stay limited to production-readiness capabilities that consume the accepted Account boundary without changing it. Apple-linking checklist items remain incomplete until tested on a signed-in device. Migration, commerce, Memory backup, public Connect, and messaging remain blocked by scope and their governing ADRs.
