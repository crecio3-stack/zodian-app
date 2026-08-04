import {
  getZodianCanonicalIdentityDistillationPilotProfileV1,
  listZodianCanonicalIdentityDistillationPilotV1,
} from "./zodian-canonical-identity-distillation-pilot-v1.ts";
import type { ZodianIdentityEditorialProfile } from "./zodian-identity-editorial-layer-v1.ts";
import {
  ZODIAN_STORY_ENGINE_V1,
  type ZodianStoryEngineV1Brief,
  validateZodianStoryEngineV1Brief,
} from "./zodian-story-engine-v1.ts";

export const ZODIAN_SHADOW_STORY_SCENARIO_V1 = "zodian-shadow-story-scenario-v1" as const;
type IdentityCategory = "coreMotivations" | "recurringStrengths" | "recurringFriction" | "commonBlindSpots" | "interpersonalPatterns" | "emotionalPatterns";

export type ZodianShadowStoryScenarioV1 = {
  version: typeof ZODIAN_SHADOW_STORY_SCENARIO_V1;
  scenarioId: string;
  identity: { westernSign: string; chineseSign: string };
  sourceProfileVersion: "zodian-identity-editorial-layer-v1";
  selectedIdentitySignal: { category: IdentityCategory; note: string };
  editorialPressure: string;
  selectionReason: string;
  dailyThreadDirection: string;
  centralTensionDirection: string;
  readerQuestionDirection: string;
  hookDirection: string;
  perspectiveShiftDirection: string;
  landingDirection: string;
};

export type ZodianShadowStoryPipelineV1Finding = {
  field: string;
  code: "required" | "duplicate_scenario_id" | "unsupported_identity" | "incorrect_profile_version" | "unknown_category" | "selected_note_not_in_profile" | "too_long" | "second_person" | "direct_command" | "horoscope_prose" | "technical_astrology" | "fixed_external_scenario" | "multiple_pressures" | "invalid_brief" | "duplicate_daily_thread" | "duplicate_brief_field" | "mismatched_identity" | "profile_note_copied" | "wrong_scenario_count";
  message: string;
  index?: number;
};

const CATEGORIES: IdentityCategory[] = ["coreMotivations", "recurringStrengths", "recurringFriction", "commonBlindSpots", "interpersonalPatterns", "emotionalPatterns"];
const TEXT_FIELDS = ["editorialPressure", "selectionReason", "dailyThreadDirection", "centralTensionDirection", "readerQuestionDirection", "hookDirection", "perspectiveShiftDirection", "landingDirection"] as const;
const MAX_LENGTH = 160;
const SECOND_PERSON = /\b(?:you|your|yourself|yours)\b/i;
const COMMAND = /^\s*(?:do not|don't|remember to|make sure|try to|avoid|stop|start|choose|take|tell|ask|wait|let|keep)\b/i;
const HOROSCOPE = /\b(?:your horoscope|the stars say|today you will|the universe wants|a lucky|fortune)\b/i;
const ASTROLOGY = /\b(?:planet|transit|ascendant|rising sign|house|natal|retrograde|conjunction|opposition|trine|square|sextile|chart|zodiac|\d{1,2}\s*°)\b/i;
const FIXED_SCENE = /\b(?:at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)|slack|zoom|instagram|tiktok|office|workplace|meeting|restaurant|cafe|airport|classroom|kitchen|manager|coworker|boss)\b/i;
const MULTIPLE_PRESSURES = /\b(?:while also|as well as|and separately)\b/i;

