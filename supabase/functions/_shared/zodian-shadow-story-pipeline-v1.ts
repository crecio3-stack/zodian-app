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
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "libra-snake-boundary", identity: { westernSign: "Libra", chineseSign: "Snake" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "Charm can obscure when a firmer boundary is needed." }, editorialPressure: "A small discomfort keeps getting softened so the real limit stays unnamed.", selectionReason: "The wish to remain appealing can delay a needed boundary.", dailyThreadDirection: "A softened discomfort is asking for a clear limit.", centralTensionDirection: "Keeping the mood easy versus naming what no longer works.", readerQuestionDirection: "What changes once the issue is named without managing every reaction?", hookDirection: "The problem is not as small as it has been made to seem.", perspectiveShiftDirection: "A boundary can be direct without becoming harsh.", landingDirection: "The next honest limit matters more than a perfect response." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "libra-snake-management", identity: { westernSign: "Libra", chineseSign: "Snake" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "Generosity of attention can become managing everyone." }, editorialPressure: "Extra care is beginning to steer choices that belong to other people.", selectionReason: "Warmth becomes relevant when it quietly takes over another person's part.", dailyThreadDirection: "Helpful attention is starting to carry more than its share.", centralTensionDirection: "Offering care versus leaving room for another person to decide.", readerQuestionDirection: "Where does support end and quiet control begin?", hookDirection: "The kind gesture may be doing more than it admits.", perspectiveShiftDirection: "Care can remain warm without directing every outcome.", landingDirection: "The useful move is to leave one choice open." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "taurus-horse-overlooked", identity: { westernSign: "Taurus", chineseSign: "Horse" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May mistake being overlooked for being undervalued." }, editorialPressure: "A lack of response is being treated as proof that ability does not matter.", selectionReason: "Feeling unseen can pull focus from the work that makes ability visible.", dailyThreadDirection: "Feeling unseen is competing with the effort needed to be noticed.", centralTensionDirection: "Protecting pride versus making the work easier to see.", readerQuestionDirection: "What evidence is missing before this becomes a verdict?", hookDirection: "The silence may not mean what it first appears to mean.", perspectiveShiftDirection: "Recognition often follows visible effort rather than private certainty.", landingDirection: "One clear contribution can test the assumption." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "taurus-horse-trust", identity: { westernSign: "Taurus", chineseSign: "Horse" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "recurringFriction", note: "Confidence in talent can collide with the slow work of earning trust." }, editorialPressure: "A quick self-assessment faces a slower test of reliability.", selectionReason: "Ability matters here, but consistency is the part under review.", dailyThreadDirection: "A strong ability is being tested by the patience that trust requires.", centralTensionDirection: "Relying on talent versus staying present for the slower proof.", readerQuestionDirection: "What would make this strength easier for others to rely on?", hookDirection: "Being capable is not the same as being counted on yet.", perspectiveShiftDirection: "Trust grows through repeated proof, not one impressive showing.", landingDirection: "The next steady step carries more weight than a grand claim." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "sagittarius-monkey-stake", identity: { westernSign: "Sagittarius", chineseSign: "Monkey" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May hide self-interest behind a larger mission." }, editorialPressure: "A larger aim is making a personal advantage harder to name.", selectionReason: "The mission matters, but the private stake changes how the choice should be read.", dailyThreadDirection: "A worthy mission is carrying an interest that needs a clearer name.", centralTensionDirection: "Serving the larger aim versus admitting the personal stake.", readerQuestionDirection: "What becomes simpler when the private gain is included in the picture?", hookDirection: "The cause may be carrying more than one motive.", perspectiveShiftDirection: "Naming the personal stake can make the larger aim more honest.", landingDirection: "A clearer motive makes the next decision easier to trust." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "sagittarius-monkey-obligation", identity: { westernSign: "Sagittarius", chineseSign: "Monkey" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "emotionalPatterns", note: "Keeps emotional obligations secondary to larger aims." }, editorialPressure: "A meaningful ambition is asking for time that a close bond also needs.", selectionReason: "A larger aim becomes relevant when closeness is treated as a distraction.", dailyThreadDirection: "A larger aim is competing with a bond that needs real attention.", centralTensionDirection: "Protecting momentum versus making room for emotional obligation.", readerQuestionDirection: "What part of this ambition changes when the close bond stays visible?", hookDirection: "The goal is clear, but another claim on attention is not going away.", perspectiveShiftDirection: "Closeness need not cancel ambition to matter.", landingDirection: "The next choice can show what remains important beside the goal." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "gemini-dragon-commitment", identity: { westernSign: "Gemini", chineseSign: "Dragon" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May confuse a bold first move with durable commitment." }, editorialPressure: "An exciting start is being treated as evidence that the hard part is finished.", selectionReason: "Early momentum matters, but the less exciting follow-through decides what lasts.", dailyThreadDirection: "A strong opening is asking to be tested by what happens after the spark.", centralTensionDirection: "Enjoying momentum versus staying with the less exciting work.", readerQuestionDirection: "What remains after the first burst of energy settles?", hookDirection: "The beginning worked; the real test arrives next.", perspectiveShiftDirection: "A bold start becomes meaningful when it survives the routine.", landingDirection: "The next repeatable action shows whether the promise can hold." },
  { version: ZODIAN_SHADOW_STORY_SCENARIO_V1, scenarioId: "gemini-dragon-distance", identity: { westernSign: "Gemini", chineseSign: "Dragon" }, sourceProfileVersion: "zodian-identity-editorial-layer-v1", selectedIdentitySignal: { category: "commonBlindSpots", note: "May read ordinary distance as a loss of loyalty." }, editorialPressure: "A normal pause in closeness is being read as a change in loyalty.", selectionReason: "The need for reassurance can make an ordinary gap feel like rejection.", dailyThreadDirection: "A quiet gap is carrying more meaning than it may deserve.", centralTensionDirection: "Wanting reassurance versus allowing ordinary distance.", readerQuestionDirection: "What else could this pause mean before it becomes a verdict?", hookDirection: "The gap may be real without meaning what it seems to mean.", perspectiveShiftDirection: "Distance can be ordinary without becoming disloyalty.", landingDirection: "One calmer reading leaves room for the connection to speak." },
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
