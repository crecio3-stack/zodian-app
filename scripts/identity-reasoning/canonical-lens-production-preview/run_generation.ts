import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { resolveRealModelConfig } from "../canonical-lens-model/config.ts";
import {
  buildOpenAIProvider,
  writeModelLens,
} from "../canonical-lens-model/model_writer.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import {
  buildCanonicalLibrary,
  loadArchetypeSources,
  sourceFingerprint,
} from "./source.ts";
import {
  buildFocusedContext,
  buildManifestationLibrary,
  buildReasoningPlan,
  validateFocusedContext,
  validateManifestation,
} from "./manifestations.ts";

const real = Deno.args.includes("--real");
const preflight = Deno.args.includes("--preflight");
const retryAborted = Deno.args.includes("--retry-aborted");
const maxArg = Deno.args.find((arg) => arg.startsWith("--max-identities="));
const maxIdentities = maxArg ? Number(maxArg.split("=")[1]) : Infinity;
if (
  !Number.isFinite(maxIdentities) && maxIdentities !== Infinity ||
  maxIdentities < 1
) {
  throw new Error("--max-identities must be a positive number");
}
const config = resolveRealModelConfig(Deno.env.toObject());
const inputRateValue = Deno.env.get("OPENAI_INPUT_USD_PER_MILLION");
const outputRateValue = Deno.env.get("OPENAI_OUTPUT_USD_PER_MILLION");
const inputRate = inputRateValue ? Number(inputRateValue) : null;
const outputRate = outputRateValue ? Number(outputRateValue) : null;
const expansionUsage = {
  outputs: 80,
  attempts: 86,
  inputTokens: 91876,
  outputTokens: 16346,
};
const scale = 1440 / expansionUsage.outputs;
const estimate = {
  expectedOutputs: 1440,
  expectedCalls: Math.ceil(expansionUsage.attempts * scale),
  inputTokens: Math.ceil(expansionUsage.inputTokens * scale),
  outputTokens: Math.ceil(expansionUsage.outputTokens * scale),
  totalTokens: Math.ceil(
    (expansionUsage.inputTokens + expansionUsage.outputTokens) * scale,
  ),
  inputRatePerMillion: inputRate,
  outputRatePerMillion: outputRate,
  estimatedUsd: inputRate !== null && outputRate !== null
    ? Number(
      ((expansionUsage.inputTokens * scale / 1_000_000) * inputRate +
        (expansionUsage.outputTokens * scale / 1_000_000) * outputRate)
        .toFixed(2),
    )
    : null,
  basis: inputRate !== null && outputRate !== null
    ? "scaled from the completed 80-output expansion using explicitly configured rates"
    : "token estimate scaled from the completed 80-output expansion; dollar estimate unavailable until explicit rates are configured",
};

