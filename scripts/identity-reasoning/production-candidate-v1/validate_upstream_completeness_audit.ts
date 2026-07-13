const ROOT = new URL("../../..", import.meta.url).pathname;
const artifact = (name: string) => `${ROOT}/scripts/identity-reasoning/production-candidate-v1/artifacts/${name}`;
const readJson = async (path: string): Promise<any> => JSON.parse(await Deno.readTextFile(path));
const assert = (condition: unknown, message: string): void => {
  if (!condition) throw new Error(message);
};

const snapshot: any = await readJson(`${ROOT}/supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json`);
const audit: any = await readJson(artifact("production-candidate-v1-upstream-completeness-audit-v1.json"));
const fixtures: any = await readJson(artifact("production-candidate-v1-upstream-completeness-gate-fixtures-v1.json"));

assert(snapshot.sha256 === fixtures.runtime_snapshot_sha256, "runtime snapshot fingerprint mismatch");
assert(audit.source_artifacts.runtime_snapshot.sha256 === snapshot.sha256, "audit runtime snapshot fingerprint mismatch");
assert(audit.results.length === 7, "audit must cover exactly seven input-bound thin cases");
assert(fixtures.expected_results.length === 7, "fixtures must cover exactly seven cases");

const validClasses = new Set(["SECOND_BEAT_SUPPORTED", "ONE_BEAT_COMPLETE", "TOO_THIN", "BLOCKED"]);
const validTypes = new Set(["consequence", "tension", "contrast", "action", "effect"]);
const snapshotById = new Map<string, any>(
  snapshot.cases.map((entry: any): [string, any] => [entry.stable_case_id, entry]),
);
const auditById = new Map<string, any>(
  audit.results.map((entry: any): [string, any] => [entry.stable_case_id, entry]),
);

for (const fixture of fixtures.expected_results) {
  const result = auditById.get(fixture.stable_case_id);
  const snapshotCase = snapshotById.get(fixture.stable_case_id);
  assert(snapshotCase, `case missing from runtime snapshot: ${fixture.stable_case_id}`);
  assert(result, `case missing from audit: ${fixture.stable_case_id}`);
  assert(validClasses.has(result.classification), `invalid classification for ${fixture.stable_case_id}`);
  assert(result.classification === fixture.expected_classification, `unexpected classification for ${fixture.stable_case_id}`);

  if (result.classification === "SECOND_BEAT_SUPPORTED") {
    assert(result.second_beat, `supported second beat missing for ${fixture.stable_case_id}`);
    assert(validTypes.has(result.second_beat.type), `unsupported second-beat type for ${fixture.stable_case_id}`);
    const cited = snapshotCase.candidate_evidence.some((entry: { path: string; claim: string }) =>
      entry.path === result.second_beat.evidence.path && entry.claim === result.second_beat.evidence.claim,
    );
    assert(cited, `second-beat citation is not present in snapshot evidence for ${fixture.stable_case_id}`);
  } else {
    assert(result.second_beat === null, `non-supported result may not carry a second beat: ${fixture.stable_case_id}`);
  }
}

console.log(JSON.stringify({
  passed: true,
  providerCalls: 0,
  cases: audit.results.length,
  totals: audit.totals,
  runtimeSnapshotSha256: snapshot.sha256,
}, null, 2));
