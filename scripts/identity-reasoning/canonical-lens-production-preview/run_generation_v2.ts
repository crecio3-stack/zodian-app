import { resolveRealModelConfig } from "../canonical-lens-model/config.ts";
import { writeModelLens } from "../canonical-lens-model/model_writer.ts";
import type { CanonicalIdentityModel } from "../canonical/types.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import {
  validateCanonicalEditorial,
  validateManifestationEditorial,
} from "./editorial_validate.ts";
import type { ArenaManifestation } from "./manifestations.ts";
import {
  validateFocusedContext,
  validateManifestation,
} from "./manifestations.ts";
import {
  buildReliableOpenAIProvider,
  ProviderAuthenticationError,
  type TransportEvent,
} from "./reliable_provider.ts";
import { sourceFingerprint } from "./source.ts";

const real = Deno.args.includes("--real");
const preflight = Deno.args.includes("--preflight");
const forceCase = Deno.args.find((arg) => arg.startsWith("--force-case="))
  ?.slice("--force-case=".length);
const config = resolveRealModelConfig(Deno.env.toObject());
const base = new URL("./artifacts/", import.meta.url);
const paths = {
  library: new URL("canonical-library-v2.json", base),
  manifestations: new URL("manifestations-v2.json", base),
  contexts: new URL("context-audit-v2.json", base),
  traceability: new URL("source-traceability-v2.json", base),
  editorial: new URL("editorial-audit-v2.json", base),
  checkpointDirectory: new URL("generation-v2-checkpoints/", base),
  checkpointIndex: new URL("generation-v2-checkpoint.json", base),
  generation: new URL("generation-v2.json", base),
  summary: new URL("generation-v2-summary.json", base),
  failures: new URL("generation-v2-failures.json", base),
  usage: new URL("generation-v2-usage.json", base),
  review: new URL("generation-v2-review-book.md", base),
};
const readJson = async (url: URL) => JSON.parse(await Deno.readTextFile(url));
const libraryArtifact = await readJson(paths.library);
const manifestationArtifact = await readJson(paths.manifestations);
const contextArtifact = await readJson(paths.contexts);
const traceabilityArtifact = await readJson(paths.traceability);
const editorialArtifact = await readJson(paths.editorial);
const models = libraryArtifact.identities as CanonicalIdentityModel[];
const manifestations = manifestationArtifact.manifestations as Record<
  string,
  ArenaManifestation
>;
const contextRows = contextArtifact.contexts as Array<
  {
    identity: string;
    scenarioId: string;
    arena: string;
    manifestationKey: string;
    context: Parameters<typeof validateFocusedContext>[0];
    reasoning: Parameters<typeof validateFocusedContext>[1];
    errors: string[];
  }
>;
const currentSourceSha256 = await sourceFingerprint();
const hashes = [
  libraryArtifact.sourceSha256,
  manifestationArtifact.sourceSha256,
  contextArtifact.sourceSha256,
  traceabilityArtifact.sourceSha256,
  editorialArtifact.sourceSha256,
];
if (hashes.some((hash) => hash !== currentSourceSha256)) {
  throw new Error(
    "Preflight aborted before network: v2 source SHA-256 mismatch.",
  );
}