const SCENARIOS: readonly ZodianShadowStoryScenarioV1[] = Object.freeze([
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "libra-snake-boundary", identity: { westernSign: "Libra", chineseSign: "Snake" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "Charm can obscure when a firmer boundary is needed." }, editorialPressure: "A small discomfort keeps getting softened so the real limit stays unnamed.", selectionReason: "The wish to remain appealing can delay a needed boundary.", dailyThreadDirection: "A softened discomfort is asking for a clear limit.", centralTensionDirection: "Keeping the mood easy versus naming what no longer works.", readerQuestionDirection: "What changes once the issue is named without managing every reaction?", hookDirection: "The problem is not as small as it has been made to seem.", perspectiveShiftDirection: "The silence has started to change the balance on its own.", landingDirection: "What stays unnamed is already shaping the connection." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "libra-snake-management", identity: { westernSign: "Libra", chineseSign: "Snake" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "Generosity of attention can become managing everyone." }, editorialPressure: "Helping starts before the other person has chosen what belongs to them.", selectionReason: "Generosity can hide the moment attention begins carrying an unassigned decision.", dailyThreadDirection: "Care is starting to carry a decision that was never handed over.", centralTensionDirection: "Helping quickly versus allowing another person their part.", readerQuestionDirection: "When did the help begin taking the place of a choice?", hookDirection: "The help arrived before anyone asked it to decide.", perspectiveShiftDirection: "The attention is doing work that no one assigned it.", landingDirection: "The other person's part is getting smaller inside the help." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "taurus-horse-overlooked", identity: { westernSign: "Taurus", chineseSign: "Horse" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May mistake being overlooked for being undervalued." }, editorialPressure: "A lack of response is being treated as proof that ability does not matter.", selectionReason: "Feeling unseen can turn incomplete evidence into a verdict about ability.", dailyThreadDirection: "A quiet response is starting to stand in for a judgment of worth.", centralTensionDirection: "Protecting pride versus waiting for the picture to fill in.", readerQuestionDirection: "What evidence is missing before this becomes a verdict?", hookDirection: "The silence may not mean what it first appears to mean.", perspectiveShiftDirection: "The verdict arrived before the evidence did.", landingDirection: "The silence still has more than one meaning." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "taurus-horse-trust", identity: { westernSign: "Taurus", chineseSign: "Horse" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "recurringFriction", note: "Confidence in talent can collide with the slow work of earning trust." }, editorialPressure: "A quick self-assessment faces a slower test of reliability.", selectionReason: "Ability matters here, but reliability unfolds more slowly than confidence.", dailyThreadDirection: "A strong first impression is facing the slower question of reliability.", centralTensionDirection: "Being impressive versus being someone others settle into relying on.", readerQuestionDirection: "What makes an early showing feel settled before it has lasted?", hookDirection: "Being capable is not the same as being counted on yet.", perspectiveShiftDirection: "The first showing and the longer experience are not asking the same thing.", landingDirection: "What lasts is still separate from what impressed at first." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "sagittarius-monkey-stake", identity: { westernSign: "Sagittarius", chineseSign: "Monkey" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May hide self-interest behind a larger mission." }, editorialPressure: "A larger aim is making what benefits the person harder to name.", selectionReason: "The cause matters, but what the person gets from it changes the choice.", dailyThreadDirection: "A larger cause is carrying something that also benefits the person.", centralTensionDirection: "Serving the cause versus admitting what is also gained.", readerQuestionDirection: "What changes when what is gained becomes part of the picture?", hookDirection: "The cause may be carrying more than one motive.", perspectiveShiftDirection: "The cause and the benefit do not have to be the same story.", landingDirection: "The part that belongs to the person has been present all along." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "sagittarius-monkey-obligation", identity: { westernSign: "Sagittarius", chineseSign: "Monkey" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "emotionalPatterns", note: "Keeps emotional obligations secondary to larger aims." }, editorialPressure: "The goal keeps moving forward while someone close keeps being asked to wait.", selectionReason: "Momentum becomes relevant when a relationship is treated as background.", dailyThreadDirection: "A moving goal is pushing a close bond farther into the background.", centralTensionDirection: "Keeping momentum versus noticing what has been asked to wait.", readerQuestionDirection: "What has been pushed aside while the goal keeps moving?", hookDirection: "The goal is moving forward, but something close has been left behind it.", perspectiveShiftDirection: "The bond has become part of the cost, not just background.", landingDirection: "What has been waiting is no longer outside the story." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "gemini-dragon-commitment", identity: { westernSign: "Gemini", chineseSign: "Dragon" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May confuse a bold first move with durable commitment." }, editorialPressure: "An exciting start is being treated as evidence that the hard part is finished.", selectionReason: "The first burst holds attention, but routine decides whether it lasts.", dailyThreadDirection: "A loud beginning is starting to feel complete before the routine arrives.", centralTensionDirection: "Following the spark versus staying when the spark is gone.", readerQuestionDirection: "What remains after the first burst of energy settles?", hookDirection: "The momentum is real, but it has not asked to stay yet.", perspectiveShiftDirection: "The first move feels finished because it made an entrance.", landingDirection: "What happens after the excitement fades is still unwritten." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "gemini-dragon-distance", identity: { westernSign: "Gemini", chineseSign: "Dragon" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May read ordinary distance as a loss of loyalty." }, editorialPressure: "A normal pause in closeness is being read as a change in loyalty.", selectionReason: "The pause feels personal before there is evidence.", dailyThreadDirection: "A quiet gap is starting to fill itself in.", centralTensionDirection: "Filling in the silence versus leaving the gap unfinished.", readerQuestionDirection: "What else could this pause mean before it becomes a verdict?", hookDirection: "The gap is starting to fill itself in.", perspectiveShiftDirection: "The pause has become a verdict before it has said anything.", landingDirection: "The meaning of the gap is still open." },
]) as unknown as readonly ZodianShadowStoryScenarioV1[];

