import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "../canonical/fixtures/taurus-horse.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import {
  buildDiversifiedCanonicalLensContext,
  planDiversifiedCanonicalLens,
  validateDiversifiedContext,
} from "./diversified_plan.ts";

const rows = [];
for (const scenario of MATCHED_SCENARIOS) {
  for (const model of [libraSnakeCanonical, taurusHorseCanonical]) {
    const context = buildDiversifiedCanonicalLensContext(model, scenario);
    const reasoning = planDiversifiedCanonicalLens(context);
    const errors = validateDiversifiedContext(context, reasoning);
    rows.push({
      scenarioId: scenario.id,
      identity: model.signPair,
      arena: scenario.arena,
      manifestationKey: context.selected.manifestationKey,
      perception: context.selected.perception,
      observableBehaviors: context.selected.observableBehaviors,
      arenaDetail: context.selected.arenaDetail,
      reasoningRole: reasoning.identitySpecificRole,
      recognition: reasoning.recognition,
      naturalMove: reasoning.naturalMove,
      compatibility: { passed: errors.length === 0, errors },
    });
  }
}
const artifact = {
  developmentOnly: true,
  sampleCount: rows.length,
  mismatches: rows.filter((row) => !row.compatibility.passed).length,
  rows,
};
await Deno.mkdir(new URL("./artifacts/", import.meta.url), { recursive: true });
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-diversified-context-audit.json",
    import.meta.url,
  ),
  `${JSON.stringify(artifact, null, 2)}\n`,
);
const markdown = [
  "# Diversified context audit",
  "",
  `Cases: ${artifact.sampleCount}`,
  `Compatibility mismatches: ${artifact.mismatches}`,
  "",
  "| Scenario | Identity | Arena | Manifestation | Result |",
  "|---|---|---|---|---|",
  ...rows.map((row) =>
    `| ${row.scenarioId} | ${row.identity} | ${row.arena} | ${row.manifestationKey} | ${
      row.compatibility.passed
        ? "PASS"
        : `FAIL: ${row.compatibility.errors.join("; ")}`
    } |`
  ),
  "",
  "Each bundle is selected by identity + arena. No positional or modulo evidence selection is used.",
];
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-diversified-context-audit.md",
    import.meta.url,
  ),
  `${markdown.join("\n")}\n`,
);
console.log(
  `Wrote ${rows.length} context audit rows; mismatches=${artifact.mismatches}.`,
);
