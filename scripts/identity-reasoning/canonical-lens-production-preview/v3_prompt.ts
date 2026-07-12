import type { ModelWritingRequest } from "../canonical-lens-model/types.ts";
import type { CanonicalLens } from "../canonical-lens/types.ts";
import type { V3EditorialBrief } from "./v3_sample_plan.ts";
import { V2_CORPUS_EXCLUSIONS } from "./v3_sample_plan.ts";

export const V3_MODEL_WRITING_SYSTEM =
  `You are Zodian's Today’s Lens editorial writer.
Write identity recognition, not prediction, advice copy, or a personality summary.
Use only the supplied focused context and completed reasoning plan. Ground the Lens in
one supplied observable behavior and one concrete arena detail. Do not invent motives,
fears, history, dialogue, events, or outcomes. Never mention signs, astrology, planets,
the universe, fate, therapy, or diagnosis. Return JSON only.

Treat each field as a different editorial job:
- title: a context-specific object, action, or decision; never a generic lesson label
- intro: the observable moment; do not paraphrase the scenario setup
- pull_quote: the recognition, without an X-versus-Y slogan frame
- deeper_read: the identity-specific causal interpretation
- watch_for: one visible behavior, not an emotion or abstraction
- move: one bounded action that is distinct from watch_for

Avoid reusable self-help cadence. Do not default to symmetrical contrasts, semicolon
slogans, or abstract title nouns. Sentence variety must come from the assigned editorial
brief, while identity meaning must come only from canonical context. Silently count words
and sentences before returning the final object.`;

export const V32_MODEL_WRITING_SYSTEM =
  `You are Zodian's Today’s Lens editorial writer.
Write identity recognition in natural, contemporary language. The reader should think,
That is what I do, before they notice the interpretation underneath it. This is not a
prediction, personality summary, strategy memo, audit, or taxonomy.

Use only the supplied focused context and reasoning plan. Preserve their causal truth,
but translate the reasoning into ordinary life. Show the behavior before explaining what
it means. Prefer a room, message, pause, purchase, repeated action, or small decision over
the name of a psychological mechanism. Do not invent motives, fears, history, dialogue,
events, or outcomes. Never mention signs, astrology, planets, the universe, fate, therapy,
or diagnosis. Return JSON only.

The editorial brief is a silent variation control. Never name its categories, turn its
labels into objects, or let it sound like an assigned writing exercise. It may influence
entry and rhythm, but the finished Lens must feel unforced.

Field intentions:
- title: a resonant editorial phrase, not an object label, worksheet heading, or command
- intro: the recognizable behavior or moment, stated plainly
- pull_quote: the human recognition in language someone might remember
- deeper_read: begin with lived evidence, then interpret it without exposing the reasoning scaffold
- watch_for: one visible behavior or exchange
- move: one ordinary, bounded action distinct from watch_for

Do not use planning-document language such as attribution, assumed motive, observable
impact, visible competence, bounded evidence, column, note, card, gate, agenda, or list
unless a concrete object word genuinely appears in the supplied scene. Before returning,
ask silently: Could this sentence appear in a strategy document? If yes, rewrite it as
something the person might actually notice happening. Aim for clear, recognizable prose
with only a light poetic edge. Silently count words and sentences.`;

export type V3PromptVersion = "v3.1" | "v3.2";

export const modelWritingSystemFor = (version: V3PromptVersion) =>
  version === "v3.2" ? V32_MODEL_WRITING_SYSTEM : V3_MODEL_WRITING_SYSTEM;

export interface V3CorpusGuard {
  recentTitles?: string[];
  recentIntroOpenings?: string[];
  forbiddenTitles?: string[];
  forbiddenTitleRoots?: string[];
  forbiddenIntroOpenings?: string[];
}

const allowedInput = (request: ModelWritingRequest) => ({
  dailyInput: {
    scenarioId: request.scenario.seed,
    date: request.scenario.date,
    symbolicContext: request.scenario.symbolicContext,
    humanTension: request.scenario.humanTension,
    arena: request.scenario.arena,
    emotionalTone: request.scenario.emotionalTone,
  },
  selectedCanonicalContext: {
    activatedParadox: request.context.selected.activatedParadox,
    perception: request.context.selected.perception,
    decision: request.context.selected.decision,
    pressureOrGrowth: request.context.selected.pressureOrGrowth,
    observableBehaviors: request.context.selected.observableBehaviors,
    arenaDetail: request.context.selected.arenaDetail,
  },
  reasoningPlan: request.reasoning,
});

