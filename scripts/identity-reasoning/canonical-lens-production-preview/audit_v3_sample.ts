import type { CanonicalLens } from "../canonical-lens/types.ts";
import { validateCanonicalLens } from "../canonical-lens/validate.ts";
import {
  V2_CORPUS_EXCLUSIONS,
  V32_ABSTRACT_MECHANISMS,
  V32_PLANNING_TITLE_WORDS,
  V3_SAMPLE_IDENTITIES,
} from "./v3_sample_plan.ts";

const base = new URL("./artifacts/", import.meta.url);
const v31 = Deno.args.includes("--v3-1");
const v32 = Deno.args.includes("--v3-2");
const full = Deno.args.includes("--full");
const repaired = Deno.args.includes("--repaired");
if (v31 && v32) throw new Error("Choose only one artifact version.");
if (full && !v32) throw new Error("Full audit requires --v3-2.");
if (repaired && (!full || !v32)) {
  throw new Error("Repaired audit requires --v3-2 --full --repaired.");
}
const artifactVersion = repaired
  ? "v3.2-full-repaired"
  : full
  ? "v3.2-full"
  : v32
  ? "v3.2"
  : v31
  ? "v3.1"
  : "v3";
const paths = {
  v2: new URL("generation-v2.json", base),
  v3: new URL(
    repaired
      ? "generation-v3.2-full-repaired.json"
      : `generation-${artifactVersion}-sample.json`,
    base,
  ),
  qaJson: new URL(
    repaired
      ? "qa-report-v3.2-full-repaired.json"
      : `qa-report-${artifactVersion}-sample.json`,
    base,
  ),
  qaMarkdown: new URL(
    repaired
      ? "qa-report-v3.2-full-repaired.md"
      : `qa-report-${artifactVersion}-sample.md`,
    base,
  ),
  blindJson: new URL(`blind-audit-${artifactVersion}-sample.json`, base),
  blindMarkdown: new URL(`blind-audit-${artifactVersion}-sample.md`, base),
  blindReveal: new URL(`blind-reveal-${artifactVersion}-sample.json`, base),
  corpusMarkdown: new URL(
    repaired
      ? "corpus-audit-v3.2-full-repaired.md"
      : "corpus-audit-v3.2-full.md",
    base,
  ),
};
const readJson = async (url: URL) => JSON.parse(await Deno.readTextFile(url));
const v2 = await readJson(paths.v2);
const v3 = await readJson(paths.v3);
const outputs = v3.identities.flatMap((checkpoint: { outputs: unknown[] }) =>
  checkpoint.outputs
) as Array<{
  key: string;
  identity: string;
  arena: string;
  scenarioId: string;
  context: unknown;
  result: {
    accepted: boolean;
    retryCount: number;
    finalLens: CanonicalLens | null;
    attempts: Array<{
      validFieldsPreserved: boolean;
      validation?: { reasons?: string[] };
    }>;
  };
}>;
const accepted = outputs.filter((output) => output.result.accepted);
const normalize = (value: string) =>
  value.toLowerCase().replace(/[^a-z0-9\s]/g, " ").trim().replace(/\s+/g, " ");
const opening = (value: string) =>
  normalize(value).split(" ").slice(0, 4).join(" ");
const titleRoot = (value: string) =>
  normalize(value).split(" ").find((word) =>
    !["a", "an", "the"].includes(word)
  ) ?? "";
const countBy = (values: string[]) =>
  Object.entries(values.reduce<Record<string, number>>((map, value) => {
    map[value] = (map[value] ?? 0) + 1;
    return map;
  }, {})).sort((a, b) => b[1] - a[1]);
