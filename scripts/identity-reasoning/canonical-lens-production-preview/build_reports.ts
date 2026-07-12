import { validateCanonicalLens } from "../canonical-lens/validate.ts";

type Lens = {
  title: string;
  intro: string;
  pull_quote: string;
  deeper_read: string;
  watch_for: string;
  move: string;
};
type Output = {
  arena: string;
  scenario: Record<string, unknown>;
  manifestation: Record<string, unknown>;
  context: Record<string, unknown>;
  reasoning: Record<string, unknown>;
  result: {
    accepted: boolean;
    retryCount: number;
    finalLens: Lens | null;
    attempts: Array<
      {
        parsedResponse?: Partial<Lens>;
        validation?: { accepted: boolean; reasons: string[] };
        usage?: Record<string, unknown>;
      }
    >;
  };
};
type IdentityResult = {
  identity: string;
  sourceId: string;
  status: string;
  fixture: Record<string, unknown>;
  sourceTraceability: Record<string, unknown>;
  outputs: Output[];
  errors: string[];
};

const artifacts = new URL("./artifacts/", import.meta.url);
const generationV2Url = new URL("generation-v2.json", artifacts);
const completeUrl = new URL("complete-generation.json", artifacts);
const progressUrl = new URL("generation-progress.json", artifacts);
let artifactVersion = "";
let generation: {
  identities: IdentityResult[];
  model?: string;
  provider?: string;
};
try {
  generation = JSON.parse(await Deno.readTextFile(generationV2Url));
  artifactVersion = "-v2";
} catch {
  try {
    generation = JSON.parse(await Deno.readTextFile(completeUrl));
  } catch {
    try {
      generation = JSON.parse(await Deno.readTextFile(progressUrl));
    } catch {
      throw new Error(
        "No generation artifact exists. Run run_generation_v2.ts --real first.",
      );
    }
  }
}

