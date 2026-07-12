import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import {
  ARENAS,
  buildFocusedContext,
  buildManifestationLibrary,
  buildReasoningPlan,
  validateFocusedContext,
  validateManifestation,
} from "./manifestations.ts";
import { buildCanonicalLibrary, loadArchetypeSources } from "./source.ts";
import {
  normalizeBehaviorClause,
  normalizeGerund,
  normalizeImperative,
  normalizeTraitPhrase,
} from "./source.ts";
import {
  validateCanonicalEditorial,
  validateManifestationEditorial,
  validateSourceFragmentNormalization,
} from "./editorial_validate.ts";

Deno.test("authoritative source contains the complete 12 by 12 library", async () => {
  const sources = await loadArchetypeSources();
  assertEquals(sources.length, 144);
  assertEquals(new Set(sources.map((s) => s.combinedName)).size, 144);
  assertEquals(
    new Set(sources.map((s) => s.combinedName.split(" × ")[0])).size,
    12,
  );
  assertEquals(
    new Set(sources.map((s) => s.combinedName.split(" × ")[1])).size,
    12,
  );
});

Deno.test("all canonical fixtures pass the existing validator", async () => {
  const models = await buildCanonicalLibrary();
  assertEquals(models.length, 144);
  for (const model of models) {
    assertEquals(
      validateCanonicalIdentity(model),
      { valid: true, errors: [] },
      model.signPair,
    );
    assert(model.evidence.observableBehaviors.length >= 7, model.signPair);
    assert(model.relationships.trustBuilders.length >= 3, model.signPair);
    assert(model.relationships.trustBreakers.length >= 3, model.signPair);
  }
});

Deno.test("all 1440 explicit manifestations and contexts validate", async () => {
  const models = await buildCanonicalLibrary();
  const library = buildManifestationLibrary(models);
  assertEquals(ARENAS.length, 10);
  assertEquals(Object.keys(library).length, 1440);
  let contexts = 0;
  for (const model of models) {
    for (const scenario of MATCHED_SCENARIOS) {
      const key = `${model.signPair}|${scenario.arena}`;
      assertEquals(validateManifestation(key, library[key]), []);
      const context = buildFocusedContext(model, scenario, library);
      const plan = buildReasoningPlan(context, library);
      assertEquals(context.selected.manifestationKey, key);
      assertEquals(validateFocusedContext(context, plan, library), []);
      contexts++;
    }
  }
  assertEquals(contexts, 1440);
});

Deno.test("each identity has diverse arena mechanisms", async () => {
  const models = await buildCanonicalLibrary();
  const library = buildManifestationLibrary(models);
  for (const model of models) {
    const bundles = MATCHED_SCENARIOS.map((scenario) =>
      library[`${model.signPair}|${scenario.arena}`]
    );
    const behaviors = bundles.flatMap((bundle) => bundle.observableBehaviors);
    const behaviorCounts = behaviors.reduce<Record<string, number>>(
      (counts, value) => {
        counts[value] = (counts[value] ?? 0) + 1;
        return counts;
      },
      {},
    );
    assert(
      Object.values(behaviorCounts).every((count) => count <= 2),
      model.signPair,
    );
    assertEquals(
      new Set(bundles.map((bundle) => bundle.recognition)).size,
      10,
      model.signPair,
    );
    const moveOpenings = bundles.map((bundle) =>
      bundle.naturalMove.split(/\s+/)[0].toLowerCase()
    );
    assert(new Set(moveOpenings).size >= 6, model.signPair);
    const moveCounts = moveOpenings.reduce<Record<string, number>>(
      (counts, value) => {
        counts[value] = (counts[value] ?? 0) + 1;
        return counts;
      },
      {},
    );
    assert(
      Object.values(moveCounts).every((count) => count <= 3),
      model.signPair,
    );
  }
});

Deno.test("selection code contains no modulo, positional, or fallback mechanism", async () => {
  const source = await Deno.readTextFile(
    new URL("./manifestations.ts", import.meta.url),
  );
  assert(!source.includes("%"));
  assert(!source.includes("fallback"));
  assert(!source.includes("ARENAS[") && !source.includes("models["));
});

Deno.test("development preview code contains no production write path", async () => {
  for (const file of ["prepare.ts", "source.ts", "manifestations.ts"]) {
    const source = await Deno.readTextFile(
      new URL(`./${file}`, import.meta.url),
    );
    assert(!source.includes("supabase/functions"));
    assert(!source.includes("daily_rituals"));
  }
});

Deno.test("fixture revision and audit paths make no provider calls", async () => {
  for (const file of ["prepare_v2.ts", "editorial_validate.ts"]) {
    const source = await Deno.readTextFile(
      new URL(`./${file}`, import.meta.url),
    );
    assert(!source.includes("buildOpenAIProvider"));
    assert(!source.includes("api.openai.com"));
    assert(!source.includes("fetch("));
  }
});

Deno.test("semantic normalizers repair source fragment perspective and grammar", () => {
  assertEquals(
    normalizeImperative("State the real position sooner"),
    "state the real position sooner",
  );
  assertEquals(
    normalizeImperative("Talks around tension instead of naming it"),
    "talk around tension instead of naming it",
  );
  assertEquals(
    normalizeGerund("State the real position sooner"),
    "stating the real position sooner",
  );
  assertEquals(
    normalizeBehaviorClause("Keeps too many angles open at once"),
    "keep too many angles open at once",
  );
  assertEquals(normalizeTraitPhrase("Quick"), "quickness");
  assert(
    validateSourceFragmentNormalization(
      "You have enough visible proof when you act when others hesitate.",
    ).length > 0,
  );
  assertEquals(
    validateSourceFragmentNormalization(
      "You have enough visible proof when you act as others hesitate.",
    ),
    [],
  );
});

Deno.test("v2 fixture and manifestation editorial validators are clean", async () => {
  const models = await buildCanonicalLibrary();
  const library = buildManifestationLibrary(models);
  for (const model of models) {
    assertEquals(validateCanonicalEditorial(model), [], model.signPair);
  }
  for (const [key, manifestation] of Object.entries(library)) {
    assertEquals(validateManifestationEditorial(manifestation), [], key);
    assert(manifestation.sourcePaths.length > 0);
    assert(/^[A-Z]/.test(manifestation.naturalMove));
  }
});
