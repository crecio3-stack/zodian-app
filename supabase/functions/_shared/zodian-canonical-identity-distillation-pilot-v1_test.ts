import { assert, assertEquals } from "jsr:@std/assert";
import {
  getZodianCanonicalIdentityDistillationPilotProfileV1,
  listZodianCanonicalIdentityDistillationPilotIdentitiesV1,
  listZodianCanonicalIdentityDistillationPilotV1,
  validateZodianCanonicalIdentityDistillationPilotV1,
  ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID,
} from "./zodian-canonical-identity-distillation-pilot-v1.ts";
import { validateZodianIdentityEditorialProfile } from "./zodian-identity-editorial-layer-v1.ts";
import { sourceMayInformDistilledEditorialProfiles, zodianCanonicalSourceExistsV1 } from "./zodian-canonical-source-registry-v1.ts";

const APPROVED_MILESTONE_PATHS = [
  "docs/editorial/ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1.md",
  "docs/editorial/ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1_REVIEW.md",
  "supabase/functions/_shared/zodian-canonical-identity-distillation-pilot-v1.ts",
  "supabase/functions/_shared/zodian-canonical-identity-distillation-pilot-v1_test.ts",
];

Deno.test("the pilot has exactly the four required identities without duplicates", () => {
  assertEquals(listZodianCanonicalIdentityDistillationPilotIdentitiesV1(), [
    { westernSign: "Libra", chineseSign: "Snake" },
    { westernSign: "Taurus", chineseSign: "Horse" },
    { westernSign: "Sagittarius", chineseSign: "Monkey" },
    { westernSign: "Gemini", chineseSign: "Dragon" },
  ]);
  assertEquals(validateZodianCanonicalIdentityDistillationPilotV1().filter((finding) => finding.code === "duplicate_identity"), []);
});

Deno.test("every profile passes the identity editorial contract with all bounded categories", () => {
  for (const profile of listZodianCanonicalIdentityDistillationPilotV1()) {
    assertEquals(validateZodianIdentityEditorialProfile(profile), []);
    for (const field of ["coreMotivations", "recurringStrengths", "recurringFriction", "commonBlindSpots", "interpersonalPatterns", "emotionalPatterns"] as const) {
      assert(profile[field].length >= 2 && profile[field].length <= 4);
      assert(profile[field].every((note) => note.length <= 160));
    }
  }
});

Deno.test("every profile retains the exact approved Suzanne White provenance", () => {
  for (const profile of listZodianCanonicalIdentityDistillationPilotV1()) {
    assertEquals(profile.provenance?.sourceIds, [ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID]);
    assert(zodianCanonicalSourceExistsV1(ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID));
    assert(sourceMayInformDistilledEditorialProfiles(ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID));
  }
});

Deno.test("duplicate-note audit catches exact and normalized duplicates", () => {
  const profiles = listZodianCanonicalIdentityDistillationPilotV1();
  profiles[1].coreMotivations[0] = profiles[0].coreMotivations[0];
  assert(validateZodianCanonicalIdentityDistillationPilotV1(profiles).some((finding) => finding.code === "duplicate_note"));

  const normalized = listZodianCanonicalIdentityDistillationPilotV1();
  normalized[1].coreMotivations[0] = "SEeks influence through rapport rather than force!";
  assert(validateZodianCanonicalIdentityDistillationPilotV1(normalized).some((finding) => finding.code === "normalized_duplicate_note"));
});

Deno.test("pilot audit is clean and lookup is exact and safe", () => {
  assertEquals(validateZodianCanonicalIdentityDistillationPilotV1(), []);
  assertEquals(getZodianCanonicalIdentityDistillationPilotProfileV1("Libra", "Snake")?.identity, { westernSign: "Libra", chineseSign: "Snake" });
  assertEquals(getZodianCanonicalIdentityDistillationPilotProfileV1("Unknown", "Unknown"), undefined);
});

Deno.test("returned profiles cannot mutate the immutable pilot collection", () => {
  const copy = getZodianCanonicalIdentityDistillationPilotProfileV1("Gemini", "Dragon")!;
  copy.coreMotivations[0] = "changed";
  copy.provenance!.sourceIds[0] = "changed";
  const canonical = getZodianCanonicalIdentityDistillationPilotProfileV1("Gemini", "Dragon")!;
  assertEquals(canonical.coreMotivations[0], "Seeks momentum, attention, and the thrill of a new possibility.");
  assertEquals(canonical.provenance!.sourceIds[0], ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID);
});

Deno.test("pilot profiles contain no raw source-content fields", () => {
  for (const profile of listZodianCanonicalIdentityDistillationPilotV1()) {
    const record = profile as Record<string, unknown>;
    for (const forbiddenField of ["excerpt", "passage", "content", "pages", "sourceText"]) assert(!(forbiddenField in record));
  }
});

Deno.test("pilot imports only the two isolated contracts and has no execution-path references", async () => {
  const source = await Deno.readTextFile(new URL("./zodian-canonical-identity-distillation-pilot-v1.ts", import.meta.url));
  const executableSource = source.replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, "");
  assertEquals([...executableSource.matchAll(/^\s*import\s.+$/gm)].length, 2);
  for (const forbiddenReference of [
    /\bfetch\s*\(/i, /\b(?:openai|anthropic|GoogleGenerativeAI|model)\b/i,
    /\bcreateClient\s*\(/i, /\.(?:from|rpc)\s*\(/i,
    /\b(?:publish|publication|resolver|scheduler|cron)\b/i,
    /natural-reader-writer-v1-production/i, /generate-daily-rituals/i,
    /zodian-story-engine-v1/i,
  ]) assert(!forbiddenReference.test(executableSource));
});

Deno.test("an opted-in pilot milestone revision changes only approved paths", async () => {
  const permission = await Deno.permissions.query({ name: "env", variable: "ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1_MILESTONE_REVISION" });
  if (permission.state !== "granted") return;
  const revision = Deno.env.get("ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1_MILESTONE_REVISION");
  if (!revision) return;
  const result = await new Deno.Command("git", { args: ["diff-tree", "--no-commit-id", "--name-only", "-r", revision] }).output();
  assertEquals(result.code, 0);
  const paths = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean).sort();
  assertEquals(paths, [...APPROVED_MILESTONE_PATHS].sort());
});
