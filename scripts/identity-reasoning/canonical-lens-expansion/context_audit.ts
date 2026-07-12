import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import { expansionIdentities } from "./identities.ts";
import {
  buildExpansionContext,
  buildExpansionPlan,
  expansionManifestations,
  validateExpansionContext,
} from "./manifestations.ts";

const rows = [];
for (const identity of expansionIdentities) {
  const validation = validateCanonicalIdentity(identity);
  if (!validation.valid) {
    throw new Error(
      `${identity.signPair} fixture invalid: ${validation.errors.join("; ")}`,
    );
  }
  for (const scenario of MATCHED_SCENARIOS) {
    const context = buildExpansionContext(identity, scenario);
    const plan = buildExpansionPlan(context);
    const errors = validateExpansionContext(context, plan);
    rows.push({
      scenarioId: scenario.id,
      identity: identity.signPair,
      arena: scenario.arena,
      manifestationKey: context.selected.manifestationKey,
      perception: context.selected.perception,
      observableBehaviors: context.selected.observableBehaviors,
      arenaDetail: context.selected.arenaDetail,
      role: plan.identitySpecificRole,
      recognition: plan.recognition,
      naturalMove: plan.naturalMove,
      compatibility: { passed: errors.length === 0, errors },
    });
  }
}
const expected = expansionIdentities.length * MATCHED_SCENARIOS.length;
const artifact = {
  developmentOnly: true,
  expectedCases: expected,
  sampleCount: rows.length,
  mismatches: rows.filter((row) => !row.compatibility.passed).length,
  missingBundles: expected - Object.keys(expansionManifestations).length,
  rows,
};
await Deno.mkdir(new URL("./artifacts/", import.meta.url), { recursive: true });
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-context-audit.json",
    import.meta.url,
  ),
  `${JSON.stringify(artifact, null, 2)}\n`,
);
const markdown = [
  "# Canonical Lens expansion context audit",
  "",
  `Expected cases: ${artifact.expectedCases}`,
  `Contexts: ${artifact.sampleCount}`,
  `Compatibility mismatches: ${artifact.mismatches}`,
  `Missing bundles: ${artifact.missingBundles}`,
  "",
  "| Identity | Scenario | Arena | Manifestation | Result |",
  "|---|---|---|---|---|",
  ...rows.map((row) =>
    `| ${row.identity} | ${row.scenarioId} | ${row.arena} | ${row.manifestationKey} | ${
      row.compatibility.passed
        ? "PASS"
        : `FAIL: ${row.compatibility.errors.join("; ")}`
    } |`
  ),
  "",
  "Selection is explicit identity + arena; no positional, modulo, fallback, or independent field selection is used.",
];
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-context-audit.md",
    import.meta.url,
  ),
  `${markdown.join("\n")}\n`,
);
console.log(
  `Wrote ${rows.length} expansion contexts; mismatches=${artifact.mismatches}; missingBundles=${artifact.missingBundles}.`,
);
