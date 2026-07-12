import { resolveRealModelConfig } from "../canonical-lens-model/config.ts";
import type { CanonicalLens } from "../canonical-lens/types.ts";
import { validateCanonicalLens } from "../canonical-lens/validate.ts";
import { buildReliableOpenAIProvider } from "./reliable_provider.ts";
import type { TransportEvent } from "./reliable_provider.ts";
import { V32_MODEL_WRITING_SYSTEM } from "./v3_prompt.ts";
import {
  V2_CORPUS_EXCLUSIONS,
  V32_ABSTRACT_MECHANISMS,
  V32_PLANNING_TITLE_WORDS,
} from "./v3_sample_plan.ts";

const real = Deno.args.includes("--real");
const preflight = Deno.args.includes("--preflight");
const config = resolveRealModelConfig(Deno.env.toObject());
const base = new URL("./artifacts/", import.meta.url);
const paths = {
  source: new URL("generation-v3.2-full-sample.json", base),
  sourceQa: new URL("qa-report-v3.2-full-sample.json", base),
  sourceQaMarkdown: new URL("qa-report-v3.2-full-sample.md", base),
  sourceCorpusMarkdown: new URL("corpus-audit-v3.2-full.md", base),
  freeze: new URL("v3.2-freeze.json", base),
  run: new URL("generation-v3.2-full-repair.json", base),
  attempts: new URL("generation-v3.2-full-repair-attempts.json", base),
  repaired: new URL("generation-v3.2-full-repaired.json", base),
  qa: new URL("qa-report-v3.2-full-repaired.json", base),
  qaMarkdown: new URL("qa-report-v3.2-full-repaired.md", base),
  corpusMarkdown: new URL("corpus-audit-v3.2-full-repaired.md", base),
};
const EXPECTED_SOURCE_SHA =
  "d77dfc34e0a8367dcab3eac37bc939e1c3c82dd8dfe4d78d55ca12a764c7e58d";
const fields = [
  "title",
  "intro",
  "pull_quote",
  "deeper_read",
  "watch_for",
  "move",
] as const;
type Field = typeof fields[number];
type Target = {
  key: string;
  identity: string;
  arena: string;
  field: Field;
  reason: string;
  before: string;
};
const EXPECTED_TARGETS = [
  "Leo × Goat|rest|title",
  "Virgo × Dragon|confidence|title",
  "Virgo × Horse|confidence|title",
  "Virgo × Pig|routine|title",
  "Virgo × Rabbit|money|title",
  "Virgo × Rooster|money|title",
  "Virgo × Snake|money|title",
  "Libra × Monkey|love|intro",
  "Aquarius × Tiger|love|intro",
  "Cancer × Goat|love|intro",
  "Libra × Tiger|work|title",
  "Aquarius × Dog|money|pull_quote",
  "Leo × Rat|money|pull_quote",
].sort();
const literaryPatterns = [
  /\bgently closes\b/i,
  /\bquietly asks\b/i,
  /\bthe space between\b/i,
  /\bdoor it .{0,20} closes\b/i,
  /\bsoftly opens\b/i,
];
const unsupportedPatterns = [
  /\bwill definitely\b/i,
  /\bguaranteed\b/i,
  /\balways happens\b/i,
  /\btrauma response\b/i,
  /\byour therapist\b/i,
];
const planningFallbackTitles = [
  "a better way",
  "a new choice",
  "moving forward",
  "the next step",
  "choose again",
];

const readJson = async (url: URL) => JSON.parse(await Deno.readTextFile(url));
const sha256Bytes = async (bytes: Uint8Array) => {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new Uint8Array(bytes).buffer as ArrayBuffer,
  );
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
};
const sha256File = async (url: URL) => sha256Bytes(await Deno.readFile(url));
const sha256Text = async (value: string) =>
  sha256Bytes(new TextEncoder().encode(value));