const offlineErrors: string[] = [];
if (models.length !== 144) {
  offlineErrors.push(`expected 144 identities, found ${models.length}`);
}
if (Object.keys(manifestations).length !== 1440) {
  offlineErrors.push(
    `expected 1440 manifestations, found ${Object.keys(manifestations).length}`,
  );
}
if (contextRows.length !== 1440) {
  offlineErrors.push(`expected 1440 contexts, found ${contextRows.length}`);
}
const identityNames = new Set(models.map((model) => model.signPair));
if (identityNames.size !== 144) {
  offlineErrors.push("canonical identity names are not unique");
}
for (const model of models) {
  const schema = validateCanonicalIdentity(model);
  if (!schema.valid) {
    offlineErrors.push(`${model.signPair}: ${schema.errors.join("; ")}`);
  }
  const editorial = validateCanonicalEditorial(model);
  if (editorial.length) {
    offlineErrors.push(`${model.signPair}: ${editorial.join("; ")}`);
  }
}
for (const [key, manifestation] of Object.entries(manifestations)) {
  const errors = validateManifestation(key, manifestation).concat(
    validateManifestationEditorial(manifestation),
  );
  if (errors.length) offlineErrors.push(`${key}: ${errors.join("; ")}`);
}
for (const row of contextRows) {
  const errors = row.errors.concat(
    validateFocusedContext(row.context, row.reasoning, manifestations),
  );
  if (row.manifestationKey !== `${row.identity}|${row.arena}`) {
    errors.push("explicit identity|arena key mismatch");
  }
  if (errors.length) {
    offlineErrors.push(`${row.identity}|${row.arena}: ${errors.join("; ")}`);
  }
}
if (
  editorialArtifact.grammarFailures || editorialArtifact.fragmentFailures ||
  editorialArtifact.perspectiveFailures ||
  editorialArtifact.subjectVerbAgreementFailures
) offlineErrors.push("v2 editorial audit contains failures");
if (offlineErrors.length) {
  throw new Error(
    `Preflight aborted before network:\n${
      offlineErrors.slice(0, 100).join("\n")
    }`,
  );
}
if (!real) throw new Error("Use --real --preflight or --real.");
if (!config.apiKey) {
  throw new Error(
    "Preflight aborted before network: OPENAI_API_KEY is missing.",
  );
}
if (config.model !== "gpt-5.6-terra") {
  throw new Error(
    `Preflight aborted before network: expected gpt-5.6-terra, resolved ${config.model}.`,
  );
}
await Deno.mkdir(paths.checkpointDirectory, { recursive: true });
const probe = new URL(
  `.writable-${crypto.randomUUID()}`,
  paths.checkpointDirectory,
);
await Deno.writeTextFile(probe, "ok");
await Deno.remove(probe);
const estimate = {
  projectedCalls: 1548,
  projectedInputTokens: 1653768,
  projectedOutputTokens: 294228,
  projectedTotalTokens: 1947996,
  costFormula:
    "(input_tokens - cached_input_tokens) × input_rate + cached_input_tokens × cached_rate + output_tokens × output_rate; divide token terms by 1,000,000",
};
if (preflight) {
  console.log(JSON.stringify(
    {
      passed: true,
      networkCall: false,
      selectedModel: config.model,
      sourceSha256: currentSourceSha256,
      identities: models.length,
      manifestations: Object.keys(manifestations).length,
      contexts: contextRows.length,
      invalidFixtures: 0,
      invalidManifestations: 0,
      incompatibleContexts: 0,
      editorialFailures: 0,
      productionWritePaths: [],
      boundedConcurrency: 1,
      checkpointLocation: paths.checkpointDirectory.pathname,
      outputArtifactLocation: paths.generation.pathname,
      priorArtifactsOverwritten: false,
      ...estimate,
    },
    null,
    2,
  ));
  Deno.exit(0);
}

type OutputRecord = {
  key: string;
  arena: string;
  scenarioId: string;
  context: unknown;
  reasoning: unknown;
  manifestation: ArenaManifestation;
  result?: Awaited<ReturnType<typeof writeModelLens>>;
  transportEvents: TransportEvent[];
  retryFieldPreservation?: unknown;
  failure?: string;
};
type IdentityCheckpoint = {
  identity: string;
  sourceId: string;
  sourceSha256: string;
  status: "complete" | "partial" | "failed";
  archetypeName: string;
  centralParadox: string;
  sourceTraceability: unknown;
  outputs: OutputRecord[];
  errors: string[];
  updatedAt: string;
};
const atomicWrite = async (url: URL, value: unknown) => {
  const temporary = new URL(
    `${url.pathname}.tmp-${crypto.randomUUID()}`,
    "file://",
  );
  await Deno.writeTextFile(temporary, JSON.stringify(value, null, 2) + "\n");
  await Deno.rename(temporary, url);
};
const loadCheckpoint = async (
  model: CanonicalIdentityModel,
): Promise<IdentityCheckpoint> => {
  const url = new URL(
    `${model.westernSign.toLowerCase()}-${model.chineseSign.toLowerCase()}.json`,
    paths.checkpointDirectory,
  );
  try {
    const value = JSON.parse(
      await Deno.readTextFile(url),
    ) as IdentityCheckpoint;
    if (
      value.identity !== model.signPair ||
      value.sourceSha256 !== currentSourceSha256 ||
      new Set(value.outputs.map((output) => output.key)).size !==
        value.outputs.length
    ) throw new Error(`Corrupted checkpoint state for ${model.signPair}`);
    return value;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return {
        identity: model.signPair,
        sourceId:
          `${model.westernSign.toLowerCase()}-${model.chineseSign.toLowerCase()}`,
        sourceSha256: currentSourceSha256,
        status: "partial",
        archetypeName: model.archetypeName,
        centralParadox: model.core.centralParadox,
        sourceTraceability: traceabilityArtifact.identities[model.signPair],
        outputs: [],
        errors: [],
        updatedAt: new Date().toISOString(),
      };
    }
    throw error;
  }
};
const checkpointUrl = (checkpoint: IdentityCheckpoint) =>
  new URL(`${checkpoint.sourceId}.json`, paths.checkpointDirectory);