const stop = new Set(
  "a an and are as at be been before but by can could for from had has have if in into is it its of on one or our so than that the their them then there they this to under when while who will with you your"
    .split(" "),
);
const words = (text: string) =>
  text.toLowerCase().replace(/[’']/g, "").replace(/[^a-z0-9\s-]/g, " ").split(
    /\s+/,
  ).filter((word) => word.length > 1 && !stop.has(word));
const ngrams = (text: string) => {
  const ws = words(text);
  return [...ws, ...ws.slice(0, -1).map((w, i) => `${w}_${ws[i + 1]}`)];
};
const norm = (text: string) => words(text).join(" ");
const opening = (text: string, count = 3) =>
  words(text).slice(0, count).join(" ");
const firstVerb = (text: string) => words(text)[0] ?? "";
const overlap = (left: string, right: string) => {
  const a = new Set(words(left));
  const b = new Set(words(right));
  const union = new Set([...a, ...b]);
  return union.size ? [...a].filter((x) => b.has(x)).length / union.size : 0;
};
const lensText = (lens: Lens) => Object.values(lens).join(" ");
const countBy = (values: string[]) =>
  Object.entries(values.reduce<Record<string, number>>((map, value) => {
    map[value] = (map[value] ?? 0) + 1;
    return map;
  }, {})).sort((a, b) => b[1] - a[1]);

const allOutputs = generation.identities.flatMap((identity) =>
  (identity.outputs ?? []).map((output) => ({
    identity,
    output,
    lens: output.result.finalLens,
  }))
);
const outputs = allOutputs.filter((
  row,
): row is { identity: IdentityResult; output: Output; lens: Lens } =>
  Boolean(row.lens)
);
const documents = outputs.map((row) => ngrams(lensText(row.lens)));
const documentFrequency = new Map<string, number>();
for (const document of documents) {
  for (const term of new Set(document)) {
    documentFrequency.set(term, (documentFrequency.get(term) ?? 0) + 1);
  }
}
function vector(document: string[]): Map<string, number> {
  const counts = new Map<string, number>();
  for (const term of document) counts.set(term, (counts.get(term) ?? 0) + 1);
  const result = new Map<string, number>();
  for (const [term, count] of counts) {
    result.set(
      term,
      (count / document.length) *
        (Math.log(
          (documents.length + 1) / ((documentFrequency.get(term) ?? 0) + 1),
        ) + 1),
    );
  }
  return result;
}
const vectors = documents.map(vector);
function cosine(a: Map<string, number>, b: Map<string, number>): number {
  let dot = 0, aa = 0, bb = 0;
  for (const value of a.values()) aa += value * value;
  for (const value of b.values()) bb += value * value;
  for (const [key, value] of a) dot += value * (b.get(key) ?? 0);
  return aa && bb ? dot / Math.sqrt(aa * bb) : 0;
}

const leakageTerms = [
  "astrology",
  "zodiac",
  "horoscope",
  "planet",
  "venus",
  "mars",
  "mercury",
  "universe",
  "fate",
  "destiny",
  "retrograde",
];
const signNames = [
  "aries",
  "taurus",
  "gemini",
  "cancer",
  "leo",
  "virgo",
  "libra",
  "scorpio",
  "sagittarius",
  "capricorn",
  "aquarius",
  "pisces",
  "rat",
  "ox",
  "tiger",
  "rabbit",
  "dragon",
  "snake",
  "horse",
  "goat",
  "monkey",
  "rooster",
  "dog",
  "pig",
];
const unsupportedPatterns = [
  /\bwill definitely\b/i,
  /\bguaranteed\b/i,
  /\balways happens\b/i,
  /\bdiagnos(?:e|is|ed)\b/i,
  /\btrauma response\b/i,
  /\byour therapist\b/i,
];
const qaFlags: Array<Record<string, unknown>> = [];
let validationFailures = 0,
  leakage = 0,
  unsupportedInference = 0,
  retryPreservationFailures = 0;
for (const { identity, output, lens } of outputs) {
  const validation = validateCanonicalLens(lens);
  if (!validation.accepted) {
    validationFailures++;
    qaFlags.push({
      identity: identity.identity,
      arena: output.arena,
      type: "schema",
      reasons: validation.reasons,
    });
  }
  const text = lensText(lens).toLowerCase();
  const leaked = [...leakageTerms, ...signNames].filter((term) =>
    new RegExp(`\\b${term}\\b`, "i").test(text)
  );
  if (leaked.length) {
    leakage++;
    qaFlags.push({
      identity: identity.identity,
      arena: output.arena,
      type: "leakage",
      terms: leaked,
    });
  }
  const unsupported = unsupportedPatterns.filter((pattern) =>
    pattern.test(text)
  ).map(String);
  if (unsupported.length) {
    unsupportedInference++;
    qaFlags.push({
      identity: identity.identity,
      arena: output.arena,
      type: "unsupported_inference",
      patterns: unsupported,
    });
  }
  const attempts = output.result.attempts;
  for (let i = 1; i < attempts.length; i++) {
    const previous = attempts[i - 1].parsedResponse ?? {};
    const current = attempts[i].parsedResponse ?? {};
    const failedFields = new Set(
      (attempts[i - 1].validation?.reasons ?? []).map((reason) =>
        ["title", "intro", "pull_quote", "deeper_read", "watch_for", "move"]
          .find((field) => reason.startsWith(`${field} `))
      ).filter(Boolean),
    );
    const changedValid = [
      "title",
      "intro",
      "pull_quote",
      "deeper_read",
      "watch_for",
      "move",
    ].filter((field) =>
      !failedFields.has(field) &&
      previous[field as keyof Lens] !== current[field as keyof Lens]
    );
    if (changedValid.length) {
      retryPreservationFailures++;
      qaFlags.push({
        identity: identity.identity,
        arena: output.arena,
        type: "retry_field_preservation",
        attempt: i,
        changedValid,
      });
    }
  }
}

const titleCounts = countBy(outputs.map((row) => norm(row.lens.title)));
const titleRootCounts = countBy(
  outputs.map((row) => opening(row.lens.title, 1)),
);
const introOpeningCounts = countBy(
  outputs.map((row) => opening(row.lens.intro)),
);
const watchOpeningCounts = countBy(
  outputs.map((row) => opening(row.lens.watch_for)),
);
const moveVerbCounts = countBy(outputs.map((row) => firstVerb(row.lens.move)));
const behavioralFrames = countBy(
  outputs.map((row) =>
    `${firstVerb(row.lens.watch_for)}>${firstVerb(row.lens.move)}`
  ),
);
const reasoningStructures = countBy(
  outputs.map((row) =>
    `${firstVerb(String(row.output.reasoning.ordinaryLifeExpression ?? ""))}>${
      firstVerb(String(row.output.reasoning.naturalMove ?? ""))
    }`
  ),
);

const withinIdentity: Array<Record<string, unknown>> = [];
const crossIdentity: Array<Record<string, unknown>> = [];
const arenaSimilarity: Array<Record<string, unknown>> = [];
for (let i = 0; i < outputs.length; i++) {
  for (let j = i + 1; j < outputs.length; j++) {
    const a = outputs[i], b = outputs[j];
    const score = cosine(vectors[i], vectors[j]);
    if (a.identity.identity === b.identity.identity && score >= 0.72) {
      withinIdentity.push({
        identity: a.identity.identity,
        arenas: [a.output.arena, b.output.arena],
        score,
      });
    }
    if (
      a.output.arena === b.output.arena &&
      a.identity.identity !== b.identity.identity && score >= 0.68
    ) {
      crossIdentity.push({
        identities: [a.identity.identity, b.identity.identity],
        arena: a.output.arena,
        score,
      });
    }
    if (a.output.arena !== b.output.arena && score >= 0.85) {
      arenaSimilarity.push({
        identities: [a.identity.identity, b.identity.identity],
        arenas: [a.output.arena, b.output.arena],
        score,
      });
    }
  }
}
withinIdentity.sort((a, b) => Number(b.score) - Number(a.score));
crossIdentity.sort((a, b) => Number(b.score) - Number(a.score));
arenaSimilarity.sort((a, b) => Number(b.score) - Number(a.score));

const identityVectors = generation.identities.map((identity) =>
  vector(
    ngrams(
      (identity.outputs ?? []).filter((output) => output.result.finalLens).map((
        output,
      ) => lensText(output.result.finalLens!)).join(" "),
    ),
  )
);
const parent = generation.identities.map((_, index) => index);
const find = (index: number): number =>
  parent[index] === index ? index : parent[index] = find(parent[index]);
const union = (a: number, b: number) => {
  const left = find(a), right = find(b);
  if (left !== right) parent[right] = left;
};
for (let i = 0; i < identityVectors.length; i++) {
  for (let j = i + 1; j < identityVectors.length; j++) {
    if (cosine(identityVectors[i], identityVectors[j]) >= 0.58) union(i, j);
  }
}
const clusterMap = new Map<number, string[]>();
generation.identities.forEach((identity, index) => {
  const root = find(index);
  clusterMap.set(root, [...(clusterMap.get(root) ?? []), identity.identity]);
});
const clusters = [...clusterMap.values()].filter((members) =>
  members.length > 1
).map((members, index) => ({
  clusterId: index + 1,
  members,
  westernSigns: [...new Set(members.map((name) => name.split(" × ")[0]))],
  chineseSigns: [...new Set(members.map((name) => name.split(" × ")[1]))],
}));

const attempts = allOutputs.flatMap((row) => row.output.result.attempts);
const usage = attempts.map((attempt) => attempt.usage ?? {});
const inputTokens = usage.reduce(
  (sum, item) => sum + Number(item.input_tokens ?? 0),
  0,
);
const outputTokens = usage.reduce(
  (sum, item) => sum + Number(item.output_tokens ?? 0),
  0,
);
const totalTokens = usage.reduce(
  (sum, item) => sum + Number(item.total_tokens ?? 0),
  0,
);
const acceptedFirstAttempt =
  allOutputs.filter((row) =>
    row.output.result.accepted && row.output.result.retryCount === 0
  ).length;
const acceptedAfterRetry =
  allOutputs.filter((row) =>
    row.output.result.accepted && row.output.result.retryCount > 0
  ).length;
const rejected = allOutputs.filter((row) => !row.output.result.accepted).length;
const statistics = {
  developmentOnly: true,
  model: generation.model,
  provider: generation.provider,
  totalIdentities: generation.identities.length,
  acceptedIdentities:
    generation.identities.filter((identity) =>
      identity.status === "accepted" || identity.status === "complete"
    )
      .length,
  abortedIdentities:
    generation.identities.filter((identity) =>
      identity.status === "aborted" || identity.status === "partial"
    )
      .length,
  totalContexts: allOutputs.length,
  totalLLMCalls: attempts.length,
  totalRetries: attempts.length - allOutputs.length,
  acceptedFirstAttempt,
  acceptedAfterRetry,
  rejected,
  acceptancePercentage: allOutputs.length
    ? Number(
      ((allOutputs.length - rejected) / allOutputs.length * 100).toFixed(2),
    )
    : 0,
  retryPercentage: allOutputs.length
    ? Number((acceptedAfterRetry / allOutputs.length * 100).toFixed(2))
    : 0,
  averageTokens: attempts.length
    ? Number((totalTokens / attempts.length).toFixed(2))
    : 0,
  averageTokensPerOutput: allOutputs.length
    ? Number((totalTokens / allOutputs.length).toFixed(2))
    : 0,
  inputTokens,
  outputTokens,
  totalTokens,
};
const inputRate = Deno.env.get("OPENAI_INPUT_USD_PER_MILLION");
const outputRate = Deno.env.get("OPENAI_OUTPUT_USD_PER_MILLION");
const cost = {
  developmentOnly: true,
  inputTokens,
  outputTokens,
  inputRatePerMillion: inputRate ? Number(inputRate) : null,
  outputRatePerMillion: outputRate ? Number(outputRate) : null,
  estimatedProductionCostUsd: inputRate && outputRate
    ? Number(
      (inputTokens / 1_000_000 * Number(inputRate) +
        outputTokens / 1_000_000 * Number(outputRate)).toFixed(2),
    )
    : null,
  note: inputRate && outputRate
    ? "Calculated from explicit rates supplied to the report process."
    : "Set OPENAI_INPUT_USD_PER_MILLION and OPENAI_OUTPUT_USD_PER_MILLION for a dollar estimate; no model price was guessed.",
};
const qa = {
  developmentOnly: true,
  thresholds: {
    retryRateMaximum: 10,
    retryFieldPreservation: 100,
    leakage: 0,
    rejected: 0,
    exactTitleGlobalMaximum: 3,
    moveVerbGlobalShareMaximum: 0.15,
  },
  validationFailures,
  leakage,
  unsupportedInference,
  retryPreservationFailures,
  repeatedTitleRoots: titleRootCounts.filter(([, count]) =>
    count > Math.max(3, outputs.length * .08)
  ),
  repeatedOpenings: {
    intro: introOpeningCounts.filter(([, count]) =>
      count > Math.max(2, outputs.length * .03)
    ),
    watchFor: watchOpeningCounts.filter(([, count]) =>
      count > Math.max(2, outputs.length * .03)
    ),
  },
  repeatedMoveVerbs: moveVerbCounts.filter(([, count]) =>
    count > outputs.length * .15
  ),
  repeatedBehavioralFraming: behavioralFrames.filter(([, count]) => count > 3),
  repeatedReasoningStructures: reasoningStructures.filter(([, count]) =>
    count > 3
  ),
  repeatedExactTitles: titleCounts.filter(([, count]) => count > 3),
  flags: qaFlags,
  ready: generation.identities.length === 144 &&
    statistics.totalContexts === 1440 && statistics.rejected === 0 &&
    validationFailures === 0 && leakage === 0 &&
    statistics.retryPercentage <= 10 && retryPreservationFailures === 0,
};
const similarity = {
  developmentOnly: true,
  method: "TF-IDF cosine over word unigrams and bigrams",
  thresholds: {
    withinIdentityReview: .72,
    crossIdentitySameArenaReview: .68,
    critical: .85,
    cluster: .58,
  },
  withinIdentity,
  crossIdentity: crossIdentity.slice(0, 1000),
  arenaSimilarity: arenaSimilarity.slice(0, 1000),
  clusters,
};

const reviewDirectory = `review${artifactVersion}/`;
await Deno.mkdir(new URL(reviewDirectory, artifacts), { recursive: true });
const indexRows: Array<Record<string, unknown>> = [];
const reviewBook: string[] = [
  "# Canonical Lens production preview review book",
  "",
  `Generated identities: ${generation.identities.length}`,
  "",
];
for (let index = 0; index < generation.identities.length; index++) {
  const identity = generation.identities[index];
  const retryCount = (identity.outputs ?? []).reduce(
    (sum, output) => sum + output.result.retryCount,
    0,
  );
  const identityFlags = qaFlags.filter((flag) =>
    flag.identity === identity.identity
  );
  const lines = [
    `# ${String(index + 1).padStart(3, "0")} · ${identity.identity}`,
    "",
    `Status: ${identity.status}`,
    `Source: Resources/archetypes.json#${identity.sourceId}`,
    `Retries: ${retryCount}`,
    `QA flags: ${identityFlags.length}`,
    "",
    "## Canonical fixture",
    "",
    "```json",
    JSON.stringify(identity.fixture, null, 2),
    "```",
    "",
  ];
  for (const output of identity.outputs ?? []) {
    lines.push(
      `## ${output.arena}`,
      "",
      `Validator: ${output.result.accepted ? "accepted" : "rejected"}`,
      `Retries: ${output.result.retryCount}`,
      "",
      "### Manifestation",
      "",
      "```json",
      JSON.stringify(output.manifestation, null, 2),
      "```",
      "",
      "### Focused context and reasoning",
      "",
      "```json",
      JSON.stringify(
        { context: output.context, reasoning: output.reasoning },
        null,
        2,
      ),
      "```",
      "",
      "### Lens",
      "",
      "```json",
      JSON.stringify(output.result.finalLens, null, 2),
      "```",
      "",
      "### Attempt history",
      "",
      "```json",
      JSON.stringify(output.result.attempts, null, 2),
      "```",
      "",
    );
  }
  const path = `${reviewDirectory}${
    String(index + 1).padStart(3, "0")
  }-${identity.sourceId}.md`;
  await Deno.writeTextFile(new URL(path, artifacts), lines.join("\n"));
  reviewBook.push(...lines, "---", "");
  indexRows.push({
    index: index + 1,
    identity: identity.identity,
    sourceId: identity.sourceId,
    status: identity.status,
    outputs: identity.outputs?.length ?? 0,
    retries: retryCount,
    qaFlags: identityFlags.length,
    reviewPath: path,
  });
}
const reviewIndex = { developmentOnly: true, identities: indexRows };
const indexMarkdown = [
  "# Canonical Lens production preview review index",
  "",
  "| # | Identity | Status | Outputs | Retries | QA flags | Review |",
  "|---:|---|---|---:|---:|---:|---|",
  ...indexRows.map((row) =>
    `| ${row.index} | ${row.identity} | ${row.status} | ${row.outputs} | ${row.retries} | ${row.qaFlags} | [open](${row.reviewPath}) |`
  ),
  "",
].join("\n");
const jsonWrites: Array<[string, unknown]> = [
  [`qa-report${artifactVersion}.json`, qa],
  [`similarity-report${artifactVersion}.json`, similarity],
  [`statistics${artifactVersion}.json`, statistics],
  [`cost-report${artifactVersion}.json`, cost],
  [`review-index${artifactVersion}.json`, reviewIndex],
];
for (const [name, value] of jsonWrites) {
  await Deno.writeTextFile(
    new URL(name, artifacts),
    JSON.stringify(value, null, 2) + "\n",
  );
}
await Promise.all([
  Deno.writeTextFile(
    new URL(`review-book${artifactVersion}.md`, artifacts),
    reviewBook.join("\n"),
  ),
  Deno.writeTextFile(
    new URL(`review-index${artifactVersion}.md`, artifacts),
    indexMarkdown,
  ),
  Deno.writeTextFile(
    new URL(`qa-report${artifactVersion}.md`, artifacts),
    `# QA report\n\n- Ready: ${qa.ready}\n- Validation failures: ${validationFailures}\n- Leakage: ${leakage}\n- Unsupported-inference flags: ${unsupportedInference}\n- Retry preservation failures: ${retryPreservationFailures}\n- Repeated title roots: ${qa.repeatedTitleRoots.length}\n- Repeated move verbs: ${qa.repeatedMoveVerbs.length}\n`,
  ),
  Deno.writeTextFile(
    new URL(`similarity-report${artifactVersion}.md`, artifacts),
    `# Similarity report\n\n- Within-identity review pairs: ${withinIdentity.length}\n- Cross-identity same-arena review pairs: ${crossIdentity.length}\n- Critical cross-arena pairs: ${arenaSimilarity.length}\n- Semantic clusters: ${clusters.length}\n`,
  ),
  Deno.writeTextFile(
    new URL(`statistics${artifactVersion}.md`, artifacts),
    `# Statistics\n\n\`\`\`json\n${
      JSON.stringify(statistics, null, 2)
    }\n\`\`\`\n`,
  ),
  Deno.writeTextFile(
    new URL(`cost-report${artifactVersion}.md`, artifacts),
    `# Cost report\n\n\`\`\`json\n${JSON.stringify(cost, null, 2)}\n\`\`\`\n`,
  ),
]);
console.log(
  `Reports written for ${generation.identities.length} identities and ${outputs.length} accepted outputs. Ready=${qa.ready}.`,
);
