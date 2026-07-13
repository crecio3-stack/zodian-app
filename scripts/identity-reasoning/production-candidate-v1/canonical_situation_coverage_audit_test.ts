const artifact = new URL("artifacts/production-candidate-v1-canonical-situation-coverage-audit-v1.json", import.meta.url);
function assert(value: unknown, message: string): asserts value { if (!value) throw new Error(message); }
Deno.test("coverage audit preserves known gaps without inventing completeness", async () => {
  const audit = JSON.parse(await Deno.readTextFile(artifact));
  assert(audit.status === "FROZEN_PROVIDER_FREE_CANONICAL_SITUATION_COVERAGE_AUDIT", "audit must remain frozen provider-free");
  assert(audit.providerCalls === 0 && audit.writerCalls === 0 && audit.copyPersistenceCalls === 0, "audit must not generate or persist");
  assert(audit.totals.cases === 24 && audit.totals.direct_situation_coverage === 19, "direct coverage baseline changed");
  assert(audit.totals.complete_situation_coverage === 7, "complete coverage baseline changed");
  assert(audit.totals.thin_coverage === 6 && audit.totals.no_coverage === 5, "known coverage failures changed");
  assert(audit.totals.direct_only_unassessed === 6, "unassessed cases must not be misreported as complete");
});
