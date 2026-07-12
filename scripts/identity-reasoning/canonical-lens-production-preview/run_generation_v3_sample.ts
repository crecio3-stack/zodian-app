import { resolveRealModelConfig } from "../canonical-lens-model/config.ts";
import type { CanonicalLens } from "../canonical-lens/types.ts";
import type { LensArena } from "../canonical-lens/types.ts";
import { validateCanonicalLens } from "../canonical-lens/validate.ts";
import type { ArenaManifestation } from "./manifestations.ts";
import { buildReliableOpenAIProvider } from "./reliable_provider.ts";
import type { TransportEvent } from "./reliable_provider.ts";
import { sourceFingerprint } from "./source.ts";
import { writeModelLensV3 } from "./v3_model_writer.ts";
import { modelWritingSystemFor } from "./v3_prompt.ts";
import {
  buildV32EditorialBrief,
  buildV3EditorialBrief,
  V2_CORPUS_EXCLUSIONS,
  V32_ABSTRACT_MECHANISMS,
  V32_PLANNING_TITLE_WORDS,
  V3_SAMPLE_IDENTITIES,
  v3SampleKeys,
} from "./v3_sample_plan.ts";

const real = Deno.args.includes("--real");
const preflight = Deno.args.includes("--preflight");
const v31 = Deno.args.includes("--v3-1");
const v32 = Deno.args.includes("--v3-2");
const full = Deno.args.includes("--full");
const retryRejected = Deno.args.includes("--retry-rejected");
if (v31 && v32) throw new Error("Choose only one prompt version.");
if (full && !v32) throw new Error("Full generation requires --v3-2.");
const artifactVersion = full ? "v3.2-full" : v32 ? "v3.2" : v31 ? "v3.1" : "v3";
const promptVersion = v32 ? "v3.2" : "v3.1";
const config = resolveRealModelConfig(Deno.env.toObject());
const base = new URL("./artifacts/", import.meta.url);
const paths = {
  library: new URL("canonical-library-v2.json", base),
  manifestations: new URL("manifestations-v2.json", base),
  contexts: new URL("context-audit-v2.json", base),
  checkpoints: new URL(
    `generation-${artifactVersion}-sample-checkpoints/`,
    base,
  ),
  generation: new URL(`generation-${artifactVersion}-sample.json`, base),
  summary: new URL(`generation-${artifactVersion}-sample-summary.json`, base),
};
const readJson = async (url: URL) => JSON.parse(await Deno.readTextFile(url));
const library = await readJson(paths.library);
const manifestationArtifact = await readJson(paths.manifestations);
const contextArtifact = await readJson(paths.contexts);
const manifestations = manifestationArtifact.manifestations as Record<
  string,
  ArenaManifestation
>;
type ContextRow = typeof contextArtifact.contexts[number];
const allContextRows = contextArtifact.contexts as ContextRow[];
const currentSourceSha256 = await sourceFingerprint();
if (
  [
    library.sourceSha256,
    manifestationArtifact.sourceSha256,
    contextArtifact.sourceSha256,
  ].some((hash) => hash !== currentSourceSha256)
) throw new Error("V3 preflight aborted before network: source hash mismatch.");

const sha256 = async (url: URL) => {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    await Deno.readFile(url),
  );
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
};
if (full) {
  const freeze = await readJson(new URL("v3.2-freeze.json", base));
  if (
    freeze.status !== "frozen_for_full_corpus_preview" ||
    freeze.sourceSha256 !== currentSourceSha256
  ) throw new Error("Full preflight aborted: v3.2 freeze is invalid.");
  for (
    const file of [
      "v3_prompt.ts",
      "v3_model_writer.ts",
      "v3_sample_plan.ts",
    ]
  ) {
    const actual = await sha256(new URL(file, import.meta.url));
    if (actual !== freeze.codeSha256[file]) {
      throw new Error(`Full preflight aborted: frozen file changed: ${file}`);
    }
  }
}

const arenas = [
  ...new Set(allContextRows.map((row) => row.arena)),
] as LensArena[];
const runIdentities: string[] = full
  ? library.identities.map((identity: { signPair: string }) =>
    identity.signPair
  )
  : [...V3_SAMPLE_IDENTITIES];
