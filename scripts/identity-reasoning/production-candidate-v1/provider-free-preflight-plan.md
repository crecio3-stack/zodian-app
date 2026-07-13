# Production Candidate v1 — Provider-Free Unseen Cohort Preflight Plan

This is a plan only. It authorizes no provider calls, generation, production
writes, shadow writes, schedules, allowlists, deployments, or consumer changes.

## Proposed validation cohort

Create a new, separately versioned **24-case** matrix after review:

- 12 identities, with two unseen situation/identity pairs each;
- 20–30 total cases as approved; 24 gives broad identity coverage without
  restarting a corpus experiment;
- neutral external situations only; no scenario may prescribe behavior,
  interpretation, advice, tension, or a Move;
- coverage across work, relationships, home, money, rest, confidence, routine,
  conflict, friendship, and opportunity; and
- deliberate inclusion of some no-action and narrowed/PARTIAL inputs when the
  evidence supports only a narrow observation.

The matrix must exclude cases used to tune or assess the v4 writer. It must be
frozen with stable case IDs and a canonical-payload SHA-256 before any provider
call. No case may be substituted after the first call.

## Provider-free preflight checks

### Immutable inputs

1. Recompute every frozen-input SHA listed in
   `production-candidate-v1.json`; abort on any mismatch.
2. Verify the proposed cohort has exactly 24 unique deterministic case IDs.
3. Verify every identity/situation record is source-traceable and every
   situation is neutral under the scenario-leakage audit.
4. Verify frozen historical artifacts are read-only inputs and no candidate
   output path can overwrite them.

### Stage isolation

5. Assert the selector payload contains only situation data and canonical
   path/claim evidence. It must exclude old scenario contexts, raw reasoning
   plans, Gold-copy target copy, prior generated Lens text, actions, and titles.
6. Assert a `BLOCKED` selector fixture never reaches input calibration or the
   writer boundary.
7. Assert the v4 writer fixture receives only calibrated plain insight, nullable
   action, clarity status, and approved examples—not raw evidence or excluded
   claims.
8. Assert person-first and human-language gates never modify a string; they may
   pass, narrow, block, or flag only.

### Validation behavior

9. Run deterministic fixtures for SELECTED, BLOCKED, invalid citation, invalid
   applicability, missing actor, unsupported phrase, missing action, invalid
   writer JSON, and repetition hold.
10. Confirm each fixture records an explicit terminal state and preserves valid
    sibling stage artifacts; no fallback copy is emitted.
11. Confirm final accepted fixture output is exactly `{ title, read }` and
    passes the v4 structural contract, actor-preservation check, and excluded
    claim check.

### Repetition and runtime boundaries

12. Exercise exact duplicate, near-duplicate, title-collapse, template-collapse,
    identical-insight/action, and recent-user-history fixtures. Confirm only
    exact duplication can hard-block automatically; broader patterns create
    evidence-rich human review holds.
13. Assert all provider-call counters are zero in preflight.
14. Assert production and shadow write-path lists are empty; assert no schedule,
    allowlist, deployment, or consumer paths are imported or invoked.
15. Write a versioned preflight artifact with source/matrix/configuration hashes,
    fixture outcomes, and output paths. Re-read it and verify its recorded
    canonical-payload hash before presenting it for approval.

## Paid-run authorization gate

The provider-backed 24-case run may begin only after a human approves:

- the frozen unseen matrix and its SHA-256;
- the explicit model/provider configuration;
- the generated preflight artifact;
- the exact artifact namespace and resume behavior; and
- the promise that no production, shadow, scheduling, allowlist, or deployment
  path is in scope.

During the paid run, retain every case in the denominator. `BLOCKED`, held, and
rejected are valid visible outcomes. Do not tune prompts, rewrite inputs, or
replace weak outputs mid-run. The post-run review evaluates two dimensions
separately: evidence/compliance and human quality (naturalness, felt-seen
specificity, usefulness, and return-tomorrow value).
