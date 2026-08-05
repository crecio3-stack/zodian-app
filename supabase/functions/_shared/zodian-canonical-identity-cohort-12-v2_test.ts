import { assert, assertEquals } from "jsr:@std/assert";
import { getZodianCanonicalIdentityCohort12V2, listZodianCanonicalIdentityCohort12V2, validateZodianCanonicalIdentityCohort12V2, ZODIAN_CANONICAL_IDENTITY_COHORT_12_V2_BLIND_IDS } from "./zodian-canonical-identity-cohort-12-v2.ts";
import { listZodianCanonicalIdentityCohort12V1 } from "./zodian-canonical-identity-cohort-12-v1.ts";
import { ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FINGERPRINT } from "./zodian-shadow-natural-reader-writer-v1-freeze.ts";

Deno.test("v2 is a complete source-ready profile-free selection distinct from v1", () => {
  const entries = listZodianCanonicalIdentityCohort12V2(); const v1 = new Set(listZodianCanonicalIdentityCohort12V1().map((entry) => `${entry.identity.westernSign}\0${entry.identity.chineseSign}`));
  assertEquals(entries.length, 12); assertEquals(new Set(entries.map((entry) => `${entry.identity.westernSign}\0${entry.identity.chineseSign}`)).size, 12); // 11-13
  for (const entry of entries) { assert(!v1.has(`${entry.identity.westernSign}\0${entry.identity.chineseSign}`)); assert(entry.sourceSectionLocated && entry.readyForManualDistillation); assert(entry.sourceId); assert(entry.selectionRationale && entry.structuralRiskTags.length); assert(v1.has(`${entry.nearestV1Comparison.westernSign}\0${entry.nearestV1Comparison.chineseSign}`)); assertEquals(entry.status, "source_ready"); assertEquals(entry.profile, null); } // 14-23
  assertEquals(validateZodianCanonicalIdentityCohort12V2(), []);
});

Deno.test("v2 lookup, defensive copies, blind payload, and forbidden scaffold states are safe", () => {
  assertEquals(getZodianCanonicalIdentityCohort12V2("Unknown", "Unknown"), undefined); // 25
  const copy = getZodianCanonicalIdentityCohort12V2("Libra", "Tiger")!; (copy.structuralRiskTags as string[])[0] = "changed"; assert(getZodianCanonicalIdentityCohort12V2("Libra", "Tiger")!.structuralRiskTags[0] !== "changed"); // 24, 26
  assertEquals(ZODIAN_CANONICAL_IDENTITY_COHORT_12_V2_BLIND_IDS.length, 12); for (const id of ZODIAN_CANONICAL_IDENTITY_COHORT_12_V2_BLIND_IDS) assert(!/libra|tiger|taurus|pig|sagittarius|sheep|gemini|ox|aries|pisces|leo|dog|aquarius|dragon|cancer|rat|virgo|cat|capricorn|monkey|scorpio|horse/i.test(id)); // 27, 28
  const invalid = listZodianCanonicalIdentityCohort12V2(); (invalid[0] as { status: string }).status = "approved"; (invalid[1] as { profile: unknown }).profile = {};
  const codes = validateZodianCanonicalIdentityCohort12V2(invalid).map((finding) => finding.code); assert(codes.includes("unknown_status") && codes.includes("profile_present_in_scaffold"));
});

Deno.test("v2 modules are isolated and frozen references remain unchanged", async () => {
  assertEquals(ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FINGERPRINT, "77e1b08cc156abbfe2e16753fddd35e1e10422fbb0e391fc21ea3133500b5c20"); // 29-31
  const source = await Deno.readTextFile(new URL("./zodian-canonical-identity-cohort-12-v2.ts", import.meta.url));
  assert(!/\b(?:fetch|supabase|rpc|database|publish|resolver|scheduler|cron|openai|provider|generate)\b/i.test(source)); // 38
  const diff = await new Deno.Command("git", { args:["diff", "--cached", "--name-only", "a6e03b919206d3d034be86a64c58ef70b2985291"] }).output();
  const changed = new TextDecoder().decode(diff.stdout).trim().split("\n").filter(Boolean);
  const allowed = new Set(["docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_FREEZE.md", "docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V2.md", "docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V2_REVIEW.md", "docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V2_BLIND_REVIEW.md", "supabase/functions/_shared/zodian-canonical-identity-cohort-12-v1-freeze.ts", "supabase/functions/_shared/zodian-canonical-identity-cohort-12-v1-freeze_test.ts", "supabase/functions/_shared/zodian-canonical-identity-cohort-12-v2.ts", "supabase/functions/_shared/zodian-canonical-identity-cohort-12-v2_test.ts"]);
  assert(changed.every((path) => allowed.has(path))); // 32-39 by committed-boundary inspection
});
