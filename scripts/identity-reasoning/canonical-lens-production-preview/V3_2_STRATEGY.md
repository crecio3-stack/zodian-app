# Canonical Lens v3.2 surface-voice strategy

## Objective

Combine v2's natural recognition voice with v3.1's corpus discipline. Do not change
canonical fixtures, manifestations, focused contexts, reasoning plans, final six-field
schema, diversity thresholds, or patch-only retry architecture.

## Prompt changes

- Treat deterministic form briefs as silent variation controls, never literal copy.
- Show observable behavior before canonical interpretation.
- Translate the reasoning plan into ordinary-life language instead of naming mechanisms.
- Reject strategy-document language such as `attribution`, `assumed motive`, `observable
  impact`, `visible competence`, and `bounded evidence`.
- Reject `column`, `note`, `card`, `gate`, `agenda`, or `list` in a title unless that
  concrete object is actually present in the focused context.
- Ask silently whether each sentence could appear in a strategy document; if so, rewrite
  it as something a person might notice happening.
- Use natural 2–4 word editorial titles with no terminal punctuation.
- Continue blocking exact duplicate and saturated titles, but do not ban v2-style roots
  such as `name`, `make`, `proof`, or `let` before they actually saturate.

## Validation

Run the same 18 identities and ten arenas. The automated gates remain:

- 180/180 accepted;
- retry rate below 10%;
- 100% valid-field preservation;
- zero schema failures, leakage, unsupported inference, duplicate titles, saturated title
  roots, saturated openings, or blocked exact patterns;
- zero v3.2 surface-voice flags.

If automated gates pass, create a fresh 36-pair v2/v3.2 comparison. The review JSON and
Markdown contain no reveal mapping. Store the mapping only in a separate reveal file that
must remain unopened until human scoring is complete.

V3.2 must win or tie at least 70% of pairs on identity specificity and canonical
grounding, while materially improving naturalness over v3.1. A narrow mechanical pass is
not enough.

## Commands

Preflight:

```sh
deno run --allow-env --allow-read \
  scripts/identity-reasoning/canonical-lens-production-preview/run_generation_v3_sample.ts \
  --real --preflight --v3-2
```

Generate only the isolated 180-output v3.2 sample:

```sh
deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/run_generation_v3_sample.ts \
  --real --v3-2
```

Audit and create separate blind/reveal artifacts:

```sh
deno run --allow-read --allow-write \
  scripts/identity-reasoning/canonical-lens-production-preview/audit_v3_sample.ts \
  --v3-2
```

Do not run the full 1,440-output library unless the automated and uncontaminated human
gates both pass.