const leakageTerms = [
  "astrology",
  "zodiac",
  "horoscope",
  "planet",
  "universe",
  "fate",
  "destiny",
  ...[
    ...new Set(
      V3_SAMPLE_IDENTITIES.flatMap((identity) => identity.split(" × ")),
    ),
  ],
];
const unsupportedPatterns = [
  /\bwill definitely\b/i,
  /\bguaranteed\b/i,
  /\balways happens\b/i,
  /\btrauma response\b/i,
  /\byour therapist\b/i,
];
const schemaFailures = accepted.filter((output) =>
  !validateCanonicalLens(output.result.finalLens!).accepted
).map((output) => output.key);
const leakage = accepted.flatMap((output) => {
  const text = normalize(Object.values(output.result.finalLens!).join(" "));
  const terms = leakageTerms.filter((term) =>
    new RegExp(`\\b${normalize(term)}\\b`, "i").test(text)
  );
  return terms.length ? [{ key: output.key, terms }] : [];
});
const unsupportedInference = accepted.flatMap((output) => {
  const text = Object.values(output.result.finalLens!).join(" ");
  const patterns = unsupportedPatterns.filter((pattern) => pattern.test(text))
    .map(String);
  return patterns.length ? [{ key: output.key, patterns }] : [];
});
const retryPreservationFailures = outputs.flatMap((output) =>
  output.result.attempts.slice(1).flatMap((attempt, index) =>
    attempt.validFieldsPreserved
      ? []
      : [{ key: output.key, attempt: index + 1 }]
  )
);
const standaloneOpeningFlags = accepted.flatMap((output) =>
  /^(but|and|so)\b/i.test(output.result.finalLens!.intro.trim())
    ? [{ key: output.key, intro: output.result.finalLens!.intro }]
    : []
);
const literaryVaguenessPatterns = [
  /\bgently closes\b/i,
  /\bquietly asks\b/i,
  /\bthe space between\b/i,
  /\bdoor it .{0,20} closes\b/i,
  /\bsoftly opens\b/i,
];
const literaryVaguenessFlags = accepted.flatMap((output) => {
  const text = Object.values(output.result.finalLens!).join(" ");
  const patterns = literaryVaguenessPatterns.filter((pattern) =>
    pattern.test(text)
  ).map(String);
  return patterns.length ? [{ key: output.key, patterns }] : [];
});
const surfaceVoiceFlags = v32
  ? accepted.flatMap((output) => {
    const lens = output.result.finalLens!;
    const contextEvidence = normalize(JSON.stringify(output.context));
    const reasons: string[] = [];
    if (/[.!?]$/.test(lens.title.trim())) reasons.push("title punctuation");
    for (const word of V32_PLANNING_TITLE_WORDS) {
      if (
        new RegExp(`\\b${word}\\b`, "i").test(normalize(lens.title)) &&
        !new RegExp(`\\b${word}\\b`, "i").test(contextEvidence)
      ) reasons.push(`unsupported title object ${word}`);
    }
    const text = normalize(Object.values(lens).join(" "));
    for (const phrase of V32_ABSTRACT_MECHANISMS) {
      if (text.includes(phrase)) reasons.push(`abstract mechanism ${phrase}`);
    }
    return reasons.length ? [{ key: output.key, reasons }] : [];
  })
  : [];
const titleCounts = countBy(
  accepted.map((output) => normalize(output.result.finalLens!.title)),
);
const rootCounts = countBy(
  accepted.map((output) => titleRoot(output.result.finalLens!.title)),
);
const openingCounts = countBy(
  accepted.map((output) => opening(output.result.finalLens!.intro)),
);
const contentWords = (value: string) =>
  normalize(value).split(" ").filter((word) =>
    word.length > 2 &&
    !new Set([
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
    ]).has(word)
  );
