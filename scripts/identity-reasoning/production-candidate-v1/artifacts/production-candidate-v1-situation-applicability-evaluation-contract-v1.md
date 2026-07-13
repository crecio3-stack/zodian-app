# Production Candidate v1 — Situation Applicability Evaluation v1

Status: provider-free review contract between canonical enumeration and Insight Reselection.

The evaluator consumes the exact enumerated queue in frozen source order and requires one record for every candidate: `DIRECTLY_APPLICABLE`, `NOT_APPLICABLE`, or `BLOCKED`. It does not write, paraphrase, synthesize, infer relevance, rank candidates, select the first valid candidate, or call a provider.

`DIRECTLY_APPLICABLE` requires an exact citation to the frozen neutral situation or one of its observable facts, recorded as `EXPLICIT_SITUATION_TO_EVIDENCE`. Thematic similarity and inferred bridges fail closed. Every review retains the candidate's exact citation key, path, claim, source ordinal, and any exact situation citation.

When direct candidates exist, the complete reviewed queue returns to human selection. A chosen candidate must still pass person-first, human-language, approval, and Completeness Gate v1 before writer eligibility. When no direct candidate remains, the result is `NO_DIRECTLY_APPLICABLE_ALTERNATIVE` and terminal no-copy. Every outcome prohibits writer calls and copy persistence.