const outputFields = [
  "title",
  "intro",
  "pull_quote",
  "deeper_read",
  "watch_for",
  "move",
] as const;
const retryPreservation = (
  result: Awaited<ReturnType<typeof writeModelLens>>,
) =>
  result.attempts.slice(1).map((attempt, index) => {
    const previous = result.attempts[index];
    const failed = new Set(
      previous.validation.reasons.map((reason) =>
        outputFields.find((field) => reason.startsWith(`${field} `))
      ).filter(Boolean),
    );
    const before = previous.parsedResponse as Record<string, unknown> | null;
    const after = attempt.parsedResponse as Record<string, unknown> | null;
    const changedValidFields = before && after
      ? outputFields.filter((field) =>
        !failed.has(field) && before[field] !== after[field]
      )
      : [];
    return {
      editorialAttempt: attempt.attempt,
      priorErrors: previous.validation.reasons,
      changedValidFields,
      preserved: changedValidFields.length === 0,
    };
  });

const checkpoints: IdentityCheckpoint[] = [];
let consecutiveTransportFailures = 0;
let consecutiveSchemaRejections = 0;
const runStartedAt = new Date().toISOString();
for (const model of models) {
  const checkpoint = await loadCheckpoint(model);
  const forcedKey = forceCase?.startsWith(`${model.signPair}|`)
    ? forceCase
    : undefined;
  if (forcedKey) {
    checkpoint.outputs = checkpoint.outputs.filter((output) =>
      output.key !== forcedKey
    );
  }
  const existingKeys = new Set(checkpoint.outputs.map((output) => output.key));
  for (
    const row of contextRows.filter((candidate) =>
      candidate.identity === model.signPair
    )
  ) {
    const key = `${model.signPair}|${row.arena}`;
    if (existingKeys.has(key)) continue;
    const transportEvents: TransportEvent[] = [];
    const provider = buildReliableOpenAIProvider({
      apiKey: config.apiKey,
      model: config.model,
      events: transportEvents,
      maxTransportRetries: 3,
      timeoutMs: 60_000,
    });
    const output: OutputRecord = {
      key,
      arena: row.arena,
      scenarioId: row.scenarioId,
      context: row.context,
      reasoning: row.reasoning,
      manifestation: manifestations[key],
      transportEvents,
    };
    try {
      const result = await writeModelLens({
        context: row.context,
        reasoning: row.reasoning,
        scenario: row.context.scenario,
      }, provider);
      output.result = result;
      output.retryFieldPreservation = retryPreservation(result);
      consecutiveTransportFailures = 0;
      consecutiveSchemaRejections = result.accepted
        ? 0
        : consecutiveSchemaRejections + 1;
      if (consecutiveSchemaRejections >= 5) {
        throw new Error(
          "Systemic schema incompatibility: five consecutive outputs rejected after editorial retries.",
        );
      }
    } catch (error) {
      if (error instanceof ProviderAuthenticationError) throw error;
      output.failure = error instanceof Error ? error.message : String(error);
      consecutiveTransportFailures++;
      if (consecutiveTransportFailures >= 3) {
        throw new Error(
          "Provider-wide outage suspected after three consecutive exhausted transport failures.",
        );
      }
    }
    checkpoint.outputs.push(output);
    existingKeys.add(key);
    const accepted = checkpoint.outputs.filter((record) =>
      record.result?.accepted
    ).length;
    checkpoint.status = checkpoint.outputs.length === 10 && accepted === 10
      ? "complete"
      : accepted === 0 && checkpoint.outputs.length === 10
      ? "failed"
      : "partial";
    checkpoint.updatedAt = new Date().toISOString();
    await atomicWrite(checkpointUrl(checkpoint), checkpoint);
    console.log(
      `[generation-v2] ${model.signPair} · ${row.arena} · ${
        output.result?.accepted
          ? `accepted editorialRetries=${output.result.retryCount}`
          : "failed"
      }`,
    );
  }
  checkpoints.push(checkpoint);
  await atomicWrite(paths.checkpointIndex, {
    developmentOnly: true,
    sourceSha256: currentSourceSha256,
    model: config.model,
    identities: checkpoints.map((item) => ({
      identity: item.identity,
      status: item.status,
      outputs: item.outputs.length,
      accepted: item.outputs.filter((output) => output.result?.accepted).length,
      checkpoint: checkpointUrl(item).pathname,
    })),
  });
}

