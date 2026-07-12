import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "../canonical/fixtures/taurus-horse.ts";
import {
  buildCanonicalLensContext,
  generateCanonicalLens,
  planCanonicalLens,
  writeCanonicalLens,
} from "../canonical-lens/adapter.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import {
  buildMockProvider,
  buildOpenAIProvider,
  writeModelLens,
} from "./model_writer.ts";
import { automatedNotes, scoreLens } from "./comparison.ts";
import type { ModelWritingResult, RubricScores } from "./types.ts";
import type { CanonicalLens } from "../canonical-lens/types.ts";
import { resolveRealModelConfig, runPreflight } from "./config.ts";
import {
  buildDiversifiedCanonicalLensContext,
  planDiversifiedCanonicalLens,
  validateDiversifiedContext,
} from "./diversified_plan.ts";

const useReal = Deno.args.includes("--real");
const preflight = Deno.args.includes("--preflight");
const config = resolveRealModelConfig(Deno.env.toObject());
if (preflight) {
  const checks = runPreflight({
    real: useReal,
    env: Deno.env.toObject(),
    scenarioCount: MATCHED_SCENARIOS.length,
    mockArtifactPath: "artifacts/canonical-lens-model-comparison.json",
    realArtifactPath:
      "artifacts/canonical-lens-real-model-comparison-diversified-v2.json",
    productionPaths: [],
  });
  console.log(
    [
      "Preflight passed (no network call, no artifacts written).",
      ...checks.map((check) => `- ${check}`),
    ].join("\n"),
  );
  Deno.exit(0);
}
const apiKey = useReal ? config.apiKey : undefined;
if (useReal && !apiKey) {
  throw new Error(
    "Real run blocked before network request: OPENAI_API_KEY is missing. The mock provider remains available without credentials. Retry after setting OPENAI_API_KEY.",
  );
}
const provider = useReal ? buildOpenAIProvider(apiKey!) : buildMockProvider();
type ComparisonRow = {
  scenario: typeof MATCHED_SCENARIOS[number];
  signPair: string;
  focusedContext: ReturnType<typeof buildCanonicalLensContext>["selected"];
  reasoning: ReturnType<typeof planCanonicalLens>;
  deterministicBaseline: {
    lens: CanonicalLens;
    validation: { accepted: boolean; reasons: string[] };
    retryCount: number;
    scores: RubricScores;
  };
  modelWrittenExperimental: ModelWritingResult & {
    scores: RubricScores | null;
  };
  notes: string[];
};
const comparisons: ComparisonRow[] = [];
let caseNumber = 0;

for (const scenario of MATCHED_SCENARIOS) {
  for (const model of [libraSnakeCanonical, taurusHorseCanonical]) {
    caseNumber += 1;
    if (useReal) {
      console.log(
        `[real-model] ${caseNumber}/20 ${model.signPair} · ${scenario.id}`,
      );
    }
    const context = buildDiversifiedCanonicalLensContext(model, scenario);
    const reasoning = planDiversifiedCanonicalLens(context);
    const compatibilityErrors = validateDiversifiedContext(context, reasoning);
    if (compatibilityErrors.length) {
      throw new Error(
        `Context compatibility failed before provider call: ${
          compatibilityErrors.join("; ")
        }`,
      );
    }
    const baseline = generateCanonicalLens(model, scenario);
    const experimental = await writeModelLens(
      { context, reasoning, scenario },
      provider,
    );
    const baselineScores = scoreLens(baseline.lens, context, reasoning);
    const modelScores = experimental.finalLens
      ? scoreLens(experimental.finalLens, context, reasoning)
      : null;
    comparisons.push({
      scenario,
      signPair: model.signPair,
      focusedContext: context.selected,
      reasoning,
      deterministicBaseline: {
        lens: baseline.lens,
        validation: baseline.validation,
        retryCount: baseline.retryCount,
        scores: baselineScores,
      },
      modelWrittenExperimental: { ...experimental, scores: modelScores },
      notes: automatedNotes(baseline.lens, experimental.finalLens),
    });
  }
}

const artifact = {
  experiment: "canonical-identity-to-todays-lens-model-writing-v1",
  developmentOnly: true,
  productionWiring: false,
  provider: provider.name,
  sampleCount: comparisons.length,
  comparisons,
  summary: {
    acceptedFirstAttempt:
      comparisons.filter((item) =>
        item.modelWrittenExperimental.accepted &&
        item.modelWrittenExperimental.retryCount === 0
      ).length,
    acceptedAfterRetry:
      comparisons.filter((item) =>
        item.modelWrittenExperimental.accepted &&
        item.modelWrittenExperimental.retryCount > 0
      ).length,
    rejected:
      comparisons.filter((item) => !item.modelWrittenExperimental.accepted)
        .length,
    totalAttempts: comparisons.reduce(
      (total, item) => total + item.modelWrittenExperimental.attempts.length,
      0,
    ),
  },
};
await Deno.mkdir(new URL("./artifacts/", import.meta.url), { recursive: true });
const artifactStem = useReal
  ? "canonical-lens-real-model-comparison-diversified-v2"
  : "canonical-lens-model-comparison";