function cloneScenario(s: ZodianShadowStoryScenarioV1): ZodianShadowStoryScenarioV1 { return { ...s, identity: { ...s.identity }, selectedIdentitySignal: { ...s.selectedIdentitySignal } }; }
function add(findings: ZodianShadowStoryPipelineV1Finding[], field: string, code: ZodianShadowStoryPipelineV1Finding["code"], message: string, index?: number) { findings.push({ field, code, message, ...(index === undefined ? {} : { index }) }); }
function profileFor(s: ZodianShadowStoryScenarioV1) { return getZodianCanonicalIdentityDistillationPilotProfileV1(s.identity.westernSign, s.identity.chineseSign); }

export function listZodianShadowStoryScenariosV1(): ZodianShadowStoryScenarioV1[] { return SCENARIOS.map(cloneScenario); }
export function getZodianShadowStoryScenarioV1(scenarioId: string): ZodianShadowStoryScenarioV1 | undefined { const s = SCENARIOS.find((candidate) => candidate.scenarioId === scenarioId); return s ? cloneScenario(s) : undefined; }

export function validateZodianShadowStoryScenarioV1(s: ZodianShadowStoryScenarioV1): ZodianShadowStoryPipelineV1Finding[] {
  const findings: ZodianShadowStoryPipelineV1Finding[] = [];
  if (!s.scenarioId.trim()) add(findings, "scenarioId", "required", "scenarioId is required.");
  const profile = profileFor(s);
  if (!profile) add(findings, "identity", "unsupported_identity", "Identity is not in the pilot.");
  if (s.sourceProfileVersion !== "zodian-identity-editorial-layer-v1") add(findings, "sourceProfileVersion", "incorrect_profile_version", "Profile version is not supported.");
  if (!CATEGORIES.includes(s.selectedIdentitySignal.category)) add(findings, "selectedIdentitySignal.category", "unknown_category", "Profile category is not supported.");
  if (profile && (!CATEGORIES.includes(s.selectedIdentitySignal.category) || !profile[s.selectedIdentitySignal.category].includes(s.selectedIdentitySignal.note))) add(findings, "selectedIdentitySignal.note", "selected_note_not_in_profile", "Selected note is not in the identity profile.");
  for (const field of TEXT_FIELDS) {
    const value = s[field].trim();
    if (!value) add(findings, field, "required", "Scenario direction is required.");
    if (value.length > MAX_LENGTH) add(findings, field, "too_long", "Scenario directions must be 160 characters or fewer.");
    if (SECOND_PERSON.test(value)) add(findings, field, "second_person", "Scenario directions must not address the reader.");
    if (COMMAND.test(value)) add(findings, field, "direct_command", "Scenario directions must not give commands.");
    if (HOROSCOPE.test(value)) add(findings, field, "horoscope_prose", "Scenario directions must not be horoscope prose.");
    if (ASTROLOGY.test(value)) add(findings, field, "technical_astrology", "Scenario directions must not contain astrology mechanics.");
    if (FIXED_SCENE.test(value)) add(findings, field, "fixed_external_scenario", "Scenario directions must not fix an external scene.");
  }
  if (MULTIPLE_PRESSURES.test(s.editorialPressure)) add(findings, "editorialPressure", "multiple_pressures", "Scenario must contain one editorial pressure.");
  return findings;
}