const atomicWrite = async (url: URL, value: unknown) => {
  const temporary = new URL(
    `${url.pathname}.tmp-${crypto.randomUUID()}`,
    "file://",
  );
  await Deno.writeTextFile(temporary, JSON.stringify(value, null, 2) + "\n");
  await Deno.rename(temporary, url);
};
const normalize = (value: string) =>
  value.toLowerCase().replace(/[^a-z0-9\s]/g, " ").trim().replace(/\s+/g, " ");
const titleRoot = (value: string) =>
  normalize(value).split(" ").find((word) =>
    !["a", "an", "the"].includes(word)
  ) ?? "";
const opening = (value: string) =>
  normalize(value).split(" ").slice(0, 4).join(" ");
const words = (value: string) =>
  normalize(value).split(" ").filter((word) =>
    word.length > 2 &&
    ![
      "the",
      "and",
      "you",
      "your",
      "that",
      "this",
      "with",
      "from",
      "when",
      "into",
      "for",
      "one",
    ].includes(word)
  );
const jaccard = (left: string, right: string) => {
  const a = new Set(words(left)), b = new Set(words(right));
  const union = new Set([...a, ...b]);
  return union.size
    ? [...a].filter((word) => b.has(word)).length / union.size
    : 0;
};
const lensText = (lens: CanonicalLens) => Object.values(lens).join(" ");

const generation = await readJson(paths.source);
const sourceQa = await readJson(paths.sourceQa);
const freeze = await readJson(paths.freeze);
const sourceQaMarkdown = await Deno.readTextFile(paths.sourceQaMarkdown);
const sourceCorpusMarkdown = await Deno.readTextFile(
  paths.sourceCorpusMarkdown,
);
if (await sha256File(paths.source) !== EXPECTED_SOURCE_SHA) {
  throw new Error(
    "Repair preflight aborted: frozen full-corpus artifact hash changed.",
  );
}
if (
  freeze.status !== "frozen_for_full_corpus_preview" ||
  generation.sourceSha256 !== freeze.sourceSha256
) {
  throw new Error(
    "Repair preflight aborted: frozen v3.2 source fingerprint mismatch.",
  );
}
for (
  const file of ["v3_prompt.ts", "v3_model_writer.ts", "v3_sample_plan.ts"]
) {
  const actual = await sha256File(new URL(file, import.meta.url));
  if (actual !== freeze.codeSha256[file]) {
    throw new Error(`Repair preflight aborted: frozen file changed: ${file}`);
  }
}
if (
  !sourceQaMarkdown.includes("Rejected: 7") ||
  !sourceQaMarkdown.includes("Standalone conjunction openings: 3") ||
  !sourceQaMarkdown.includes("Literary-vagueness flags: 3") ||
  !sourceCorpusMarkdown.includes("Rejected: 7")
) throw new Error("Repair preflight aborted: source report counts changed.");

