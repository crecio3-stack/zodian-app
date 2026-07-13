import { enumerateCanonicalCandidates } from "./canonical_candidate_enumeration.ts";

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

const first = { path: "evidence.observableBehaviors[0]", claim: "You check the details before deciding.", source: "canonical_identity" };
const nonBehavior = { path: "decision.defaultProcess", claim: "A process description.", source: "canonical_domain" };
const second = { path: "pressure.visibleBehaviors[0]", claim: "You wait before answering.", source: "canonical_domain" };
const duplicateFirst = { path: "growth.groundingBehaviors[0]", claim: "You check the details before deciding.", source: "canonical_domain" };

Deno.test("enumeration is complete over remaining behavior-bearing evidence in frozen source order", () => {
  const result = enumerateCanonicalCandidates({
    stableCaseId: "provider-free-enumeration-fixture",
    situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE",
    candidateEvidence: [first, nonBehavior, duplicateFirst, second],
    excludedCitations: [first],
  });
  assert(result.status === "ENUMERATED", "remaining behavior-bearing evidence should enumerate");
  assert(result.candidates.length === 1, "non-behavior source and excluded citation must not be surfaced");
  assert(result.candidates[0].sourceOrdinal === 3, "source order must remain visible without ranking");
  assert(result.candidates[0].evidence === second, "candidate must retain the exact input citation object");
  assert(!result.writerCallAllowed && !result.persistCopy, "enumeration must stay upstream-only");
});

Deno.test("duplicate canonical claims of rejected evidence are not distinct alternatives", () => {
  const result = enumerateCanonicalCandidates({
    stableCaseId: "provider-free-enumeration-fixture",
    situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE",
    candidateEvidence: [first, duplicateFirst, second],
    excludedCitations: [first],
  });
  assert(result.candidates.length === 1 && result.candidates[0].evidence === second, "duplicate claim under another path must remain excluded");
});

Deno.test("enumeration fails closed for an unknown exclusion and never synthesizes a proposition", () => {
  const result = enumerateCanonicalCandidates({
    stableCaseId: "provider-free-enumeration-fixture",
    situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE",
    candidateEvidence: [first, second],
    excludedCitations: [{ path: "evidence.observableBehaviors[99]", claim: "Not present." }],
  });
  assert(result.status === "BLOCKED", "unknown exclusions must not silently alter the set");
  assert(result.candidates.length === 0, "blocked enumeration must surface no candidate propositions");
});

Deno.test("all excluded behavior-bearing citations produce EMPTY rather than a retry", () => {
  const result = enumerateCanonicalCandidates({
    stableCaseId: "provider-free-enumeration-fixture",
    situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE",
    candidateEvidence: [first, second],
    excludedCitations: [first, second],
  });
  assert(result.status === "EMPTY", "no remaining candidate must be explicit");
  assert(!result.writerCallAllowed && !result.persistCopy, "empty enumeration cannot create copy");
});
