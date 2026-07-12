# Canonical Lens v3.2 blind evaluation

## Result

- Pairs reviewed: 36
- V3.2 preferred: 19
- V2 preferred: 14
- Ties: 3
- V3.2 win-or-tie rate: 61.1%

The review was completed before resolving versions against the separate reveal file.

## Decision

Pass and freeze v3.2. Do not create v3.3 or resume prompt tuning before the full-corpus
audit. The previous 70% pairwise threshold is not used as a release gate because v2 is an
already-strong editorial baseline and v3.2's principal job is to preserve individual-read
quality while correcting corpus-scale repetition.

V3.2 preserved approximate editorial parity, passed every automated diversity and safety
gate, and materially improved behavioral-first progression. Its remaining risk is
scenario-template gravity across the full library, not prompt-level identity grounding.

## Full-corpus audit priorities

1. Semantic repetition across 1,440 outputs.
2. Scenario-template repetition within each arena.
3. Identity differentiation inside the same scenario.
4. Same-identity voice across ten arenas.
5. Title quality and naturalness.
6. Standalone conjunction openings such as `But`.
7. Literary phrasing that sacrifices clarity.
8. Outputs that differ lexically but remain functionally interchangeable.

Proceed only with an isolated, development-only v3.2 full-corpus generation.