const lensText = (lens: CanonicalLens) => Object.values(lens).join(" ");
const jaccard = (left: string, right: string) => {
  const a = new Set(contentWords(left));
  const b = new Set(contentWords(right));
  const union = new Set([...a, ...b]);
  return union.size
    ? [...a].filter((word) => b.has(word)).length / union.size
    : 0;
};
const crossIdentitySameScenario: Array<Record<string, unknown>> = [];
const withinIdentityAcrossArenas: Array<Record<string, unknown>> = [];
if (full) {
  for (let left = 0; left < accepted.length; left++) {
    for (let right = left + 1; right < accepted.length; right++) {
      const a = accepted[left], b = accepted[right];
      const score = jaccard(
        lensText(a.result.finalLens!),
        lensText(b.result.finalLens!),
      );
      if (a.arena === b.arena && a.identity !== b.identity && score >= .5) {
        crossIdentitySameScenario.push({
          keys: [a.key, b.key],
          arena: a.arena,
          score,
        });
      }
      if (a.identity === b.identity && a.arena !== b.arena && score >= .5) {
        withinIdentityAcrossArenas.push({
          identity: a.identity,
          arenas: [a.arena, b.arena],
          score,
        });
      }
    }
  }
}
crossIdentitySameScenario.sort((a, b) => Number(b.score) - Number(a.score));
withinIdentityAcrossArenas.sort((a, b) => Number(b.score) - Number(a.score));
const scenarioOpeningFamilies = Object.fromEntries(
  [...new Set(accepted.map((output) => output.arena))].map((arena) => [
    arena,
    countBy(
      accepted.filter((output) => output.arena === arena).map((output) =>
        opening(output.result.finalLens!.intro)
      ),
    ).filter(([, count]) => count > 2),
  ]),
);
const blockedPatternReuse = accepted.flatMap((output) => {
  const lens = output.result.finalLens!;
  const title = normalize(lens.title);
  const root = titleRoot(lens.title);
  const intro = normalize(lens.intro);
  const reasons: string[] = [];
  if (
    V2_CORPUS_EXCLUSIONS.exactTitles.some((value) => normalize(value) === title)
  ) {
    reasons.push("exact title");
  }
  if (
    !v32 && V2_CORPUS_EXCLUSIONS.titleRoots.some((value) => value === root)
  ) {
    reasons.push("title root");
  }
  if (
    V2_CORPUS_EXCLUSIONS.introOpenings.some((value) =>
      intro.startsWith(normalize(value))
    )
  ) reasons.push("intro opening");
  const text = Object.values(lens).join(" ");
  if (/\byou do not need\b.+;\s*you need\b/i.test(text)) {
    reasons.push("you do not need X; you need Y frame");
  }
  if (/\bthe question is not\b.+;\s*it is\b/i.test(text)) {
    reasons.push("the question is not X; it is Y frame");
  }
  return reasons.length ? [{ key: output.key, reasons }] : [];
});
const retryAcceptances =
  accepted.filter((output) => output.result.retryCount > 0).length;
const retryRate = outputs.length
  ? Number((retryAcceptances / outputs.length * 100).toFixed(2))
  : 0;
const schemaRetryContexts =
  outputs.filter((output) =>
    output.result.attempts.some((attempt) =>
      (attempt.validation?.reasons ?? []).some((reason) =>
        ["intro ", "pull_quote ", "deeper_read ", "watch_for ", "move "]
          .some((prefix) => reason.startsWith(prefix))
      )
    )
  ).length;
const schemaRetryRate = outputs.length
  ? Number((schemaRetryContexts / outputs.length * 100).toFixed(2))
  : 0;
