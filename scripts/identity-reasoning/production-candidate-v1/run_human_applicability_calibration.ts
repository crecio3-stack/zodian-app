import { enumerateCanonicalCandidates } from "./canonical_candidate_enumeration.ts";
import { evaluateSituationApplicability } from "./situation_applicability_evaluation.ts";

const root = new URL("../../..", import.meta.url);
const artifacts = new URL("scripts/identity-reasoning/production-candidate-v1/artifacts/", root);
const snapshotPath = new URL("supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json", root);
const auditPath = new URL("production-candidate-v1-upstream-completeness-audit-v1.json", artifacts);
const jsonPath = new URL("production-candidate-v1-human-applicability-calibration-v1.json", artifacts);
const markdownPath = new URL("production-candidate-v1-human-applicability-calibration-v1.md", artifacts);

function assert(value: unknown, message: string): asserts value { if (!value) throw new Error(message); }
function stable(value: unknown): string { return JSON.stringify(value, null, 2) + "\n"; }
type Citation = { path: string; claim: string };
type SnapshotCase = {
  stable_case_id: string;
  identity: string;
  neutral_situation: { situation: string; observableFacts: string[] };
  candidate_evidence: Array<Citation & { source: string }>;
  approved_calibration: { selected_evidence: Citation[] } | null;
};

// These are deliberately blocked rather than promoted: each has a narrow
// literal overlap with the situation, but not a complete direct bridge.
const policyAmbiguities = new Map<string, { citationKey: string; note: string }>([
  [
    "pcv1-unseen-24-taurus-x-horse-rest-open-evening-neutral",
    {
      citationKey: "evidence.observableBehaviors[0]\u0000You maintain momentum over time.",
      note: "A busy day supplies temporal context, but does not directly establish continued momentum during an unplanned evening.",
    },
  ],
  [
    "pcv1-unseen-24-aquarius-x-snake-relationship-shared-plan-changes-neutral",
    {
      citationKey: "relationships.relationshipBlindSpot\u0000You may avoid direct expression after closeness is already possible.",
      note: "Closeness is explicit, but the evidence does not directly connect avoidance of expression to the changed plan.",
    },
  ],
]);

const [snapshot, audit] = await Promise.all([
  Deno.readTextFile(snapshotPath).then((text) => JSON.parse(text) as { cases: SnapshotCase[] }),
  Deno.readTextFile(auditPath).then((text) => JSON.parse(text) as { results: Array<{ stable_case_id: string; plain_insight: string; classification: string }> }),
]);
const byId = new Map(snapshot.cases.map((item) => [item.stable_case_id, item]));
const thinCases = audit.results.filter((item) => item.classification === "TOO_THIN");
assert(thinCases.length === 6, "frozen audit must retain six TOO_THIN cases");

const cases = thinCases.map((auditResult) => {
  const item = byId.get(auditResult.stable_case_id);
  assert(item?.approved_calibration?.selected_evidence[0], `missing rejected citation: ${auditResult.stable_case_id}`);
  const enumerationInput = {
    stableCaseId: auditResult.stable_case_id,
    situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE" as const,
    candidateEvidence: item.candidate_evidence,
    excludedCitations: [item.approved_calibration.selected_evidence[0]],
  };
  const enumeration = enumerateCanonicalCandidates(enumerationInput);
  assert(enumeration.status === "ENUMERATED", `enumeration unavailable: ${auditResult.stable_case_id}`);
  const ambiguity = policyAmbiguities.get(auditResult.stable_case_id);
  const reviews = enumeration.candidates.map((candidate) =>
    candidate.citationKey === ambiguity?.citationKey
      ? {
        citationKey: candidate.citationKey,
        classification: "BLOCKED" as const,
        blockedReason: "MISSING_EXACT_SUPPORT" as const,
      }
      : { citationKey: candidate.citationKey, classification: "NOT_APPLICABLE" as const }
  );
  const evaluation = evaluateSituationApplicability({
    enumerationInput,
    enumeratedQueue: enumeration.candidates,
    frozenSituation: item.neutral_situation,
    reviews,
  });
  assert(evaluation.status === "NO_DIRECTLY_APPLICABLE_ALTERNATIVE", `unexpected direct alternative: ${auditResult.stable_case_id}`);
  return {
    stable_case_id: auditResult.stable_case_id,
    identity: item.identity,
    frozen_situation: item.neutral_situation,
    classifications: evaluation.reviewedQueue.map((candidate) => ({
      citation_key: candidate.citationKey,
      source_ordinal: candidate.sourceOrdinal,
      evidence: candidate.evidence,
      classification: candidate.classification,
      blocked_reason: candidate.classification === "BLOCKED" ? "MISSING_EXACT_SUPPORT" : null,
    })),
    direct_alternatives: [],
    result: evaluation.status,
  };
});
const ambiguities = cases.flatMap((item) => {
  const ambiguity = policyAmbiguities.get(item.stable_case_id);
  return ambiguity
    ? [{
      stable_case_id: item.stable_case_id,
      ...ambiguity,
      displayCitation: ambiguity.citationKey.replace("\u0000", " — "),
    }]
    : [];
});
const calibration = {
  developmentOnly: true,
  status: "FROZEN_PROVIDER_FREE_HUMAN_APPLICABILITY_CALIBRATION",
  providerCalls: 0,
  writerCalls: 0,
  copyPersistenceCalls: 0,
  policy: "DIRECTLY_APPLICABLE requires an exact frozen-situation citation and an explicit complete bridge; broad behavioral resemblance is NOT_APPLICABLE.",
  totals: {
    cases: cases.length,
    directlyApplicable: 0,
    notApplicable: cases.flatMap((item) => item.classifications).filter((item) => item.classification === "NOT_APPLICABLE").length,
    blocked: cases.flatMap((item) => item.classifications).filter((item) => item.classification === "BLOCKED").length,
  },
  cases_with_direct_alternatives: [],
  cases_with_no_direct_alternatives: cases.map((item) => item.stable_case_id),
  ambiguous_candidates_requiring_policy_clarification: ambiguities,
  cases,
};
await Deno.writeTextFile(jsonPath, stable(calibration));
const markdown = [
  "# Production Candidate v1 — Human Applicability Calibration v1",
  "",
  "**Result:** No frozen TOO_THIN case has a directly applicable replacement under the current exact-bridge policy.",
  "",
  `- Cases reviewed: ${calibration.totals.cases}`,
  `- Direct alternatives: ${calibration.totals.directlyApplicable}`,
  `- Not applicable: ${calibration.totals.notApplicable}`,
  `- Blocked as policy ambiguities: ${calibration.totals.blocked}`,
  "- Provider, writer, and copy-persistence calls: 0",
  "",
  "## No direct alternatives",
  "",
  ...calibration.cases_with_no_direct_alternatives.map((id) => `- \`${id}\``),
  "",
  "## Policy ambiguities",
  "",
  ...ambiguities.flatMap((item) => [`- \`${item.stable_case_id}\` — \`${item.displayCitation}\`: ${item.note}`]),
  "",
  "All remaining candidates are recorded in the JSON artifact with exact citations and source ordinals. No candidate was selected, rewritten, or sent to Completeness Gate or the writer.",
].join("\n") + "\n";
await Deno.writeTextFile(markdownPath, markdown);
console.log(JSON.stringify(calibration, null, 2));
