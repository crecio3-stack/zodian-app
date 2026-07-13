# Production Candidate v1 — Development Shadow Three-Case Run

**Result:** PASS

Target: Zodian Development (`wlsewblvpyeanfganbkc`) only. Candidate version: `pcv1-frozen-approved-input-v1`.

| Case | Result | Provider calls | Verification |
|---|---|---:|---|
| Virgo × Dragon · work | ACCEPTED | 1 | Frozen approval bypassed selector; idempotency confirmed; endpoint returned only version, status, title, and read. |
| Virgo × Dragon · home | ACCEPTED | 1 | Frozen approval bypassed selector; approved action was preserved; endpoint returned only version, status, title, and read. |
| Cancer × Pig · routine | BLOCKED | 0 | No writer call and no copy; endpoint returned only version, status, and safe reason. |

## Endpoint and isolation checks

- Explicit version allowlist accepts only `pcv1` and `pcv1-frozen-approved-input-v1`.
- Unsupported version: rejected.
- Missing internal secret: rejected.
- Raw traces, evidence, provider payloads, tokens, and fingerprints: not returned.
- `daily_rituals`: unchanged at zero Development rows.
- Canonical shadow storage: unchanged at zero Development rows.
- Candidate rows for this version/date: exactly three.
- Production, iOS, scheduling, allowlists, and current Today’s Lens behavior: unchanged.

## Stop point

The first Development shadow slice is complete. No further producer cases were run.
