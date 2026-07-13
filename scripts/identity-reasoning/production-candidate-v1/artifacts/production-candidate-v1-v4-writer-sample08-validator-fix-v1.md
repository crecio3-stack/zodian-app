# Sample 08 validator fix v1

## Scope

This provider-free correction addresses only the unsupported-addition false positive in frozen Sample 08. It does not regenerate, replace, or edit the original paid writer output.

## Generic rule

When a generated `read`, after trimming, exactly equals its approved `plain_insight`, unsupported-addition heuristics do not scan that `read`. A verbatim read contains no writer-added wording to classify as an invented motive or action.

The model-generated title remains independently scanned. Schema, meaning, personal-actor, and repetition validation are unchanged. Any non-verbatim read remains subject to the original unsupported-addition scan.

## Evidence

- Frozen case: `pcv1-unseen-24-scorpio-x-dragon-recognition-public-credit-neutral`
- Original status: `TERMINAL_REJECTED`
- Original rejection reason: the phrase `longer than you need to`, copied verbatim from the approved plain insight, matched two broad unsupported-addition regular expressions.
- Provider-free revalidation: schema errors `0`; actor errors `0`; unsupported-addition errors `0`; would accept `true`.

## Regression coverage

The regression test proves both sides of the boundary:

1. The pre-fix heuristic reproduces the stored two-error false positive for the verbatim Sample 08 read.
2. The new generic rule accepts that verbatim read while continuing to scan a title containing `You Need to Act`.
3. A non-verbatim read containing newly added advice remains subject to the unsupported-advice scan.

## Run safety

The paid writer runner now refuses to start if its frozen generation artifact already exists. Validator corrections therefore require a provider-free validation overlay and cannot silently trigger a paid regeneration of this cohort.

## Side effects

- Provider calls: `0`
- Writer calls: `0`
- Production writes: `0`
- Shadow writes: `0`
