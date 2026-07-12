import {
  assert,
  assertNotEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "../canonical/fixtures/taurus-horse.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import {
  buildDiversifiedCanonicalLensContext,
  planDiversifiedCanonicalLens,
  validateDiversifiedContext,
} from "./diversified_plan.ts";

Deno.test("diversified planning changes the behavioral manifestation by arena", () => {
  const libraPlans = MATCHED_SCENARIOS.map((scenario) =>
    planDiversifiedCanonicalLens(planContext(libraSnakeCanonical, scenario))
  );
  const taurusPlans = MATCHED_SCENARIOS.map((scenario) =>
    planDiversifiedCanonicalLens(planContext(taurusHorseCanonical, scenario))
  );
  assert(
    new Set(libraPlans.map((plan) => plan.identitySpecificRole)).size >= 8,
  );
  assert(
    new Set(taurusPlans.map((plan) => plan.identitySpecificRole)).size >= 8,
  );
});

Deno.test("same scenario retains cross-identity causal difference", () => {
  const scenario = MATCHED_SCENARIOS[0];
  const libra = planDiversifiedCanonicalLens(
    planContext(libraSnakeCanonical, scenario),
  );
  const taurus = planDiversifiedCanonicalLens(
    planContext(taurusHorseCanonical, scenario),
  );
  assertNotEquals(libra.identitySpecificRole, taurus.identitySpecificRole);
  assertNotEquals(libra.naturalMove, taurus.naturalMove);
});

Deno.test("a contaminated manifestation key fails before provider invocation", () => {
  const scenario = MATCHED_SCENARIOS[0];
  const context = buildDiversifiedCanonicalLensContext(
    libraSnakeCanonical,
    scenario,
  );
  const reasoning = planDiversifiedCanonicalLens(context);
  const contaminated = {
    ...context,
    selected: { ...context.selected, manifestationKey: "Libra × Snake|love" },
  };
  const errors = validateDiversifiedContext(contaminated, reasoning);
  assert(errors.some((error) => error.includes("manifestation key mismatch")));
});

function planContext(
  model: typeof libraSnakeCanonical,
  scenario: typeof MATCHED_SCENARIOS[number],
) {
  return buildDiversifiedCanonicalLensContext(model, scenario);
}
