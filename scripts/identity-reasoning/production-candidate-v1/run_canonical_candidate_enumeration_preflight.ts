import { enumerateCanonicalCandidates } from "./canonical_candidate_enumeration.ts";

const root = new URL("../../..", import.meta.url);
const artifacts = new URL("scripts/identity-reasoning/production-candidate-v1/artifacts/", root);
const snapshotPath = new URL("supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json", root);
const auditPath = new URL("production-candidate-v1-upstream-completeness-audit-v1.json", artifacts);
const preflightPath = new URL("production-candidate-v1-canonical-candidate-enumeration-preflight-v1.json", artifacts);

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}
function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}
type Citation = { path: string; claim: string };
type SnapshotCase = { stable_case_id: string; candidate_evidence: Array<Citation & { source: string }>; approved_calibration: { selected_evidence: Citation[] } | null };
type AuditResult = { stable_case_id: string; classification: string };

const [snapshot, audit] = await Promise.all([
  Deno.readTextFile(snapshotPath).then((text) => JSON.parse(text) as { cases: SnapshotCase[] }),
  Deno.readTextFile(auditPath).then((text) => JSON.parse(text) as { results: AuditResult[] }),
]);
const byId = new Map(snapshot.cases.map((item) => [item.stable_case_id, item]));
const thinCases = audit.results.filter((item) => item.classification === "TOO_THIN");
assert(thinCases.length === 6, "frozen audit must retain six TOO_THIN cases");

const results = thinCases.map((auditResult) => {
  const item = byId.get(auditResult.stable_case_id);
  assert(item?.approved_calibration?.selected_evidence[0], `missing rejected citation: ${auditResult.stable_case_id}`);
  const enumeration = enumerateCanonicalCandidates({
    stableCaseId: auditResult.stable_case_id,
    situationEvidenceScope: "FROZEN_SITUATION_RELEVANT_CANONICAL_EVIDENCE",
    candidateEvidence: item.candidate_evidence,
    excludedCitations: [item.approved_calibration.selected_evidence[0]],
  });
  assert(enumeration.status === "ENUMERATED", `remaining eligible evidence must enumerate: ${auditResult.stable_case_id}`);
  assert(!enumeration.writerCallAllowed && !enumeration.persistCopy, `enumeration must stay upstream-only: ${auditResult.stable_case_id}`);
  const sourceOrdinals = enumeration.candidates.map((candidate) => candidate.sourceOrdinal);
  assert(sourceOrdinals.every((ordinal, index) => index === 0 || sourceOrdinals[index - 1] < ordinal), `source order changed: ${auditResult.stable_case_id}`);
  return {
    stable_case_id: auditResult.stable_case_id,
    enumerated_candidates: enumeration.candidates.length,
    exact_citation_keys: enumeration.candidates.map((candidate) => candidate.citationKey),
    writer_call_allowed: enumeration.writerCallAllowed,
    persist_copy: enumeration.persistCopy,
  };
});
const preflight = {
  passed: true,
  developmentOnly: true,
  providerCalls: 0,
  writerCalls: 0,
  copyPersistenceCalls: 0,
  frozenTooThinCases: results.length,
  ordering: "frozen_candidate_evidence_source_order",
  creativeRanking: false,
  synthesisOrParaphrase: false,
  autonomousSecondBeatGeneration: false,
  results,
};
await Deno.writeTextFile(preflightPath, stable(preflight));
console.log(JSON.stringify(preflight, null, 2));
