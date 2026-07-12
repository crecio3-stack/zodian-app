# Canonical Identity → Today’s Lens expansion

Development-only expansion to eight structurally diverse identities: Sagittarius
× Monkey, Scorpio × Dragon, Aries × Rat, Pisces × Dog, Leo × Horse, Aquarius ×
Snake, Cancer × Pig, and Virgo × Dragon.

Each identity has an explicit keyed manifestation for all ten arenas. No
positional indexing, modulo selection, fallback arena, or independent evidence
shuffling is used. Existing Libra × Snake/Taurus × Horse fixtures and artifacts
are untouched.

## Offline audit

```sh
deno test --allow-read scripts/identity-reasoning/canonical-lens-expansion/canonical_lens_expansion_test.ts
deno run --allow-read --allow-write scripts/identity-reasoning/canonical-lens-expansion/context_audit.ts
```

## Cost preflight

Using the corrected v2 run as reference, this estimates 80 cases, roughly 92
calls including retry headroom, and approximately 118,000 tokens. Preflight
makes no provider call and writes no artifacts.

```sh
deno run --allow-env --allow-read scripts/identity-reasoning/canonical-lens-expansion/run_expansion.ts --real --preflight
```

## Real run

```sh
deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-expansion/run_expansion.ts --real
```

The run requires explicit `--real`, uses the configured provider/model, and
writes only new expansion artifacts. It does not modify production code, rows,
prompts, UI, scheduled jobs, or prior experiment artifacts.
