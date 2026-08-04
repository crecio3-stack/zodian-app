/** Shadow-only prompt and validation contract. Provider execution lives in a local script. */
import {
  buildAllZodianShadowStoryBriefsV1,
  listZodianShadowStoryScenariosV1,
} from "./zodian-shadow-story-pipeline-v1.ts";
import type { ZodianStoryEngineV1Brief } from "./zodian-story-engine-v1.ts";

export const ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1 = "zodian-shadow-natural-reader-writer-canary-v1" as const;
export const ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_SCENARIOS_V1 = [
  "libra-snake-boundary",
  "taurus-horse-overlooked",
  "sagittarius-monkey-obligation",
  "gemini-dragon-commitment",
] as const;

export type ZodianShadowNaturalReaderWriterCanaryV1Output = {
  version: typeof ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1;
  scenarioId: string;
  identity: { westernSign: string; chineseSign: string };
  title: string;
  read: string;
};

export type ZodianShadowNaturalReaderWriterCanaryV1Packet = {
  scenarioId: string;
  identity: { westernSign: string; chineseSign: string };
  brief: ZodianStoryEngineV1Brief;
  prompt: string;
};

export type ZodianShadowNaturalReaderWriterCanaryV1Finding = {
  field: "output" | "version" | "scenarioId" | "identity" | "title" | "read";
  code: string;
  severity: "error" | "warning";
  message: string;
};

