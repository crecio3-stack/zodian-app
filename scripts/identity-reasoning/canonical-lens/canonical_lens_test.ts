import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "../canonical/fixtures/taurus-horse.ts";
import { buildCanonicalLensContext, generateCanonicalLens } from "./adapter.ts";
import { MATCHED_SCENARIOS } from "./scenarios.ts";

Deno.test("matched scenarios produce twenty accepted Lens-shaped outputs", () => {
  const results = MATCHED_SCENARIOS.flatMap((scenario) => [
    generateCanonicalLens(libraSnakeCanonical, scenario),
    generateCanonicalLens(taurusHorseCanonical, scenario),
  ]);
  assertEquals(results.length, 20);
  assert(
    results.every((result) =>
      result.validation.accepted && result.retryCount === 0
    ),
  );
  assert(
    results.every((result) =>
      Object.keys(result.lens).sort().join(",") ===
        "deeper_read,intro,move,pull_quote,title,watch_for"
    ),
  );
});

Deno.test("the same scenario selects different canonical slices", () => {
  const scenario = MATCHED_SCENARIOS[0];
  const libra = buildCanonicalLensContext(libraSnakeCanonical, scenario);
  const taurus = buildCanonicalLensContext(taurusHorseCanonical, scenario);
  assert(libra.selected.activatedParadox !== taurus.selected.activatedParadox);
  assert(libra.selected.decision !== taurus.selected.decision);
  assert(libra.selected.pressureOrGrowth !== taurus.selected.pressureOrGrowth);
});