const outputRows = generation.identities.flatMap((
  identity: { outputs: unknown[] },
) => identity.outputs) as Array<Record<string, any>>;
if (outputRows.length !== 1440) {
  throw new Error("Repair preflight aborted: expected 1440 outputs.");
}
const outputByKey = new Map(outputRows.map((output) => [output.key, output]));
const effectiveLens = (output: Record<string, any>): CanonicalLens => {
  const lens = output.result.finalLens ??
    output.result.attempts.at(-1)?.mergedCandidate;
  if (!lens || !validateCanonicalLens(lens).accepted) {
    throw new Error(
      `Repair preflight aborted: no schema-valid current Lens for ${output.key}.`,
    );
  }
  return lens;
};
const derivedTargets: Target[] = [];
for (const output of outputRows.filter((row) => !row.result.accepted)) {
  const reasons = output.result.attempts.at(-1).validation.reasons as string[];
  if (
    !reasons.length || reasons.some((reason) => !reason.startsWith("title "))
  ) {
    throw new Error(
      `Repair preflight aborted: unexpected rejected field for ${output.key}.`,
    );
  }
  derivedTargets.push({
    key: output.key,
    identity: output.identity,
    arena: output.arena,
    field: "title",
    reason: reasons.join("; "),
    before: effectiveLens(output).title,
  });
}
for (
  const flag of sourceQa.standaloneOpeningFlags as Array<
    { key: string; intro: string }
  >
) {
  const output = outputByKey.get(flag.key)!;
  derivedTargets.push({
    key: flag.key,
    identity: output.identity,
    arena: output.arena,
    field: "intro",
    reason: "intro begins with a standalone conjunction",
    before: effectiveLens(output).intro,
  });
}
for (
  const flag of sourceQa.literaryVaguenessFlags as Array<
    { key: string; patterns: string[] }
  >
) {
  const output = outputByKey.get(flag.key)!;
  const lens = effectiveLens(output);
  const matching = fields.filter((field) =>
    literaryPatterns.some((pattern) => pattern.test(lens[field]))
  );
  if (matching.length !== 1) {
    throw new Error(
      `Repair preflight aborted: literary field ambiguity for ${flag.key}.`,
    );
  }
  derivedTargets.push({
    key: flag.key,
    identity: output.identity,
    arena: output.arena,
    field: matching[0],
    reason: `field triggered literary-vagueness audit: ${
      flag.patterns.join("; ")
    }`,
    before: lens[matching[0]],
  });
}
const targetIds = derivedTargets.map((target) =>
  `${target.key}|${target.field}`
).sort();
if (
  derivedTargets.length !== 13 ||
  new Set(targetIds).size !== 13 ||
  JSON.stringify(targetIds) !== JSON.stringify(EXPECTED_TARGETS)
) {
  throw new Error(
    `Repair preflight aborted: repair scope differs from 13 exact fields.\n${
      targetIds.join("\n")
    }`,
  );
}
const targetSet = new Set(targetIds);
const fieldSnapshot = (overrides = new Map<string, string>()) =>
  outputRows.flatMap((output) => {
    const lens = effectiveLens(output);
    return fields.map((field) => {
      const id = `${output.key}|${field}`;
      return `${id}\u0000${overrides.get(id) ?? lens[field]}`;
    });
  }).sort();
const nonTargetHash = async (overrides = new Map<string, string>()) =>
  sha256Text(
    fieldSnapshot(overrides).filter((row) =>
      !targetSet.has(row.slice(0, row.indexOf("\u0000")))
    ).join("\n"),
  );
const baselineNonTargetHash = await nonTargetHash();
const baselineEffectiveHash = await sha256Text(fieldSnapshot().join("\n"));

if (!real) throw new Error("Use --real --preflight or --real.");
if (!config.apiKey) {
  throw new Error("Repair preflight aborted: OPENAI_API_KEY is missing.");
}
if (config.model !== "gpt-5.6-terra") {
  throw new Error(
    `Repair preflight aborted: expected gpt-5.6-terra, resolved ${config.model}.`,
  );
}
if (preflight) {
  console.log(JSON.stringify(
    {
      passed: true,
      networkCall: false,
      developmentOnly: true,
      model: config.model,
      sourceArtifactSha256: EXPECTED_SOURCE_SHA,
      sourceSha256: generation.sourceSha256,
      outputs: outputRows.length,
      targets: derivedTargets.map(({ key, field, reason, before }) => ({
        key,
        field,
        reason,
        before,
      })),
      targetCount: derivedTargets.length,
      nonTargetFieldHash: baselineNonTargetHash,
      baselineEffectiveFieldHash: baselineEffectiveHash,
      originalArtifactsOverwritten: false,
      productionWritePaths: [],
      outputArtifacts: Object.fromEntries(
        Object.entries(paths).filter(([key]) =>
          ["run", "attempts", "repaired", "qa", "qaMarkdown", "corpusMarkdown"]
            .includes(key)
        )
          .map(([key, url]) => [key, (url as URL).pathname]),
      ),
    },
    null,
    2,
  ));
  Deno.exit(0);
}