const qa = {
  developmentOnly: true,
  artifactVersion,
  contexts: outputs.length,
  accepted: accepted.length,
  rejected: outputs.length - accepted.length,
  retryAcceptances,
  retryRate,
  schemaRetryContexts,
  schemaRetryRate,
  schemaFailures,
  leakage,
  unsupportedInference,
  retryPreservationFailures,
  standaloneOpeningFlags,
  literaryVaguenessFlags,
  surfaceVoiceFlags,
  duplicateTitles: titleCounts.filter(([, count]) => count > 1),
  saturatedTitleRoots: rootCounts.filter(([, count]) =>
    count > (full ? 48 : 6)
  ),
  saturatedIntroOpenings: openingCounts.filter(([, count]) =>
    count > (full ? 16 : 2)
  ),
  blockedPatternReuse,
  scenarioOpeningFamilies,
  crossIdentitySameScenario: crossIdentitySameScenario.slice(0, 1000),
  withinIdentityAcrossArenas: withinIdentityAcrossArenas.slice(0, 1000),
  editorialReviewRequired: full,
  automatedReady: false,
};
const expectedContexts = full ? 1440 : 180;
qa.automatedReady = qa.contexts === expectedContexts &&
  qa.accepted === expectedContexts &&
  (repaired ? schemaRetryRate < 10 : retryRate < 10) &&
  schemaFailures.length === 0 && leakage.length === 0 &&
  unsupportedInference.length === 0 && retryPreservationFailures.length === 0 &&
  surfaceVoiceFlags.length === 0 &&
  (!full || standaloneOpeningFlags.length === 0) &&
  (!repaired || literaryVaguenessFlags.length === 0) &&
  qa.duplicateTitles.length === 0 && qa.saturatedTitleRoots.length === 0 &&
  qa.saturatedIntroOpenings.length === 0 && blockedPatternReuse.length === 0;
await Deno.writeTextFile(paths.qaJson, JSON.stringify(qa, null, 2) + "\n");
await Deno.writeTextFile(
  paths.qaMarkdown,
  `# Canonical Lens ${artifactVersion} QA\n\n- Automated ready: ${qa.automatedReady}\n- Editorial review required: ${full}\n- Contexts: ${qa.contexts}\n- Accepted: ${qa.accepted}\n- Rejected: ${qa.rejected}\n- Combined retry rate: ${qa.retryRate}%\n- Schema retry rate: ${qa.schemaRetryRate}%\n- Schema failures: ${schemaFailures.length}\n- Leakage: ${leakage.length}\n- Unsupported inference: ${unsupportedInference.length}\n- Retry preservation failures: ${retryPreservationFailures.length}\n- Surface voice flags: ${surfaceVoiceFlags.length}\n- Standalone conjunction openings: ${standaloneOpeningFlags.length}\n- Literary-vagueness flags: ${literaryVaguenessFlags.length}\n- Duplicate titles: ${qa.duplicateTitles.length}\n- Saturated title roots: ${qa.saturatedTitleRoots.length}\n- Saturated intro openings: ${qa.saturatedIntroOpenings.length}\n- Blocked v2 pattern reuse: ${blockedPatternReuse.length}\n- Same-scenario high-overlap pairs: ${crossIdentitySameScenario.length}\n- Same-identity cross-arena high-overlap pairs: ${withinIdentityAcrossArenas.length}\n`,
);

if (full) {
  const scenarioLines = Object.entries(scenarioOpeningFamilies).flatMap(
    ([arena, families]) => [
      `## ${arena}`,
      "",
      ...(families as Array<[string, number]>).slice(0, 20).map(
        ([value, count]) => `- ${count} × \`${value}\``,
      ),
      "",
    ],
  );
  const overlapLines = crossIdentitySameScenario.slice(0, 100).map((row) =>
    `- ${Number(row.score).toFixed(3)} · ${(row.keys as string[]).join(" ↔ ")}`
  );
  const withinLines = withinIdentityAcrossArenas.slice(0, 100).map((row) =>
    `- ${Number(row.score).toFixed(3)} · ${row.identity} · ${
      (row.arenas as string[]).join(" ↔ ")
    }`
  );
  await Deno.writeTextFile(
    paths.corpusMarkdown,
    [
      "# Canonical Lens v3.2 full-corpus audit",
      "",
      `Automated ready: ${qa.automatedReady}`,
      `Editorial review required: true`,
      `Contexts: ${qa.contexts}`,
      `Accepted: ${qa.accepted}`,
      `Rejected: ${qa.rejected}`,
      `Retry rate: ${qa.retryRate}%`,
      `Schema retry rate: ${qa.schemaRetryRate}%`,
      `Standalone conjunction openings: ${standaloneOpeningFlags.length}`,
      `Literary-vagueness flags: ${literaryVaguenessFlags.length}`,
      `Same-scenario high-overlap pairs: ${crossIdentitySameScenario.length}`,
      `Same-identity cross-arena high-overlap pairs: ${withinIdentityAcrossArenas.length}`,
      "",
      "# Scenario opening families",
      "",
      ...scenarioLines,
      "# Highest same-scenario overlap",
      "",
      ...overlapLines,
      "",
      "# Highest same-identity cross-arena overlap",
      "",
      ...withinLines,
      "",
      "This heuristic report identifies editorial-review candidates; it is not a human production verdict.",
      "",
    ].join("\n"),
  );
}

