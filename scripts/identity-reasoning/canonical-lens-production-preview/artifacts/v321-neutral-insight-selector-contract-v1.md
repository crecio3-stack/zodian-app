# Neutral Insight Selector v1 — Contract

## Purpose

Select one existing canonical personal behavior that can plausibly apply to a frozen neutral external situation. This component is a structured reasoning selector only. It does not write a Today’s Lens, title, action, or stylistic prose.

## Input

- The exact frozen neutral situation and observable facts
- Canonical identity metadata
- Multiple exact canonical evidence candidates, each with a source path and claim

Prior scenario-specific context output is excluded from the selector input.

## Required JSON output

`{ status, behavior, supporting_evidence, applicability, unsupported_claims_added }`

- `status`: `SELECTED` or `BLOCKED`
- `behavior`: one concrete user-owned observation, or `null` when blocked
- `supporting_evidence`: only exact path/claim pairs from supplied canonical evidence
- `applicability`: short explanation of how the cited behavior can be relevant to this external situation, or `null` when blocked
- `unsupported_claims_added`: always `[]`

## Prohibitions

Do not invent a trait, motive, fear, desire, causal explanation, corrective action, title, or Lens copy. The neutral situation cannot supply a behavior. Adjective swaps over the same scenario answer do not count as differentiation.

## Downstream boundary

Only a validated `SELECTED` output may continue through reasoning clarity, person-first specificity, human-language calibration, optional independently supported action, and the frozen v4 writer.
