import {
  evaluateSituationApplicability,
  type SituationApplicabilityRequest,
} from "./situation_applicability_evaluation.ts";
import { enumerateCanonicalCandidates } from "./canonical_candidate_enumeration.ts";

function assert(value: unknown, message: string): asserts value { if (!value) throw new Error(message); }

const enumerationInput = {
  stableCaseId: "provider-free-applicability-fixture",
  situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE" as const,
  candidateEvidence: [
    { path: "evidence.observableBehaviors[0]", claim: "You check a changed plan before deciding.", source: "canonical_identity" },
    { path: "evidence.observableBehaviors[1]", claim: "You bring energy to movement.", source: "canonical_identity" },
  ],
  excludedCitations: [],
};
const queue = enumerateCanonicalCandidates(enumerationInput).candidates;
function request(overrides: Partial<SituationApplicabilityRequest> = {}): SituationApplicabilityRequest {
  return {
    enumerationInput,
    enumeratedQueue: queue,
    frozenSituation: { situation: "A shared plan changes.", observableFacts: ["The change is visible before anyone responds."] },
    reviews: [
      {
        citationKey: queue[0].citationKey,
        classification: "DIRECTLY_APPLICABLE",
        situationCitation: { path: "neutral_situation.situation", claim: "A shared plan changes." },
        supportMode: "EXPLICIT_SITUATION_TO_EVIDENCE",
      },
      { citationKey: queue[1].citationKey, classification: "NOT_APPLICABLE" },
    ],
    ...overrides,
  };
}

Deno.test("returns the complete reviewed queue to human selection without ranking", () => {
  const result = evaluateSituationApplicability(request());
  assert(result.status === "COMPLETE_REVIEWED_QUEUE", "direct candidate should keep complete reviewed queue");
  assert(result.reviewedQueue.length === 2 && result.directlyApplicable.length === 1, "all candidates must remain traceable");
  assert(result.nextStep === "HUMAN_SELECT_DIRECT_CANDIDATE_THEN_RUN_APPROVAL_STACK", "no first-valid auto-selection is allowed");
  assert(!result.writerCallAllowed && !result.persistCopy, "applicability stays upstream-only");
});

Deno.test("thematic similarity and changed queue order fail closed", () => {
  const thematic = evaluateSituationApplicability(request({
    reviews: [{ ...request().reviews[0], supportMode: "THEMATIC_SIMILARITY" }, request().reviews[1]],
  }));
  assert(thematic.status === "BLOCKED", "thematic similarity is not direct applicability");
  const reordered = evaluateSituationApplicability(request({ enumeratedQueue: [...queue].reverse() }));
  assert(reordered.status === "BLOCKED", "queue order cannot be changed for review");
});

Deno.test("no direct alternative terminates cleanly", () => {
  const result = evaluateSituationApplicability(request({
    reviews: queue.map((candidate) => ({ citationKey: candidate.citationKey, classification: "NOT_APPLICABLE" })),
  }));
  assert(result.status === "NO_DIRECTLY_APPLICABLE_ALTERNATIVE", "exhausted applicability must be explicit");
  assert(result.nextStep === "TERMINAL_NO_COPY", "no candidate must not retry or write");
});
