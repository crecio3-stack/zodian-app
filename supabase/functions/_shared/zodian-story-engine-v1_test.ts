import { assert, assertEquals } from "jsr:@std/assert";
import {
  ZODIAN_STORY_ENGINE_V1,
  type ZodianStoryEngineV1Brief,
  validateZodianStoryEngineV1Brief,
} from "./zodian-story-engine-v1.ts";

const APPROVED_MILESTONE_PATHS = [
  "docs/editorial/ZODIAN_STORY_ENGINE_V1.md",
  "supabase/functions/_shared/zodian-story-engine-v1.ts",
  "supabase/functions/_shared/zodian-story-engine-v1_test.ts",
];

function validBrief(): ZodianStoryEngineV1Brief {
  return {
    version: ZODIAN_STORY_ENGINE_V1,
    identity: { westernSign: "Libra", chineseSign: "Snake" },
    dailyThread: "A small hesitation reveals what no longer feels fair.",
    centralTension: "Keeping the peace versus naming what matters.",
    readerQuestion: "What changes when you stop smoothing this over?",
    hookDirection: "A quiet imbalance is harder to ignore.",
    perspectiveShift: "The pause is information, not a failure to decide.",
    landingDirection: "Clarity arrives when the real concern has room.",
  };
}

function codes(brief: ZodianStoryEngineV1Brief) {
  return validateZodianStoryEngineV1Brief(brief).map((finding) => `${finding.field}:${finding.code}`);
}

Deno.test("a valid single-thread editorial brief passes and retains identity", () => {
  const brief = validBrief();
  assertEquals(validateZodianStoryEngineV1Brief(brief), []);
  assertEquals(brief.identity, { westernSign: "Libra", chineseSign: "Snake" });
});

Deno.test("daily thread and central tension are distinct parts of one mini story", () => {
  const brief = validBrief();
  assertEquals(
    brief.dailyThread,
    "A small hesitation reveals what no longer feels fair.",
  );
  assertEquals(
    brief.centralTension,
    "Keeping the peace versus naming what matters.",
  );
  assert(brief.dailyThread !== brief.centralTension);
  assertEquals(validateZodianStoryEngineV1Brief(brief), []);
});

Deno.test("compact internal editorial notes pass without being mistaken for prose", () => {
  assertEquals(validateZodianStoryEngineV1Brief(validBrief()), []);
});

Deno.test("two competing daily threads fail with field attribution", () => {
  const brief = validBrief();
  brief.dailyThread = "A small hesitation at work, while also a family conflict.";
  assert(codes(brief).includes("dailyThread:multiple_threads"));
});

Deno.test("raw astrology and degree language fail", () => {
  const brief = validBrief();
  brief.perspectiveShift = "A 12° transit through the seventh house changes the meaning.";
  assert(codes(brief).includes("perspectiveShift:technical_astrology"));
});

Deno.test("a detailed invented external scene fails", () => {
  const brief = validBrief();
  brief.dailyThread = "At 3pm in the Slack meeting, a manager changes the plan.";
  assert(codes(brief).includes("dailyThread:fixed_external_scenario"));
});

Deno.test("a command or coaching instruction fails", () => {
  const brief = validBrief();
  brief.landingDirection = "Do not explain yourself before you are ready.";
  assert(codes(brief).includes("landingDirection:direct_command"));
});

Deno.test("polished second-person horoscope prose and overlong notes fail", () => {
  const brief = validBrief();
  brief.hookDirection = "Today you will discover a lucky surprise, so trust the universe to guide every choice.";
  brief.landingDirection = "A".repeat(161);
  assert(codes(brief).includes("hookDirection:horoscope_prose"));
  assert(codes(brief).includes("landingDirection:too_long"));
});

Deno.test("the isolated module has no imports or production and infrastructure references", async () => {
  const source = await Deno.readTextFile(new URL("./zodian-story-engine-v1.ts", import.meta.url));
  const executableSource = source.replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, "");
  const imports = [...executableSource.matchAll(/^\s*import\s.+$/gm)];
  const forbiddenReferences = [
    /\bfetch\s*\(/i,
    /\b(?:openai|anthropic|gemini|model)\b/i,
    /\bcreateClient\s*\(/i,
    /\.(?:from|rpc)\s*\(/i,
    /\b(?:publish|publication)\b/i,
    /\b(?:resolver|scheduler|cron)\b/i,
    /natural-reader-writer-v1-production/i,
    /generate-daily-rituals/i,
  ];
  assertEquals(imports, []);
  for (const forbiddenReference of forbiddenReferences) {
    assert(!forbiddenReference.test(executableSource));
  }
});

Deno.test("an opted-in milestone revision changes only approved Story Engine paths", async () => {
  const permission = await Deno.permissions.query({
    name: "env",
    variable: "ZODIAN_STORY_ENGINE_V1_MILESTONE_REVISION",
  });
  if (permission.state !== "granted") return;
  const revision = Deno.env.get("ZODIAN_STORY_ENGINE_V1_MILESTONE_REVISION");
  if (!revision) return;
  const result = await new Deno.Command("git", {
    args: ["diff-tree", "--no-commit-id", "--name-only", "-r", revision],
  }).output();
  assertEquals(result.code, 0);
  const paths = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean).sort();
  assertEquals(paths, [...APPROVED_MILESTONE_PATHS].sort());
});