const models = await buildCanonicalLibrary();
const sources = await loadArchetypeSources();
const sourceSha256 = await sourceFingerprint();
const manifestations = buildManifestationLibrary(models);
const globalOfflineErrors: string[] = [];
const identityOfflineErrors = new Map<string, string[]>();
if (models.length !== 144) {
  globalOfflineErrors.push(`expected 144 identities, found ${models.length}`);
}
if (Object.keys(manifestations).length !== 1440) {
  globalOfflineErrors.push(
    `expected 1440 manifestations, found ${Object.keys(manifestations).length}`,
  );
}
for (const model of models) {
  const errors: string[] = [];
  const validation = validateCanonicalIdentity(model);
  if (!validation.valid) {
    errors.push(`fixture: ${validation.errors.join("; ")}`);
  }
  for (const scenario of MATCHED_SCENARIOS) {
    const key = `${model.signPair}|${scenario.arena}`;
    const manifestation = manifestations[key];
    if (!manifestation) {
      errors.push(`${scenario.arena} manifestation: missing explicit bundle`);
      continue;
    }
    const manifestationErrors = validateManifestation(key, manifestation);
    if (manifestationErrors.length) {
      errors.push(
        `${scenario.arena} manifestation: ${manifestationErrors.join("; ")}`,
      );
    }
    try {
      const context = buildFocusedContext(model, scenario, manifestations);
      const plan = buildReasoningPlan(context, manifestations);
      const contextErrors = validateFocusedContext(
        context,
        plan,
        manifestations,
      );
      if (contextErrors.length) {
        errors.push(`${scenario.arena} context: ${contextErrors.join("; ")}`);
      }
    } catch (error) {
      errors.push(
        `${scenario.arena} context: ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
    }
  }
  if (errors.length) identityOfflineErrors.set(model.signPair, errors);
}
if (globalOfflineErrors.length) {
  throw new Error(
    `Offline preflight failed before network access:\n${
      globalOfflineErrors.join("\n")
    }`,
  );
}
if (!real) {
  throw new Error(
    "Generation requires explicit --real. Use --real --preflight for a no-network check.",
  );
}
if (!config.apiKey) {
  throw new Error(
    "Preflight failed before network access: OPENAI_API_KEY is missing.",
  );
}
if (config.modelSource === "default") {
  throw new Error(
    "Preflight failed before network access: set OPENAI_IDENTITY_LENS_MODEL to the approved model.",
  );
}
if (preflight) {
  console.log(JSON.stringify(
    {
      passed: identityOfflineErrors.size === 0,
      networkCall: false,
      provider: "real",
      model: config.model,
      modelSource: config.modelSource,
      identities: models.length,
      manifestations: Object.keys(manifestations).length,
      contexts: models.length * MATCHED_SCENARIOS.length,
      artifactDirectory:
        "scripts/identity-reasoning/canonical-lens-production-preview/artifacts",
      productionWriteScope: [],
      sourceSha256,
      invalidIdentities: identityOfflineErrors.size,
      estimate,
    },
    null,
    2,
  ));
  Deno.exit(0);
}

const provider = buildOpenAIProvider(config.apiKey, config.model);
const artifacts = new URL("./artifacts/", import.meta.url);
const checkpointDirectory = new URL(
  "./artifacts/checkpoints/",
  import.meta.url,
);
await Deno.mkdir(checkpointDirectory, { recursive: true });
const completed = [];
let processed = 0;
for (
  let identityIndex = 0;
  identityIndex < models.length && processed < maxIdentities;
  identityIndex++
) {
  const model = models[identityIndex];
  const source = sources[identityIndex];
  const checkpointUrl = new URL(`${source.id}.json`, checkpointDirectory);
  let existing: Record<string, unknown> | null = null;
  try {
    existing = JSON.parse(await Deno.readTextFile(checkpointUrl));
  } catch { /* no completed checkpoint */ }
  if (existing) {
    if (existing.sourceSha256 !== sourceSha256) {
      throw new Error(
        `Checkpoint source mismatch for ${model.signPair}; preserve the old run and start a new versioned artifact directory.`,
      );
    }
    if (existing.status !== "aborted" || !retryAborted) {
      completed.push(existing);
      console.log(
        `[preview] resume ${identityIndex + 1}/144 ${model.signPair}`,
      );
      continue;
    }
    const historyDirectory = new URL(
      "./artifacts/checkpoints/history/",
      import.meta.url,
    );
    await Deno.mkdir(historyDirectory, { recursive: true });
    await Deno.writeTextFile(
      new URL(`${source.id}-${Date.now()}.json`, historyDirectory),
      JSON.stringify(existing, null, 2) + "\n",
    );
    console.log(
      `[preview] retry preserved aborted checkpoint ${model.signPair}`,
    );
  }
  const identityResult: Record<string, unknown> = {
    identity: model.signPair,
    sourceId: source.id,
    sourceSha256,
    status: "running",
    fixture: model,
    sourceTraceability: {
      file: "Resources/archetypes.json",
      sourceId: source.id,
      sourceSha256,
    },
    outputs: [],
    errors: [],
  };
  const localOfflineErrors = identityOfflineErrors.get(model.signPair) ?? [];
  if (localOfflineErrors.length) {
    identityResult.status = "aborted";
    identityResult.errors = localOfflineErrors;
    await Deno.writeTextFile(
      checkpointUrl,
      JSON.stringify(identityResult, null, 2) + "\n",
    );
    completed.push(identityResult);
    processed++;
    console.error(
      `[preview] skipped invalid identity ${model.signPair}: ${
        localOfflineErrors.join("; ")
      }`,
    );
    continue;
  }
  try {
    for (const scenario of MATCHED_SCENARIOS) {
      const context = buildFocusedContext(model, scenario, manifestations);
      const reasoning = buildReasoningPlan(context, manifestations);
      const errors = validateFocusedContext(context, reasoning, manifestations);
      if (errors.length) {
        throw new Error(`${scenario.arena}: ${errors.join("; ")}`);
      }
      const result = await writeModelLens(
        { context, reasoning, scenario },
        provider,
      );
      (identityResult.outputs as unknown[]).push({
        scenario,
        arena: scenario.arena,
        manifestation: manifestations[context.selected.manifestationKey!],
        context,
        reasoning,
        result,
      });
      console.log(
        `[preview] ${
          identityIndex + 1
        }/144 ${model.signPair} · ${scenario.arena} · ${
          result.accepted ? `accepted retry=${result.retryCount}` : "rejected"
        }`,
      );
      if (!result.accepted) {
        throw new Error(
          `${scenario.arena}: rejected after ${result.attempts.length} attempts`,
        );
      }
    }
    identityResult.status = "accepted";
  } catch (error) {
    identityResult.status = "aborted";
    (identityResult.errors as string[]).push(
      error instanceof Error ? error.message : String(error),
    );
    console.error(
      `[preview] aborted ${model.signPair}: ${
        (identityResult.errors as string[]).join("; ")
      }`,
    );
  }
  await Deno.writeTextFile(
    checkpointUrl,
    JSON.stringify(identityResult, null, 2) + "\n",
  );
  completed.push(identityResult);
  processed++;
}

const acceptedIdentities = completed.filter((identity) =>
  identity.status === "accepted"
);
const outputs = completed.flatMap((identity) =>
  Array.isArray(identity.outputs) ? identity.outputs : []
);
const acceptedOutputs = outputs.filter((output) => output.result?.accepted);
const summary = {
  developmentOnly: true,
  provider: provider.name,
  model: config.model,
  totalIdentities: completed.length,
  acceptedIdentities: acceptedIdentities.length,
  abortedIdentities: completed.length - acceptedIdentities.length,
  totalContextsAttempted: outputs.length,
  acceptedFirstAttempt:
    acceptedOutputs.filter((output) => output.result.retryCount === 0).length,
  acceptedAfterRetry:
    acceptedOutputs.filter((output) => output.result.retryCount > 0).length,
  rejected: outputs.filter((output) => !output.result?.accepted).length,
  totalCalls: outputs.reduce(
    (sum, output) => sum + (output.result?.attempts?.length ?? 0),
    0,
  ),
};
const generation = { ...summary, sourceSha256, identities: completed };
await Deno.mkdir(artifacts, { recursive: true });
await Deno.writeTextFile(
  new URL("generation-progress.json", artifacts),
  JSON.stringify(generation, null, 2) + "\n",
);
if (acceptedIdentities.length === 144 && acceptedOutputs.length === 1440) {
  await Deno.writeTextFile(
    new URL("complete-generation.json", artifacts),
    JSON.stringify(generation, null, 2) + "\n",
  );
}
console.log(JSON.stringify(summary, null, 2));
