import { assert, assertEquals } from "jsr:@std/assert";
import { canonicalizeZodianCanonicalIdentityCohort12V1, fingerprintZodianCanonicalIdentityCohort12V1, ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_APPROVAL_COMMIT, ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_APPROVED, ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_FINGERPRINT } from "./zodian-canonical-identity-cohort-12-v1-freeze.ts";
import { listZodianCanonicalIdentityCohort12V1 } from "./zodian-canonical-identity-cohort-12-v1.ts";

Deno.test("approved v1 cohort fingerprint is stable and covers canonical approval data only", async () => {
  const entries = listZodianCanonicalIdentityCohort12V1();
  assertEquals(ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_APPROVED, "zodian-canonical-identity-cohort-12-v1-approved");
  assertEquals(ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_APPROVAL_COMMIT, "a6e03b919206d3d034be86a64c58ef70b2985291");
  assertEquals(ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_FINGERPRINT, await fingerprintZodianCanonicalIdentityCohort12V1()); // 1-4
  for (const mutate of [
    (items: ReturnType<typeof listZodianCanonicalIdentityCohort12V1>) => { items[0].profile!.coreMotivations[0] = "changed"; },
    (items: ReturnType<typeof listZodianCanonicalIdentityCohort12V1>) => { items[0].identity.westernSign = "Changed"; },
    (items: ReturnType<typeof listZodianCanonicalIdentityCohort12V1>) => { items[0].status = "editorial_review"; },
    (items: ReturnType<typeof listZodianCanonicalIdentityCohort12V1>) => { items[0].profile!.provenance!.sourceIds[0] = "changed"; },
  ]) { const altered = listZodianCanonicalIdentityCohort12V1(); mutate(altered); assert((await fingerprintZodianCanonicalIdentityCohort12V1(altered)) !== ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_FINGERPRINT); } // 5-8
  const canonical = canonicalizeZodianCanonicalIdentityCohort12V1(entries);
  assert(!/OPENAI_API_KEY|sk-[A-Za-z0-9]|writerFingerprint|blindReview/i.test(canonical)); // 9, 10
});