const allOutputs = checkpoints.flatMap((checkpoint) =>
  checkpoint.outputs.map((output) => ({ checkpoint, output }))
);
const calls = allOutputs.flatMap(({ output }) => output.result?.attempts ?? []);
const transportEvents = allOutputs.flatMap(({ output }) =>
  output.transportEvents
);
const acceptedFirstAttempt =
  allOutputs.filter(({ output }) =>
    output.result?.accepted && output.result.retryCount === 0
  ).length;
const acceptedAfterRetry =
  allOutputs.filter(({ output }) =>
    output.result?.accepted && (output.result.retryCount ?? 0) > 0
  ).length;
const rejected =
  allOutputs.filter(({ output }) => !output.result?.accepted).length;
const usageTotals = calls.reduce((totals, attempt) => {
  const usage = attempt.usage ?? {};
  const inputDetails = usage.input_tokens_details as
    | Record<string, unknown>
    | undefined;
  const outputDetails = usage.output_tokens_details as
    | Record<string, unknown>
    | undefined;
  totals.inputTokens += Number(usage.input_tokens ?? 0);
  totals.cachedInputTokens += Number(inputDetails?.cached_tokens ?? 0);
  totals.outputTokens += Number(usage.output_tokens ?? 0);
  totals.reasoningTokens += Number(outputDetails?.reasoning_tokens ?? 0);
  totals.totalTokens += Number(usage.total_tokens ?? 0);
  return totals;
}, {
  inputTokens: 0,
  cachedInputTokens: 0,
  outputTokens: 0,
  reasoningTokens: 0,
  totalTokens: 0,
});
const aggregate = (
  selector: (checkpoint: IdentityCheckpoint, output: OutputRecord) => string,
) =>
  Object.fromEntries(
    Object.entries(
      allOutputs.reduce<
        Record<
          string,
          {
            contexts: number;
            accepted: number;
            rejected: number;
            editorialRetries: number;
            transportRetries: number;
            tokens: number;
          }
        >
      >((map, { checkpoint, output }) => {
        const key = selector(checkpoint, output);
        const value = map[key] ??
          {
            contexts: 0,
            accepted: 0,
            rejected: 0,
            editorialRetries: 0,
            transportRetries: 0,
            tokens: 0,
          };
        value.contexts++;
        value.accepted += output.result?.accepted ? 1 : 0;
        value.rejected += output.result?.accepted ? 0 : 1;
        value.editorialRetries += output.result?.retryCount ?? 0;
        value.transportRetries += output.transportEvents.filter((event) =>
          event.status === "retry"
        ).length;
        value.tokens += (output.result?.attempts ?? []).reduce(
          (sum, attempt) => sum + Number(attempt.usage?.total_tokens ?? 0),
          0,
        );
        map[key] = value;
        return map;
      }, {}),
    ),
  );
const latencies = transportEvents.filter((event) => event.status === "accepted")
  .map((event) => event.latencyMs).sort((a, b) => a - b);
const percentile = (p: number) =>
  latencies.length
    ? latencies[
      Math.min(latencies.length - 1, Math.floor(latencies.length * p))
    ]
    : 0;