if (qa.automatedReady && !full) {
  const v2ByKey = new Map<string, CanonicalLens>();
  for (const identity of v2.identities) {
    for (const output of identity.outputs ?? []) {
      if (output.result?.accepted && output.result.finalLens) {
        v2ByKey.set(output.key, output.result.finalLens);
      }
    }
  }
  function stableUnit(value: string): number {
    let hash = 2166136261;
    for (const character of value) {
      hash ^= character.charCodeAt(0);
      hash = Math.imul(hash, 16777619);
    }
    return (hash >>> 0) / 4294967296;
  }
  const pairs = V3_SAMPLE_IDENTITIES.flatMap((identity) =>
    accepted.filter((output) =>
      output.identity === identity && v2ByKey.has(output.key)
    )
      .sort((left, right) =>
        stableUnit(`${left.key}|pick`) - stableUnit(`${right.key}|pick`)
      )
      .slice(0, 2)
  ).map((output, index) => {
    const v3First = stableUnit(`${output.key}|order`) < 0.5;
    const versions = v3First
      ? { A: output.result.finalLens!, B: v2ByKey.get(output.key)! }
      : { A: v2ByKey.get(output.key)!, B: output.result.finalLens! };
    const reveal = {
      pair: index + 1,
      A: v3First ? artifactVersion : "v2",
      B: v3First ? "v2" : artifactVersion,
    };
    return {
      pair: index + 1,
      identity: output.identity,
      scenario: output.arena,
      versions,
      review: {
        preferred: null,
        identitySpecificity: null,
        canonicalGrounding: null,
        behavioralConcreteness: null,
        notes: null,
      },
      reveal,
    };
  });
  const blind = {
    developmentOnly: true,
    instructions:
      "Preferred must be A, B, or tie. Complete every review before opening the separate reveal file.",
    pairs: pairs.map(({ reveal: _reveal, ...pair }) => pair),
  };
  await Deno.writeTextFile(
    paths.blindJson,
    JSON.stringify(blind, null, 2) + "\n",
  );
  await Deno.writeTextFile(
    paths.blindReveal,
    JSON.stringify(
      {
        developmentOnly: true,
        artifactVersion,
        warning: "Open only after the blind review is complete.",
        mappings: pairs.map((pair) => pair.reveal),
      },
      null,
      2,
    ) + "\n",
  );
  const markdown = [
    "# Canonical Lens v3 sample blind review",
    "",
    "Do not open the separate reveal file until all preferences are recorded.",
    "",
    ...pairs.flatMap((pair) => [
      `## ${pair.pair}. ${pair.identity} · ${pair.scenario}`,
      "",
      "### Version A",
      "",
      "```json",
      JSON.stringify(pair.versions.A, null, 2),
      "```",
      "",
      "### Version B",
      "",
      "```json",
      JSON.stringify(pair.versions.B, null, 2),
      "```",
      "",
      "Preferred: ___",
      "",
      "Identity specificity: ___",
      "Canonical grounding: ___",
      "Behavioral concreteness: ___",
      "Notes: ___",
      "",
    ]),
  ].join("\n");
  await Deno.writeTextFile(paths.blindMarkdown, markdown);
}
console.log(JSON.stringify(qa, null, 2));
