const root = new URL("../../..", import.meta.url);
const artifacts = new URL("scripts/identity-reasoning/production-candidate-v1/artifacts/", root);
const snapshotPath = new URL("supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json", root);
const thinPath = new URL("production-candidate-v1-human-applicability-calibration-v1.json", artifacts);
const completenessPath = new URL("production-candidate-v1-upstream-completeness-audit-v1.json", artifacts);
const outputJson = new URL("production-candidate-v1-canonical-situation-coverage-audit-v1.json", artifacts);
const outputMd = new URL("production-candidate-v1-canonical-situation-coverage-audit-v1.md", artifacts);
function assert(value: unknown, message: string): asserts value { if (!value) throw new Error(message); }
function stable(value: unknown): string { return JSON.stringify(value, null, 2) + "\n"; }
type Citation = { path: string; claim: string };
type Case = { stable_case_id: string; domain: string; candidate_evidence: Array<Citation & { source: string }>; approved_calibration: null | { plain_insight: string; plain_action: string | null; selected_evidence: Citation[] } };
const [snapshot, thinCalibration, completeness] = await Promise.all([
  Deno.readTextFile(snapshotPath).then((text) => JSON.parse(text) as { cases: Case[] }),
  Deno.readTextFile(thinPath).then(JSON.parse),
  Deno.readTextFile(completenessPath).then(JSON.parse),
]);
const thinIds = new Set(thinCalibration.cases_with_no_direct_alternatives as string[]);
assert(thinIds.size === 6, "six frozen thin cases required");
const libraId = "pcv1-unseen-24-libra-x-snake-relationship-shared-plan-changes-neutral";
const libra = completeness.results.find((item: any) => item.stable_case_id === libraId);
assert(libra?.classification === "SECOND_BEAT_SUPPORTED", "Libra × Snake must retain supported contrast");
const cases = snapshot.cases.map((item) => {
  let coverage: "COMPLETE" | "THIN" | "NO_COVERAGE" | "DIRECT_ONLY_UNASSESSED";
  let evidenceBasis: string;
  if (!item.approved_calibration) {
    coverage = "NO_COVERAGE";
    evidenceBasis = "No human-approved situation-specific primary insight exists.";
  } else if (thinIds.has(item.stable_case_id)) {
    coverage = "THIN";
    evidenceBasis = "Approved primary insight exists, but human applicability calibration found no directly applicable alternative after it was classified TOO_THIN.";
  } else if (item.stable_case_id === libraId) {
    coverage = "COMPLETE";
    evidenceBasis = "A separately cited approved contrast is available: evidence.observableBehaviors[4].";
  } else if (item.approved_calibration.plain_action !== null) {
    coverage = "COMPLETE";
    evidenceBasis = "Approved primary insight plus separately approved concrete action.";
  } else {
    coverage = "DIRECT_ONLY_UNASSESSED";
    evidenceBasis = "Approved direct primary insight exists; completeness has not been human-audited for this case.";
  }
  return { stable_case_id: item.stable_case_id, arena: item.domain, coverage, selected_evidence: item.approved_calibration?.selected_evidence ?? [], evidenceBasis };
});
const count = (coverage: string) => cases.filter((item) => item.coverage === coverage).length;
const arenas = [...new Set(cases.map((item) => item.arena))].sort().map((arena) => ({
  arena,
  direct_situation_coverage: cases.filter((item) => item.arena === arena && item.coverage !== "NO_COVERAGE").length,
  complete_situation_coverage: cases.filter((item) => item.arena === arena && item.coverage === "COMPLETE").length,
  thin_coverage: cases.filter((item) => item.arena === arena && item.coverage === "THIN").length,
  no_coverage: cases.filter((item) => item.arena === arena && item.coverage === "NO_COVERAGE").length,
  direct_only_unassessed: cases.filter((item) => item.arena === arena && item.coverage === "DIRECT_ONLY_UNASSESSED").length,
}));
const sourceCounts = new Map<string, number>();
for (const item of cases) for (const citation of item.selected_evidence) sourceCounts.set(citation.path, (sourceCounts.get(citation.path) ?? 0) + 1);
const audit = {
  developmentOnly: true, status: "FROZEN_PROVIDER_FREE_CANONICAL_SITUATION_COVERAGE_AUDIT",
  providerCalls: 0, writerCalls: 0, copyPersistenceCalls: 0,
  scope: "Frozen 24-case representative identity × situation matrix. This audit measures only existing human-approved, completeness, and applicability evidence; it does not infer missing semantic judgments.",
  totals: { cases: cases.length, direct_situation_coverage: cases.length - count("NO_COVERAGE"), complete_situation_coverage: count("COMPLETE"), thin_coverage: count("THIN"), no_coverage: count("NO_COVERAGE"), direct_only_unassessed: count("DIRECT_ONLY_UNASSESSED") },
  coverage_by_arena: arenas,
  coverage_by_canonical_field: [...sourceCounts.entries()].sort(([a], [b]) => a.localeCompare(b)).map(([path, cases]) => ({ path, cases })),
  cases,
};
assert(audit.totals.cases === 24, "representative matrix must contain 24 cases");
assert(audit.totals.thin_coverage === 6 && audit.totals.no_coverage === 5, "frozen known gaps changed");
await Deno.writeTextFile(outputJson, stable(audit));
const md = [
  "# Production Candidate v1 — Canonical Situation Coverage Audit v1", "",
  "**Scope:** frozen provider-free 24-case representative matrix. No semantic classification was inferred where no human completeness review exists.", "",
  "| Measure | Cases |", "|---|---:|",
  `| Direct situation coverage | ${audit.totals.direct_situation_coverage} |`,
  `| Complete situation coverage | ${audit.totals.complete_situation_coverage} |`,
  `| Thin coverage | ${audit.totals.thin_coverage} |`,
  `| No coverage | ${audit.totals.no_coverage} |`,
  `| Direct-only, completeness unassessed | ${audit.totals.direct_only_unassessed} |`, "",
  "## Conclusion", "",
  "The six calibrated thin cases are confirmed canonical coverage failures for their situations: no direct replacement exists under the exact-bridge standard. Five further cases have no approved situation-specific primary insight. The remaining six direct-only cases need human completeness review before this audit can claim product-ready complete coverage. The fix path for confirmed gaps is canonical evidence, not the writer or a looser gate.", "",
  "## Coverage by arena", "", "| Arena | Direct | Complete | Thin | No coverage | Unassessed |", "|---|---:|---:|---:|---:|---:|",
  ...arenas.map((item) => `| ${item.arena} | ${item.direct_situation_coverage} | ${item.complete_situation_coverage} | ${item.thin_coverage} | ${item.no_coverage} | ${item.direct_only_unassessed} |`), "",
  "No provider, writer, or persistence activity occurred.",
].join("\n") + "\n";
await Deno.writeTextFile(outputMd, md);
console.log(JSON.stringify(audit, null, 2));
