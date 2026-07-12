# Canonical Identity Model v1

The Canonical Identity Model is Zodian's development-only, machine-readable
understanding of a stable identity. It records how a person notices, decides,
trusts, relates, works, responds to pressure, restores themselves, and matures.
It is framework-agnostic TypeScript and is not read by the iOS app, Supabase,
Today’s Lens, Connect, or Pattern Intelligence.

## Three distinct artifacts

- **Identity Reasoning Plan:** temporary internal planning produced while a new
  editorial identity is generated.
- **Canonical Identity Model:** reviewed, persistent behavioral understanding
  derived manually from approved editorial work.
- **Editorial Identity:** reader-facing prose that shows the canonical behavior
  through recognizable life rather than exposing the model.

The canonical model is not a trait list and does not replace approved prose. Its
evidence layer exists specifically to keep future writing grounded in actions,
ordinary situations, and identity-specific contrasts.

## Current reviewed fixtures

- `fixtures/libra-snake.ts` — frozen, manually mapped from the immutable Libra ×
  Snake editorial benchmark.
- `fixtures/taurus-horse.ts` — reviewed, manually mapped from the reviewed
  Taurus × Horse identity.

No other identities are canonical in v1. Aries × Rat and Pisces × Horse remain
development review prose and were deliberately not promoted without editorial
approval.

## Validate

```sh
deno test --allow-read scripts/identity-reasoning/canonical/canonical_identity_test.ts
```

Validation covers required fields, 3–5 unique themes, synthesis, evidence depth,
relationship/work/pressure completeness, strict reviewed-fixture requirements,
model differentiation, and semantic traceability.

## Inspect

```sh
deno run scripts/identity-reasoning/canonical/diagnostic.ts
deno run scripts/identity-reasoning/canonical/diagnostic.ts libra-snake
deno run scripts/identity-reasoning/canonical/diagnostic.ts taurus-horse
```

This layer may eventually inform Identity, Today’s Lens, Connect, and Pattern
Intelligence, but production adoption requires separate contracts, review, and
migration decisions. v1 intentionally contains no production wiring.
