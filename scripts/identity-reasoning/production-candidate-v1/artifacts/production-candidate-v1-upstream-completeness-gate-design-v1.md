# Production Candidate v1 — Upstream Completeness Gate Design

Status: provider-free design only. This is not a writer change, a selector change, or a production runtime change.

## Purpose

Decide whether an evidence-supported `plain_insight` has a directly supported second concrete beat before it is offered to the one-paragraph writer.

The gate protects a simple rule:

> Do not make a valid but thin insight sound deeper by inventing a second sentence.

## Inputs

- frozen neutral situation and observable facts;
- approved or candidate `plain_insight` with its exact citation;
- candidate canonical evidence already in scope for that identity and domain.

The gate never receives raw provider output and never generates user-facing prose.

## Allowed second-beat categories

| Category | Requirement |
|---|---|
| consequence | A cited behavior-bearing claim directly states what tends to follow. |
| tension | A cited behavior-bearing claim directly states a concrete competing behavior or friction. |
| contrast | A second cited behavior directly contrasts with the insight in the same neutral situation. |
| action | A separately cited, concrete action is available; it is not merely the generic opposite of the insight. |
| effect | A cited claim directly supports a recognizable practical or interpersonal effect. |

## Disallowed material

- inferred motives, fears, desires, or hidden psychology;
- generic advice such as “slow down,” “communicate,” or “think first” when not separately cited;
- a consequence inferred solely from the scenario;
- traits, archetype labels, or abstract growth language converted into behavior;
- a rephrasing of the same observation;
- text added only because a one-sentence read feels short.

## Decision procedure

1. Verify the first beat against its exact citation and the neutral situation.
2. Enumerate only distinct candidate claims that are behavior-bearing and in scope.
3. For each candidate, require a direct bridge to the same situation without adding a missing event, motive, or other person's response.
4. Select at most one plainly stated second beat. Do not combine several weak claims to manufacture one.
5. Classify the input:

   - `SECOND_BEAT_SUPPORTED`: one distinct candidate meets every condition; record its type, plain proposition, and exact citation.
   - `ONE_BEAT_COMPLETE`: no additional beat is needed because the approved input already contains a concrete completed action, effect, or consequence.
   - `TOO_THIN`: the first beat is valid but is only an observation and no direct second beat is available.
   - `BLOCKED`: the first beat itself is unsupported, too abstract, or does not directly apply to the neutral situation.

## Boundary behavior

- `SECOND_BEAT_SUPPORTED` is a candidate for human review, not automatic prose.
- `ONE_BEAT_COMPLETE` may proceed as one sentence.
- `TOO_THIN` must not be padded or passed as if complete; it needs a different, stronger evidence-supported insight in a future selection pass.
- `BLOCKED` remains terminal and produces no copy.

## Non-goals

- No semantic-uniqueness scoring.
- No forced two-sentence requirement.
- No retries for editorial taste.
- No modification of the frozen v4 writer, title/read contract, existing validators, or repetition policy.
