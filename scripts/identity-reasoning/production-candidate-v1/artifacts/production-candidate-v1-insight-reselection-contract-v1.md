# Production Candidate v1 — Insight Reselection Contract v1

Status: provider-free and upstream only. This contract starts only after Completeness Gate v1 returns `TOO_THIN`.

Its purpose is to make one bounded search through the remaining canonical evidence for a different situation-relevant primary insight. It does not generate a second beat, write user-facing copy, call a provider, or make a writer-eligibility decision.

## Required boundary

- Record the rejected `TOO_THIN` proposition and its exact citation.
- Start a distinct candidate version. The rejected version cannot retry itself.
- Remove every previously rejected citation from the remaining canonical-evidence queue.
- Reject any proposal that reuses a rejected citation, normalized rejected proposition, or durable rejected proposition key.
- Require the replacement to independently pass evidence, applicability, person-first, and human-language checks, plus approval for completeness review.
- Send an approved replacement back to Completeness Gate v1. It remains ineligible for the writer until that gate classifies it.

## Bounded routing

| State | Result | Writer / persistence |
|---|---|---|
| First pass, no replacement recorded | `READY_FOR_NEW_SUPPORTED_SELECTION` with remaining canonical evidence | Neither allowed |
| Distinct approved replacement recorded | `READY_FOR_COMPLETENESS_GATE` | Neither allowed |
| Attempt consumed with no supported replacement | `EXHAUSTED_NO_ALTERNATE_SUPPORTED_INSIGHT` | Terminal no-copy |
| Missing version, citation, approval, or required gate | `BLOCKED` | Terminal no-copy |

The contract deliberately has no automatic retry. Another attempt is a new explicit candidate version with its own recorded rejected-history set.
