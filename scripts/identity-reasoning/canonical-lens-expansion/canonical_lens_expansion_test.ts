import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { expansionIdentities } from "./identities.ts";
import {
  buildExpansionContext,
  buildExpansionPlan,
  expansionManifestations,
  validateExpansionContext,
} from "./manifestations.ts";

Deno.test("all eight expansion fixtures validate", () => {
  assertEquals(expansionIdentities.length, 8);
  assert(
    expansionIdentities.every((identity) =>
      validateCanonicalIdentity(identity).valid
    ),
  );
});

Deno.test("all 80 identity-arena bundles and contexts exist", () => {
  assertEquals(Object.keys(expansionManifestations).length, 80);
  for (const identity of expansionIdentities) {
    for (const scenario of MATCHED_SCENARIOS) {
      const context = buildExpansionContext(identity, scenario);
      const plan = buildExpansionPlan(context);
      assertEquals(validateExpansionContext(context, plan), []);
      assertEquals(
        context.selected.manifestationKey,
        `${identity.signPair}|${scenario.arena}`,
      );
    }
  }
});

Deno.test("cross-arena contamination fails locally", () => {
  const identity = expansionIdentities[0];
  const context = buildExpansionContext(identity, MATCHED_SCENARIOS[0]);
  const plan = buildExpansionPlan(context);
  const contaminated = {
    ...context,
    selected: {
      ...context.selected,
      manifestationKey: `${identity.signPair}|love`,
    },
  };
  assert(validateExpansionContext(contaminated, plan).length > 0);
});

Deno.test("no positional or modulo selector exists in expansion manifestation code", async () => {
  const source = await Deno.readTextFile(
    new URL("./manifestations.ts", import.meta.url),
  );
  assert(!source.includes("%"));
});

Deno.test("within-identity manifestations remain behaviorally distinct", () => {
  for (const identity of expansionIdentities) {
    const bundles = MATCHED_SCENARIOS.map((s) =>
      expansionManifestations[`${identity.signPair}|${s.arena}`]
    );
    const behaviors = bundles.flatMap((b) => b.observableBehaviors);
    const behaviorCounts = new Map<string, number>();
    for (const behavior of behaviors) {
      behaviorCounts.set(behavior, (behaviorCounts.get(behavior) ?? 0) + 1);
    }
    assert([...behaviorCounts.values()].every((count) => count <= 2));
    assertEquals(new Set(bundles.map((b) => b.recognition)).size, 10);
    const moveOpenings = bundles.map((b) => b.naturalMove.split(" ")[0]);
    const moveCounts = new Map<string, number>();
    for (const opening of moveOpenings) {
      moveCounts.set(opening, (moveCounts.get(opening) ?? 0) + 1);
    }
    assert([...moveCounts.values()].every((count) => count <= 3));
  }
});
