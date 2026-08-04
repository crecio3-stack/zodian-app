import { assert, assertEquals, assertThrows } from "jsr:@std/assert";
import {
  auditZodianShadowStoryPipelineV1,
  buildAllZodianShadowStoryBriefsV1,
  buildZodianShadowStoryBriefV1,
  getZodianShadowStoryScenarioV1,
  listZodianShadowStoryScenariosV1,
  validateZodianShadowStoryScenarioV1,
} from "./zodian-shadow-story-pipeline-v1.ts";
import { getZodianCanonicalIdentityDistillationPilotProfileV1 } from "./zodian-canonical-identity-distillation-pilot-v1.ts";
import { validateZodianStoryEngineV1Brief } from "./zodian-story-engine-v1.ts";

const APPROVED_PATHS = [
  "docs/editorial/ZODIAN_SHADOW_STORY_PIPELINE_V1.md",
  "docs/editorial/ZODIAN_SHADOW_STORY_PIPELINE_V1_REVIEW.md",
  "supabase/functions/_shared/zodian-shadow-story-pipeline-v1.ts",
  "supabase/functions/_shared/zodian-shadow-story-pipeline-v1_test.ts",
];

Deno.test("eight unique scenarios cover each pilot identity twice with different signals", () => {
  const scenarios = listZodianShadowStoryScenariosV1();
  assertEquals(scenarios.length, 8);
  assertEquals(new Set(scenarios.map((scenario) => scenario.scenarioId)).size, 8);
  for (const identity of ["Libra\u0000Snake", "Taurus\u0000Horse", "Sagittarius\u0000Monkey", "Gemini\u0000Dragon"]) {
    const pair = scenarios.filter((scenario) => `${scenario.identity.westernSign}\u0000${scenario.identity.chineseSign}` === identity);
    assertEquals(pair.length, 2);
    assert(pair[0].selectedIdentitySignal.note !== pair[1].selectedIdentitySignal.note);
  }
});

Deno.test("every scenario is valid, selects an exact pilot note, and generates a valid matching brief", () => {
  for (const scenario of listZodianShadowStoryScenariosV1()) {
    assertEquals(validateZodianShadowStoryScenarioV1(scenario), []);
    const profile = getZodianCanonicalIdentityDistillationPilotProfileV1(scenario.identity.westernSign, scenario.identity.chineseSign)!;
    const brief = buildZodianShadowStoryBriefV1(profile, scenario);
    assertEquals(validateZodianStoryEngineV1Brief(brief), []);
    assertEquals(brief.identity, scenario.identity);
    assert(brief.dailyThread.trim().length > 0);
  }
});

Deno.test("paired briefs have distinct daily threads and do not copy full profile notes", () => {
  const scenarios = listZodianShadowStoryScenariosV1();
  const briefs = buildAllZodianShadowStoryBriefsV1();
  assertEquals(new Set(briefs.map((brief) => brief.dailyThread)).size, 8);
  for (const [index, scenario] of scenarios.entries()) {
    const profile = getZodianCanonicalIdentityDistillationPilotProfileV1(scenario.identity.westernSign, scenario.identity.chineseSign)!;
    const text = JSON.stringify(briefs[index]);
    const notes = [...profile.coreMotivations, ...profile.recurringStrengths, ...profile.recurringFriction, ...profile.commonBlindSpots, ...profile.interpersonalPatterns, ...profile.emotionalPatterns];
    assert(notes.every((note) => !text.includes(note)));
  }
});

Deno.test("invalid selected notes, duplicate IDs, and unsupported identities fail", () => {
  const invalidNote = listZodianShadowStoryScenariosV1()[0];
  invalidNote.selectedIdentitySignal.note = "not a pilot note";
  assert(validateZodianShadowStoryScenarioV1(invalidNote).some((finding) => finding.field === "selectedIdentitySignal.note" && finding.code === "selected_note_not_in_profile"));
  assertThrows(() => buildZodianShadowStoryBriefV1(getZodianCanonicalIdentityDistillationPilotProfileV1("Libra", "Snake")!, invalidNote));

  const invalid = listZodianShadowStoryScenariosV1();
  invalid[1].scenarioId = invalid[0].scenarioId;
  invalid[2].identity = { westernSign: "Unknown", chineseSign: "Unknown" };
  const findings = auditZodianShadowStoryPipelineV1(invalid);
  assert(findings.some((finding) => finding.code === "duplicate_scenario_id"));
  assert(findings.some((finding) => finding.code === "unsupported_identity"));
});

Deno.test("aggregate audit reports injected invalid scenarios and briefs", () => {
  const invalidScenario = listZodianShadowStoryScenariosV1();
  invalidScenario[0].selectedIdentitySignal.note = "not a pilot note";
  assert(auditZodianShadowStoryPipelineV1(invalidScenario).some((finding) => finding.code === "selected_note_not_in_profile"));

  const invalidBrief = listZodianShadowStoryScenariosV1();
  invalidBrief[0].dailyThreadDirection = "One pressure while also another pressure.";
  assert(auditZodianShadowStoryPipelineV1(invalidBrief).some((finding) => finding.code === "invalid_brief"));
});

Deno.test("lookup is safe, copies are defensive, and aggregate audit is clean", () => {
  assertEquals(getZodianShadowStoryScenarioV1("unknown"), undefined);
  const copy = getZodianShadowStoryScenarioV1("gemini-dragon-distance")!;
  copy.dailyThreadDirection = "changed";
  assert(getZodianShadowStoryScenarioV1("gemini-dragon-distance")!.dailyThreadDirection !== "changed");
  assertEquals(auditZodianShadowStoryPipelineV1(), []);
});

Deno.test("module imports only isolated layers and has no external execution references", async () => {
  const source = await Deno.readTextFile(new URL("./zodian-shadow-story-pipeline-v1.ts", import.meta.url));
  const executable = source.replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, "");
  assertEquals([...executable.matchAll(/^\s*import\s.+$/gm)].length, 3);
  for (const forbidden of [/\bfetch\s*\(/i, /\b(?:openai|anthropic|GoogleGenerativeAI|model)\b/i, /\bcreateClient\s*\(/i, /\.(?:from|rpc)\s*\(/i, /\b(?:publish|publication|resolver|scheduler|cron)\b/i, /natural-reader-writer-v1-production/i, /generate-daily-rituals/i]) assert(!forbidden.test(executable));
});

Deno.test("an opted-in shadow-pipeline revision changes only approved paths", async () => {
  const permission = await Deno.permissions.query({ name: "env", variable: "ZODIAN_SHADOW_STORY_PIPELINE_V1_REVISION" });
  if (permission.state !== "granted") return;
  const revision = Deno.env.get("ZODIAN_SHADOW_STORY_PIPELINE_V1_REVISION");
  if (!revision) return;
  const result = await new Deno.Command("git", { args: ["diff-tree", "--no-commit-id", "--name-only", "-r", revision] }).output();
  assertEquals(result.code, 0);
  const paths = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean).sort();
  assertEquals(paths, [...APPROVED_PATHS].sort());
});
