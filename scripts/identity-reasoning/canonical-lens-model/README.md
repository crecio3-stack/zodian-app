# Canonical Identity → Today’s Lens model-writing pass

This directory is a development-only continuation of the deterministic
canonical-lens experiment. It adds an injectable editorial writing provider
after focused context selection and reasoning. The deterministic adapter and its
20 baseline outputs remain unchanged and are the control group.

The model writer receives only the selected context, the completed reasoning
plan, the daily scenario inputs, and the six-field Lens contract. It never
receives the full canonical fixture or unselected canonical fields.

The experimental run uses `diversified_plan.ts` to select a different behavioral
manifestation by arena while leaving the deterministic adapter and baseline
artifacts unchanged. Libra × Snake can therefore resolve through missing
conditions, follow-through, ceremony, attribution, or reversible tests; Taurus ×
Horse can resolve through handoffs, separate time, physical adjustment, route
variation, maintenance, or expanded options. This is an upstream planning
experiment, not a writing-prompt rewrite.

## Providers

The default provider is a deterministic no-network mock backed by the existing
development Lens library. It makes the harness repeatable without an API key.
The real provider requires `OPENAI_API_KEY`. The optional model is read from
`OPENAI_IDENTITY_LENS_MODEL`, then `OPENAI_MODEL`; if neither is set, the safe
default is `gpt-5.2`. There are no other temperature, reasoning-effort, or token
limit environment variables in this runner; response format is JSON mode and
sampling uses the provider default. No keys are stored in source.

```sh
deno run --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-model/run_comparison.ts

deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-model/run_comparison.ts --real
```

For an ephemeral local setup, use placeholders only in your shell:

```sh
export OPENAI_API_KEY="<your-development-key>"
export OPENAI_IDENTITY_LENS_MODEL="<approved-model-id>"
deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-model/run_comparison.ts --real
```

Run a no-network preflight first:

```sh
deno run --allow-env --allow-read \
  scripts/identity-reasoning/canonical-lens-model/run_comparison.ts \
  --real --preflight
```

Preflight prints the selected model, matched-case count, distinct artifact-path
check, and empty production write scope. It never prints the key, calls the
provider, or writes artifacts. Without `--real`, the mock remains the default:

```sh
deno run --allow-env --allow-read \
  scripts/identity-reasoning/canonical-lens-model/run_comparison.ts \
  --preflight
```

If configuration is missing, the command fails before any network request and
names the missing variable. Never put credentials in tracked files or a
populated `.env`; this repository has no established `.env` loading convention.

Each result records the initial raw response, parsed response, validation, all
validation errors, retry count, final state, and source traceability. A maximum
of two retries is allowed, and retry prompts retain the same focused context.

## Artifacts and validation

- `artifacts/canonical-lens-model-comparison.json` contains all 20 baseline and
  20 experimental outputs, focused contexts, reasoning, attempts, and scores.
- `artifacts/canonical-lens-model-comparison.md` is the field-by-field audit.

The development validator preserves the existing six-field shape and published
word/sentence constraints. Direct reuse of the production validator is not
possible here because it is not exported and its Edge Function module is
runtime-coupled; the adapter documents this boundary and uses strict parsing.
Production integration should expose and share the existing validator rather
than maintain two long-term implementations.

```sh
deno test --allow-net --allow-read \
  scripts/identity-reasoning/canonical-lens-model/canonical_lens_model_test.ts
```

No production prompts, Supabase functions, validators, rows, API contracts,
scheduled jobs, UI, or analytics are modified by this experiment.
