# Canonical Identity → Today’s Lens matched comparison

Development-only artifact. Ten matched scenarios produce twenty Lens-shaped
outputs using the same daily context for both reviewed identities. No production
validator, Supabase function, app code, or stored row is touched.

Accepted first attempt: 20/20 Accepted after retry: 0 Rejected: 0 Retries: 0

## Matched differentiation audit

| Scenario               | Arena       | Libra role                                       | Taurus role                                                            | Distinct resolution | Quote overlap | Validation |
| ---------------------- | ----------- | ------------------------------------------------ | ---------------------------------------------------------------------- | ------------------: | ------------: | ---------- |
| work-speaking-up       | work        | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| love-trust             | love        | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| home-change            | home        | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| friends-harmony        | friends     | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| money-comfort          | money       | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| rest-responsibility    | rest        | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| confidence-recognition | confidence  | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| routine-freedom        | routine     | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| conflict-directness    | conflict    | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |
| opportunity-expansion  | opportunity | the person who notices what the room has skipped | the person who tests whether the arrangement still leaves room to move |                 yes |             0 | pass       |

## Self-critique

- The matched cases differentiate reliably because the adapter selects different
  perception, decision, pressure, and growth fields before writing. Libra ×
  Snake tends toward missing context, earned judgment, and naming the unanswered
  part; Taurus × Horse tends toward accumulated constraint, chosen stability,
  and making a smaller adjustment before escape becomes necessary.
- The outputs remain daily reads by constraining each result to one scenario,
  one arena, one visible behavior, and one natural move. They do not expose the
  canonical model or restate a whole identity profile.
- This is a controlled architecture experiment, not evidence that deterministic
  copy is ready for production. The next test should replace the hand-authored
  development copy with a writing-stage model call while retaining the same
  selected-context boundary and existing production validation contract.
- Direct reuse of `validateStructuredDailyRead` was not safe in this isolated
  script because the production function is not exported and imports live Edge
  Function/Supabase runtime concerns. The adapter validator mirrors its existing
  field shape and published word/sentence constraints without weakening them;
  production integration should call the shared validator through an explicit
  export rather than maintaining two implementations.