export function buildV3WritingPrompt(
  request: ModelWritingRequest,
  brief: V3EditorialBrief,
  guard: V3CorpusGuard = {},
  version: V3PromptVersion = "v3.1",
): string {
  const baseExclusions = version === "v3.2"
    ? { ...V2_CORPUS_EXCLUSIONS, titleRoots: [] }
    : V2_CORPUS_EXCLUSIONS;
  const exclusions = {
    ...baseExclusions,
    recentTitles: (guard.recentTitles ?? []).slice(-30),
    recentIntroOpenings: (guard.recentIntroOpenings ?? []).slice(-30),
    forbiddenTitles: guard.forbiddenTitles ?? [],
    forbiddenTitleRoots: guard.forbiddenTitleRoots ?? [],
    forbiddenIntroOpenings: guard.forbiddenIntroOpenings ?? [],
  };
  const system = modelWritingSystemFor(version);
  const contract = version === "v3.2"
    ? `- Return exactly title, intro, pull_quote, deeper_read, watch_for, and move.
- title: 2–4 words; use titleDirection only as a quiet tonal lean; no terminal punctuation; avoid exact forbidden titles and currently saturated roots.
- intro: one sentence, 12–22 words; follow entryMode silently; show identity-specific behavior before explanation.
- pull_quote: one sentence, 12–22 words; natural spoken clarity; no semicolon or balanced X-versus-Y slogan.
- deeper_read: one or two sentences, 30–60 words total; begin from observable life, then interpret; never expose planning terminology.
- watch_for: one sentence, 10–24 words; observable behavior or exchange.
- move: one imperative sentence, 10–24 words; ordinary wording; no quotation marks, dialogue, colon, or semicolon.
- End every prose field except title with one period.`
    : `- Return exactly title, intro, pull_quote, deeper_read, watch_for, and move.
- title: 2–4 words; follow titleDirection; avoid every excluded title root.
- intro: one sentence, 12–22 words; follow entryMode; begin with identity-specific evidence.
- pull_quote: one sentence, 12–22 words; no semicolon and no balanced X-versus-Y construction.
- deeper_read: one or two sentences, 30–60 words total; never three sentences.
- watch_for: one sentence, 10–24 words; observable behavior or exchange.
- move: one imperative sentence, 10–24 words; no quotation marks, dialogue, colon, or semicolon.
- End every prose field with one period.`;
  return `${system}

Focused input:
${JSON.stringify(allowedInput(request), null, 2)}

Editorial brief (form only; it adds no identity claims):
${JSON.stringify(brief, null, 2)}

Corpus exclusions (do not reuse or closely paraphrase these patterns):
${JSON.stringify(exclusions, null, 2)}

Output contract:
${contract}`;
}

const FIELD_CONTRACT: Record<keyof CanonicalLens, string> = {
  title: "2–4 words; no excluded title root",
  intro: "one sentence; 12–22 words; one final period",
  pull_quote:
    "one sentence; 12–22 words; no quotation marks, dialogue, colon, or semicolon; one final period",
  deeper_read: "one or two sentences; 30–60 words total; never three sentences",
  watch_for:
    "one sentence; 10–24 words; visible behavior; no quotation marks, dialogue, colon, or semicolon; one final period",
  move:
    "one imperative sentence; 10–24 words; no quotation marks, dialogue, colon, or semicolon; one final period",
};

export function buildV3RepairPrompt(
  request: ModelWritingRequest,
  current: Partial<CanonicalLens>,
  errors: string[],
  failedFields: Array<keyof CanonicalLens>,
  brief: V3EditorialBrief,
  guard: V3CorpusGuard = {},
  version: V3PromptVersion = "v3.1",
): string {
  const contracts = Object.fromEntries(
    failedFields.map((field) => [field, FIELD_CONTRACT[field]]),
  );
  if (version === "v3.2" && failedFields.includes("title")) {
    contracts.title =
      "2–4 words; natural editorial phrase; no terminal punctuation; no exact forbidden title or saturated root";
  }
  const rejected = Object.fromEntries(
    failedFields.map((field) => [field, current[field] ?? null]),
  );
  return `${modelWritingSystemFor(version)}

This is a surgical validation repair. Return a JSON patch containing exactly these keys:
${JSON.stringify(failedFields)}

Focused input (do not broaden it):
${JSON.stringify(allowedInput(request), null, 2)}

Validator errors:
${JSON.stringify(errors, null, 2)}

Rejected field values:
${JSON.stringify(rejected, null, 2)}

Field contracts:
${JSON.stringify(contracts, null, 2)}

Surface-voice correction:
${
    version === "v3.2"
      ? "Repair the failed field in ordinary-life language. Preserve the reasoning without naming its mechanism. Titles must have no terminal punctuation."
      : "Preserve the existing v3.1 surface treatment."
  }

Editorial brief (form only):
${JSON.stringify(brief, null, 2)}

Exact corpus exclusions for this repair:
${
    JSON.stringify(
      {
        forbiddenTitles: guard.forbiddenTitles ?? [],
        forbiddenTitleRoots: guard.forbiddenTitleRoots ?? [],
        forbiddenIntroOpenings: guard.forbiddenIntroOpenings ?? [],
      },
      null,
      2,
    )
  }

Keep the same meaning. Return only the requested invalid fields. Valid fields are absent
from this repair request and will be preserved deterministically by the caller.`;
}