type RepairAttempt = {
  attempt: number;
  prompt: string;
  rawResponse: string | null;
  parsedResponse: unknown;
  validation: { accepted: boolean; reasons: string[] };
  usage?: Record<string, unknown>;
  transportEvents: TransportEvent[];
};
type RepairRecord = Target & {
  accepted: boolean;
  after: string | null;
  attempts: RepairAttempt[];
};
type Ledger = {
  developmentOnly: true;
  sourceArtifactSha256: string;
  sourceSha256: string;
  baselineNonTargetHash: string;
  repairs: RepairRecord[];
};
let ledger: Ledger = {
  developmentOnly: true,
  sourceArtifactSha256: EXPECTED_SOURCE_SHA,
  sourceSha256: generation.sourceSha256,
  baselineNonTargetHash,
  repairs: [],
};
try {
  const existing = await readJson(paths.attempts) as Ledger;
  if (
    existing.sourceArtifactSha256 !== EXPECTED_SOURCE_SHA ||
    existing.baselineNonTargetHash !== baselineNonTargetHash
  ) throw new Error("Existing repair ledger does not match frozen source.");
  ledger = existing;
} catch (error) {
  if (!(error instanceof Deno.errors.NotFound)) throw error;
}
const overrides = new Map<string, string>(
  ledger.repairs.filter((repair) => repair.accepted && repair.after).map((
    repair,
  ) => [
    `${repair.key}|${repair.field}`,
    repair.after!,
  ]),
);
const currentLensFor = (output: Record<string, any>): CanonicalLens => {
  const lens = { ...effectiveLens(output) };
  for (const field of fields) {
    const override = overrides.get(`${output.key}|${field}`);
    if (override !== undefined) lens[field] = override;
  }
  return lens;
};
const leakageTerms = [
  "astrology",
  "zodiac",
  "horoscope",
  "planet",
  "universe",
  "fate",
  "destiny",
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

function exclusionsFor(target: Target, current: CanonicalLens) {
  const otherRows = outputRows.filter((output) => output.key !== target.key);
  const titles = otherRows.map((output) => currentLensFor(output).title);
  const rootCounts = titles.reduce<Record<string, number>>((map, title) => {
    const root = titleRoot(title);
    map[root] = (map[root] ?? 0) + 1;
    return map;
  }, {});
  const openings = otherRows.map((output) =>
    opening(currentLensFor(output).intro)
  );
  const openingCounts = openings.reduce<Record<string, number>>(
    (map, value) => {
      map[value] = (map[value] ?? 0) + 1;
      return map;
    },
    {},
  );
  const sameArenaSimilarTitles = otherRows.filter((output) =>
    output.arena === target.arena
  )
    .map((output) => ({
      key: output.key,
      title: currentLensFor(output).title,
      score: jaccard(lensText(current), lensText(currentLensFor(output))),
    })).sort((left, right) => right.score - left.score).slice(0, 20);
  const identityOtherTitles = otherRows.filter((output) =>
    output.identity === target.identity
  )
    .map((output) => ({
      key: output.key,
      title: currentLensFor(output).title,
    }));
  return {
    allExistingTitles: titles,
    saturatedContentWordRoots: Object.entries(rootCounts).filter(([, count]) =>
      count >= 48
    )
      .map(([root]) => root),
    saturatedIntroOpenings: Object.entries(openingCounts).filter(([, count]) =>
      count >= 16
    )
      .map(([value]) => value),
    blockedV2Titles: V2_CORPUS_EXCLUSIONS.exactTitles,
    identityOtherTitles,
    sameArenaSimilarTitles,
    forbiddenStandaloneOpenings: ["But", "And", "So"],
    forbiddenLiteraryPatterns: literaryPatterns.map(String),
    forbiddenPlanningTitleWords: V32_PLANNING_TITLE_WORDS,
    genericFallbackTitles: planningFallbackTitles,
  };
}

const contractFor = (target: Target) =>
  target.field === "title"
    ? "Return a natural editorial title of 2-4 words with no terminal punctuation. It must be unique, reflect this Lens rather than merely its arena, avoid saturated roots, blocked titles, generic fallbacks, forced synonym substitution, strategy-document nouns, astrology, and identity terminology."
    : target.field === "intro"
    ? "Return one complete standalone sentence of 12-22 words. Preserve the same behavioral observation. Do not begin with But, And, or So. Add no motive, event, prediction, or generic time-of-day language."
    : "Preserve the exact underlying meaning in one immediately understandable sentence of 12-22 words. Replace vague metaphor with concrete behavior; do not introduce self-help, strategy, or another metaphor.";

function buildRepairPrompt(
  target: Target,
  current: CanonicalLens,
  errors: string[],
  exclusions: ReturnType<typeof exclusionsFor>,
) {
  return `Development-only frozen v3.2 field repair. Return JSON only.

Identity: ${target.identity}
Arena: ${target.arena}
Focused context:
${JSON.stringify(outputByKey.get(target.key)!.context, null, 2)}

Current full Lens for reference:
${JSON.stringify(current, null, 2)}

Repair exactly this field: ${target.field}
Exact error:
${errors.join("; ")}

Corpus exclusions relevant to this field:
${JSON.stringify(exclusions, null, 2)}

Repair contract:
${contractFor(target)}

Return a JSON object containing exactly one key, ${
    JSON.stringify(target.field)
  }. Do not return or rewrite any other field.`;
}

function validatePatch(
  target: Target,
  current: CanonicalLens,
  raw: string,
  exclusions: ReturnType<typeof exclusionsFor>,
): { parsed: unknown; value: string | null; reasons: string[] } {
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return { parsed: null, value: null, reasons: ["patch is not valid JSON"] };
  }
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    return { parsed, value: null, reasons: ["patch must be a JSON object"] };
  }
  const object = parsed as Record<string, unknown>;
  if (JSON.stringify(Object.keys(object)) !== JSON.stringify([target.field])) {
    return {
      parsed,
      value: null,
      reasons: [`patch must contain exactly ${target.field}`],
    };
  }
  if (typeof object[target.field] !== "string") {
    return {
      parsed,
      value: null,
      reasons: [`${target.field} must be a string`],
    };
  }
  const value = object[target.field] as string;
  const reasons: string[] = [];
  if (value === current[target.field]) {
    reasons.push(`${target.field} did not change`);
  }
  const merged = { ...current, [target.field]: value };
  reasons.push(
    ...validateCanonicalLens(merged).reasons.filter((reason) =>
      reason.startsWith(`${target.field} `) || reason.includes(target.field)
    ),
  );
  const text = Object.values(merged).join(" ");
  const leaked = leakageTerms.filter((term) =>
    new RegExp(`\\b${term}\\b`, "i").test(text)
  );
  if (leaked.length) {
    reasons.push(`identity or astrology leakage: ${leaked.join(", ")}`);
  }
  if (unsupportedPatterns.some((pattern) => pattern.test(text))) {
    reasons.push("unsupported inference pattern");
  }
  if (target.field === "title") {
    const normalized = normalize(value);
    if (/[.!?]$/.test(value.trim())) {
      reasons.push("title must not end with punctuation");
    }
    if (
      exclusions.allExistingTitles.some((title) =>
        normalize(title) === normalized
      )
    ) {
      reasons.push("title duplicates an existing full-corpus title");
    }
    if (exclusions.saturatedContentWordRoots.includes(titleRoot(value))) {
      reasons.push("title uses a saturated content-word root");
    }
    if (
      exclusions.blockedV2Titles.some((title) =>
        normalize(title) === normalized
      )
    ) {
      reasons.push("title repeats a blocked v2 title");
    }
    if (planningFallbackTitles.includes(normalized)) {
      reasons.push("title is a generic fallback");
    }
    const contextText = normalize(
      JSON.stringify(outputByKey.get(target.key)!.context),
    );
    for (const word of V32_PLANNING_TITLE_WORDS) {
      if (
        new RegExp(`\\b${word}\\b`, "i").test(normalized) &&
        !new RegExp(`\\b${word}\\b`, "i").test(contextText)
      ) {
        reasons.push(`title uses unsupported strategy-document noun ${word}`);
      }
    }
  }
  if (target.field === "intro") {
    if (/^(but|and|so)\b/i.test(value.trim())) {
      reasons.push("intro begins with a conjunction");
    }
    if (
      /\b(this morning|this afternoon|this evening|tonight|today)\b/i.test(
        value,
      )
    ) {
      reasons.push("intro adds generic time-of-day language");
    }
    if (exclusions.saturatedIntroOpenings.includes(opening(value))) {
      reasons.push("intro uses a saturated opening");
    }
  }
  if (target.reason.includes("literary-vagueness")) {
    if (literaryPatterns.some((pattern) => pattern.test(value))) {
      reasons.push(`${target.field} remains literarily vague`);
    }
  }
  for (const phrase of V32_ABSTRACT_MECHANISMS) {
    if (normalize(value).includes(phrase)) {
      reasons.push(`${target.field} exposes abstract mechanism ${phrase}`);
    }
  }
  return { parsed, value: reasons.length ? null : value, reasons };
}

