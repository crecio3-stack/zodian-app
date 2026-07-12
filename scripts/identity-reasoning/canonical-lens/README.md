# Canonical Identity → Today’s Lens adapter

This is a development-only architecture experiment. It proves that one daily
tension can resolve differently for two reviewed canonical identities without
passing the entire canonical model into Lens writing.

## Flow

`CanonicalIdentityModel` → `buildCanonicalLensContext` → `planCanonicalLens` →
`writeCanonicalLens` → existing six-field Lens shape → validation.

The context selector passes only the activated paradox, one perception detail,
one decision or pressure/growth detail, two observable behaviors, and one arena
detail. The reasoning plan remains debug-only. The final Lens contains exactly:
`title`, `intro`, `pull_quote`, `deeper_read`, `watch_for`, and `move`.

The current writer is deterministic development copy so the comparison can be
reviewed without an API key. It is intentionally not a production prompt or Edge
Function path.

## Run the matched comparison

```sh
deno run --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens/run_comparison.ts
```

This writes twenty outputs—ten Libra × Snake and ten Taurus × Horse—under
`artifacts/`, paired by ten shared scenarios. The artifact preserves selected
context, reasoning, final Lens, validation, and retry count for every result.

## Validation boundary

The production `validateStructuredDailyRead` is not exported and its module is
coupled to the live Edge Function runtime, so direct import is unsafe for this
isolated script. `validateCanonicalLens` is the thinnest development adapter: it
keeps the same six-field shape and the existing sentence/word constraints and
does not loosen acceptance. Before production wiring, expose and share the
existing validator instead of keeping two implementations.

No production Today’s Lens generation, prompts, validators, retries, database,
API contracts, scheduled jobs, analytics, UI, or stored rows are changed.
