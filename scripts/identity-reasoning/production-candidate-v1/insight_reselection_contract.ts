/**
 * Provider-free contract for one bounded attempt to replace a TOO_THIN insight.
 * It enumerates remaining canonical evidence but never chooses prose, creates a
 * second beat, calls a provider, or makes a writer-eligible decision.
 */

import {
  enumerateCanonicalCandidates,
} from "./canonical_candidate_enumeration.ts";
import type { CandidateEvidence, EvidenceCitation } from "./upstream_completeness_gate.ts";

export type ReselectionStatus =
  | "READY_FOR_NEW_SUPPORTED_SELECTION"
  | "READY_FOR_COMPLETENESS_GATE"
  | "EXHAUSTED_NO_ALTERNATE_SUPPORTED_INSIGHT"
  | "BLOCKED";

export type ReselectionAttemptState = "NOT_STARTED" | "CONSUMED";

export type RejectedInsight = {
  propositionKey: string;
  proposition: string;
  evidence: EvidenceCitation;
};

export type ProposedReplacement = {
  propositionKey: string;
  proposition: string;
  evidence: EvidenceCitation;
  evidencePassed: boolean;
  applicabilityPassed: boolean;
  personFirstPassed: boolean;
  humanLanguagePassed: boolean;
  approvalStatus: "APPROVED_FOR_COMPLETENESS" | "REJECTED";
};

export type InsightReselectionRequest = {
  stableCaseId: string;
  rejectedCandidateVersion: string;
  nextCandidateVersion: string;
  tooThinConfirmed: boolean;
  attemptState: ReselectionAttemptState;
  rejectedInsights: RejectedInsight[];
  candidateEvidence: CandidateEvidence[];
  proposedReplacement?: ProposedReplacement;
};

export type InsightReselectionResult = {
  status: ReselectionStatus;
  writerCallAllowed: false;
  persistCopy: false;
  nextStep:
    | "RECORD_ONE_NEW_SELECTION_ATTEMPT"
    | "SEND_APPROVED_REPLACEMENT_TO_COMPLETENESS_GATE"
    | "TERMINAL_NO_COPY"
    | "FIX_CONTRACT_INPUT";
  remainingEvidence: CandidateEvidence[];
  errors: string[];
};

function normalize(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim();
}

function sameCitation(left: EvidenceCitation, right: EvidenceCitation): boolean {
  return left.path === right.path && left.claim === right.claim;
}

function citedIn(citation: EvidenceCitation, evidence: CandidateEvidence[]): boolean {
  return evidence.some((item) => sameCitation(item, citation));
}

function invalidInput(
  errors: string[],
  evidence: CandidateEvidence[],
): InsightReselectionResult {
  return {
    status: "BLOCKED",
    writerCallAllowed: false,
    persistCopy: false,
    nextStep: "FIX_CONTRACT_INPUT",
    remainingEvidence: evidence,
    errors,
  };
}

/**
 * A completed selection attempt may never retry itself. A new attempt requires
 * a distinct candidate version and must return through Completeness Gate v1.
 */
export function routeInsightReselection(
  request: InsightReselectionRequest,
): InsightReselectionResult {
  const enumeration = enumerateCanonicalCandidates({
    stableCaseId: request.stableCaseId,
    situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE",
    candidateEvidence: request.candidateEvidence,
    excludedCitations: request.rejectedInsights.map((item) => item.evidence),
  });
  const remaining = enumeration.candidates.map((candidate) => candidate.evidence);
  const errors: string[] = [];
  if (enumeration.status === "BLOCKED") errors.push(...enumeration.errors);
  if (!request.tooThinConfirmed) errors.push("reselection is available only after TOO_THIN");
  if (!request.stableCaseId.trim()) errors.push("stable case id is required");
  if (!request.rejectedCandidateVersion.trim() || !request.nextCandidateVersion.trim()) {
    errors.push("rejected and next candidate versions are required");
  }
  if (request.rejectedCandidateVersion === request.nextCandidateVersion) {
    errors.push("reselection requires a new candidate version");
  }
  if (request.rejectedInsights.length === 0) {
    errors.push("the rejected TOO_THIN insight must be recorded");
  }
  for (const rejected of request.rejectedInsights) {
    if (
      !rejected.propositionKey.trim() ||
      !rejected.proposition.trim() ||
      !citedIn(rejected.evidence, request.candidateEvidence)
    ) {
      errors.push("each rejected insight requires a proposition key and exact canonical citation");
    }
  }
  if (errors.length) return invalidInput(errors, remaining);

  if (request.attemptState === "CONSUMED" && !request.proposedReplacement) {
    return {
      status: "EXHAUSTED_NO_ALTERNATE_SUPPORTED_INSIGHT",
      writerCallAllowed: false,
      persistCopy: false,
      nextStep: "TERMINAL_NO_COPY",
      remainingEvidence: remaining,
      errors: [],
    };
  }

  if (!request.proposedReplacement) {
    return {
      status: "READY_FOR_NEW_SUPPORTED_SELECTION",
      writerCallAllowed: false,
      persistCopy: false,
      nextStep: "RECORD_ONE_NEW_SELECTION_ATTEMPT",
      remainingEvidence: remaining,
      errors: [],
    };
  }

  const replacement = request.proposedReplacement;
  if (!replacement.propositionKey.trim()) errors.push("replacement proposition key is required");
  if (!replacement.proposition.trim()) errors.push("replacement proposition is required");
  if (!citedIn(replacement.evidence, remaining)) {
    errors.push("replacement must cite remaining canonical evidence, not rejected evidence");
  }
  const rejectedPropositions = new Set(request.rejectedInsights.map((item) => normalize(item.proposition)));
  const rejectedPropositionKeys = new Set(request.rejectedInsights.map((item) => item.propositionKey));
  if (rejectedPropositions.has(normalize(replacement.proposition))) {
    errors.push("replacement must not recycle a rejected proposition");
  }
  if (rejectedPropositionKeys.has(replacement.propositionKey)) {
    errors.push("replacement must not recycle a rejected proposition key");
  }
  if (!replacement.evidencePassed) errors.push("replacement did not pass evidence");
  if (!replacement.applicabilityPassed) errors.push("replacement did not pass applicability");
  if (!replacement.personFirstPassed) errors.push("replacement did not pass person-first");
  if (!replacement.humanLanguagePassed) errors.push("replacement did not pass human-language");
  if (replacement.approvalStatus !== "APPROVED_FOR_COMPLETENESS") {
    errors.push("replacement is not approved for completeness review");
  }
  if (errors.length) return invalidInput(errors, remaining);

  return {
    status: "READY_FOR_COMPLETENESS_GATE",
    writerCallAllowed: false,
    persistCopy: false,
    nextStep: "SEND_APPROVED_REPLACEMENT_TO_COMPLETENESS_GATE",
    remainingEvidence: remaining,
    errors: [],
  };
}