await Deno.writeTextFile(
  new URL(`./artifacts/${artifactStem}.json`, import.meta.url),
  `${JSON.stringify(artifact, null, 2)}\n`,
);

const average = (
  key: keyof RubricScores,
  model: "deterministicBaseline" | "modelWrittenExperimental",
) => {
  const values = comparisons.map((item) => item[model].scores?.[key]).filter((
    value,
  ): value is number => typeof value === "number");
  return values.length
    ? (values.reduce((sum, value) => sum + value, 0) / values.length).toFixed(2)
    : "n/a";
};
const scoreKeys = [
  "identitySpecificity",
  "behavioralConcreteness",
  "scenarioRelevance",
  "canonicalGrounding",
  "internalCoherence",
  "fieldDifferentiation",
  "contemporaryVoice",
  "usefulness",
  "nonPredictiveDiscipline",
  "repetitionControl",
] as const;
const md = [
  "# Canonical Identity → Today’s Lens model-writing comparison",
  "",
  `Provider: ${provider.name}. Twenty deterministic baseline outputs remain the control group; twenty model-written outputs are experimental.`,
  "",
  `Accepted first attempt: ${artifact.summary.acceptedFirstAttempt}  
Accepted after retry: ${artifact.summary.acceptedAfterRetry}  
Rejected: ${artifact.summary.rejected}  
Total provider attempts: ${artifact.summary.totalAttempts}`,
  "",
  "## Average rubric scores",
  "",
  "| Criterion | Deterministic | Model-written |",
  "|---|---:|---:|",
  ...scoreKeys.map((key) =>
    `| ${key} | ${average(key, "deterministicBaseline")} | ${
      average(key, "modelWrittenExperimental")
    } |`
  ),
  "",
  "## Field-by-field comparison",
  "",
  ...comparisons.map((item) => {
    const result = item.modelWrittenExperimental;
    return `### ${item.scenario.id} — ${item.signPair}\n\n**Scenario:** ${item.scenario.humanTension} · ${item.scenario.arena}\n\n**Baseline title:** ${item.deterministicBaseline.lens.title}\n\n**Model title:** ${
      result.finalLens?.title ?? "REJECTED"
    }\n\n**Notes:** ${item.notes.join("; ")}\n\n**Validation:** ${
      result.accepted
        ? "accepted"
        : `rejected (${result.attempts.at(-1)?.validation.reasons.join(", ")})`
    } · retries ${result.retryCount}`;
  }),
  "",
  "## Recommendation",
  "",
  "Revise the writing prompt and rerun before any production consideration. This mock pass proves the injectable contract, focused-context boundary, strict parsing, and comparison audit, but it cannot establish that live model writing is more specific or more grounded than the deterministic control.",
].join("\n");
await Deno.writeTextFile(
  new URL(`./artifacts/${artifactStem}.md`, import.meta.url),
  `${md}\n`,
);
if (
  useReal && artifact.summary.rejected === 0 &&
  artifact.summary.acceptedFirstAttempt +
        artifact.summary.acceptedAfterRetry === 20
) {
  const blinded = comparisons.map((item, index) => {
    const modelFirst = ((index * 17 + 11) % 2) === 0;
    return {
      scenario: item.scenario,
      signPair: item.signPair,
      versionA: modelFirst
        ? item.modelWrittenExperimental.finalLens
        : item.deterministicBaseline.lens,
      versionB: modelFirst
        ? item.deterministicBaseline.lens
        : item.modelWrittenExperimental.finalLens,
    };
  });
  await Deno.writeTextFile(
    new URL(
      "./artifacts/canonical-lens-real-model-blind-audit-diversified-v2.json",
      import.meta.url,
    ),
    `${
      JSON.stringify(
        {
          seed: "lens-blind-v1",
          scoringMetadataHidden: true,
          comparisons: blinded,
        },
        null,
        2,
      )
    }\n`,
  );
  await Deno.writeTextFile(
    new URL(
      "./artifacts/canonical-lens-real-model-blind-audit-diversified-v2.md",
      import.meta.url,
    ),
    "# Real-model blind audit\n\nVersion A/B ordering is deterministic and source metadata is withheld until scoring is complete. Score the ten-part rubric and pairwise preference before using each reveal mapping in the JSON artifact.\n",
  );
}
console.log(
  `Wrote ${comparisons.length} baseline/experimental comparisons using ${provider.name}.`,
);
