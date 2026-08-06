# Zodian operating playbook

Every procedure uses the same safety rule: implementation authorization does not authorize deployment or production action. Authorization expires with the task.

## 1. Documentation-only change

**Purpose:** revise repository guidance without runtime mutation. **Authorization:** documentation scope only. **Prerequisites/evidence:** inspect status, existing docs, referenced paths, and current diff. **Steps:** (1) identify exact files; (2) verify claims with source/tests; (3) edit docs only; (4) check links and examples; (5) run `git diff --check`. **Allowed:** documentation edits and read-only inspection. **Prohibited:** code, provider, database, batch, publication, scheduler, deploy, commit, push. **Stop:** evidence conflicts or path is missing. **Verify/report:** files, evidence, checks, all zero operational counts, unresolved claims.

## 2. Provider-free local test

**Purpose:** validate local behavior without external calls. **Authorization:** local test. **Prerequisites:** identify an existing test and confirm it is fixture/provider-free. **Steps:** (1) inspect test source; (2) run the verified repository command, or `[VERIFY CURRENT REPOSITORY COMMAND BEFORE USE]`; (3) capture exact result. **Allowed:** local process and temporary test output. **Prohibited:** provider, persistence, deploy, publish. **Stop:** test requires credentials/network or writes shared state. **Verify/report:** command, pass/fail, provider calls `0`, writes `0`.

## 3. Provider-backed non-persisting canary

**Purpose:** sample an authorized writer without publication. **Authorization:** explicit provider-call authorization naming model, input, size, endpoint, and non-persistence guarantee. **Prerequisites:** frozen input, stop criteria, secret-safe logging, and output destination. **Steps:** (1) confirm target is non-persisting; (2) run the existing canary or `[VERIFY CURRENT REPOSITORY COMMAND BEFORE USE]`; (3) stop at the approved sample; (4) validate and preserve diagnostics. **Allowed:** only the stated calls. **Prohibited:** batch/row writes, publication, retry outside scope, routing changes. **Stop:** auth error, unexpected persistence, output drift, or count mismatch. **Verify/report:** calls/model/count/results, all writes and publications.

## 4. Implement and commit

**Purpose:** make an authorized local change. **Authorization:** implementation; commit only if explicitly included. **Prerequisites:** cleanly scoped diff and tests. **Steps:** (1) inspect status; (2) edit narrow files; (3) run relevant tests; (4) run `git diff --check`; (5) if authorized, stage only intended files and commit. **Allowed:** local source/docs/tests. **Prohibited:** deploy or production action. **Stop:** unrelated diff or unclear behavior. **Verify/report:** files, exact tests, commit hash or “not committed.”

## 5. Pull-request review

**Purpose:** assess a proposed diff. **Authorization:** review only. **Prerequisites:** obtain diff, base, tests, and environment claims. **Steps:** (1) inspect changed files; (2) trace behavior and authorization boundaries; (3) check tests/docs; (4) report findings and unresolved questions. **Allowed:** read-only review and local provider-free checks. **Prohibited:** modifying PR, deploying, publishing, or changing state unless separately authorized. **Stop:** missing context prevents evidence-backed review. **Verify/report:** findings by severity and exact checks.

## 6. Deployment verification

**Purpose:** verify an already authorized deployment. **Authorization:** deployment verification only, naming target/version. **Prerequisites:** clean source, expected function/config, rollback target. **Steps:** (1) inspect deployment metadata through an existing verified tool; (2) compare version/config; (3) perform only approved read-only smoke checks; (4) record result. **Allowed:** read-only verification. **Prohibited:** deploying, migrating, publishing, or changing scheduler state. **Stop:** dirty source, target mismatch, or unavailable verified command. **Verify/report:** target, observed version, checks, unresolved live state. Use `[VERIFY CURRENT REPOSITORY COMMAND BEFORE USE]` where needed.

## 7. Production batch health inspection

**Purpose:** inspect production without mutation. **Authorization:** explicit read-only production authorization. **Prerequisites:** environment/date/batch target and safe authenticated access. **Steps:** (1) capture pre-state; (2) inspect batch status/counts/errors/versions; (3) inspect rows only as needed; (4) inspect publication and scheduler metadata; (5) preserve evidence. **Allowed:** reads. **Prohibited:** retry, repair, rollback, replacement, publish, or scheduler changes. **Stop:** target ambiguity or secret exposure risk. **Verify/report:** exact target/state, evidence, and zero writes/provider calls/publications.

## 8. Inspect production or a failed batch

Use procedure 7. For a failed batch also record failure reason, missing/duplicate pairs, attempts, validation errors, and whether a supported recovery action exists. Preserve evidence before any retry or repair.

## 9. Review prompt or validator

Identify the version, read implementation/tests/fixtures together, compare accepted/rejected boundaries, and follow `docs/validator.md`’s Prompt-validator alignment procedure. No provider or production mutation.

## 10. Run scheduler, recover, publish, or roll back

These are production-affecting procedures and require a fresh authorization checkpoint naming the exact action. Use only existing manager actions/RPCs and verified deployment procedures. The source confirms scheduler windows and lifecycle guards, but no safe generic deployment command is documented here. If the exact command, target, rollback, or live state cannot be verified, stop and write `[VERIFY CURRENT REPOSITORY COMMAND BEFORE USE]` rather than guessing.
