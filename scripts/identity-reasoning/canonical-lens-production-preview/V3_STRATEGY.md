# Canonical Lens v3 prompt and generation strategy

## Outcome

V3 is a bounded development experiment, not another full-library run. It preserves the
v2 canonical fixtures, explicit identity-and-arena manifestations, focused contexts,
reasoning plans, provider, validators, and final six-field Lens shape. It changes only
the model-writing instructions, corpus-diversity guard, and editorial retry protocol.

## What v3 changes

### 1. Evidence-first writing

The first-pass prompt gives every field one job. The intro must begin from an
identity-specific observable behavior or arena detail instead of paraphrasing the shared
scenario. The deeper read carries the causal interpretation. Watch-for and move remain
behaviorally distinct.

### 2. Deterministic form variation

Each identity-and-arena key receives a deterministic editorial brief covering entry mode,
title direction, and sentence rhythm. These controls vary form only. They do not select,
replace, or add canonical identity evidence.

### 3. Corpus-aware exclusions

The prompt receives the saturated v2 titles, roots, intro openings, and slogan frames,
plus recent titles and openings from the current v3 sample. A local editorial validator
also rejects:

- any duplicate sample title;
- a title root after six prior uses;
- a four-word intro opening after two prior uses;
- any blocked v2 title, title root, or intro opening.

These failures are field-addressable, so only `title` or `intro` is retried.

### 4. Patch-only retries

The first call still returns the exact six-field Lens. If validation fails, the retry
request contains exactly the invalid field names, their rejected values, their individual
contracts, the validator errors, and the original focused context. The provider returns
only those failed fields. The runner records the raw patch and the merged candidate.
Valid fields are never sent back for rewriting, so preservation is deterministic rather
than aspirational. The final accepted artifact remains the unchanged six-field schema.

## Representative validation batch

Run 18 identities × 10 arenas = 180 outputs. The explicit identity list covers all 12
Western signs, all 12 Chinese signs, the five v2 rejected cases, the eight requested
expansion identities, and the Taurus × Horse / Libra × Snake anchors.

The sample is defined in `v3_sample_plan.ts`; it is not selected positionally from the
canonical library.

## Acceptance gates

Do not run v3 across all 1,440 contexts unless the 180-output sample meets every gate:

- 180/180 contexts accepted;
- editorial retry rate below 10%;
- zero final schema failures;
- 100% valid-field preservation across retries;
- zero identity or astrology leakage;
- zero unsupported-inference flags;
- zero exact duplicate titles;
- no title root used more than six times;
- no four-word intro opening used more than twice;
- zero reuse of the blocked v2 title/opening patterns;
- no regression in identity specificity, canonical grounding, or behavioral concreteness
  in a fresh blinded review of at least 36 stratified v2/v3 pairs.

The blinded review must show v3 win or tie on identity specificity and canonical grounding
in at least 70% of pairs. Do not score the blind artifact automatically as human judgment.

## Execution

Preflight only, with no network call or generated output:

```sh
deno run --allow-env --allow-read \
  scripts/identity-reasoning/canonical-lens-production-preview/run_generation_v3_sample.ts \
  --real --preflight
```

Run the 180-output sample only after preflight passes:

```sh
deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/run_generation_v3_sample.ts \
  --real
```

The runner checkpoints per identity and writes only new `generation-v3-sample*`
development artifacts. It does not overwrite v2 artifacts or write production paths.

## Decision after the sample

- If all automated and blind-review gates pass, prepare the isolated v3 full-library run.
- If schema or retry gates fail, revise only the field contracts or patch retry prompt.
- If repetition fails, revise the form brief and corpus guard.
- If identity grounding regresses, roll back the relevant first-pass prompt instruction;
  do not alter fixtures or manifestations without new evidence.

## V3 sample result and v3.1 correction

The first v3 sample proved patch preservation and output diversity, but its online corpus
gate incorrectly counted articles such as `The` and `A` as title roots. Repair prompts
also received a generic saturation error without the exact forbidden-root list. This
inflated the reported editorial retry rate and left 21 otherwise schema-valid candidates
held back. The original v3 artifacts remain evidence and must not be overwritten.

V3.1 corrects title-root normalization and supplies exact forbidden titles, saturated
content roots, and saturated intro openings on both first-pass and patch calls. Run it as
a new isolated 180-output sample:

```sh
deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/run_generation_v3_sample.ts \
  --real --v3-1
```

Then audit it with:

```sh
deno run --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/audit_v3_sample.ts \
  --v3-1
```
