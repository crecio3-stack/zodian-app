/**
 * Provider-free applicability review for an already enumerated canonical queue.
 * It validates recorded direct bridges; it does not infer relevance, rank, or
 * choose a replacement.
 */

import {
  enumerateCanonicalCandidates,
  type CanonicalCandidateEnumerationInput,
  type EnumeratedCanonicalCandidate,
} from "./canonical_candidate_enumeration.ts";

export type FrozenSituation = {
  situation: string;
  observableFacts: string[];
};
export type ApplicabilityClassification =
  | "DIRECTLY_APPLICABLE"
  | "NOT_APPLICABLE"
  | "BLOCKED";
export type SituationCitation = {
  path: "neutral_situation.situation" | `neutral_situation.observableFacts[${number}]`;
  claim: string;
};
export type ApplicabilityReview = {
  citationKey: string;
  classification: ApplicabilityClassification;
  situationCitation?: SituationCitation;
  supportMode?: "EXPLICIT_SITUATION_TO_EVIDENCE" | "THEMATIC_SIMILARITY" | "INFERRED";
  blockedReason?: "NO_DIRECT_SITUATION_BRIDGE" | "MISSING_EXACT_SUPPORT" | "UNSAFE_INFERENCE";
};
export type SituationApplicabilityRequest = {
  enumerationInput: CanonicalCandidateEnumerationInput;
  enumeratedQueue: EnumeratedCanonicalCandidate[];
  frozenSituation: FrozenSituation;
  reviews: ApplicabilityReview[];
};
export type ReviewedCandidate = EnumeratedCanonicalCandidate & {
  classification: ApplicabilityClassification;
  situationCitation?: SituationCitation;
};
export type SituationApplicabilityResult = {
  status: "COMPLETE_REVIEWED_QUEUE" | "NO_DIRECTLY_APPLICABLE_ALTERNATIVE" | "BLOCKED";
  writerCallAllowed: false;
  persistCopy: false;
  nextStep:
    | "HUMAN_SELECT_DIRECT_CANDIDATE_THEN_RUN_APPROVAL_STACK"
    | "TERMINAL_NO_COPY"
    | "FIX_APPLICABILITY_RECORD";
  reviewedQueue: ReviewedCandidate[];
  directlyApplicable: ReviewedCandidate[];
  errors: string[];
};

function exactSituationCitation(
  citation: SituationCitation,
  situation: FrozenSituation,
): boolean {
  if (citation.path === "neutral_situation.situation") return citation.claim === situation.situation;
  const match = /^neutral_situation\.observableFacts\[(\d+)\]$/.exec(citation.path);
  return !!match && citation.claim === situation.observableFacts[Number(match[1])];
}

function sameQueue(
  left: EnumeratedCanonicalCandidate[],
  right: EnumeratedCanonicalCandidate[],
): boolean {
  return left.length === right.length && left.every((item, index) =>
    item.sourceOrdinal === right[index].sourceOrdinal &&
    item.citationKey === right[index].citationKey &&
    item.evidence.path === right[index].evidence.path &&
    item.evidence.claim === right[index].evidence.claim
  );
}

export function evaluateSituationApplicability(
  request: SituationApplicabilityRequest,
): SituationApplicabilityResult {
  const expected = enumerateCanonicalCandidates(request.enumerationInput);
  const errors: string[] = [...expected.errors];
  if (expected.status !== "ENUMERATED") errors.push("applicability requires a non-empty enumerated queue");
  if (!sameQueue(expected.candidates, request.enumeratedQueue)) {
    errors.push("review queue must exactly match the frozen enumeration in source order");
  }
  if (!request.frozenSituation.situation.trim() || request.frozenSituation.observableFacts.length === 0) {
    errors.push("frozen situation is incomplete");
  }
  if (request.reviews.length !== request.enumeratedQueue.length) {
    errors.push("every enumerated candidate requires exactly one applicability classification");
  }
  if (!request.reviews.every((review, index) => review.citationKey === request.enumeratedQueue[index]?.citationKey)) {
    errors.push("applicability reviews must preserve enumeration source order");
  }
  if (errors.length) return {
    status: "BLOCKED", writerCallAllowed: false, persistCopy: false,
    nextStep: "FIX_APPLICABILITY_RECORD", reviewedQueue: [], directlyApplicable: [], errors,
  };

  const reviewedQueue: ReviewedCandidate[] = [];
  for (let index = 0; index < request.enumeratedQueue.length; index++) {
    const candidate = request.enumeratedQueue[index];
    const review = request.reviews[index];
    if (review.classification === "DIRECTLY_APPLICABLE") {
      if (review.supportMode !== "EXPLICIT_SITUATION_TO_EVIDENCE" || !review.situationCitation) {
        errors.push(`direct applicability requires explicit exact situation support: ${review.citationKey}`);
      } else if (!exactSituationCitation(review.situationCitation, request.frozenSituation)) {
        errors.push(`situation support is outside the frozen situation: ${review.citationKey}`);
      }
    } else if (review.supportMode === "THEMATIC_SIMILARITY" || review.supportMode === "INFERRED") {
      errors.push(`thematic or inferred applicability is not allowed: ${review.citationKey}`);
    }
    reviewedQueue.push({
      ...candidate,
      classification: review.classification,
      situationCitation: review.situationCitation,
    });
  }
  if (errors.length) return {
    status: "BLOCKED", writerCallAllowed: false, persistCopy: false,
    nextStep: "FIX_APPLICABILITY_RECORD", reviewedQueue: [], directlyApplicable: [], errors,
  };
  const directlyApplicable = reviewedQueue.filter((candidate) => candidate.classification === "DIRECTLY_APPLICABLE");
  return directlyApplicable.length
    ? {
      status: "COMPLETE_REVIEWED_QUEUE", writerCallAllowed: false, persistCopy: false,
      nextStep: "HUMAN_SELECT_DIRECT_CANDIDATE_THEN_RUN_APPROVAL_STACK",
      reviewedQueue, directlyApplicable, errors: [],
    }
    : {
      status: "NO_DIRECTLY_APPLICABLE_ALTERNATIVE", writerCallAllowed: false, persistCopy: false,
      nextStep: "TERMINAL_NO_COPY", reviewedQueue, directlyApplicable, errors: [],
    };
}
