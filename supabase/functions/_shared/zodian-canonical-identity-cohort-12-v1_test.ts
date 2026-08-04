import { assert, assertEquals } from "jsr:@std/assert";
import { getZodianCanonicalIdentityCohort12V1, listZodianCanonicalIdentityCohort12V1, validateZodianCanonicalIdentityCohort12V1 } from "./zodian-canonical-identity-cohort-12-v1.ts";
import { ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FINGERPRINT, ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FROZEN } from "./zodian-shadow-natural-reader-writer-v1-freeze.ts";

Deno.test("frozen writer and twelve-identity source-ready scaffold are explicit and safe", async () => {
  assertEquals(ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FROZEN, "zodian-shadow-natural-reader-writer-v1-frozen");
  assert(ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FINGERPRINT.length > 0);
  const entries = listZodianCanonicalIdentityCohort12V1();
  assertEquals(entries.length, 12);
  assertEquals(new Set(entries.map((entry) => `${entry.identity.westernSign}\0${entry.identity.chineseSign}`)).size, 12);
  assert(entries.filter((entry) => ["Libra\0Snake","Taurus\0Horse","Sagittarius\0Monkey","Gemini\0Dragon"].includes(`${entry.identity.westernSign}\0${entry.identity.chineseSign}`)).length === 4);
  assert(entries.every((entry) => entry.status === "source_ready" && entry.profile === null && entry.sourceSectionLocated && entry.rationale && entry.contradictionToTest));
  assertEquals(validateZodianCanonicalIdentityCohort12V1(), []);
  assertEquals(getZodianCanonicalIdentityCohort12V1("Unknown", "Unknown"), undefined);
  const copy = getZodianCanonicalIdentityCohort12V1("Libra", "Snake")!; copy.identity.westernSign = "changed"; assertEquals(getZodianCanonicalIdentityCohort12V1("Libra", "Snake")!.identity.westernSign, "Libra");
  const freeze = await Deno.readTextFile(new URL("../../../docs/editorial/ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FREEZE.md", import.meta.url));
  assert(freeze.includes("gpt-5.6-terra") && freeze.includes("no temperature"));
  const writer = await Deno.readTextFile(new URL("./zodian-shadow-natural-reader-writer-canary-v1.ts", import.meta.url));
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(writer));
  assertEquals(ZODIAN_SHADOW_NATURAL_READER_WRITER_V1_FINGERPRINT, [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, "0")).join(""));
});
