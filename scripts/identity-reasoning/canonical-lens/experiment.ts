import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "../canonical/fixtures/taurus-horse.ts";
import { writeCanonicalLens } from "./adapter.ts";
import { MATCHED_SCENARIOS } from "./scenarios.ts";
import type { MatchedLensComparison } from "./types.ts";

export interface ComparisonArtifact {
  experiment: "canonical-identity-to-todays-lens-v1";
  developmentOnly: true;
  productionWiring: false;
  generatedAt: string;
  comparisons: MatchedLensComparison[];
  summary: {
    total: number;
    acceptedFirstAttempt: number;
    acceptedAfterRetry: number;
    rejected: number;
    rejectionReasons: string[];
    differentiatedPairs: number;
  };
}

export function buildComparisonArtifact(): ComparisonArtifact {
  const comparisons = MATCHED_SCENARIOS.map((scenario) => ({
    scenario,
    libraSnake: writeCanonicalLens({
      identity: libraSnakeCanonical,
      scenario,
      debug: true,
    }),
    taurusHorse: writeCanonicalLens({
      identity: taurusHorseCanonical,
      scenario,
      debug: true,
    }),
  }));
  const results = comparisons.flatMap((
    comparison,
  ) => [comparison.libraSnake, comparison.taurusHorse]);
  return {
    experiment: "canonical-identity-to-todays-lens-v1",
    developmentOnly: true,
    productionWiring: false,
    generatedAt: "2026-07-10T00:00:00.000Z",
    comparisons,
    summary: {
      total: results.length,
      acceptedFirstAttempt:
        results.filter((result) =>
          result.validation.ok && result.retryCount === 0
        ).length,
      acceptedAfterRetry:
        results.filter((result) =>
          result.validation.ok && result.retryCount > 0
        ).length,
      rejected: results.filter((result) => !result.validation.ok).length,
      rejectionReasons: [
        ...new Set(results.flatMap((result) => result.validation.reasons)),
      ],
      differentiatedPairs:
        comparisons.filter((comparison) =>
          comparison.libraSnake.lens.pull_quote !==
            comparison.taurusHorse.lens.pull_quote &&
          comparison.libraSnake.debug?.reasoning.recognition !==
            comparison.taurusHorse.debug?.reasoning.recognition
        ).length,
    },
  };
}

if (import.meta.main) {
  console.log(JSON.stringify(buildComparisonArtifact(), null, 2));
}