const SIGNS = /\b(?:aries|taurus|gemini|cancer|leo|virgo|libra|scorpio|sagittarius|capricorn|aquarius|pisces|rat|ox|tiger|rabbit|dragon|snake|horse|goat|monkey|rooster|dog|pig)\b/i;
const ASTROLOGY = /\b(?:planet|transit|ascendant|rising sign|house|natal|retrograde|conjunction|opposition|trine|square|sextile|chart|zodiac|mercury|venus|mars|jupiter|saturn|uranus|neptune|pluto|\d{1,2}\s*°)\b/i;
const FIXED_SCENE = /\b(?:at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)|slack|zoom|instagram|tiktok|office|workplace|meeting|restaurant|cafe|airport|classroom|kitchen|manager|coworker|boss|on the train|at work)\b/i;
const THERAPY_OR_CORPORATE = /\b(?:trauma|triggered|healing journey|inner child|emotional regulation|boundaries work|stakeholder|deliverable|leverage|synergy|bandwidth|optimize|action item)\b/i;
const METADATA = /\b(?:the (?:editorial )?brief|daily thread|central tension|reader question|hook direction|perspective shift|landing direction|metadata|scenario id)\b/i;
const HOROSCOPE_WARMUP = /\b(?:today you(?:'ll| will)|your horoscope|the stars|the universe|lucky day|cosmic)\b/i;
const MULTIPLE_THEMES = /\b(?:meanwhile|on the other hand|in a different area|separately)\b/i;
const DIRECTIVE = /(?:^|[.!?]\s+)(?:try to|remember to|make sure you|you should|you need to|do not|don't|avoid|start by|take time to)\b/gi;
const GENERIC_ADVICE_ENDING = /\b(?:trust yourself|be yourself|everything happens for a reason|keep going|you've got this)\s*[.!?]?$/i;

function add(findings: ZodianShadowNaturalReaderWriterCanaryV1Finding[], field: ZodianShadowNaturalReaderWriterCanaryV1Finding["field"], code: string, severity: "error" | "warning", message: string) {
  findings.push({ field, code, severity, message });
}

function words(value: string): string[] { return value.toLowerCase().match(/[a-z]+(?:'[a-z]+)?/g) ?? []; }
function normalize(value: string): string { return words(value).join(" "); }
function repeatedSentence(value: string): boolean {
  const sentences = value.split(/[.!?]+/).map(normalize).filter((sentence) => sentence.length >= 12);
  return new Set(sentences).size !== sentences.length;
}
function containsCopiedPhrase(read: string, brief: ZodianStoryEngineV1Brief): boolean {
  const sourceFields = [brief.dailyThread, brief.centralTension, brief.readerQuestion, brief.hookDirection, brief.perspectiveShift, brief.landingDirection];
  const readWords = new Set(words(read));
  return sourceFields.filter((field) => {
    const fieldWords = words(field).filter((word) => word.length > 3);
    return fieldWords.length >= 4 && fieldWords.filter((word) => readWords.has(word)).length / fieldWords.length >= 0.8;
  }).length >= 2;
}

export function listZodianShadowNaturalReaderWriterCanaryV1Packets(): ZodianShadowNaturalReaderWriterCanaryV1Packet[] {
  const scenarios = new Map(listZodianShadowStoryScenariosV1().map((scenario) => [scenario.scenarioId, scenario]));
  const briefs = new Map(buildAllZodianShadowStoryBriefsV1().map((brief, index) => [listZodianShadowStoryScenariosV1()[index].scenarioId, brief]));
  return ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_SCENARIOS_V1.map((scenarioId) => {
    const scenario = scenarios.get(scenarioId)!;
    const brief = briefs.get(scenarioId)!;
    const identity = { ...scenario.identity };
    return { scenarioId, identity, brief: { ...brief, identity: { ...brief.identity } }, prompt: buildZodianShadowNaturalReaderWriterCanaryV1Prompt(scenarioId, identity, brief) };
  });
}

export function buildZodianShadowNaturalReaderWriterCanaryV1Prompt(scenarioId: string, identity: { westernSign: string; chineseSign: string }, brief: ZodianStoryEngineV1Brief): string {
  return `Write one concise daily read for a person. The story has already been selected; write only that story. Do not add another lesson or theme. Do not explain astrology, mention signs, invent a detailed external scene, use named people, locations, workplaces, or apps, or expose this packet's structure. Do not turn the perspective shift into a command. Transform the internal direction into natural reader-facing copy rather than copying its wording. The first sentence must create curiosity. The last sentence must land, not instruct. Use plain, current, conversational English: direct, observant, confident, and warm. Avoid therapy, corporate, mystical, generic-advice, decorative, and moralizing language. Return JSON only with exactly: version, scenarioId, identity, title, read. Identity must be an object, never a label string: {"westernSign":"${identity.westernSign}","chineseSign":"${identity.chineseSign}"}. The title should be short and curious. The read should address the reader as you and normally be about 80–130 words.\n\nIdentity labels: ${identity.westernSign} × ${identity.chineseSign}\nScenario ID: ${scenarioId}\nDaily thread: ${brief.dailyThread}\nCentral tension: ${brief.centralTension}\nReader question: ${brief.readerQuestion}\nHook direction: ${brief.hookDirection}\nPerspective shift: ${brief.perspectiveShift}\nLanding direction: ${brief.landingDirection}\n\nRequired JSON version: ${ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1}`;
}

export function validateZodianShadowNaturalReaderWriterCanaryV1Output(output: unknown, packet: Pick<ZodianShadowNaturalReaderWriterCanaryV1Packet, "scenarioId" | "identity" | "brief">): ZodianShadowNaturalReaderWriterCanaryV1Finding[] {
  const findings: ZodianShadowNaturalReaderWriterCanaryV1Finding[] = [];
  if (!output || typeof output !== "object") { add(findings, "output", "malformed", "error", "Output must be an object."); return findings; }
  const value = output as Partial<ZodianShadowNaturalReaderWriterCanaryV1Output>;
  if (value.version !== ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1) add(findings, "version", "incorrect_version", "error", "Output version is incorrect.");
  if (value.scenarioId !== packet.scenarioId) add(findings, "scenarioId", "incorrect_scenario", "error", "Scenario ID must match the requested packet.");
  if (!value.identity || value.identity.westernSign !== packet.identity.westernSign || value.identity.chineseSign !== packet.identity.chineseSign) add(findings, "identity", "incorrect_identity", "error", "Identity must match the requested packet.");
  const title = typeof value.title === "string" ? value.title.trim() : "";
  const read = typeof value.read === "string" ? value.read.trim() : "";
  if (!title) add(findings, "title", "required", "error", "Title is required.");
  if (!read) add(findings, "read", "required", "error", "Read is required.");
  if (!title || !read) return findings;
  if (title.length > 72) add(findings, "title", "too_long", "error", "Title must stay concise.");
  if (words(title).length < 2 || words(title).length > 8) add(findings, "title", "title_length", "warning", "Title is outside the preferred short range.");
  if (read.length < 220) add(findings, "read", "too_short", "error", "Read is incomplete for the canary.");
  if (read.length > 900) add(findings, "read", "too_long", "error", "Read is too long for mobile reading.");
  if (words(read).length < 80 || words(read).length > 130) add(findings, "read", "target_length", "warning", "Read is outside the approximate 80–130 word target.");
  for (const [field, text] of [["title", title], ["read", read]] as const) {
    if (SIGNS.test(text)) add(findings, field, "sign_name", "error", "Reader-facing copy must not name signs.");
    if (ASTROLOGY.test(text)) add(findings, field, "astrology_mechanics", "error", "Reader-facing copy must not include astrology mechanics.");
    if (FIXED_SCENE.test(text)) add(findings, field, "invented_scene", "error", "Reader-facing copy must not invent a fixed external scene.");
    if (THERAPY_OR_CORPORATE.test(text)) add(findings, field, "therapy_or_corporate_language", "error", "Reader-facing copy must avoid therapy and corporate language.");
    if (METADATA.test(text)) add(findings, field, "metadata_reference", "error", "Reader-facing copy must not reference editorial metadata.");
  }
  if (HOROSCOPE_WARMUP.test(read)) add(findings, "read", "generic_horoscope_warmup", "error", "Read must not use a generic horoscope opening.");
  if (MULTIPLE_THEMES.test(read)) add(findings, "read", "multiple_themes", "error", "Read contains a second-theme tripwire.");
  if (repeatedSentence(read)) add(findings, "read", "excessive_repetition", "error", "Read repeats a substantial sentence.");
  if ((read.match(DIRECTIVE) ?? []).length > 1) add(findings, "read", "commands_dominate", "error", "Commands dominate the read.");
  if (containsCopiedPhrase(read, packet.brief)) add(findings, "read", "mechanical_brief_copy", "warning", "Read closely mirrors multiple internal brief fields.");
  if (normalize(title) === normalize(packet.brief.hookDirection)) add(findings, "title", "mechanical_hook_title", "warning", "Title mechanically repeats the hook direction.");
  if (GENERIC_ADVICE_ENDING.test(read)) add(findings, "read", "generic_advice_ending", "warning", "Ending reads as generic advice.");
  const sentences = read.split(/[.!?]+/).map((sentence) => sentence.trim()).filter(Boolean);
  if (sentences.length >= 2 && normalize(sentences[0]) === normalize(sentences.at(-1)!)) add(findings, "read", "repeated_opening_ending", "warning", "Ending repeats the opening.");
  if ((read.match(/\?/g) ?? []).length > 2) add(findings, "read", "excessive_rhetorical_questions", "warning", "Read relies on too many rhetorical questions.");
  return findings;
}
