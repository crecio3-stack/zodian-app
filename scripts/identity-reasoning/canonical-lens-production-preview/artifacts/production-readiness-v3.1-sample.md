# Canonical Lens v3.1 sample readiness

## Decision

V3.1 passes every automated sample gate and is ready for human blind pairwise evaluation.
It is not yet approved for the full 1,440-output generation.

## Generation

- Model: `gpt-5.6-terra`
- Source SHA-256: `d43433b9bf72d56d85b9d6ab4b9614fe5a004c07b57e9139e4bb836dea093ffe`
- Identities: 18
- Arenas: 10
- Contexts: 180
- Provider calls: 186
- First-attempt acceptances: 174
- Retry acceptances: 6
- Rejections: 0
- Retry rate: 3.33%
- Total tokens: 564,348
- Valid-field preservation: 100%

## Automated QA

- Schema failures: 0
- Identity or astrology leakage: 0
- Unsupported-inference flags: 0
- Retry-preservation failures: 0
- Duplicate titles: 0
- Saturated title roots: 0
- Saturated intro openings: 0
- Blocked v2 pattern reuse: 0

## Blind artifact

- Pairs: 36
- Identities represented: 18
- Arenas represented: 10
- V2 in Version A: 20
- V3.1 in Version A: 16
- Human preferences recorded: 0
- Provider metadata visible in review Markdown: no
- Source mapping visible in review Markdown: no
- Reveal mapping: stored only in the JSON artifact

Do not inspect the JSON reveal mapping until all 36 preferences and qualitative scores
have been recorded in the Markdown review. Do not automatically score the blind artifact
as human judgment.

## Recommendation

Complete blind pairwise evaluation.
