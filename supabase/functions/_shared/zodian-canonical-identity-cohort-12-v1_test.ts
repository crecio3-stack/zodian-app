import { assert, assertEquals } from "jsr:@std/assert";
import { getZodianCanonicalIdentityCohort12V1, listBlockedZodianCanonicalIdentityCohort12V1, listCompletedZodianCanonicalIdentityCohort12V1, listZodianCanonicalIdentityCohort12V1, validateZodianCanonicalIdentityCohort12V1, ZODIAN_COHORT_12_SOURCE_ID, type ZodianCohort12Entry } from "./zodian-canonical-identity-cohort-12-v1.ts";
import { validateZodianIdentityEditorialProfile } from "./zodian-identity-editorial-layer-v1.ts";
import { ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FINGERPRINT, ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FROZEN } from "./zodian-shadow-natural-reader-writer-v1-freeze.ts";

const fields = ["coreMotivations", "recurringStrengths", "recurringFriction", "commonBlindSpots", "interpersonalPatterns", "emotionalPatterns"] as const;
const key = (entry: ZodianCohort12Entry) => `${entry.identity.westernSign}\0${entry.identity.chineseSign}`;
const findings = (entries: readonly ZodianCohort12Entry[]) => validateZodianCanonicalIdentityCohort12V1(entries).map((finding) => finding.code);

Deno.test("cohort retains exactly the twelve selected identities and valid complete profiles", () => {
  const entries = listZodianCanonicalIdentityCohort12V1();
  const names = new Set(entries.map(key));
  assertEquals(entries.length, 12); // 1
  assertEquals(names.size, 12); // 4
  for (const name of ["Libra\0Snake", "Taurus\0Horse", "Sagittarius\0Monkey", "Gemini\0Dragon"]) assert(names.has(name)); // 2
  for (const name of ["Aries\0Rat", "Pisces\0Dog", "Leo\0Horse", "Aquarius\0Snake", "Cancer\0Pig", "Virgo\0Dragon", "Capricorn\0Rooster", "Scorpio\0Dragon"]) assert(names.has(name)); // 3
  assertEquals(listCompletedZodianCanonicalIdentityCohort12V1().length, 12);
  for (const entry of entries) {
    assert(entry.profile); assertEquals(validateZodianIdentityEditorialProfile(entry.profile!), []); // 5
    assertEquals(entry.profile!.identity, entry.identity); // 6
    for (const field of fields) assert(entry.profile![field].length >= 1 && entry.profile![field].length <= 4); // 7, 8
    assertEquals(entry.profile!.provenance!.sourceIds, [ZODIAN_COHORT_12_SOURCE_ID]); // 9, 10
    assertEquals(entry.status, "approved");
    assertEquals(entry.reviewState, "approved");
    assert(entry.approvalEvidence); // 22
  }
  assertEquals(validateZodianCanonicalIdentityCohort12V1(), []);
});

Deno.test("cohort audit detects duplicate and incomplete authoring defects deterministically", () => {
  const base = listZodianCanonicalIdentityCohort12V1();
  const duplicate = structuredClone(base[0]);
  assert(findings([...base, duplicate]).includes("incorrect_size"));
  assert(findings([...base, duplicate]).includes("duplicate_identity"));
  const changed = structuredClone(base); changed[0].profile!.coreMotivations[0] = changed[0].profile!.recurringStrengths[0];
  assert(findings(changed).includes("same_profile_cross_field_duplicate")); // 14
  const normalized = structuredClone(base); normalized[1].profile!.recurringStrengths[0] = base[0].profile!.recurringStrengths[0].toUpperCase();
  assert(findings(normalized).includes("normalized_duplicate_note")); // 12, 13
  const placeholder = structuredClone(base); placeholder[2].profile!.coreMotivations[0] = "TODO";
  assert(findings(placeholder).includes("placeholder_note")); // 15
  const generic = structuredClone(base); generic[3].profile!.coreMotivations[0] = "Values honesty.";
  assert(findings(generic).includes("generic_note_tripwire")); // 16
});

