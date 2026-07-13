import {
  routeInsightReselection,
  type InsightReselectionRequest,
} from "./insight_reselection_contract.ts";

const root = new URL("../../..", import.meta.url);
const artifacts = new URL("scripts/identity-reasoning/production-candidate-v1/artifacts/", root);
const snapshotPath = new URL("supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json", root);
const auditPath = new URL("production-candidate-v1-upstream-completeness-audit-v1.json", artifacts);
const preflightPath = new URL("production-candidate-v1-insight-reselection-preflight-v1.json", artifacts);

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}
function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}

type Citation = { path: string; claim: string };
type SnapshotCase = { stable_case_id: string; candidate_evidence: Array<Citation & { source: string }>; approved_calibration: { selected_evidence: Citation[] } | null };
type AuditResult = { stable_case_id: string; plain_insight: string; classification: string };

const [snapshot, audit] = await Promise.all([
  Deno.readTextFile(snapshotPath).then((text) => JSON.parse(text) as { cases: SnapshotCase[] }),
  Deno.readTextFile(auditPath).then((text) => JSON.parse(text) as { results: AuditResult[] }),
]);
const snapshotById = new Map(snapshot.cases.map((item) => [item.stable_case_id, item]));
const thinCases = audit.results.filter((item) => item.classification === "TOO_THIN");
assert(thinCases.length === 6, "frozen audit must retain six TOO_THIN cases");

const results = thinCases.map((auditResult) => {
  const item = snapshotById.get(auditResult.stable_case_id);
  assert(item?.approved_calibration?.selected_evidence[0], `missing rejected insight evidence: ${auditResult.stable_case_id}`);
  const request: InsightReselectionRequest = {
    stableCaseId: auditResult.stable_case_id,
    rejectedCandidateVersion: "pcv1-upstream-completeness-v1",
    nextCandidateVersion: "pcv1-insight-reselection-v1",
    tooThinConfirmed: true,
    attemptState: "NOT_STARTED",
    rejectedInsights: [{
      propositionKey: `${item.approved_calibration.selected_evidence[0].path}\u0000${item.approved_calibration.selected_evidence[0].claim}`,
      proposition: auditResult.plain_insight,
      evidence: item.approved_calibration.selected_evidence[0],
    }],
    candidateEvidence: item.candidate_evidence,
  };
  const result = routeInsightReselection(request);
  assert(result.status === "READY_FOR_NEW_SUPPORTED_SELECTION", `reselection must start from remaining evidence: ${auditResult.stable_case_id}`);
  assert(!result.writerCallAllowed && !result.persistCopy, `reselection must stay no-copy: ${auditResult.stable_case_id}`);
  return {
    stable_case_id: auditResult.stable_case_id,
    status: result.status,
    remaining_canonical_evidence: result.remainingEvidence.length,
    writer_call_allowed: result.writerCallAllowed,
    persist_copy: result.persistCopy,
  };
});

const preflight = {
  passed: true,
  developmentOnly: true,
  providerCalls: 0,
  writerCalls: 0,
  copyPersistenceCalls: 0,
  frozenTooThinCases: results.length,
  recycledPropositionsAllowed: false,
  rejectedEvidenceAllowed: false,
  automaticRetryAllowed: false,
  autonomousSecondBeatGeneration: false,
  results,
};
await Deno.writeTextFile(preflightPath, stable(preflight));
console.log(JSON.stringify(preflight, null, 2));
