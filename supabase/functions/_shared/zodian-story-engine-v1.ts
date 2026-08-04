/**
 * Shadow-only editorial input contract. This module has no runtime, provider,
 * database, resolver, scheduler, or publication dependencies.
 */
export const ZODIAN_STORY_ENGINE_V1 = "zodian-story-engine-v1" as const;

export type ZodianStoryEngineV1Brief = {
  version: typeof ZODIAN_STORY_ENGINE_V1;
  identity: {
    westernSign: string;
    chineseSign: string;
  };
  dailyThread: string;
  centralTension: string;
  readerQuestion: string;
  hookDirection: string;
  perspectiveShift: string;
  landingDirection: string;
};

export type ZodianStoryEngineV1Field =
  | "identity.westernSign"
  | "identity.chineseSign"
  | "dailyThread"
  | "centralTension"
  | "readerQuestion"
  | "hookDirection"
  | "perspectiveShift"
  | "landingDirection";

export type ZodianStoryEngineV1Finding = {
  field: ZodianStoryEngineV1Field;
  code:
    | "required"
    | "too_long"
    | "technical_astrology"
    | "multiple_threads"
    | "direct_command"
    | "fixed_external_scenario"
    | "horoscope_prose";
  message: string;
};

const BRIEF_FIELDS = [
  "dailyThread",
  "centralTension",
  "readerQuestion",
  "hookDirection",
  "perspectiveShift",
  "landingDirection",
] as const;

const TECHNICAL_ASTROLOGY = /\b(?:planet|transit|ascendant|rising sign|house|natal|retrograde|conjunction|opposition|trine|square|sextile|\d{1,2}\s*°|\d{1,2}\s*degrees?)\b/i;
const COMPETING_THREADS = /\b(?:while also|as well as|and separately)\b/i;
const DIRECT_COMMAND = /^\s*(?:do not|don't|remember to|make sure|try to|be sure to|avoid|stop|start|choose|take|tell|ask|wait|let|keep)\b/i;
const FIXED_EXTERNAL_SCENARIO = /\b(?:at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)|slack|zoom|instagram|tiktok|office|workplace|meeting|restaurant|cafe|airport|classroom|kitchen|manager|coworker|boss)\b/i;
const HOROSCOPE_PROSE = /\b(?:your horoscope|the stars say|today you will|the universe wants|expect(?:\s+to)?|a lucky|fortune)\b/i;

function addFinding(
  findings: ZodianStoryEngineV1Finding[],
  field: ZodianStoryEngineV1Field,
  code: ZodianStoryEngineV1Finding["code"],
  message: string,
) {
  findings.push({ field, code, message });
}

/** Validates concise internal editorial notes, not finished reader-facing copy. */
export function validateZodianStoryEngineV1Brief(
  brief: ZodianStoryEngineV1Brief,
): ZodianStoryEngineV1Finding[] {
  const findings: ZodianStoryEngineV1Finding[] = [];
  const identityFields: Array<[ZodianStoryEngineV1Field, string]> = [
    ["identity.westernSign", brief.identity.westernSign],
    ["identity.chineseSign", brief.identity.chineseSign],
  ];
  for (const [field, value] of identityFields) {
    if (!value.trim()) addFinding(findings, field, "required", "Identity is required.");
  }

  for (const field of BRIEF_FIELDS) {
    const value = brief[field].trim();
    if (!value) {
      addFinding(findings, field, "required", "Editorial note is required.");
      continue;
    }
    if (value.length > 160) addFinding(findings, field, "too_long", "Editorial note must be 160 characters or fewer.");
    if (TECHNICAL_ASTROLOGY.test(value)) addFinding(findings, field, "technical_astrology", "Technical astrology does not belong in an editorial brief.");
    if (DIRECT_COMMAND.test(value)) addFinding(findings, field, "direct_command", "Briefs must not give the reader a command.");
    if (FIXED_EXTERNAL_SCENARIO.test(value)) addFinding(findings, field, "fixed_external_scenario", "Briefs must leave the external scene open for reader participation.");
    if (HOROSCOPE_PROSE.test(value)) addFinding(findings, field, "horoscope_prose", "Briefs must be internal notes, not horoscope prose.");
  }

  for (const field of ["dailyThread", "centralTension"] as const) {
    if (COMPETING_THREADS.test(brief[field])) {
      addFinding(findings, field, "multiple_threads", "Brief must identify one daily thread, not competing tensions.");
    }
  }
  return findings;
}
