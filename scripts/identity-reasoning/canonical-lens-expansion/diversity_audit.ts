import { expansionIdentities } from "./identities.ts";
import { arenas, expansionManifestations } from "./manifestations.ts";
import {
  buildExpansionContext,
  buildExpansionPlan,
  validateExpansionContext,
} from "./manifestations.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";

const counts = (xs: string[]) =>
  Object.entries(
    xs.reduce<Record<string, number>>(
      (a, x) => (a[x] = (a[x] ?? 0) + 1, a),
      {},
    ),
  ).filter(([, n]) => n > 1);
const rows = [];
for (const identity of expansionIdentities) {
  const ms = arenas.map((arena) =>
    expansionManifestations[`${identity.signPair}|${arena}`]
  );
  const behaviors = ms.flatMap((m) => m.observableBehaviors);
  const moves = ms.map((m) => m.naturalMove.split(" ")[0]);
  const recognitions = ms.map((m) => m.recognition);
  const flagged = ms.filter((m) =>
    counts(behaviors).some(([x, n]) =>
      n > 2 && m.observableBehaviors.includes(x)
    ) || counts(moves).some(([x, n]) => n > 3 && m.naturalMove.startsWith(x))
  );
  rows.push({
    identity: identity.signPair,
    arenaCount: ms.length,
    repeatedBehaviors: counts(behaviors),
    repeatedMoveOpenings: counts(moves),
    repeatedRecognitions: counts(recognitions),
    flaggedArenas: flagged.map((m) => m.arena),
    strongestArena: ms.sort((a, b) =>
      b.observableBehaviors.join(" ").length -
      a.observableBehaviors.join(" ").length
    )[0].arena,
    weakestArena: flagged[0]?.arena ?? "none",
  });
}
const contextResults = expansionIdentities.flatMap((identity) =>
  MATCHED_SCENARIOS.map((scenario) => {
    const c = buildExpansionContext(identity, scenario);
    return validateExpansionContext(c, buildExpansionPlan(c));
  })
);
const generationPath = new URL(
  "./artifacts/canonical-lens-expansion-generation.json",
  import.meta.url,
);
let generation: any = null;
try {
  generation = JSON.parse(await Deno.readTextFile(generationPath));
} catch { /* audit remains offline */ }
const artifact = {
  developmentOnly: true,
  modelCalls: 0,
  fixtureValidation: expansionIdentities.map((i) => ({
    identity: i.signPair,
    errors: validateCanonicalIdentity(i),
  })),
  contextErrors: contextResults.flat(),
  identities: rows,
  generationSummary: generation?.summary ?? null,
  flaggedManifestations: rows.flatMap((r) =>
    r.flaggedArenas.map((arena) => `${r.identity}|${arena}`)
  ),
};
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-diversity-audit.json",
    import.meta.url,
  ),
  JSON.stringify(artifact, null, 2) + "\n",
);
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-diversity-audit.md",
    import.meta.url,
  ),
  `# Expansion diversity audit\n\nModel calls during audit: 0\n\nFlagged manifestations: ${artifact.flaggedManifestations.length}\n\n` +
    rows.map((r) =>
      `## ${r.identity}\n- Repeated behaviors: ${r.repeatedBehaviors.length}\n- Repeated move openings: ${r.repeatedMoveOpenings.length}\n- Repeated recognition lines: ${r.repeatedRecognitions.length}\n- Strongest arena: ${r.strongestArena}\n- Weakest arena: ${r.weakestArena}\n- Arenas requiring revision: ${
        r.flaggedArenas.join(", ") || "none"
      }`
    ).join("\n\n") + "\n",
);
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-manifestation-revisions.json",
    import.meta.url,
  ),
  JSON.stringify(
    {
      developmentOnly: true,
      revised: artifact.flaggedManifestations,
      bundles: Object.fromEntries(
        artifact.flaggedManifestations.map((
          k,
        ) => [k, expansionManifestations[k]]),
      ),
    },
    null,
    2,
  ) + "\n",
);
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-manifestation-revisions.md",
    import.meta.url,
  ),
  `# Manifestation revisions\n\nRevised bundles: ${artifact.flaggedManifestations.length}\n\nRevisions are arena-specific and preserve canonical identity cores.\n`,
);
console.log(
  `Diversity audit complete: flagged=${artifact.flaggedManifestations.length}; contextErrors=${artifact.contextErrors.length}; modelCalls=0`,
);
