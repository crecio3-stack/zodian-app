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
  matchedBriefField?: "dailyThread" | "centralTension" | "readerQuestion" | "hookDirection" | "perspectiveShift" | "landingDirection";
};

export type ZodianShadowNaturalReaderWriterCanaryV1ProviderRequest = {
  model: "gpt-5.6-terra";
  input: string;
  text: { format: { type: "json_object" } };
  max_output_tokens: 500;
};

export type ZodianShadowNaturalReaderWriterCanaryV1CorpusFinding = {
  field: "corpus";
  code: "repeated_but_turn" | "repeated_ending_structure" | "repeated_real_but" | "repeated_what_happens_ending";
  severity: "warning";
  message: string;
};

const SIGNS = /\b(?:aries|taurus|gemini|cancer|leo|virgo|libra|scorpio|sagittarius|capricorn|aquarius|pisces|rat|ox|tiger|rabbit|dragon|snake|horse|goat|monkey|rooster|dog|pig)\b/i;
const ASTROLOGY = /\b(?:planet|transit|ascendant|rising sign|house|natal|retrograde|conjunction|opposition|trine|square|sextile|chart|zodiac|mercury|venus|mars|jupiter|saturn|uranus|neptune|pluto|\d{1,2}\s*°)\b/i;
const FIXED_SCENE = /\b(?:at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)|slack|zoom|instagram|tiktok|office|workplace|meeting|restaurant|cafe|airport|classroom|kitchen|manager|coworker|boss|on the train|at work)\b/i;
const THERAPY_OR_CORPORATE = /\b(?:trauma|triggered|healing journey|inner child|emotional regulation|boundaries work|stakeholder|deliverable|leverage|synergy|bandwidth|optimize|action item)\b/i;
const METADATA = /\b(?:the (?:editorial )?brief|daily thread|central tension|reader question|hook direction|perspective shift|landing direction|metadata|scenario id)\b/i;
const HOROSCOPE_WARMUP = /\b(?:today you(?:'ll| will)|your horoscope|the stars|the universe|lucky day|cosmic)\b/i;
const MULTIPLE_THEMES = /\b(?:on the other hand|in a different area|separately)\b/i;
const DIRECTIVE = /(?:^|[.!?]\s+)(?:try to|remember to|make sure you|you should|you need to|do not|don't|avoid|start by|take time to)\b/gi;
const GENERIC_ADVICE_ENDING = /\b(?:trust yourself|be yourself|everything happens for a reason|keep going|you've got this)\s*[.!?]?$/i;
const ACTION_ORIENTATION = /^(?:naming it may|once you|when you set|if you speak|you can simply|you may want to|you might need to|the next step is|what matters now is to|the way through is|it is time to|you do not have to|you are allowed to|you should|you need to)\b/i;
const ACTION_SHIFT = /^(?:set the boundary|say what you mean|stop waiting|follow through|ask for clarity|give them space|be honest|make the choice)\b/i;
const COMMAND_ENDING = /^(?:set|say|stop|follow|ask|give|be|make|choose|tell|take)\b/i;
const OUTPUT_FIELDS = ["version", "scenarioId", "identity", "title", "read"];
const BRIEF_FIELDS = ["dailyThread", "centralTension", "readerQuestion", "hookDirection", "perspectiveShift", "landingDirection"] as const;

function add(findings: ZodianShadowNaturalReaderWriterCanaryV1Finding[], field: ZodianShadowNaturalReaderWriterCanaryV1Finding["field"], code: string, severity: "error" | "warning", message: string, matchedBriefField?: ZodianShadowNaturalReaderWriterCanaryV1Finding["matchedBriefField"]) {
  findings.push({ field, code, severity, message, ...(matchedBriefField ? { matchedBriefField } : {}) });
}

function words(value: string): string[] { return value.toLowerCase().match(/[a-z]+(?:'[a-z]+)?/g) ?? []; }
function normalize(value: string): string { return words(value).join(" "); }
function repeatedSentence(value: string): boolean {
  const sentences = value.split(/[.!?]+/).map(normalize).filter((sentence) => sentence.length >= 12);
  return new Set(sentences).size !== sentences.length;
}
function sentences(value: string): string[] { return value.split(/[.!?]+/).map((sentence) => sentence.trim()).filter(Boolean); }
function substantialPhraseCopied(read: string, field: string): boolean {
  const source = words(field); const target = normalize(read);
  for (let index = 0; index <= source.length - 5; index++) if (target.includes(source.slice(index, index + 5).join(" "))) return true;
  return false;
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
  return `Write one concise daily read for a person. The story has already been selected; write only that story. Do not add another lesson or theme. Preserve the brief's story, not its sentences: do not reuse an entire brief sentence, reproduce its hook, perspective shift, or landing verbatim, or keep the same clause structure with small synonym changes. At most one short unavoidable phrase may survive. The final sentence must be newly phrased. Do not explain astrology, mention signs in title or read, invent a detailed external scene, use named people, locations, workplaces, or apps, or expose this packet's structure. Establish tension before any orientation. For limits, boundaries, choices, confrontation, honesty, and clarity, reveal what is already changing—the pressure, cost, or relationship shift—not the action a reader should perform. Do not make the read a boundary-setting lesson or an instruction. Avoid “Naming it may,” “Once you,” “When you set the limit,” “If you speak up,” “You can simply,” “You may want to,” “You might need to,” “The next step is,” “What matters now is to,” “The way through is,” “It is time to,” “You do not have to,” and “You are allowed to.” Prefer zero action sentences. At most one optional action-oriented sentence may appear only after tension is established; it cannot be the perspective shift or final sentence. The shift must change what the situation means, not recommend an action. The landing describes clarified reality or unresolved but better-defined tension, never a command, permission, or action plan. Do not default to a contrast sentence beginning with “But”; let escalation, contradiction, realization, or changed meaning move the read. The first sentence must create curiosity. The last sentence must land, not instruct. Use plain, current, conversational English: direct, observant, confident, and warm. Avoid therapy, corporate, mystical, generic-advice, decorative, and moralizing language. Return JSON only, with no commentary or wrapper text, and exactly these fields: version, scenarioId, identity, title, read. Identity must be an object, never a combined string: {"westernSign":"${identity.westernSign}","chineseSign":"${identity.chineseSign}"}. The title should be short and curious. The read should address the reader as you and normally be about 80–130 words.\n\nIdentity labels: ${identity.westernSign} × ${identity.chineseSign}\nScenario ID: ${scenarioId}\nDaily thread: ${brief.dailyThread}\nCentral tension: ${brief.centralTension}\nReader question: ${brief.readerQuestion}\nHook direction: ${brief.hookDirection}\nPerspective shift: ${brief.perspectiveShift}\nLanding direction: ${brief.landingDirection}\n\nRequired JSON version: ${ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1}`;
}

export function buildZodianShadowNaturalReaderWriterCanaryV1ProviderRequest(packet: Pick<ZodianShadowNaturalReaderWriterCanaryV1Packet, "prompt">): ZodianShadowNaturalReaderWriterCanaryV1ProviderRequest {
  return { model: "gpt-5.6-terra", input: packet.prompt, text: { format: { type: "json_object" } }, max_output_tokens: 500 };
}

export function validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest(request: unknown): string[] {
  if (!request || typeof request !== "object") return ["request must be an object"];
  const value = request as Record<string, unknown>; const findings: string[] = [];
  if (value.model !== "gpt-5.6-terra") findings.push("model must be gpt-5.6-terra");
  if (value.max_output_tokens !== 500) findings.push("max_output_tokens must be 500");
  if (!value.text || typeof value.text !== "object" || (value.text as { format?: { type?: unknown } }).format?.type !== "json_object") findings.push("text.format.type must be json_object");
  if ("temperature" in value) findings.push("temperature is unsupported");
  for (const key of Object.keys(value)) if (!["model", "input", "text", "max_output_tokens"].includes(key)) findings.push(`unexpected generation parameter: ${key}`);
  return findings;
}

export function validateZodianShadowNaturalReaderWriterCanaryV1Output(output: unknown, packet: Pick<ZodianShadowNaturalReaderWriterCanaryV1Packet, "scenarioId" | "identity" | "brief">): ZodianShadowNaturalReaderWriterCanaryV1Finding[] {
  const findings: ZodianShadowNaturalReaderWriterCanaryV1Finding[] = [];
  if (!output || typeof output !== "object") { add(findings, "output", "malformed", "error", "Output must be an object."); return findings; }
  const value = output as Partial<ZodianShadowNaturalReaderWriterCanaryV1Output>;
  for (const key of Object.keys(value)) if (!OUTPUT_FIELDS.includes(key)) add(findings, "output", "unexpected_field", "error", `Unexpected output field: ${key}.`);
  if (value.version !== ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1) add(findings, "version", "incorrect_version", "error", "Output version is incorrect.");
  if (value.scenarioId !== packet.scenarioId) add(findings, "scenarioId", "incorrect_scenario", "error", "Scenario ID must match the requested packet.");
  if (!value.identity || typeof value.identity !== "object" || Object.keys(value.identity).length !== 2 || !Object.hasOwn(value.identity, "westernSign") || !Object.hasOwn(value.identity, "chineseSign") || value.identity.westernSign !== packet.identity.westernSign || value.identity.chineseSign !== packet.identity.chineseSign) add(findings, "identity", "incorrect_identity", "error", "Identity must be the exact requested westernSign/chineseSign object.");
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
  if ((read.match(DIRECTIVE) ?? []).length > 1) add(findings, "read", "commands_dominate", "error", "Advice language dominates the read.");
  if (GENERIC_ADVICE_ENDING.test(read)) add(findings, "read", "generic_advice_ending", "error", "Ending must not be generic advice.");
  const outputSentences = sentences(read); const opening = normalize(outputSentences[0] ?? ""); const ending = normalize(outputSentences.at(-1) ?? "");
  const copiedFields = BRIEF_FIELDS.filter((field) => substantialPhraseCopied(read, packet.brief[field]));
  for (const field of BRIEF_FIELDS) {
    const source = normalize(packet.brief[field]);
    if (source && outputSentences.some((sentence) => normalize(sentence) === source)) add(findings, "read", "brief_sentence_copied", field === "hookDirection" || field === "landingDirection" ? "error" : "warning", "A complete internal brief sentence appears in the read.", field);
  }
  if (opening === normalize(packet.brief.hookDirection)) add(findings, "read", "hook_copied_at_opening", "error", "Opening exactly copies hookDirection.", "hookDirection");
  if (ending === normalize(packet.brief.landingDirection)) add(findings, "read", "landing_copied_at_ending", "error", "Ending exactly copies landingDirection.", "landingDirection");
  if (copiedFields.length >= 2) add(findings, "read", "mechanical_brief_copy", "warning", "Two or more substantial brief phrases appear in the read.", copiedFields[0]);
  if (copiedFields.length >= 2 && opening && ending && (substantialPhraseCopied(outputSentences[0] ?? "", packet.brief.hookDirection) || substantialPhraseCopied(outputSentences.at(-1) ?? "", packet.brief.landingDirection))) add(findings, "read", "opening_ending_brief_mirror", "warning", "Opening and ending both mirror internal brief language.");
  if (normalize(title) === normalize(packet.brief.hookDirection)) add(findings, "title", "mechanical_hook_title", "warning", "Title mechanically repeats the hook direction.");
  if (outputSentences.length >= 2 && normalize(outputSentences[0]) === normalize(outputSentences.at(-1)!)) add(findings, "read", "repeated_opening_ending", "warning", "Ending repeats the opening.");
  if ((read.match(/\?/g) ?? []).length > 2) add(findings, "read", "excessive_rhetorical_questions", "warning", "Read relies on too many rhetorical questions.");
  const actionSentences = outputSentences.map((sentence, index) => ({ sentence, index })).filter(({ sentence }) => ACTION_ORIENTATION.test(sentence) || ACTION_SHIFT.test(sentence));
  if (actionSentences.length >= 2) add(findings, "read", "advice_sentences_dominate", "error", "Two or more advice-oriented sentences are not allowed.");
  for (const { sentence, index } of actionSentences) {
    if (index < 2) add(findings, "read", "advice_before_tension", "error", "Action-oriented language appears before tension is established.");
    else if (index === outputSentences.length - 1) add(findings, "read", "action_landing", "error", "Landing must describe clarified reality, not an action.");
    else if (ACTION_SHIFT.test(sentence)) add(findings, "read", "action_recommendation_shift", "error", "Perspective shift must reinterpret the situation, not recommend an action.");
    else add(findings, "read", "mild_action_orientation", "warning", "One optional action-oriented sentence follows the established tension.");
    if (/^(?:naming it may|once you)\b/i.test(sentence)) add(findings, "read", "disguised_instruction", "warning", "Naming it or Once you construction may disguise advice as observation.");
  }
  const finalSentence = outputSentences.at(-1) ?? "";
  if (COMMAND_ENDING.test(finalSentence)) add(findings, "read", "direct_command_ending", "error", "Final sentence must not be a direct command.");
  if (/^(?:you are allowed to|you do not have to|now you can)\b/i.test(finalSentence)) add(findings, "read", "permission_ending", "error", "Final sentence must not use permission language.");
  if (/\bthe next step\b/i.test(finalSentence)) add(findings, "read", "next_step_ending", "error", "Final sentence must not name a next step.");
  return findings;
}

export function auditZodianShadowNaturalReaderWriterCanaryV1Corpus(outputs: readonly Pick<ZodianShadowNaturalReaderWriterCanaryV1Output, "read">[]): ZodianShadowNaturalReaderWriterCanaryV1CorpusFinding[] {
  const findings: ZodianShadowNaturalReaderWriterCanaryV1CorpusFinding[] = [];
  const reads = outputs.map((output) => sentences(output.read));
  if (reads.filter((items) => items.slice(1, -1).some((item) => /^but\b/i.test(item))).length >= 3) findings.push({ field: "corpus", code: "repeated_but_turn", severity: "warning", message: "Three or more reads use a mid-read But turn." });
  const endings = reads.map((items) => normalize(items.at(-1) ?? ""));
  if (new Set(endings).size < endings.length) findings.push({ field: "corpus", code: "repeated_ending_structure", severity: "warning", message: "Final-sentence structures repeat across reads." });
  if (outputs.filter((output) => /\bthe\s+\w+\s+is\s+real\s+but\b/i.test(output.read)).length >= 2) findings.push({ field: "corpus", code: "repeated_real_but", severity: "warning", message: "The X is real, but construction repeats." });
  if (endings.filter((ending) => /^what happens/.test(ending)).length >= 2) findings.push({ field: "corpus", code: "repeated_what_happens_ending", severity: "warning", message: "What happens ending construction repeats." });
  return findings;
}
