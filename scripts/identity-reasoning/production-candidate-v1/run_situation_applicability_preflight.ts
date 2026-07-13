import { enumerateCanonicalCandidates } from "./canonical_candidate_enumeration.ts";

const root = new URL("../../..", import.meta.url);
const artifacts = new URL("scripts/identity-reasoning/production-candidate-v1/artifacts/", root);
const snapshotPath = new URL("supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json", root);
const auditPath = new URL("production-candidate-v1-upstream-completeness-audit-v1.json", artifacts);
const preflightPath = new URL("production-candidate-v1-situation-applicability-preflight-v1.json", artifacts);
function assert(value: unknown, message: string): asserts value { if (!value) throw new Error(message); }
function stable(value: unknown): string { return JSON.stringify(value, null, 2) + "\n"; }
type Citation = { path: string; claim: string };
type SnapshotCase = { stable_case_id: string; candidate_evidence: Array<Citation & { source: string }>; approved_calibration: { selected_evidence: Citation[] } | null };
const [snapshot, audit] = await Promise.all([
  Deno.readTextFile(snapshotPath).then((text) => JSON.parse(text) as { cases: SnapshotCase[] }),
  Deno.readTextFile(auditPath).then((text) => JSON.parse(text) as { results: Array<{ stable_case_id: string; classification: string }> }),
]);
const byId = new Map(snapshot.cases.map((item) => [item.stable_case_id, item]));
const thinCases = audit.results.filter((item) => item.classification === "TOO_THIN");
assert(thinCases.length === 6, "frozen audit must retain six TOO_THIN cases");
const queues = thinCases.map((auditResult) => {
  const item = byId.get(auditResult.stable_case_id);
  assert(item?.approved_calibration?.selected_evidence[0], `missing rejected citation: ${auditResult.stable_case_id}`);
  const enumeration = enumerateCanonicalCandidates({ stableCaseId: auditResult.stable_case_id, situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE", candidateEvidence: item.candidate_evidence, excludedCitations: [item.approved_calibration.selected_evidence[0]] });
  assert(enumeration.status === "ENUMERATED", `queue must be available: ${auditResult.stable_case_id}`);
  return { stable_case_id: auditResult.stable_case_id, candidates_requiring_applicability_review: enumeration.candidates.length, frozen_source_order_preserved: enumeration.candidates.every((candidate, index) => index === 0 || enumeration.candidates[index - 1].sourceOrdinal < candidate.sourceOrdinal) };
});
const preflight = { passed: true, developmentOnly: true, providerCalls: 0, writerCalls: 0, copyPersistenceCalls: 0, frozenTooThinCases: queues.length, firstValidAutoSelection: false, creativeRanking: false, synthesisOrInference: false, applicabilityJudgmentsRecorded: false, queues };
await Deno.writeTextFile(preflightPath, stable(preflight));
console.log(JSON.stringify(preflight, null, 2));