const expectedKeys = new Set(
  full
    ? runIdentities.flatMap((identity: string) =>
      arenas.map((arena) => `${identity}|${arena}`)
    )
    : v3SampleKeys(arenas),
);
const selectedRows = allContextRows.filter((row) =>
  expectedKeys.has(`${row.identity}|${row.arena}`)
);
const errors: string[] = [];
const expectedIdentityCount = full ? 144 : 18;
const expectedContextCount = full ? 1440 : 180;
if (runIdentities.length !== expectedIdentityCount) {
  errors.push(`expected ${expectedIdentityCount} identities`);
}
if (arenas.length !== 10) errors.push("expected 10 arenas");
if (selectedRows.length !== expectedContextCount) {
  errors.push(
    `expected ${expectedContextCount} contexts, found ${selectedRows.length}`,
  );
}
if (
  new Set(selectedRows.map((row) => `${row.identity}|${row.arena}`)).size !==
    expectedContextCount
) {
  errors.push("sample identity|arena keys are not unique");
}
for (const key of expectedKeys) {
  if (!manifestations[key]) errors.push(`missing manifestation ${key}`);
}
if (errors.length) {
  throw new Error(`V3 preflight aborted before network:\n${errors.join("\n")}`);
}
if (!real) throw new Error("Use --real --preflight or --real.");
if (!config.apiKey) {
  throw new Error(
    "V3 preflight aborted before network: OPENAI_API_KEY is missing.",
  );
}
if (config.model !== "gpt-5.6-terra") {
  throw new Error(
    `V3 preflight aborted before network: expected gpt-5.6-terra, resolved ${config.model}.`,
  );
}
if (preflight) {
  console.log(JSON.stringify(
    {
      passed: true,
      networkCall: false,
      developmentOnly: true,
      model: config.model,
      artifactVersion,
      sourceSha256: currentSourceSha256,
      identities: runIdentities.length,
      westernSigns: new Set(
        runIdentities.map((identity: string) => identity.split(" × ")[0]),
      ).size,
      chineseSigns: new Set(
        runIdentities.map((identity: string) => identity.split(" × ")[1]),
      ).size,
      arenas: arenas.length,
      contexts: selectedRows.length,
      fullCorpus: full,
      projectedProviderCalls: full ? 1496 : 187,
      projectedTotalTokens: full ? 4779656 : 597457,
      projectionBasis: full
        ? "linear scale from the accepted v3.2 sample with bounded 120-title prompt history"
        : "observed v3.2 sample",
      productionWritePaths: [],
      outputArtifact: paths.generation.pathname,
      checkpointDirectory: paths.checkpoints.pathname,
      priorV2ArtifactsOverwritten: false,
    },
    null,
    2,
  ));
  Deno.exit(0);
}

await Deno.mkdir(paths.checkpoints, { recursive: true });
const atomicWrite = async (url: URL, value: unknown) => {
  const temporary = new URL(
    `${url.pathname}.tmp-${crypto.randomUUID()}`,
    "file://",
  );
  await Deno.writeTextFile(temporary, JSON.stringify(value, null, 2) + "\n");
  await Deno.rename(temporary, url);
};
const sourceId = (identity: string) =>
  identity.toLowerCase().replace(" × ", "-");
type Output = {
  key: string;
  identity: string;
  arena: LensArena;
  scenarioId: string;
  editorialBrief: ReturnType<typeof buildV3EditorialBrief>;
  manifestation: ArenaManifestation;
  context: unknown;
  reasoning: unknown;
  transportEvents: TransportEvent[];
  result: Awaited<ReturnType<typeof writeModelLensV3>>;
};
type Checkpoint = {
  identity: string;
  sourceSha256: string;
  outputs: Output[];
  rejectedHistory?: Array<{
    archivedAt: string;
    output: Output;
  }>;
  updatedAt: string;
};
const checkpoints: Checkpoint[] = [];
const acceptedLenses = (): CanonicalLens[] =>
  checkpoints.flatMap((checkpoint) => checkpoint.outputs)
    .filter((output) => output.result.accepted)
    .map((output) => output.result.finalLens!);
const normalize = (value: string) =>
  value.toLowerCase().replace(/[^a-z0-9\s]/g, " ").trim().replace(/\s+/g, " ");
const introOpening = (value: string) =>
  normalize(value).split(" ").slice(0, 4).join(" ");