for (const target of derivedTargets) {
  const id = `${target.key}|${target.field}`;
  if (overrides.has(id)) continue;
  const output = outputByKey.get(target.key)!;
  let current = currentLensFor(output);
  let errors = [target.reason];
  const record: RepairRecord = {
    ...target,
    accepted: false,
    after: null,
    attempts: [],
  };
  ledger.repairs = ledger.repairs.filter((repair) =>
    `${repair.key}|${repair.field}` !== id
  );
  ledger.repairs.push(record);
  for (let attempt = 0; attempt <= 2; attempt++) {
    const exclusions = exclusionsFor(target, current);
    const prompt = buildRepairPrompt(target, current, errors, exclusions);
    const transportEvents: TransportEvent[] = [];
    const provider = buildReliableOpenAIProvider({
      apiKey: config.apiKey,
      model: config.model,
      instructions: V32_MODEL_WRITING_SYSTEM,
      events: transportEvents,
      maxTransportRetries: 3,
      timeoutMs: 60_000,
    });
    try {
      const response = await provider.complete(prompt, attempt);
      const validation = validatePatch(
        target,
        current,
        response.raw,
        exclusions,
      );
      record.attempts.push({
        attempt,
        prompt,
        rawResponse: response.raw,
        parsedResponse: validation.parsed,
        validation: {
          accepted: validation.reasons.length === 0,
          reasons: validation.reasons,
        },
        usage: response.usage,
        transportEvents,
      });
      await atomicWrite(paths.attempts, ledger);
      if (validation.value !== null) {
        record.accepted = true;
        record.after = validation.value;
        overrides.set(id, validation.value);
        break;
      }
      errors = validation.reasons;
    } catch (error) {
      record.attempts.push({
        attempt,
        prompt,
        rawResponse: null,
        parsedResponse: null,
        validation: {
          accepted: false,
          reasons: [error instanceof Error ? error.message : String(error)],
        },
        transportEvents,
      });
      await atomicWrite(paths.attempts, ledger);
      throw error;
    }
  }
  await atomicWrite(paths.attempts, ledger);
}

