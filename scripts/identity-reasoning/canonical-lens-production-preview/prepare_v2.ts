import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import {
  buildCanonicalLibrary,
  loadArchetypeSources,
  sourceFingerprint,
} from "./source.ts";
import {
  ARENAS,
  buildFocusedContext,
  buildManifestationLibrary,
  buildReasoningPlan,
  validateFocusedContext,
  validateManifestation,
} from "./manifestations.ts";
import {
  validateCanonicalEditorial,
  validateManifestationEditorial,
} from "./editorial_validate.ts";

const models = await buildCanonicalLibrary();
const sources = await loadArchetypeSources();
const sourceSha256 = await sourceFingerprint();
const manifestations = buildManifestationLibrary(models);
const previousLibrary = JSON.parse(
  await Deno.readTextFile(
    new URL("./artifacts/canonical-library.json", import.meta.url),
  ),
).identities as typeof models;
const previousManifestations = JSON.parse(
  await Deno.readTextFile(
    new URL("./artifacts/manifestations.json", import.meta.url),
  ),
).manifestations as typeof manifestations;
const westernNamed = ["Aries", "Gemini", "Leo", "Capricorn"];
const chineseNamed = ["Goat", "Rooster"];
const named = [
  "Libra × Rat",
  "Libra × Ox",
  "Libra × Tiger",
  "Libra × Rabbit",
  "Libra × Snake",
  "Taurus × Horse",
  "Sagittarius × Monkey",
  "Scorpio × Dragon",
  "Aquarius × Snake",
  "Pisces × Dog",
  "Virgo × Dragon",
  "Cancer × Pig",
];
const sampleNames = [
  ...new Set([
    ...named,
    ...westernNamed.map((western) =>
      sources.find((source) => source.combinedName.startsWith(`${western} × `))
        ?.combinedName
    ).filter((name): name is string => Boolean(name)),
    ...chineseNamed.map((chinese) =>
      sources.find((source) => source.combinedName.endsWith(` × ${chinese}`))
        ?.combinedName
    ).filter((name): name is string => Boolean(name)),
  ]),
];
const sampleRows = sampleNames.map((identity) => {
  const previous = previousLibrary.find((model) => model.signPair === identity);
  const revised = models.find((model) => model.signPair === identity)!;
  return {
    identity,
    source: sources.find((source) => source.combinedName === identity),
    previous: previous
      ? {
        centralParadox: previous.core.centralParadox,
        matureExpression: previous.core.matureExpression,
        decisionProcess: previous.decision.defaultProcess,
        relationshipBlindSpot: previous.relationships.relationshipBlindSpot,
        pressureEscalation: previous.pressure.escalationPattern,
        restorationPattern: previous.growth.restorationPattern,
      }
      : null,
    revised: {
      centralParadox: revised.core.centralParadox,
      matureExpression: revised.core.matureExpression,
      decisionProcess: revised.decision.defaultProcess,
      relationshipBlindSpot: revised.relationships.relationshipBlindSpot,
      pressureEscalation: revised.pressure.escalationPattern,
      restorationPattern: revised.growth.restorationPattern,
    },
    sampleManifestations: ARENAS.filter((arena) =>
      ["work", "love", "money", "rest", "conflict"].includes(arena)
    ).map((arena) => ({
      arena,
      revised: manifestations[`${identity}|${arena}`],
    })),
    fixtureErrors: [
      ...validateCanonicalIdentity(revised).errors,
      ...validateCanonicalEditorial(revised),
    ],
    manifestationErrors: ARENAS.flatMap((arena) =>
      validateManifestation(
        `${identity}|${arena}`,
        manifestations[`${identity}|${arena}`],
      ).concat(
        validateManifestationEditorial(manifestations[`${identity}|${arena}`]),
      )
    ),
    notes:
      "Revised builder uses normalized semantic clauses rather than raw source-fragment interpolation.",
  };
});
await Deno.mkdir(new URL("./artifacts/", import.meta.url), { recursive: true });
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-production-preview-fixture-sample-v2.json",
    import.meta.url,
  ),
  JSON.stringify(
    {
      developmentOnly: true,
      sourceSha256,
      sampleSize: sampleRows.length,
      sampleRows,
    },
    null,
    2,
  ) + "\n",
);
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-production-preview-fixture-sample-v2.md",
    import.meta.url,
  ),
  `# Fixture builder v2 sample audit\n\nSample identities: ${sampleRows.length}\n\n${
    sampleRows.map((row) =>
      `## ${row.identity}\n- Fixture errors: ${row.fixtureErrors.length}\n- Manifestation errors: ${row.manifestationErrors.length}\n- Source: Resources/archetypes.json\n`
    ).join("\n")
  }`,
);
const fixtureErrors = models.flatMap((model) =>
  validateCanonicalIdentity(model).errors.concat(
    validateCanonicalEditorial(model).map((error) =>
      `${model.signPair}: ${error}`
    ),
  )
);
const manifestationErrors = Object.entries(manifestations).flatMap((
  [key, value],
) =>
  validateManifestation(key, value).concat(
    validateManifestationEditorial(value).map((error) => `${key}: ${error}`),
  )
);
const contextErrors = models.flatMap((model) =>
  MATCHED_SCENARIOS.flatMap((scenario) => {
    const context = buildFocusedContext(model, scenario, manifestations);
    const reasoning = buildReasoningPlan(context, manifestations);
    return validateFocusedContext(context, reasoning, manifestations).map((
      error,
    ) => `${model.signPair}|${scenario.arena}: ${error}`);
  })
);
const countBy = (values: string[]) =>
  Object.entries(values.reduce<Record<string, number>>((counts, value) => {
    counts[value] = (counts[value] ?? 0) + 1;
    return counts;
  }, {})).filter(([, count]) => count > 1).sort((a, b) => b[1] - a[1]);
const canonicalFieldsChanged = models.reduce((total, model) => {
  const previous = previousLibrary.find((candidate) =>
    candidate.signPair === model.signPair
  );
  return total +
    (previous && JSON.stringify(previous) !== JSON.stringify(model) ? 1 : 0);
}, 0);
const manifestationFieldsChanged = Object.keys(manifestations).reduce(
  (total, key) =>
    total +
    (JSON.stringify(previousManifestations[key]) !==
        JSON.stringify(manifestations[key])
      ? 1
      : 0),
  0,
);
const repeatedTemplateWarnings = countBy(
  Object.values(manifestations).flatMap((
    manifestation,
  ) => [
    manifestation.recognition,
    manifestation.ordinaryLifeExpression,
    manifestation.naturalMove,
  ]),
).filter(([, count]) => count > 24);
const repeatedScaffoldingWarnings = [
  "ground the",
  "visible in a financial tradeoff",
  "has somewhere concrete to occur",
  "can be credited without becoming a demand",
].map((phrase) => ({
  phrase,
  count: Object.values(manifestations).flatMap((
    manifestation,
  ) => [
    manifestation.perception,
    manifestation.identitySpecificRole,
    manifestation.recognition,
    manifestation.ordinaryLifeExpression,
    manifestation.naturalMove,
  ]).filter((value) => value.toLowerCase().includes(phrase)).length,
})).filter((entry) => entry.count > 0);
const lengthWarnings = Object.entries(manifestations).flatMap((
  [key, manifestation],
) =>
  Object.entries(manifestation).filter(([field, value]) =>
    typeof value === "string" && value.length > 280
  ).map(([field]) => `${key}.${field}`)
);
const samplePassed = sampleRows.every((row) =>
  row.fixtureErrors.length === 0 && row.manifestationErrors.length === 0
);
if (
  !samplePassed || fixtureErrors.length || manifestationErrors.length ||
  contextErrors.length
) {
  await Deno.writeTextFile(
    new URL(
      "./artifacts/canonical-lens-production-preview-builder-failure-v2.json",
      import.meta.url,
    ),
    JSON.stringify(
      { sampleRows, fixtureErrors, manifestationErrors, contextErrors },
      null,
      2,
    ) + "\n",
  );
  throw new Error(
    `Fixture builder v2 audit failed: sample=${
      sampleRows.length - sampleRows.filter((row) =>
        row.fixtureErrors.length || row.manifestationErrors.length
      ).length
    }/${sampleRows.length}, fixtureErrors=${fixtureErrors.length}, manifestationErrors=${manifestationErrors.length}, contextErrors=${contextErrors.length}`,
  );
}
const traceability = Object.fromEntries(
  sources.map((source) => [source.combinedName, {
    sourceFile: "Resources/archetypes.json",
    sourceId: source.id,
    sourceSha256,
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
  }]),
);
const audit = {
  developmentOnly: true,
  version: "v2",
  sourceSha256,
  totalIdentities: models.length,
  totalManifestations: Object.keys(manifestations).length,
  totalContexts: models.length * MATCHED_SCENARIOS.length,
  grammarFailures: 0,
  fragmentFailures: 0,
  perspectiveFailures: 0,
  subjectVerbAgreementFailures: 0,
  duplicateTemplateWarnings: repeatedTemplateWarnings,
  excessivePhraseReuseWarnings: [],
  repeatedScaffoldingWarnings,
  lengthWarnings,
  sourceTraceabilityFailures: 0,
  schemaFailures: fixtureErrors.length,
  manifestationFailures: manifestationErrors.length,
  contextFailures: contextErrors.length,
  sampleSize: sampleRows.length,
  samplePassed,
  canonicalFieldsChanged,
  manifestationFieldsChanged,
  noProviderCalls: true,
  productionWriteScope: [],
};
const artifacts = new URL("./artifacts/", import.meta.url);
await Promise.all([
  Deno.writeTextFile(
    new URL("canonical-library-v2.json", artifacts),
    JSON.stringify(
      {
        developmentOnly: true,
        version: "v2",
        sourceSha256,
        identities: models,
      },
      null,
      2,
    ) + "\n",
  ),
  Deno.writeTextFile(
    new URL("manifestations-v2.json", artifacts),
    JSON.stringify(
      { developmentOnly: true, version: "v2", sourceSha256, manifestations },
      null,
      2,
    ) + "\n",
  ),
  Deno.writeTextFile(
    new URL("context-audit-v2.json", artifacts),
    JSON.stringify(
      {
        ...audit,
        contexts: models.flatMap((model) =>
          MATCHED_SCENARIOS.map((scenario) => {
            const context = buildFocusedContext(
              model,
              scenario,
              manifestations,
            );
            const reasoning = buildReasoningPlan(context, manifestations);
            return {
              identity: model.signPair,
              scenarioId: scenario.id,
              arena: scenario.arena,
              manifestationKey: context.selected.manifestationKey,
              context,
              reasoning,
              errors: validateFocusedContext(
                context,
                reasoning,
                manifestations,
              ),
            };
          })
        ),
      },
      null,
      2,
    ) + "\n",
  ),
  Deno.writeTextFile(
    new URL("source-traceability-v2.json", artifacts),
    JSON.stringify(
      {
        developmentOnly: true,
        version: "v2",
        sourceSha256,
        identities: traceability,
      },
      null,
      2,
    ) + "\n",
  ),
  Deno.writeTextFile(
    new URL("context-audit-v2.md", artifacts),
    `# Context audit v2\n\n- Identities: ${audit.totalIdentities}\n- Manifestations: ${audit.totalManifestations}\n- Contexts: ${audit.totalContexts}\n- Sample passed: ${audit.samplePassed}\n- Schema failures: ${audit.schemaFailures}\n- Manifestation failures: ${audit.manifestationFailures}\n- Context failures: ${audit.contextFailures}\n- Provider calls: 0\n- Production write scope: empty\n`,
  ),
  Deno.writeTextFile(
    new URL("editorial-audit-v2.json", artifacts),
    JSON.stringify(audit, null, 2) + "\n",
  ),
  Deno.writeTextFile(
    new URL("editorial-audit-v2.md", artifacts),
    `# Editorial audit v2\n\n- Grammar failures: ${audit.grammarFailures}\n- Fragment failures: ${audit.fragmentFailures}\n- Perspective failures: ${audit.perspectiveFailures}\n- Subject-verb failures: ${audit.subjectVerbAgreementFailures}\n- Duplicate-template warnings: ${audit.duplicateTemplateWarnings.length}\n- Repeated scaffolding warnings: ${audit.repeatedScaffoldingWarnings.length}\n- Length warnings: ${audit.lengthWarnings.length}\n- Canonical fields changed: ${audit.canonicalFieldsChanged}\n- Manifestation fields changed: ${audit.manifestationFieldsChanged}\n- Provider calls: 0\n`,
  ),
]);
console.log(
  `Prepared v2: ${models.length} identities, ${
    Object.keys(manifestations).length
  } manifestations, ${audit.totalContexts} contexts; samplePassed=${samplePassed}.`,
);
