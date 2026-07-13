import {
  routeUpstreamCompleteness,
  type CompletenessGateInput,
  type CompletenessOutcome,
  type EvidenceCitation,
} from "./upstream_completeness_gate.ts";

const root = new URL("../../..", import.meta.url);
const artifacts = new URL("scripts/identity-reasoning/production-candidate-v1/artifacts/", root);
const snapshotPath = new URL(
  "supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json",
  root,
);
const auditPath = new URL("production-candidate-v1-upstream-completeness-audit-v1.json", artifacts);
const fixturesPath = new URL("production-candidate-v1-upstream-completeness-gate-fixtures-v1.json", artifacts);
const preflightPath = new URL("production-candidate-v1-upstream-completeness-gate-preflight-v1.json", artifacts);

function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

type SnapshotCase = {
  stable_case_id: string;
  candidate_evidence: Array<EvidenceCitation & { source: string }>;
  approved_calibration: null | { selected_evidence: EvidenceCitation[] };
};
type AuditResult = {
  stable_case_id: string;
  plain_insight: string;
  classification: CompletenessOutcome;
  second_beat: null | {
    type: "consequence" | "tension" | "contrast" | "action" | "effect";
    evidence: EvidenceCitation;
  };
};
type Fixtures = {
  runtime_snapshot_sha256: string;
  expected_results: Array<{
    stable_case_id: string;
    expected_classification: CompletenessOutcome;
  }>;
};
type PreflightResult = {
  stable_case_id: string;
  classification: CompletenessOutcome;
  writer_call_allowed: boolean;
  persist_copy: boolean;
  next_step: string;
};

const [snapshot, audit, fixtures] = await Promise.all([
  Deno.readTextFile(snapshotPath).then((text) => JSON.parse(text) as {
    sha256: string;
    cases: SnapshotCase[];
  }),
  Deno.readTextFile(auditPath).then((text) => JSON.parse(text) as {
    results: AuditResult[];
  }),
  Deno.readTextFile(fixturesPath).then((text) => JSON.parse(text) as Fixtures),
]);

assert(snapshot.sha256 === fixtures.runtime_snapshot_sha256, "runtime snapshot fingerprint mismatch");
assert(audit.results.length === 7, "frozen audit must retain seven cases");
assert(fixtures.expected_results.length === 7, "frozen fixture count must remain seven");

const snapshotById = new Map<string, SnapshotCase>(
  snapshot.cases.map((entry) => [entry.stable_case_id, entry]),
);
const expectedById = new Map<string, Fixtures["expected_results"][number]>(
  fixtures.expected_results.map((entry) => [entry.stable_case_id, entry]),
);

const results: PreflightResult[] = audit.results.map((auditResult) => {
  const item = snapshotById.get(auditResult.stable_case_id);
  const expected = expectedById.get(auditResult.stable_case_id);
  assert(item, `snapshot case missing: ${auditResult.stable_case_id}`);
  assert(expected, `fixture case missing: ${auditResult.stable_case_id}`);
  assert(item.approved_calibration, `audit case requires a frozen approved primary beat: ${auditResult.stable_case_id}`);
  const primaryEvidence = item.approved_calibration.selected_evidence[0];
  assert(primaryEvidence, `primary evidence missing: ${auditResult.stable_case_id}`);

  const input: CompletenessGateInput = {
    stableCaseId: auditResult.stable_case_id,
    proposedOutcome: auditResult.classification,
    primaryBeat: {
      proposition: auditResult.plain_insight,
      evidence: primaryEvidence,
      evidencePassed: true,
      applicabilityPassed: true,
      personFirstPassed: true,
      humanLanguagePassed: true,
      approvalStatus: "APPROVED",
    },
    candidateEvidence: item.candidate_evidence,
  };
  if (auditResult.classification === "SECOND_BEAT_SUPPORTED") {
    const secondBeat = auditResult.second_beat;
    assert(secondBeat, `supported second beat missing: ${auditResult.stable_case_id}`);
    input.secondBeat = {
      type: secondBeat.type,
      proposition: secondBeat.evidence.claim,
      evidence: secondBeat.evidence,
      support: "DIRECTLY_CITED",
      approvalStatus: "APPROVED",
    };
  }
  const gate = routeUpstreamCompleteness(input);
  assert(gate.classification === expected.expected_classification, `classification mismatch: ${auditResult.stable_case_id}`);
  if (gate.classification === "TOO_THIN") {
    assert(!gate.route.writerCallAllowed, `TOO_THIN writer call must be impossible: ${auditResult.stable_case_id}`);
    assert(!gate.route.persistCopy, `TOO_THIN must not persist copy: ${auditResult.stable_case_id}`);
  }
  if (auditResult.classification === "SECOND_BEAT_SUPPORTED") {
    assert(
      input.secondBeat?.evidence.path === "evidence.observableBehaviors[4]" &&
        input.secondBeat.evidence.claim === "You let people guess instead of naming it.",
      "Libra × Snake contrast citation changed",
    );
  }
  return {
    stable_case_id: auditResult.stable_case_id,
    classification: gate.classification,
    writer_call_allowed: gate.route.writerCallAllowed,
    persist_copy: gate.route.persistCopy,
    next_step: gate.route.nextStep,
  };
});

const totals = Object.fromEntries(
  ["SECOND_BEAT_SUPPORTED", "ONE_BEAT_COMPLETE", "TOO_THIN", "BLOCKED"].map((classification) => [
    classification,
    results.filter((result) => result.classification === classification).length,
  ]),
);
const tooThin = results.filter((result) => result.classification === "TOO_THIN");
const preflight = {
  passed: true,
  developmentOnly: true,
  providerCalls: 0,
  writerCalls: 0,
  copyPersistenceCalls: 0,
  frozenFixtureCases: results.length,
  totals,
  tooThinWriterCalls: tooThin.filter((result) => result.writer_call_allowed).length,
  tooThinCopyPersistenceCalls: tooThin.filter((result) => result.persist_copy).length,
  tooThinWriterCallImpossible: tooThin.every((result) => !result.writer_call_allowed),
  libraSnakeContrastCitation: {
    path: "evidence.observableBehaviors[4]",
    claim: "You let people guess instead of naming it.",
  },
  scope: {
    v4WriterModified: false,
    existingWriterInputsModified: false,
    frozenCohortModified: false,
    savedCandidateRowsModified: false,
    productionConfigurationModified: false,
  },
  results,
};

await Deno.writeTextFile(preflightPath, stable(preflight));
console.log(JSON.stringify(preflight, null, 2));