const failedRepairs = ledger.repairs.filter((repair) => !repair.accepted);
if (ledger.repairs.length !== 13 || failedRepairs.length) {
  await atomicWrite(paths.run, {
    developmentOnly: true,
    status: "repair_incomplete",
    targetCount: 13,
    acceptedPatches: ledger.repairs.filter((repair) => repair.accepted).length,
    failedPatches: failedRepairs.map((repair) => ({
      key: repair.key,
      field: repair.field,
    })),
  });
  throw new Error(
    `Targeted repair incomplete: ${failedRepairs.length} patches failed.`,
  );
}

const repaired = structuredClone(generation);
const repairedRows = repaired.identities.flatMap((
  identity: { outputs: unknown[] },
) => identity.outputs) as Array<Record<string, any>>;
const repairsById = new Map(
  ledger.repairs.map((repair) => [`${repair.key}|${repair.field}`, repair]),
);
for (const output of repairedRows) {
  const sourceOutput = outputByKey.get(output.key)!;
  const lens = { ...effectiveLens(sourceOutput) };
  const outputRepairs: RepairRecord[] = [];
  for (const field of fields) {
    const repair = repairsById.get(`${output.key}|${field}`);
    if (repair) {
      lens[field] = repair.after!;
      outputRepairs.push(repair);
    }
  }
  if (outputRepairs.length) {
    output.targetedRepair = {
      developmentOnly: true,
      sourceArtifactSha256: EXPECTED_SOURCE_SHA,
      fields: outputRepairs.map((repair) => ({
        field: repair.field,
        before: repair.before,
        after: repair.after,
        attempts: repair.attempts.length,
      })),
    };
  }
  output.result.finalLens = lens;
  output.result.accepted = true;
}
repaired.rejected = 0;
repaired.repair = {
  developmentOnly: true,
  sourceArtifactSha256: EXPECTED_SOURCE_SHA,
  targetCount: 13,
  changedFields: ledger.repairs.map((repair) => ({
    key: repair.key,
    field: repair.field,
    before: repair.before,
    after: repair.after,
  })),
};

