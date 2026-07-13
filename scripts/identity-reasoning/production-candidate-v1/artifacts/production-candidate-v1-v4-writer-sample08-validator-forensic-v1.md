# Production Candidate v1 — Sample 08 Validator Forensic

## Finding

**Confirmed narrow validator false positive.** The writer did not add a motive, inner state, or action.

| Field | Value |
|---|---|
| Supplied plain insight | After getting public credit, you may keep the attention on yourself longer than you need to. |
| Generated read | After getting public credit, you may keep the attention on yourself longer than you need to. |
| Equality | Exact string match |
| Supplied action | None |

The current unsupported-addition heuristic scans the concatenated generated title and read in isolation. Its motive pattern includes `you need`, and its advice pattern includes `you need to`. Both match the existing phrase **“you need to”** inside the approved plain insight, even though the writer preserved that sentence verbatim.

## Excluded causes

- Not normalization: the stored input and output are an exact match.
- Not the title: the matching phrase occurs in the read, not `When Attention Stays on You`.
- Not stale state: the stored validation errors are the same two errors reproduced directly from the current heuristic.
- Not an action error: no action was supplied or added.
- Not model-based validation: this is a local regular-expression heuristic.

## Smallest justified fix proposal — not implemented

Keep title scanning unchanged. When the generated **read** exactly matches the supplied `plain_insight`, do not run unsupported-addition regexes against that read: it contains no writer-added wording. For any non-verbatim read, keep the current checks unchanged.

This is a generic verbatim-preservation rule, not a sentence-specific exception and not a semantic-policy change. Schema, actor, meaning, and repetition checks remain in force.

## Regression fixture

`v4_writer_sample08_validator_forensic_test.ts` reproduces the two current false-positive errors and specifies the proposed narrow behavior: the verbatim read passes while a model-generated title containing `You Need` remains checked.
