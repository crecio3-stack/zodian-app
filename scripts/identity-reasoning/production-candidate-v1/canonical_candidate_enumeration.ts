/**
 * Deterministically exposes every remaining behavior-bearing citation already
 * in a frozen situation's candidate evidence. It never ranks, rewrites, or
 * combines evidence into an insight.
 */

import { isBehaviorBearingCanonicalPath } from "../../../supabase/functions/_shared/production-candidate-v1/producer_validation.ts";
import type { CandidateEvidence, EvidenceCitation } from "./upstream_completeness_gate.ts";

export type CanonicalCandidateEnumerationInput = {
  stableCaseId: string;
  situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE";
  candidateEvidence: CandidateEvidence[];
  excludedCitations: EvidenceCitation[];
};

export type EnumeratedCanonicalCandidate = {
  sourceOrdinal: number;
  citationKey: string;
  evidence: CandidateEvidence;
};

export type CanonicalCandidateEnumerationResult = {
  status: "ENUMERATED" | "EMPTY" | "BLOCKED";
  writerCallAllowed: false;
  persistCopy: false;
  candidates: EnumeratedCanonicalCandidate[];
  errors: string[];
};

function sameCitation(left: EvidenceCitation, right: EvidenceCitation): boolean {
  return left.path === right.path && left.claim === right.claim;
}

function citationKey(citation: EvidenceCitation): string {
  return `${citation.path}\u0000${citation.claim}`;
}

function claimKey(claim: string): string {
  return claim.toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim();
}

/**
 * Source order is the only order: it is the frozen candidate-evidence traversal
 * order, not a creative score, confidence score, or recommendation.
 */
export function enumerateCanonicalCandidates(
  input: CanonicalCandidateEnumerationInput,
): CanonicalCandidateEnumerationResult {
  const errors: string[] = [];
  if (!input.stableCaseId.trim()) errors.push("stable case id is required");
  if (input.situationEvidenceScope !== "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE") {
    errors.push("enumeration requires frozen situation-relevant canonical evidence");
  }
  if (input.candidateEvidence.length === 0) errors.push("candidate evidence is required");
  for (const evidence of input.candidateEvidence) {
    if (!evidence.path.trim() || !evidence.claim.trim()) {
      errors.push("candidate evidence must retain exact nonblank citation fields");
      break;
    }
  }
  for (const excluded of input.excludedCitations) {
    if (!input.candidateEvidence.some((evidence) => sameCitation(evidence, excluded))) {
      errors.push("excluded citation is not present in frozen candidate evidence");
      break;
    }
  }
  if (errors.length) {
    return { status: "BLOCKED", writerCallAllowed: false, persistCopy: false, candidates: [], errors };
  }

  const excludedClaimKeys = new Set(input.excludedCitations.map((citation) => claimKey(citation.claim)));
  const candidates = input.candidateEvidence.flatMap((evidence, sourceOrdinal) => {
    if (!isBehaviorBearingCanonicalPath(evidence.path)) return [];
    if (input.excludedCitations.some((excluded) => sameCitation(evidence, excluded))) return [];
    if (excludedClaimKeys.has(claimKey(evidence.claim))) return [];
    return [{ sourceOrdinal, citationKey: citationKey(evidence), evidence }];
  });
  return {
    status: candidates.length ? "ENUMERATED" : "EMPTY",
    writerCallAllowed: false,
    persistCopy: false,
    candidates,
    errors: [],
  };
}
