import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import {
  buildOpenAIProvider,
  writeModelLens,
} from "../canonical-lens-model/model_writer.ts";
import { resolveRealModelConfig } from "../canonical-lens-model/config.ts";
import { expansionIdentities } from "./identities.ts";
import {
  buildExpansionContext,
  buildExpansionPlan,
  validateExpansionContext,
} from "./manifestations.ts";

const real = Deno.args.includes("--real");
const preflight = Deno.args.includes("--preflight");
const config = resolveRealModelConfig(Deno.env.toObject());
const expected = expansionIdentities.length * MATCHED_SCENARIOS.length;
const estimatedCalls = 92;
const estimatedTokens = 118000;
if (preflight) {
  if (real && !config.apiKey) {
    throw new Error(
      "Expansion preflight failed: OPENAI_API_KEY is missing; no network call was made.",
    );
  }
  if (expected !== 80) {
    throw new Error(
      `Expansion preflight failed: expected 80 cases, found ${expected}`,
    );
  }
  console.log(
    [
      "Expansion preflight passed (no network call, no artifacts written).",
      `provider=${real ? "real" : "mock"}`,
      `model=${real ? config.model : "deterministic-development-mock"}`,
      `expected_cases=${expected}`,
      `estimated_calls=${estimatedCalls}`,
      `estimated_tokens=${estimatedTokens}`,
      "production_write_scope=empty",
      "versioned_artifacts=distinct",
    ].join("\n- "),
  );
  Deno.exit(0);
}
if (!real) {
  throw new Error(
    "Expansion requires explicit --real for provider generation; use --preflight for a no-network check.",
  );
}
if (!config.apiKey) {
  throw new Error(
    "Expansion blocked before network: OPENAI_API_KEY is missing.",
  );
}
const provider = buildOpenAIProvider(config.apiKey, config.model);
const results = [];
for (const identity of expansionIdentities) {
  for (const scenario of MATCHED_SCENARIOS) {
    const context = buildExpansionContext(identity, scenario);
    const plan = buildExpansionPlan(context);
    const contextErrors = validateExpansionContext(context, plan);
    if (contextErrors.length) {
      throw new Error(
        `Context failed before provider call: ${identity.signPair}|${scenario.arena}: ${
          contextErrors.join("; ")
        }`,
      );
    }
    const result = await writeModelLens(
      { context, reasoning: plan, scenario },
      provider,
    );
    results.push({
      identity: identity.signPair,
      scenario,
      context: context.selected,
      reasoning: plan,
      result,
    });
    console.log(
      `[expansion] ${results.length}/${expected} ${identity.signPair} · ${scenario.id}`,
    );
  }
}
const summary = {
  total: results.length,
  acceptedFirstAttempt:
    results.filter((r) => r.result.accepted && r.result.retryCount === 0)
      .length,
  acceptedAfterRetry:
    results.filter((r) => r.result.accepted && r.result.retryCount > 0).length,
  rejected: results.filter((r) => !r.result.accepted).length,
  totalAttempts: results.reduce((sum, r) => sum + r.result.attempts.length, 0),
};
const artifact = {
  developmentOnly: true,
  provider: provider.name,
  model: config.model,
  summary,
  results,
};
await Deno.mkdir(new URL("./artifacts/", import.meta.url), { recursive: true });
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-generation.json",
    import.meta.url,
  ),
  `${JSON.stringify(artifact, null, 2)}\n`,
);
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-expansion-generation.md",
    import.meta.url,
  ),
  `# Canonical Lens expansion generation\n\nProvider: ${provider.name}\n\n${
    JSON.stringify(summary, null, 2)
  }\n`,
);
console.log(
  `Expansion complete: ${summary.acceptedFirstAttempt} first, ${summary.acceptedAfterRetry} retried, ${summary.rejected} rejected.`,
);