export function buildZodianShadowStoryBriefV1(profile: ZodianIdentityEditorialProfile, s: ZodianShadowStoryScenarioV1): ZodianStoryEngineV1Brief {
  const errors = validateZodianShadowStoryScenarioV1(s);
  if (errors.length) throw new Error(`Invalid shadow scenario: ${errors.map((finding) => finding.code).join(",")}`);
  if (profile.identity.westernSign !== s.identity.westernSign || profile.identity.chineseSign !== s.identity.chineseSign) throw new Error("Profile identity does not match scenario identity.");
  return { version: ZODIAN_STORY_ENGINE_V1, identity: { ...s.identity }, dailyThread: s.dailyThreadDirection, centralTension: s.centralTensionDirection, readerQuestion: s.readerQuestionDirection, hookDirection: s.hookDirection, perspectiveShift: s.perspectiveShiftDirection, landingDirection: s.landingDirection };
}

export function buildAllZodianShadowStoryBriefsV1(): ZodianStoryEngineV1Brief[] { return SCENARIOS.map((s) => buildZodianShadowStoryBriefV1(profileFor(s)! , s)); }

export function auditZodianShadowStoryPipelineV1(scenarios: readonly ZodianShadowStoryScenarioV1[] = SCENARIOS): ZodianShadowStoryPipelineV1Finding[] {
  const findings: ZodianShadowStoryPipelineV1Finding[] = []; const ids = new Set<string>(); const threads = new Set<string>(); const fields = new Set<string>(); const counts = new Map<string, number>();
  scenarios.forEach((s, index) => {
    if (ids.has(s.scenarioId)) add(findings, "scenarioId", "duplicate_scenario_id", "Scenario IDs must be distinct.", index); ids.add(s.scenarioId);
    const scenarioFindings = validateZodianShadowStoryScenarioV1(s);
    for (const finding of scenarioFindings) add(findings, finding.field, finding.code, finding.message, index);
    if (scenarioFindings.length) return;
    const profile = profileFor(s); if (!profile) return;
    counts.set(`${s.identity.westernSign}\u0000${s.identity.chineseSign}`, (counts.get(`${s.identity.westernSign}\u0000${s.identity.chineseSign}`) ?? 0) + 1);
    const brief = buildZodianShadowStoryBriefV1(profile, s);
    if (validateZodianStoryEngineV1Brief(brief).length) add(findings, "brief", "invalid_brief", "Generated brief is invalid.", index);
    if (brief.identity.westernSign !== s.identity.westernSign || brief.identity.chineseSign !== s.identity.chineseSign) add(findings, "brief.identity", "mismatched_identity", "Brief identity does not match scenario.", index);
    if (threads.has(brief.dailyThread)) add(findings, "dailyThread", "duplicate_daily_thread", "Generated daily threads must be distinct.", index); threads.add(brief.dailyThread);
    for (const value of [brief.dailyThread, brief.centralTension, brief.readerQuestion, brief.hookDirection, brief.perspectiveShift, brief.landingDirection]) { if (fields.has(value)) add(findings, "brief", "duplicate_brief_field", "Brief fields must not repeat across scenarios.", index); fields.add(value); }
    const briefText = JSON.stringify(brief); for (const note of [...profile.coreMotivations, ...profile.recurringStrengths, ...profile.recurringFriction, ...profile.commonBlindSpots, ...profile.interpersonalPatterns, ...profile.emotionalPatterns]) if (briefText.includes(note)) add(findings, "brief", "profile_note_copied", "Brief must not copy profile notes.", index);
  });
  for (const profile of listZodianCanonicalIdentityDistillationPilotV1()) if (counts.get(`${profile.identity.westernSign}\u0000${profile.identity.chineseSign}`) !== 2) add(findings, "identity", "wrong_scenario_count", "Each pilot identity needs exactly two scenarios.");
  return findings;
}