Deno.test("uneven evidence density, source-fidelity amendments, lookup, and approval evidence hold", () => {
  const entries = listZodianCanonicalIdentityCohort12V1();
  const sagittarius = getZodianCanonicalIdentityCohort12V1("Sagittarius", "Monkey")!.profile!;
  const leo = getZodianCanonicalIdentityCohort12V1("Leo", "Horse")!.profile!;
  const capricorn = getZodianCanonicalIdentityCohort12V1("Capricorn", "Rooster")!.profile!;
  const scorpio = getZodianCanonicalIdentityCohort12V1("Scorpio", "Dragon")!.profile!;
  assertEquals(sagittarius.emotionalPatterns.length, 1); assertEquals(leo.emotionalPatterns.length, 1); // 4-6
  assertEquals(capricorn.recurringStrengths.length, 1); assertEquals(scorpio.emotionalPatterns.length, 1);
  const allNotes = entries.flatMap((entry) => fields.flatMap((field) => entry.profile![field]));
  for (const forbidden of ["slow work of earning trust", "right status instead of building momentum", "trust and purpose align", "what charm can carry", "proud surface around deeper need", "status built through order", "practical stamina", "organize details toward", "strategic persistence", "remembers it"]) assert(!allNotes.some((note) => note.toLowerCase().includes(forbidden))); // 7, 10-14
  for (const forbidden of ["status", "stamina", "organize details"]) assert(![...capricorn.coreMotivations, ...capricorn.recurringStrengths].some((note) => note.toLowerCase().includes(forbidden))); // 8, 9, 13
  assertEquals(getZodianCanonicalIdentityCohort12V1("Cancer", "Pig")!.status, "approved"); // 15
  assertEquals(getZodianCanonicalIdentityCohort12V1("Unknown", "Unknown"), undefined); // 18
  const copy = getZodianCanonicalIdentityCohort12V1("Libra", "Snake")!; copy.profile!.coreMotivations[0] = "changed";
  assert(getZodianCanonicalIdentityCohort12V1("Libra", "Snake")!.profile!.coreMotivations[0] !== "changed"); // 17, 19
  assertEquals(listBlockedZodianCanonicalIdentityCohort12V1(), []); // 20
  const bad = listZodianCanonicalIdentityCohort12V1(); bad[0].profile!.identity.westernSign = "Other"; bad[1].approvalEvidence = "";
  assert(findings(bad).includes("identity_mismatch"));
  assert(findings(bad).includes("approved_without_review")); // 23
  const blocked = listZodianCanonicalIdentityCohort12V1(); blocked[0].status = "blocked"; blocked[0].profile = null;
  assert(!findings(blocked).includes("blocked_profile"));
  blocked[0].profile = getZodianCanonicalIdentityCohort12V1("Libra", "Snake")!.profile;
  assert(findings(blocked).includes("blocked_profile"));
});

Deno.test("review, blind fixture, immutable boundaries, and isolation are explicit", async () => {
  const root = new URL("../../../", import.meta.url);
  const read = (path: string) => Deno.readTextFile(new URL(path, root));
  const review = await read("docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_REVIEW.md");
  const blind = await read("docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_BLIND_REVIEW.md");
  for (const entry of listZodianCanonicalIdentityCohort12V1()) { assert(review.includes(`${entry.identity.westernSign} × ${entry.identity.chineseSign}`)); assert(blind.includes("cohort-")); } // 20, 21
  for (const label of ["Libra", "Snake", "Taurus", "Horse", "Sagittarius", "Monkey", "Gemini", "Dragon", "Aries", "Rat", "Pisces", "Dog", "Leo", "Aquarius", "Cancer", "Pig", "Virgo", "Capricorn", "Rooster", "Scorpio"]) assert(!blind.includes(label));
  assertEquals(ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FROZEN, "zodian-shadow-natural-reader-writer-v1-frozen");
  const writer = await Deno.readTextFile(new URL("./zodian-shadow-natural-reader-writer-canary-v1.ts", import.meta.url));
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(writer));
  assertEquals(ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FINGERPRINT, [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, "0")).join("")); // 28, 29
  const source = await Deno.readTextFile(new URL("./zodian-canonical-identity-cohort-12-v1.ts", import.meta.url));
  assert(!/\b(?:fetch|supabase|rpc|database|publish|resolver|scheduler|cron|openai|provider|generate)\b/i.test(source)); // 35
  const diff = (await new Deno.Command("git", { args:["diff", "--cached", "--name-only", "459a6f8a86e3e635ac58ff67cca6f45063bec899"] }).output()).stdout;
  const changed = new TextDecoder().decode(diff).trim().split("\n").filter(Boolean);
  const allowed = new Set(["docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1.md", "docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_REVIEW.md", "docs/editorial/ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_BLIND_REVIEW.md", "supabase/functions/_shared/zodian-canonical-identity-cohort-12-v1.ts", "supabase/functions/_shared/zodian-canonical-identity-cohort-12-v1_test.ts"]);
  assert(changed.every((path) => allowed.has(path))); // 30-34, 36: committed-base boundary inspection
});