const repairedOverrides = new Map(ledger.repairs.map((repair) => [
  `${repair.key}|${repair.field}`,
  repair.after!,
]));
const baselineSnapshot = fieldSnapshot();
const repairedSnapshot = fieldSnapshot(repairedOverrides);
const changed = repairedSnapshot.filter((row, index) =>
  row !== baselineSnapshot[index]
);
const repairedNonTargetHash = await nonTargetHash(repairedOverrides);
if (changed.length !== 13 || repairedNonTargetHash !== baselineNonTargetHash) {
  throw new Error(
    "Post-merge integrity failure: changed-field count or non-target hash differs.",
  );
}

const finalLenses = repairedRows.map((output) => ({
  output,
  lens: output.result.finalLens as CanonicalLens,
}));
const titleCounts = finalLenses.reduce<Record<string, number>>((map, row) => {
  const value = normalize(row.lens.title);
  map[value] = (map[value] ?? 0) + 1;
  return map;
}, {});
const rootCounts = finalLenses.reduce<Record<string, number>>((map, row) => {
  const value = titleRoot(row.lens.title);
  map[value] = (map[value] ?? 0) + 1;
  return map;
}, {});
const openingCounts = finalLenses.reduce<Record<string, number>>((map, row) => {
  const value = opening(row.lens.intro);
  map[value] = (map[value] ?? 0) + 1;
  return map;
}, {});
const qa = {
  developmentOnly: true,
  sourceArtifactSha256: EXPECTED_SOURCE_SHA,
  contexts: finalLenses.length,
  accepted: finalLenses.filter(({ output }) => output.result.accepted).length,
  rejected: finalLenses.filter(({ output }) => !output.result.accepted).length,
  changedFields: changed.length,
  nonTargetFieldsChanged: repairedNonTargetHash === baselineNonTargetHash
    ? 0
    : 1,
  schemaFailures: finalLenses.filter(({ lens }) =>
    !validateCanonicalLens(lens).accepted
  ).map(({ output }) => output.key),
  duplicateTitles: Object.entries(titleCounts).filter(([, count]) => count > 1),
  saturatedTitleRoots: Object.entries(rootCounts).filter(([, count]) =>
    count > 48
  ),
  saturatedIntroOpenings: Object.entries(openingCounts).filter(([, count]) =>
    count > 16
  ),
  standaloneConjunctionIntros: finalLenses.filter(({ lens }) =>
    /^(but|and|so)\b/i.test(lens.intro.trim())
  )
    .map(({ output }) => output.key),
  literaryVaguenessFlags: finalLenses.flatMap(({ output, lens }) => {
    const matches = fields.flatMap((field) =>
      literaryPatterns.filter((pattern) => pattern.test(lens[field]))
        .map(String)
    );
    return matches.length ? [{ key: output.key, patterns: matches }] : [];
  }),
  blockedPatternReuse: finalLenses.flatMap(({ output, lens }) => {
    const reasons: string[] = [];
    if (
      V2_CORPUS_EXCLUSIONS.exactTitles.some((title) =>
        normalize(title) === normalize(lens.title)
      )
    ) {
      reasons.push("blocked v2 title");
    }
    if (/\byou do not need\b.+;\s*you need\b/i.test(lensText(lens))) {
      reasons.push("blocked slogan frame");
    }
    return reasons.length ? [{ key: output.key, reasons }] : [];
  }),
  leakage: finalLenses.flatMap(({ output, lens }) => {
    const matches = leakageTerms.filter((term) =>
      new RegExp(`\\b${term}\\b`, "i").test(lensText(lens))
    );
    return matches.length ? [{ key: output.key, terms: matches }] : [];
  }),
  unsupportedInference: finalLenses.filter(({ lens }) =>
    unsupportedPatterns.some((pattern) => pattern.test(lensText(lens)))
  ).map(({ output }) => output.key),
  validFieldPreservation: repairedNonTargetHash === baselineNonTargetHash,
};
const ready = qa.contexts === 1440 && qa.accepted === 1440 &&
  qa.rejected === 0 &&
  qa.changedFields === 13 && qa.nonTargetFieldsChanged === 0 &&
  qa.schemaFailures.length === 0 &&
  qa.duplicateTitles.length === 0 && qa.saturatedTitleRoots.length === 0 &&
  qa.saturatedIntroOpenings.length === 0 &&
  qa.standaloneConjunctionIntros.length === 0 &&
  qa.literaryVaguenessFlags.length === 0 &&
  qa.blockedPatternReuse.length === 0 &&
  qa.leakage.length === 0 && qa.unsupportedInference.length === 0 &&
  qa.validFieldPreservation;
