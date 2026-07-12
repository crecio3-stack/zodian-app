import type { LensArena } from "../canonical-lens/types.ts";

export const V3_SAMPLE_IDENTITIES = [
  "Sagittarius × Monkey",
  "Scorpio × Dragon",
  "Aries × Rat",
  "Pisces × Dog",
  "Leo × Horse",
  "Aquarius × Snake",
  "Cancer × Pig",
  "Virgo × Dragon",
  "Aquarius × Rat",
  "Aquarius × Dog",
  "Pisces × Rooster",
  "Cancer × Snake",
  "Taurus × Horse",
  "Libra × Snake",
  "Gemini × Ox",
  "Capricorn × Goat",
  "Gemini × Tiger",
  "Capricorn × Rabbit",
] as const;

export const V3_ENTRY_MODES = [
  "concrete object first",
  "visible action first",
  "choice point first",
  "sequence or timing first",
  "brief exchange first",
  "physical arrangement first",
  "consequence first",
  "interruption first",
  "contrast first",
] as const;

export interface V3EditorialBrief {
  key: string;
  entryMode: typeof V3_ENTRY_MODES[number];
  titleDirection:
    | "object"
    | "action"
    | "decision"
    | "recognition phrase"
    | "behavioral turn"
    | "quiet tension";
  sentenceRhythm: "compact-then-open" | "open-then-compact" | "even";
}

export function buildV32EditorialBrief(
  identity: string,
  arena: LensArena,
): V3EditorialBrief {
  const base = buildV3EditorialBrief(identity, arena);
  const key = `${identity}|${arena}`;
  return {
    ...base,
    titleDirection: choose(
      ["recognition phrase", "behavioral turn", "quiet tension"] as const,
      `${key}|title-v3.2`,
    ),
  };
}

function stableUnit(value: string): number {
  let hash = 2166136261;
  for (const character of value) {
    hash ^= character.charCodeAt(0);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0) / 4294967296;
}

function choose<T>(values: readonly T[], key: string): T {
  return values[Math.floor(stableUnit(key) * values.length)];
}

export function buildV3EditorialBrief(
  identity: string,
  arena: LensArena,
): V3EditorialBrief {
  const key = `${identity}|${arena}`;
  return {
    key,
    entryMode: choose(V3_ENTRY_MODES, `${key}|entry`),
    titleDirection: choose(
      ["object", "action", "decision"] as const,
      `${key}|title`,
    ),
    sentenceRhythm: choose(
      ["compact-then-open", "open-then-compact", "even"] as const,
      `${key}|rhythm`,
    ),
  };
}

export const V2_CORPUS_EXCLUSIONS = {
  exactTitles: [
    "Name the Handoff",
    "Let It Land",
    "The Real Price",
    "Proof of Departure",
    "Proof of the Leap",
    "The Remaining Hour",
  ],
  introOpenings: [
    "A tender message lands",
    "A small disagreement sharpens",
    "A familiar room asks",
    "At checkout a small comfort",
    "Someone names your work",
  ],
  titleRoots: ["name", "make", "proof", "let"],
  sentenceFrames: [
    "You do not need X; you need Y",
    "The question is not X; it is Y",
  ],
} as const;

export const V32_PLANNING_TITLE_WORDS = [
  "column",
  "note",
  "card",
  "gate",
  "agenda",
  "list",
] as const;

export const V32_ABSTRACT_MECHANISMS = [
  "attribution",
  "assumed motive",
  "observable impact",
  "visible competence",
  "bounded evidence",
] as const;

export function v3SampleKeys(arenas: readonly LensArena[]): string[] {
  return V3_SAMPLE_IDENTITIES.flatMap((identity) =>
    arenas.map((arena) => `${identity}|${arena}`)
  );
}
