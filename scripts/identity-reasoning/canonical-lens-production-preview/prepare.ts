import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import {
  buildCanonicalLibrary,
  loadArchetypeSources,
  sourceFingerprint,
} from "./source.ts";
import {
  buildFocusedContext,
  buildManifestationLibrary,
  buildReasoningPlan,
  validateFocusedContext,
  validateManifestation,
} from "./manifestations.ts";

const models = await buildCanonicalLibrary();
const sources = await loadArchetypeSources();
const sourceSha256 = await sourceFingerprint();
const manifestations = buildManifestationLibrary(models);
const fixtureResults = models.map((model) => ({
  identity: model.signPair,
  ...validateCanonicalIdentity(model),
}));
const manifestationResults = Object.entries(manifestations).map((
  [key, value],
) => ({
  key,
  errors: validateManifestation(key, value),
}));
const countBy = (values: string[]) =>
  Object.entries(values.reduce<Record<string, number>>((counts, value) => {
    counts[value] = (counts[value] ?? 0) + 1;
    return counts;
  }, {})).sort((a, b) => b[1] - a[1]);
const manifestationDiversity = models.map((model) => {
  const bundles = MATCHED_SCENARIOS.map((scenario) =>
    manifestations[`${model.signPair}|${scenario.arena}`]
  );
  const behaviorCounts = countBy(
    bundles.flatMap((bundle) => bundle.observableBehaviors),
  );
  const moveOpeningCounts = countBy(
    bundles.map((bundle) => bundle.naturalMove.split(/\s+/)[0].toLowerCase()),
  );
  const recognitionCounts = countBy(
    bundles.map((bundle) => bundle.recognition),
  );
  return {
    identity: model.signPair,
    repeatedBehaviorsAboveTwo: behaviorCounts.filter(([, count]) => count > 2),
    repeatedMoveOpeningsAboveThree: moveOpeningCounts.filter(([, count]) =>
      count > 3
    ),
    repeatedRecognitions: recognitionCounts.filter(([, count]) => count > 1),
    distinctCausalMechanisms: moveOpeningCounts.length,
  };
});
const contexts = models.flatMap((model) =>
  MATCHED_SCENARIOS.map((scenario) => {
    const context = buildFocusedContext(model, scenario, manifestations);
    const reasoning = buildReasoningPlan(context, manifestations);
    return {
      identity: model.signPair,
      scenarioId: scenario.id,
      arena: scenario.arena,
      manifestationKey: context.selected.manifestationKey,
      errors: validateFocusedContext(context, reasoning, manifestations),
      context,
      reasoning,
      sourceTraceability:
        manifestations[context.selected.manifestationKey!].sourcePaths,
    };
  })
);
const sourceTraceability = Object.fromEntries(sources.map((source) => [
  source.combinedName,
  {
    sourceFile: "Resources/archetypes.json",
    sourceId: source.id,
    sourceFields: [
      "overview",
      "howYouMove",
      "strengths",
      "shadows",
      "emotionalPattern",
      "loveStyle",
      "friendshipStyle",
      "workStyle",
      "growthPath",
      "compatibilityNotes",
      "tagline",
    ],
  },
]));
const audit = {
  developmentOnly: true,
  totalIdentities: models.length,
  totalManifestations: Object.keys(manifestations).length,
  totalContexts: contexts.length,
  invalidFixtures: fixtureResults.filter((r) => !r.valid),
  invalidManifestations: manifestationResults.filter((r) => r.errors.length),
  incompatibleContexts: contexts.filter((r) => r.errors.length).map((
    { identity, scenarioId, arena, errors },
  ) => ({ identity, scenarioId, arena, errors })),
  explicitKeyCount:
    contexts.filter((r) => r.manifestationKey === `${r.identity}|${r.arena}`)
      .length,
  productionWriteScope: [],
  sourceSha256,
  manifestationDiversity,
};
if (
  audit.totalIdentities !== 144 || audit.totalManifestations !== 1440 ||
  audit.totalContexts !== 1440 || audit.invalidFixtures.length ||
  audit.invalidManifestations.length || audit.incompatibleContexts.length ||
  audit.explicitKeyCount !== 1440 ||
  manifestationDiversity.some((identity) =>
    identity.repeatedBehaviorsAboveTwo.length ||
    identity.repeatedMoveOpeningsAboveThree.length ||
    identity.repeatedRecognitions.length ||
    identity.distinctCausalMechanisms < 6
  )
) {
  throw new Error(`Preparation failed: ${JSON.stringify(audit)}`);
}
const artifacts = new URL("./artifacts/", import.meta.url);
await Deno.mkdir(artifacts, { recursive: true });
await Promise.all([
  Deno.writeTextFile(
    new URL("canonical-library.json", artifacts),
    JSON.stringify(
      { developmentOnly: true, sourceSha256, identities: models },
      null,
      2,
    ) +
      "\n",
  ),
  Deno.writeTextFile(
    new URL("manifestations.json", artifacts),
    JSON.stringify(
      { developmentOnly: true, sourceSha256, manifestations },
      null,
      2,
    ) + "\n",
  ),
  Deno.writeTextFile(
    new URL("context-audit.json", artifacts),
    JSON.stringify({ ...audit, contexts }, null, 2) + "\n",
  ),
  Deno.writeTextFile(
    new URL("source-traceability.json", artifacts),
    JSON.stringify(
      { developmentOnly: true, sourceSha256, identities: sourceTraceability },
      null,
      2,
    ) + "\n",
  ),
  Deno.writeTextFile(
    new URL("context-audit.md", artifacts),
    `# Canonical Lens production preview context audit\n\n- Identities: ${audit.totalIdentities}\n- Manifestations: ${audit.totalManifestations}\n- Contexts: ${audit.totalContexts}\n- Invalid fixtures: ${audit.invalidFixtures.length}\n- Invalid manifestations: ${audit.invalidManifestations.length}\n- Compatibility failures: ${audit.incompatibleContexts.length}\n- Explicit identity|arena keys: ${audit.explicitKeyCount}\n- Production write scope: empty\n`,
  ),
]);
console.log(
  `Prepared ${models.length} identities, ${
    Object.keys(manifestations).length
  } manifestations, and ${contexts.length} contexts.`,
);
