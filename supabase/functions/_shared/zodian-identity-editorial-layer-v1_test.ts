import { assert, assertEquals } from "jsr:@std/assert";
import {
  ZODIAN_IDENTITY_EDITORIAL_LAYER_V1,
  type ZodianIdentityEditorialProfile,
  validateZodianIdentityEditorialProfile,
} from "./zodian-identity-editorial-layer-v1.ts";

const APPROVED_MILESTONE_PATHS = [
  "docs/editorial/ZODIAN_IDENTITY_EDITORIAL_LAYER_V1.md",
  "supabase/functions/_shared/zodian-identity-editorial-layer-v1.ts",
  "supabase/functions/_shared/zodian-identity-editorial-layer-v1_test.ts",
];

function validProfile(): ZodianIdentityEditorialProfile {
  return {
    version: ZODIAN_IDENTITY_EDITORIAL_LAYER_V1,
    identity: { westernSign: "Libra", chineseSign: "Snake" },
    coreMotivations: ["Seeks fairness without losing personal agency."],
    recurringStrengths: ["Finds balanced language under pressure."],
    recurringFriction: ["Harmony can compete with direct self-expression."],
    commonBlindSpots: ["May delay naming a concern to preserve ease."],
    interpersonalPatterns: ["Reads shifts in reciprocity quickly."],
    emotionalPatterns: ["Settles after concerns are named clearly."],
    provenance: { sourceIds: ["canonical-identity-libra-snake-v1"] },
  };
}

function codes(profile: ZodianIdentityEditorialProfile) {
  return validateZodianIdentityEditorialProfile(profile).map((finding) => `${finding.field}:${finding.code}`);
}

Deno.test("a valid concise editorial identity profile passes and retains identity", () => {
  const profile = validProfile();
  assertEquals(validateZodianIdentityEditorialProfile(profile), []);
  assertEquals(profile.identity, { westernSign: "Libra", chineseSign: "Snake" });
});

Deno.test("provenance shape is retained", () => {
  assertEquals(validProfile().provenance, { sourceIds: ["canonical-identity-libra-snake-v1"] });
});

Deno.test("astrology and chart terminology are rejected", () => {
  const profile = validProfile();
  profile.emotionalPatterns = ["A natal chart transit shapes emotional reactions."];
  assert(codes(profile).includes("emotionalPatterns:astrology_mechanics"));
});

Deno.test("horoscope prose is rejected", () => {
  const profile = validProfile();
  profile.coreMotivations = ["Today you will find a lucky turn."];
  assert(codes(profile).includes("coreMotivations:horoscope_prose"));
});

Deno.test("a copied long source passage is rejected", () => {
  const profile = validProfile();
  profile.interpersonalPatterns = ["A".repeat(281)];
  assert(codes(profile).includes("interpersonalPatterns:copied_source_passage"));
});

Deno.test("reader advice and second-person language are rejected", () => {
  const profile = validProfile();
  profile.commonBlindSpots = ["Choose your own needs first."];
  assert(codes(profile).includes("commonBlindSpots:reader_advice"));
  assert(codes(profile).includes("commonBlindSpots:second_person"));
});

Deno.test("profile fields remain short internal editorial notes", () => {
  const profile = validProfile();
  for (const field of ["coreMotivations", "recurringStrengths", "recurringFriction", "commonBlindSpots", "interpersonalPatterns", "emotionalPatterns"] as const) {
    assert(profile[field].every((note) => note.length <= 160));
  }
});

Deno.test("the module has no imports or production and infrastructure references", async () => {
  const source = await Deno.readTextFile(new URL("./zodian-identity-editorial-layer-v1.ts", import.meta.url));
  const executableSource = source.replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, "");
  assertEquals([...executableSource.matchAll(/^\s*import\s.+$/gm)], []);
  for (const forbiddenReference of [
    /\bfetch\s*\(/i, /\b(?:openai|anthropic|gemini|model)\b/i,
    /\bcreateClient\s*\(/i, /\.(?:from|rpc)\s*\(/i,
    /\b(?:publish|publication|resolver|scheduler|cron)\b/i,
    /natural-reader-writer-v1-production/i, /generate-daily-rituals/i,
  ]) assert(!forbiddenReference.test(executableSource));
});

Deno.test("an opted-in identity milestone revision leaves Story Engine and production untouched", async () => {
  const permission = await Deno.permissions.query({ name: "env", variable: "ZODIAN_IDENTITY_EDITORIAL_LAYER_V1_MILESTONE_REVISION" });
  if (permission.state !== "granted") return;
  const revision = Deno.env.get("ZODIAN_IDENTITY_EDITORIAL_LAYER_V1_MILESTONE_REVISION");
  if (!revision) return;
  const result = await new Deno.Command("git", { args: ["diff-tree", "--no-commit-id", "--name-only", "-r", revision] }).output();
  assertEquals(result.code, 0);
  const paths = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean).sort();
  assertEquals(paths, [...APPROVED_MILESTONE_PATHS].sort());
});