const titleRoot = (value: string) =>
  normalize(value).split(" ").find((word) =>
    !["a", "an", "the"].includes(word)
  ) ?? "";
const lensFields = [
  "title",
  "intro",
  "pull_quote",
  "deeper_read",
  "watch_for",
  "move",
] as const;
const counts = (values: string[]) =>
  values.reduce<Record<string, number>>(
    (map, value) => ({ ...map, [value]: (map[value] ?? 0) + 1 }),
    {},
  );

for (const identity of runIdentities) {
  const url = new URL(`${sourceId(identity)}.json`, paths.checkpoints);
  let checkpoint: Checkpoint;
  try {
    checkpoint = JSON.parse(await Deno.readTextFile(url));
    if (
      checkpoint.identity !== identity ||
      checkpoint.sourceSha256 !== currentSourceSha256
    ) {
      throw new Error(`invalid V3 checkpoint for ${identity}`);
    }
  } catch (error) {
    if (!(error instanceof Deno.errors.NotFound)) throw error;
    checkpoint = {
      identity,
      sourceSha256: currentSourceSha256,
      outputs: [],
      updatedAt: new Date().toISOString(),
    };
  }
  if (retryRejected) {
    const rejected = checkpoint.outputs.filter((output) =>
      !output.result.accepted
    );
    if (rejected.length) {
      const archivedAt = new Date().toISOString();
      checkpoint.rejectedHistory = [
        ...(checkpoint.rejectedHistory ?? []),
        ...rejected.map((output) => ({ archivedAt, output })),
      ];
      checkpoint.outputs = checkpoint.outputs.filter((output) =>
        output.result.accepted
      );
      checkpoint.updatedAt = archivedAt;
      await atomicWrite(url, checkpoint);
    }
  }
  checkpoints.push(checkpoint);
}

