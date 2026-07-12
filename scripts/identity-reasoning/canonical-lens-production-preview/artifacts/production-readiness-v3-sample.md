# Canonical Lens v3 sample readiness

## Decision

The 180-output v3 sample is not ready for blind review or full-library expansion.

## Recorded result

- Contexts: 180
- First-attempt accepted under combined schema and corpus gates: 110
- Accepted after retry: 49
- Editorially rejected: 21
- Provider calls: 291
- Reported combined retry rate: 27.22%
- Total tokens: 548,468
- Valid-field preservation: 100%

## Corrected interpretation

The combined metric overstates model schema friction:

- First-attempt schema-valid outputs: 177/180
- Schema-only retry rate: 1.67%
- Final schema-valid candidates: 180/180
- Leakage: 0
- Unsupported-inference flags: 0
- Retry-preservation failures: 0

All 21 final rejections were caused by corpus-title rules. Across the full run, corpus
validation produced 99 saturated-root errors, 24 duplicate-title errors, 13 blocked-root
errors, two repeated-opening errors, and only four ordinary schema errors.

The accepted 159-output corpus has zero duplicate titles, saturated roots, saturated
openings, blocked v2 pattern reuse, leakage, or unsupported-inference flags. This is a
strong diversity signal, but it was achieved with too much online repair pressure.

## Root cause

The development gate counted `The` and `A` as title roots. It also told repair calls that
a root was saturated without supplying the actual forbidden titles and saturated roots.
The model therefore had to guess which alternatives remained available, often exhausting
both repair attempts on another saturated choice.

## Correction

V3.1 now:

- counts the first non-article word as the title root;
- supplies every forbidden exact title;
- supplies all saturated content roots;
- supplies all saturated intro openings;
- preserves patch-only retries and the final six-field schema;
- writes isolated `generation-v3.1-sample*` artifacts.

Do not generate a blind artifact for v3. Run the isolated v3.1 180-output sample before
considering the full 1,440-output library.