const summary = {
  developmentOnly: true,
  sourceSha256: currentSourceSha256,
  provider: `openai:${config.model}`,
  model: config.model,
  runStartedAt,
  runCompletedAt: new Date().toISOString(),
  totalIdentitiesProcessed: checkpoints.length,
  totalContextsAttempted: allOutputs.length,
  totalProviderCalls: calls.length,
  transportRetries:
    transportEvents.filter((event) => event.status === "retry").length,
  firstAttemptAcceptances: acceptedFirstAttempt,
  editorialRetryAcceptances: acceptedAfterRetry,
  rejections: rejected,
  completeIdentities:
    checkpoints.filter((checkpoint) => checkpoint.status === "complete").length,
  partialIdentities:
    checkpoints.filter((checkpoint) => checkpoint.status === "partial").length,
  failedIdentities:
    checkpoints.filter((checkpoint) => checkpoint.status === "failed").length,
  usage: usageTotals,
  latencyMs: {
    count: latencies.length,
    average: latencies.length
      ? Math.round(
        latencies.reduce((sum, value) => sum + value, 0) / latencies.length,
      )
      : 0,
    p50: percentile(.5),
    p95: percentile(.95),
    maximum: latencies.at(-1) ?? 0,
  },
  mechanicalSuccess: allOutputs.length === 1440 &&
    acceptedFirstAttempt + acceptedAfterRetry >= 1425 && rejected <= 15 &&
    checkpoints.every((checkpoint) =>
      checkpoint.outputs.filter((output) => !output.result?.accepted).length <=
        2
    ),
};
const failures = allOutputs.filter(({ output }) => !output.result?.accepted)
  .map(({ checkpoint, output }) => ({
    identity: checkpoint.identity,
    arena: output.arena,
    key: output.key,
    failure: output.failure,
    attempts: output.result?.attempts ?? [],
    transportEvents: output.transportEvents,
  }));
const usage = {
  developmentOnly: true,
  formula: estimate.costFormula,
  totals: usageTotals,
  byIdentity: aggregate((checkpoint) => checkpoint.identity),
  byWesternSign: aggregate((checkpoint) => checkpoint.identity.split(" × ")[0]),
  byChineseSign: aggregate((checkpoint) => checkpoint.identity.split(" × ")[1]),
  byArena: aggregate((_checkpoint, output) => output.arena),
};
const generation = {
  developmentOnly: true,
  sourceSha256: currentSourceSha256,
  provider: `openai:${config.model}`,
  model: config.model,
  summary,
  identities: checkpoints,
};
const review = [
  "# Canonical Lens production preview generation v2",
  "",
  `Source: ${currentSourceSha256}`,
  `Model: ${config.model}`,
  "",
  ...checkpoints.flatMap((
    checkpoint,
  ) => [
    `## ${checkpoint.identity} · ${checkpoint.archetypeName}`,
    "",
    `Status: ${checkpoint.status} · Accepted: ${
      checkpoint.outputs.filter((output) => output.result?.accepted).length
    }/10`,
    `Central paradox: ${checkpoint.centralParadox}`,
    "",
    ...checkpoint.outputs.flatMap((
      output,
    ) => [
      `### ${output.arena}`,
      "",
      `Validation: ${
        output.result?.accepted ? "accepted" : "rejected"
      } · Editorial retries: ${
        output.result?.retryCount ?? 0
      } · Transport retries: ${
        output.transportEvents.filter((event) => event.status === "retry")
          .length
      }`,
      "",
      "```json",
      JSON.stringify(
        output.result?.finalLens ?? { failure: output.failure },
        null,
        2,
      ),
      "```",
      "",
      `Traceability: ${output.manifestation.sourcePaths.join(", ")}`,
      "",
    ]),
    "---",
    "",
  ]),
  "",
].join("\n");
await Promise.all([
  atomicWrite(paths.generation, generation),
  atomicWrite(paths.summary, summary),
  atomicWrite(paths.failures, { developmentOnly: true, failures }),
  atomicWrite(paths.usage, usage),
  Deno.writeTextFile(paths.review, review),
]);
console.log(JSON.stringify(summary, null, 2));