for (const checkpoint of checkpoints) {
  const identity = checkpoint.identity;
  const url = new URL(`${sourceId(identity)}.json`, paths.checkpoints);
  const existing = new Set(checkpoint.outputs.map((output) => output.key));
  for (
    const row of selectedRows.filter((candidate) =>
      candidate.identity === identity
    )
  ) {
    const key = `${identity}|${row.arena}`;
    if (existing.has(key)) continue;
    const current = acceptedLenses();
    const titleCounts = counts(current.map((lens) => normalize(lens.title)));
    const rootCounts = counts(
      current.map((lens) => titleRoot(lens.title)),
    );
    const openingCounts = counts(
      current.map((lens) => introOpening(lens.intro)),
    );
    const corpusScale = full
      ? Math.max(1, Math.ceil((current.length + 1) / 180))
      : 1;
    const titleRootLimit = 6 * corpusScale;
    const introOpeningLimit = 2 * corpusScale;
    const transportEvents: TransportEvent[] = [];
    const provider = buildReliableOpenAIProvider({
      apiKey: config.apiKey,
      model: config.model,
      instructions: modelWritingSystemFor(promptVersion),
      events: transportEvents,
      maxTransportRetries: 3,
      timeoutMs: 60_000,
    });
    const brief = v32
      ? buildV32EditorialBrief(identity, row.arena)
      : buildV3EditorialBrief(identity, row.arena);
    const blockedRoots = v32 ? [] : [...V2_CORPUS_EXCLUSIONS.titleRoots];
    const contextEvidence = normalize(JSON.stringify(row.context.selected));
    const result = await writeModelLensV3({
      request: {
        context: row.context,
        reasoning: row.reasoning,
        scenario: row.context.scenario,
      },
      provider,
      brief,
      promptVersion,
      guard: {
        recentTitles: current.map((lens) => lens.title),
        recentIntroOpenings: current.map((lens) => introOpening(lens.intro)),
        forbiddenTitles: Object.keys(titleCounts).slice(-120),
        forbiddenTitleRoots: [
          ...blockedRoots,
          ...Object.entries(rootCounts).filter(([, count]) =>
            count >= titleRootLimit
          ).map(([root]) => root),
        ],
        forbiddenIntroOpenings: Object.entries(openingCounts).filter(
          ([, count]) => count >= introOpeningLimit,
        ).map(([value]) => value),
      },
      additionalValidation: (lens) => {
        const reasons: string[] = [];
        const title = normalize(lens.title);
        const root = titleRoot(lens.title);
        const opening = introOpening(lens.intro);
        if (titleCounts[title]) {
          reasons.push("title duplicates an existing sample title");
        }
        if (rootCounts[root] >= titleRootLimit) {
          reasons.push("title repeats a saturated sample root");
        }
        if (openingCounts[opening] >= introOpeningLimit) {
          reasons.push("intro repeats a saturated sample opening");
        }
        if (
          V2_CORPUS_EXCLUSIONS.exactTitles.some((value) =>
            normalize(value) === title
          )
        ) {
          reasons.push("title repeats a blocked v2 title");
        }
        if (blockedRoots.includes(root as never)) {
          reasons.push("title repeats a blocked v2 root");
        }
        if (
          V2_CORPUS_EXCLUSIONS.introOpenings.some((value) =>
            normalize(lens.intro).startsWith(normalize(value))
          )
        ) reasons.push("intro repeats a blocked v2 opening");
        for (
          const field of ["intro", "pull_quote", "watch_for", "move"] as const
        ) {
          if (!/^[^.!?]*\.$/.test(lens[field])) {
            reasons.push(`${field} must end with one final period`);
          }
        }
        for (const field of ["pull_quote", "watch_for", "move"] as const) {
          if (/[;:\"“”]/.test(lens[field])) {
            reasons.push(
              `${field} must not contain dialogue punctuation, a colon, or a semicolon`,
            );
          }
        }
        if (v32 && /[.!?]$/.test(lens.title.trim())) {
          reasons.push("title must not end with punctuation");
        }
        if (v32) {
          for (const word of V32_PLANNING_TITLE_WORDS) {
            if (
              new RegExp(`\\b${word}\\b`, "i").test(title) &&
              !new RegExp(`\\b${word}\\b`, "i").test(contextEvidence)
            ) reasons.push(`title uses unsupported planning object ${word}`);
          }
          for (const field of lensFields) {
            const value = normalize(lens[field]);
            for (const phrase of V32_ABSTRACT_MECHANISMS) {
              if (value.includes(phrase)) {
                reasons.push(`${field} exposes abstract mechanism ${phrase}`);
              }
            }
          }
        }
        return reasons;
      },
    });
    const output: Output = {
      key,
      identity,
      arena: row.arena,
      scenarioId: row.scenarioId,
      editorialBrief: brief,
      manifestation: manifestations[key],
      context: row.context,
      reasoning: row.reasoning,
      transportEvents,
      result,
    };
    checkpoint.outputs.push(output);
    existing.add(key);
    checkpoint.updatedAt = new Date().toISOString();
    await atomicWrite(url, checkpoint);
    console.log(
      `[generation-${artifactVersion}-sample] ${key} · ${
        result.accepted ? `accepted retries=${result.retryCount}` : "rejected"
      }`,
    );
  }
}

const outputs = checkpoints.flatMap((checkpoint) => checkpoint.outputs);
const attempts = outputs.flatMap((output) => output.result.attempts);
const accepted = outputs.filter((output) => output.result.accepted);
const rejected = outputs.filter((output) => !output.result.accepted);
const totalTokens = attempts.reduce(
  (sum, attempt) => sum + Number(attempt.usage?.total_tokens ?? 0),
  0,
);
const summary = {
  developmentOnly: true,
  model: config.model,
  artifactVersion,
  sourceSha256: currentSourceSha256,
  identities: checkpoints.length,
  contexts: outputs.length,
  providerCalls: attempts.length,
  firstAttemptAcceptances:
    accepted.filter((output) => output.result.retryCount === 0).length,
  retryAcceptances:
    accepted.filter((output) => output.result.retryCount > 0).length,
  rejected: rejected.length,
  retryRate: outputs.length
    ? Number(
      (accepted.filter((output) => output.result.retryCount > 0).length /
        outputs.length * 100).toFixed(2),
    )
    : 0,
  validFieldPreservation: attempts.slice(1).every((attempt) =>
    attempt.validFieldsPreserved
  ),
  totalTokens,
  schemaValidationFailures:
    accepted.filter((output) =>
      !validateCanonicalLens(output.result.finalLens!).accepted
    ).length,
};
await Promise.all([
  atomicWrite(paths.generation, { ...summary, identities: checkpoints }),
  atomicWrite(paths.summary, summary),
]);
console.log(JSON.stringify(summary, null, 2));
