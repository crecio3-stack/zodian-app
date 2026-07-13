# Production Candidate v1 — Canonical Candidate Enumeration v1

Status: provider-free upstream input to Insight Reselection Contract v1.

For a frozen neutral situation, enumeration surfaces the complete remaining set of behavior-bearing canonical citations already retrieved for that situation. It removes rejected citations and duplicate canonical claims of those citations; a repeated source path is not a distinct alternative. It does not rank, score, prefer, combine, paraphrase, or turn a citation into a proposed insight.

## Eligibility and traceability

- Evidence must come from the frozen situation-relevant `candidate_evidence` payload.
- Only the existing behavior-bearing canonical-path allowlist is eligible; traits, motives, summaries, advice, and abstract domain material remain excluded.
- Each result retains its exact `path`, exact `claim`, source, original source ordinal, and durable `citationKey`.
- Results preserve frozen source traversal order. That order is traceability only, never a recommendation or quality rank.
- Every rejected citation must exist in the frozen payload. An unknown exclusion blocks enumeration rather than silently altering the candidate set.
- A canonical claim duplicated under another eligible path is excluded with its rejected claim; duplicate sourcing is traceability, not a new proposition.

## Routing

`ENUMERATED` provides the complete deterministic queue to the one reselection pass. `EMPTY` gives no alternative and cannot trigger a retry. `BLOCKED` exposes no candidates. All enumeration outcomes prohibit writer calls and copy persistence. A selected replacement must still independently satisfy the reselection approval stack and then return to Completeness Gate v1.
