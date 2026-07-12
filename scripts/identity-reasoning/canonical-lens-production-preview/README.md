# Canonical Identity → Today’s Lens production preview

Development-only, resumable full-library pipeline for 144 canonical identities,
1,440 explicit identity-and-arena manifestations, and 1,440 model-written
Today’s Lens outputs. It imports the existing model-writing prompt, six-field
schema validator, provider, and two-retry behavior without modifying them.

The authoritative identity source is `Resources/archetypes.json`. Every
canonical fixture and review page preserves its source ID and field-level arena
traceability.

## Offline preparation

```sh
deno test --allow-net --allow-read \
  scripts/identity-reasoning/canonical-lens-production-preview/production_preview_test.ts

deno run --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/prepare_v2.ts
```

## No-network provider and cost preflight

Set the approved model and API key in the same shell. Dollar estimates are only
calculated when explicit model rates are supplied; the pipeline does not guess
pricing.

```sh
export OPENAI_IDENTITY_LENS_MODEL='gpt-5.6-terra'
export OPENAI_INPUT_USD_PER_MILLION='<approved-input-rate>'
export OPENAI_OUTPUT_USD_PER_MILLION='<approved-output-rate>'

deno run --allow-env --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/run_generation_v2.ts \
  --real --preflight
```

## Resumable real generation

```sh
deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/run_generation_v2.ts \
  --real
```

Each identity is checkpointed independently. A fixture, manifestation, context,
provider, or final validation failure aborts only that identity; processing then
continues with the remainder. A complete-generation artifact is created only
after all 144 identities and 1,440 outputs are accepted.

For a bounded canary, append `--max-identities=N`. A later run resumes accepted
checkpoints automatically. To retry only identities previously marked aborted,
append `--retry-aborted`; the failed checkpoints are copied into a history
directory before the retry.

## QA and review package

```sh
deno run --allow-env --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/build_reports.ts
```

The v2 preparation writes versioned `*-v2.json` and `*-v2.md` artifacts while
preserving the earlier unversioned preview artifacts. Preparation and QA make no
provider calls. All writes remain under this directory’s `artifacts/` tree. No
Supabase function, database row, production prompt, production validator, app
UI, or scheduled job is read as a write target.
