# Production Candidate v1 integration design

## Goal

Safely introduce the validated PCv1 `{ title, read }` experience beside the existing six-field Today’s Lens path, with a reversible rollout and no silent fallback or data-shape mutation.

## Current compatibility finding

The deployed path is structurally six-field:

- `daily_rituals` stores `title`, `intro`, `pull_quote`, `deeper_read`, `watch_for`, and `move`.
- `get-daily-ritual` normalizes and returns those fields.
- `DailyRitualResponse` requires `title` and `intro` while decoding, and its display-readiness check derives content from the structured fields.
- Home and Daily views render intro, pull quote, deeper read, Watch, and Move independently; sharing and saved-read behavior also draw from those fields.

Therefore, PCv1 must **not** be silently projected into `daily_rituals` or treated as a valid six-field response. The initial integration needs a parallel, versioned candidate contract and consumer.

## Target runtime boundary

```text
existing production Today’s Lens
  -> daily_rituals / get-daily-ritual / DailyRitualResponse

PCv1 candidate (parallel)
  -> isolated candidate generation record
  -> versioned internal candidate endpoint
  -> DailyLensCandidateV1 { title, read, version, status }
  -> one-paragraph candidate view
```

The production control remains the only user-visible content until an explicit allowlisted rollout gate is approved.

## Proposed runtime state machine

| State | Candidate behavior | User-visible behavior during shadow/internal preparation | Required trace |
| --- | --- | --- | --- |
| `ACCEPTED` | Persist immutable candidate title/read and validation metadata | Control remains visible in shadow; allowlisted user may receive candidate only after a separate gate | Full selector/writer/validator/repetition provenance |
| `BLOCKED` | Persist terminal blocked state; do not call writer | Continue showing control; never show generic candidate copy | Selector evidence and block reason |
| `WRITER_REJECTED` | Persist terminal rejection; do not publish partial title/read | Continue showing control | Raw response, validation errors, input and prompt fingerprints |
| `VALIDATOR_REJECTED` | Persist terminal rejection; do not publish | Continue showing control | Failed rule names and stage evidence |
| `TRANSPORT_FAILED` | Record resumable transport failure according to an explicit idempotency key | Continue showing control | Provider status, retry state, timestamp |
| `REPETITION_HOLD` | Persist hold, with no automatic rewriting | Continue showing control pending review | Comparison evidence and disposition |

No state may substitute generic prose, convert a blocked result into copy, or partially overwrite a control row.

## Data and API design requirements

1. Add a future **isolated** candidate persistence model. It must reference the control read by ID/date/identity where applicable, but never mutate `daily_rituals` during shadow.
2. Store only accepted `{ title, read }` as candidate content. Store rejected/blocked state and trace separately; never create a partially populated read.
3. Use deterministic uniqueness/idempotency on candidate version + date + western sign + eastern sign + scenario/source context.
4. Expose a versioned internal response model rather than extending `get-daily-ritual` in place:

   ```json
   {
     "version": "pcv1",
     "status": "accepted",
     "title": "...",
     "read": "..."
   }
   ```

5. Keep generation trace, raw provider response, model/configuration fingerprint, latency, tokens, selector result, validation status, and repetition disposition server-side only. No API keys or raw canonical evidence leave the server.

## iOS integration requirements

Create a parallel candidate model and renderer; do not overload `DailyRitualResponse`.

| Surface | Current dependency | Candidate change needed later |
| --- | --- | --- |
| Decode | `DailyRitualResponse` requires `title` + `intro` and structured fields | `DailyLensCandidateV1` decodes only version/status/title/read |
| Home | Separate intro, pull quote, deeper-read disclosure, Watch, Move | A title plus one readable paragraph, with existing save/share affordances reviewed separately |
| Daily screen | Same six-field card and disclosure controls | One-paragraph card with no fabricated Watch/Move/disclosure sections |
| Sharing | `DailyReadShareContent` receives six fields | A title/read-specific share payload and rendering test |
| Cache | Existing cache treats six-field response as display-ready | Separate versioned cache namespace and readiness condition: accepted nonblank title/read |
| Saved reads / Pattern Memory | Existing records derive from six-field fields | Explicit product decision and migration plan before PCv1 becomes user-visible |

No adapter may invent missing six-field values from PCv1 copy merely to satisfy old UI expectations.

## Observability

Capture candidate-only metrics by version, date, identity, scenario/source context, and rollout cohort:

- selector block rate and reason category;
- selector-to-writer eligibility rate;
- writer acceptance and validation rejection rates, split by rule;
- repetition holds and confirmed duplicates;
- provider latency, tokens, retries, and estimated cost;
- accepted candidate/control comparison availability;
- for allowlisted user exposure only: open, save, share, completion, and return behavior, all tagged with content version.

Product engagement metrics must never be interpreted as evidence that an invalid or blocked candidate should have been published.

## Rollout sequence and gates

1. **Development replay:** provider-free contract tests plus isolated candidate generation against synthetic/dev inputs. No user exposure.
2. **Shadow comparison:** create isolated candidate records paired with current control reads. The app and `get-daily-ritual` remain unchanged. Review acceptance, block, rejection, latency, cost, and human copy quality.
3. **Internal allowlist:** a separately approved authenticated cohort may receive PCv1 through the versioned candidate endpoint. Everyone else continues receiving the control path.
4. **Limited TestFlight rollout:** expand only after internal checks show no contract, cache, rendering, analytics, or fallback regressions.
5. **Production ramp:** requires separate approval, rollback readiness, and live quality evidence. It is not implied by this design.

Each gate requires a documented rollback: disable the PCv1 exposure flag/allowlist and continue serving the existing control. Candidate data remains isolated for audit; it is not copied into `daily_rituals`.

## First implementation slice

The smallest safe next implementation, after approval, is **shadow storage + an internal-only candidate endpoint**. It should:

- reuse the frozen PCv1 generation stages without changing their language contract;
- create no production-row updates;
- return no candidate content from `get-daily-ritual`;
- support deterministic idempotency and explicit terminal states;
- emit the observability fields above;
- include provider-free tests for every state in the runtime table.

Only after that slice passes should the parallel iOS `{ title, read }` rendering surface be implemented for an internal allowlist.

## Non-goals for this design

- No current six-field prompt or generator changes.
- No retroactive rewrite of `daily_rituals`.
- No automatic copy repair for repetition or quality.
- No all-identity bulk generation.
- No deployment, schedule, allowlist, schema migration, or app code changes.
