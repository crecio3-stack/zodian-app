# Today’s Lens Production Candidate v1

Status: **development-only design**. This directory is the authoritative design
for the next candidate path. It supersedes neither the deployed Today’s Lens
pipeline nor any frozen experiment. Historical experiment artifacts remain
evidence, not executable production configuration.

## Approved decisions

- The user-facing candidate output is exactly `{ title, read }`.
- The v4 one-paragraph writer is the approved language direction.
- Copy should sound like someone who knows the user explaining their behavior.
- An insight must be grounded in cited canonical evidence and describe a
  person-first, observable pattern.
- A supported action is optional. When absent, the read may be short; it must
  not invent advice or filler.
- `BLOCKED` is a valid result when the evidence does not support a relevant
  observation.
- Similar themes, behavior, and actions are valid when independently supported.
  Semantic uniqueness is not a quality requirement.
- Repetition policy: **allow honest similarity; block lazy duplication**.

Frozen input fingerprints are recorded in
[production-candidate-v1.json](./production-candidate-v1.json). A future
candidate runner must verify them before provider calls.

## Candidate path

```text
neutral situation/context
  -> canonical identity evidence
  -> Neutral Insight Selector
  -> evidence + direct applicability validation
  -> person-first specificity
  -> human-language calibration
  -> optional supported action
  -> frozen v4 writer
  -> meaning + actor preservation
  -> lightweight repetition audit
  -> { title, read }
```

The canonical model remains the authority on identity evidence. The selector
chooses among exact evidence claims; it does not create traits, motives,
psychology, actions, titles, or prose. The v4 writer receives only calibrated
`plain_insight`, nullable `plain_action`, clarity status, and approved examples.
It never receives raw canonical evidence or excluded claims.

## Stage contracts and ownership

| Stage | Owner | Allowed input | Output | Prohibited responsibility |
| --- | --- | --- | --- | --- |
| Situation | deterministic request assembly | External facts and neutral constraints | `situation_id`, neutral situation | A behavior, lesson, desired action, or interpretation |
| Evidence retrieval | canonical library | Exact canonical identity record | Citable path/claim candidates | Scenario-shaped reasoning or inferred psychology |
| Insight selection | Neutral Insight Selector | Situation plus exact candidate claims | `SELECTED` cited behavior/applicability or `BLOCKED` | Lens prose, title, action, new trait, motive, or cause |
| Applicability | deterministic validation | Selector output, supplied citations, situation | PASS or invalid selection | A demand that identities differ from one another |
| Person-first | deterministic gate | Evidence-supported plain insight | PASS, NARROW, or BLOCKED | New explanation, action, or motive |
| Human language | deterministic audit plus reviewed calibration | Plain insight/action | NATURAL or REVIEW | Automatic rewording or added meaning |
| Action | evidence-backed input preparation | Separate cited action claim, when present | Nullable `plain_action` | Advice invented from the situation or writer preference |
| Writer | frozen v4 writer | Insight, nullable action, status, Gold examples | `{ title, read }` | New facts, motives, unsupported advice, raw-evidence wording |
| Final validation | deterministic checks plus review | Writer output and approved inputs | accepted candidate or explicit failure | Silent repair, fallback prose, or publication |
| Repetition | corpus/user-history audit | Accepted candidate plus comparison set/history | allow, hold-for-review, or block | Forced semantic variation or automatic rewriting |

`NARROW` means the insight can proceed only after an evidence-preserving human
rewrite of the same observation. `REVIEW` means the wording is technically
understandable but sounds engineered; it requires approved wording before the
writer receives it. Neither gate may generate copy itself.

## Direct applicability rule

This is deliberately light. A selector result can continue only when:

1. every cited path/claim is in the retrieved canonical evidence for that
   identity;
2. the selected behavior is a user-owned observable pattern, not advice;
3. its supplied applicability statement connects that behavior to the neutral
   situation without adding a motive, consequence, or solution.

The system does **not** require a different theme, action, or conclusion for
every identity. If no cited behavior is reasonably relevant, the result is
`BLOCKED` and no writer call occurs.

## Failure and BLOCKED behavior

| Condition | Required result |
| --- | --- |
| No relevant canonical behavior | Preserve `BLOCKED`; skip action and writer stages |
| Invalid citation, selector JSON, or applicability | Terminal candidate failure with raw response and errors preserved; no substitute behavior |
| Person-first or human-language review required | Hold before writing; use only an approved, evidence-preserving rewrite |
| No supported action | Pass `plain_action: null`; writer may return a short observation-only read |
| Writer transport or JSON/schema failure | Explicit terminal failure; preserve attempts; never publish a partial Lens |
| Meaning/actor preservation failure | Hold/reject; never silently alter the writer output |
| Repetition policy violation | Hold or block the candidate; do not rewrite good copy solely to make it novel |

No quality retries are permitted to make a result more distinctive or stylish.
Any future structural retry policy must be separately approved and preserve
valid data byte-for-byte.

## Lightweight repetition policy

Similarity is permitted. These controls target collapse, not shared human
experience:

| Check | Disposition |
| --- | --- |
| Exact normalized `{title, read}` duplicate | Block the duplicate candidate |
| Near-exact final copy (same title and materially matching read) | Hold for human review; block only if confirmed duplicate |
| Same exact title at corpus-scale frequency | Corpus-review hold, not automatic rewrite |
| Clearly repeated sentence template across a material cohort share | Corpus-review hold, not an individual semantic failure |
| Identical normalized insight/action pair across many identities | Corpus-review hold; allow if cited evidence supports each case |
| Substantially similar recent read for the same user | Hold that user’s candidate and select another supported behavior or return BLOCKED |

The initial implementation must log exact thresholds and comparison evidence.
Thresholds must not encode a requirement for semantic distance, unique actions,
unique topics, or unique sentence rhythm. Corpus-review holds are human review
events, never an instruction to manufacture a distinction.

## Validation and observability

Every candidate case needs an immutable trace containing:

- case and situation IDs; canonical identity fingerprint; situation fingerprint;
- evidence retrieval candidates and selector raw/parsed response;
- selected citations, applicability result, and all validation errors;
- approved plain insight/action provenance and excluded claims;
- person-first and human-language outcomes;
- writer raw/parsed response, model/configuration fingerprint, latency, tokens,
  and provider-call count; never an API key;
- exact final `{ title, read }`, actor/meaning validation result, and repetition
  comparison outcome;
- terminal state: accepted, blocked, held, or rejected.

The initial 20–30-case validation remains a human product evaluation. Automatic
checks prove boundaries; they do not claim that a Lens feels personally true.

## Migration from the current Today’s Lens pipeline

1. **No production change now.** Keep the deployed pipeline, stored rows,
   functions, schedules, and consumers intact.
2. Implement this path in a separate development-only namespace with local
   versioned artifacts and a provider-free preflight.
3. Run the frozen unseen candidate cohort and complete human quality review.
4. If approved, design an explicit versioned integration adapter from
   `{ title, read }` to the future consumer contract. Do not mutate legacy
   six-field records or silently map candidate output into current production
   rows.
5. Only after a separately approved integration review may an internal/dev
   allowlist or shadow plan be proposed. That plan must specify isolation,
   idempotency, data retention, observability, and rollback.
6. Production promotion remains a separate decision, requiring fresh consumer,
   security, and live-behavior verification.

The candidate’s success criterion is natural, evidence-supported, personally
recognizable copy—not a full pre-generation of all identities.

See [provider-free-preflight-plan.md](./provider-free-preflight-plan.md) for the
next execution checkpoint.
