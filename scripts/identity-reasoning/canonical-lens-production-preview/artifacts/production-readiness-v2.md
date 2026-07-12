# Canonical Lens production-preview v2 readiness

## Decision

The development-only run completed, but it did not meet the current production-readiness gates.

## Run

- Provider: `openai:gpt-5.6-terra`
- Model: `gpt-5.6-terra`
- Source SHA-256: `d43433b9bf72d56d85b9d6ab4b9614fe5a004c07b57e9139e4bb836dea093ffe`
- Identities processed: 144
- Contexts attempted: 1,440
- Provider calls: 1,648
- First-attempt acceptances: 1,247
- Accepted after retry: 188
- Rejected after two retries: 5
- Complete identities: 139
- Partial identities: 5
- Acceptance: 99.65%
- Accepted-output retry rate: 13.06% (current gate: at most 10%)
- Transport retries: 0

## Unresolved validation failures

| Identity | Arena | Final invalid field(s) |
|---|---|---|
| Aquarius × Rat | rest | `deeper_read` |
| Aquarius × Dog | love | `pull_quote`, `deeper_read` |
| Pisces × Rooster | conflict | `move` |
| Cancer × Snake | money | `deeper_read` |
| Leo × Horse | opportunity | `deeper_read` |

Across all attempts, validation errors occurred 220 times: `move` 168, `deeper_read` 40, `watch_for` 7, and `pull_quote` 5.

## Usage

- Input tokens: 1,772,229
- Cached input tokens: 1,172
- Output tokens: 399,782
- Reasoning tokens: 144,609
- Total tokens: 2,172,011
- Average tokens per provider call: 1,317.97
- Average tokens per requested output: 1,508.34
- Dollar estimate: not calculated because explicit model input/output rates were not supplied; no price was guessed.

## Automated QA

- Accepted-output schema failures: 0
- Identity or astrology leakage: 0
- Unsupported-inference regex flags: 0
- Retry transitions that changed already-valid fields: 198
- High-similarity pairs at the existing TF-IDF thresholds: 0
- Semantic clusters at the existing threshold: 0

The broad similarity thresholds do not capture the phrase-level repetition. The repeated-title and opening audits found substantial templating:

- `Name the Handoff`: 141 exact titles
- `Let It Land`: 114 exact titles
- `The Real Price`: 69 exact titles
- `Proof of Departure`: 52 exact titles
- `Proof of the Leap`: 50 exact titles
- Intro opening `A tender message lands`: 87 outputs
- Intro opening `A small disagreement sharpens`: 87 outputs
- Intro opening `A familiar room asks`: 71 outputs

This means the library clears leakage and broad semantic-similarity checks but fails the intended long-term originality standard.

## Validation and isolation

- 41 offline tests passed; 0 failed.
- All 144 canonical fixtures passed.
- All 1,440 manifestations and focused contexts passed compatibility checks.
- No positional, modulo, or fallback selection was found.
- No production write paths were used.
- Existing production behavior was not changed.

## Recommendation

**Revise prompt.**