const usage = ledger.repairs.flatMap((repair) => repair.attempts).reduce(
  (total, attempt) => {
    total.calls++;
    total.tokens += Number(attempt.usage?.total_tokens ?? 0);
    return total;
  },
  { calls: 0, tokens: 0 },
);
const report = {
  developmentOnly: true,
  status: ready ? "repair_complete" : "repair_failed_post_merge_qa",
  provider: `openai:${config.model}`,
  targetFields: 13,
  providerCalls: usage.calls,
  totalTokens: usage.tokens,
  firstAttemptPatchAcceptances:
    ledger.repairs.filter((repair) =>
      repair.accepted && repair.attempts.length === 1
    ).length,
  retryAcceptances:
    ledger.repairs.filter((repair) =>
      repair.accepted && repair.attempts.length > 1
    ).length,
  failedPatches: failedRepairs.length,
  changedFields: ledger.repairs.map((repair) => ({
    key: repair.key,
    field: repair.field,
    before: repair.before,
    after: repair.after,
  })),
  qa: { ...qa, ready },
  productionBehaviorChanged: false,
};
await Promise.all([
  atomicWrite(paths.repaired, repaired),
  atomicWrite(paths.run, report),
  atomicWrite(paths.qa, { ...qa, ready }),
  Deno.writeTextFile(
    paths.qaMarkdown,
    `# Canonical Lens v3.2 full repaired QA\n\n- Ready: ${ready}\n- Contexts: ${qa.contexts}\n- Accepted: ${qa.accepted}\n- Rejected: ${qa.rejected}\n- Changed fields: ${qa.changedFields}\n- Non-target fields changed: ${qa.nonTargetFieldsChanged}\n- Schema failures: ${qa.schemaFailures.length}\n- Duplicate titles: ${qa.duplicateTitles.length}\n- Saturated title roots: ${qa.saturatedTitleRoots.length}\n- Saturated intro openings: ${qa.saturatedIntroOpenings.length}\n- Standalone conjunction intros: ${qa.standaloneConjunctionIntros.length}\n- Literary-vagueness flags: ${qa.literaryVaguenessFlags.length}\n- Leakage: ${qa.leakage.length}\n- Unsupported inference: ${qa.unsupportedInference.length}\n`,
  ),
]);
if (!ready) {
  throw new Error(
    "Repaired corpus failed post-merge QA; original artifacts remain untouched.",
  );
}
console.log(JSON.stringify(report, null, 2));
