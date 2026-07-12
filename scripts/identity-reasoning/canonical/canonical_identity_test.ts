import {
  assert,
  assertEquals,
  assertNotEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { libraSnakeCanonical } from "./fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "./fixtures/taurus-horse.ts";
import {
  libraSnakeTraceability,
  taurusHorseTraceability,
} from "./traceability.ts";
import type { CanonicalIdentityModel } from "./types.ts";
import { validateCanonicalIdentity } from "./validate.ts";

Deno.test("Libra × Snake frozen canonical fixture passes strict validation", () => {
  assertEquals(validateCanonicalIdentity(libraSnakeCanonical), {
    valid: true,
    errors: [],
  });
});

Deno.test("Taurus × Horse reviewed canonical fixture passes strict validation", () => {
  assertEquals(validateCanonicalIdentity(taurusHorseCanonical), {
    valid: true,
    errors: [],
  });
});

Deno.test("an intentionally incomplete fixture fails validation", () => {
  const incomplete = {
    ...taurusHorseCanonical,
    core: { ...taurusHorseCanonical.core, recurringThemes: [] },
    sourceReasoning: {
      ...taurusHorseCanonical.sourceReasoning,
      emergentSynthesis: "",
    },
    relationships: { ...taurusHorseCanonical.relationships, trustBuilders: [] },
    work: {} as CanonicalIdentityModel["work"],
    pressure: {} as CanonicalIdentityModel["pressure"],
  };
  const result = validateCanonicalIdentity(incomplete);
  assert(!result.valid);
  assert(result.errors.length >= 5);
});

Deno.test("reviewed identities retain materially different models", () => {
  assertNotEquals(
    libraSnakeCanonical.core.centralParadox,
    taurusHorseCanonical.core.centralParadox,
  );
  assertNotEquals(libraSnakeCanonical.decision, taurusHorseCanonical.decision);
  assertNotEquals(
    libraSnakeCanonical.relationships,
    taurusHorseCanonical.relationships,
  );
  assertNotEquals(libraSnakeCanonical.pressure, taurusHorseCanonical.pressure);
});

Deno.test("traceability covers all seven required semantic areas", () => {
  const required = [
    "centralParadox",
    "primaryMisunderstanding",
    "trustPattern",
    "pressureLoop",
    "restorationPattern",
    "loveLogic",
    "workLogic",
  ];
  for (const artifact of [libraSnakeTraceability, taurusHorseTraceability]) {
    assertEquals(
      artifact.entries.map((entry) => entry.semanticArea).sort(),
      [...required].sort(),
    );
    assert(artifact.entries.every((entry) => entry.canonicalPaths.length > 0));
  }
});
