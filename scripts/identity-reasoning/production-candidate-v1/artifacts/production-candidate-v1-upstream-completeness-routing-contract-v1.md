# Production Candidate v1 — Upstream Completeness Routing Contract

Status: provider-free contract. It sits after evidence, direct applicability, person-first, and human-language approval and before any writer eligibility decision.

The gate receives an already approved primary beat, exact candidate evidence, and a human-recorded classification. It does not select an alternative insight, invent a second beat, write copy, call a provider, or modify the frozen v4 writer input.

| Classification | Required record | Writer eligibility | Copy persistence | Route |
|---|---|---|---|---|
| `SECOND_BEAT_SUPPORTED` | A separately cited, directly supported second-beat type, proposition, exact evidence citation, and `APPROVED` status. | Eligible | Only after the approved route reaches the writer. | `HUMAN_APPROVED_SECOND_BEAT_TO_WRITER` |
| `ONE_BEAT_COMPLETE` | Directly cited, approved action, consequence, or effect that makes the single approved beat complete. | Eligible | Only after the approved route reaches the writer. | `APPROVED_ONE_BEAT_TO_WRITER` |
| `TOO_THIN` | No second beat and no one-beat completion record. | Ineligible | Never. | `RESELECT_SUPPORTED_INSIGHT_UNDER_NEW_VERSION` |
| `BLOCKED` | No valid writer route. | Ineligible | Never. | `TERMINAL_NO_COPY` |

The only recognized support types are directly cited `consequence`, `tension`, `contrast`, `action`, and `effect`. The contract rejects inferred motive or psychology, generic advice, scenario-only consequences, restatements, length padding, uncited second beats, and any second beat that is pending or rejected.

`TOO_THIN` is deliberately not a repair state. It cannot call the writer or persist copy. Future work must return to canonical evidence and select a different supported insight under a new version.
