import { listZodianCanonicalIdentityCohort12V1, type ZodianCohort12Entry } from "./zodian-canonical-identity-cohort-12-v1.ts";

export const ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_APPROVED = "zodian-canonical-identity-cohort-12-v1-approved" as const;
export const ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_APPROVAL_COMMIT = "a6e03b919206d3d034be86a64c58ef70b2985291" as const;

/** Only approved cohort data and stable review metadata participate in this digest. */
export function canonicalizeZodianCanonicalIdentityCohort12V1(entries: readonly ZodianCohort12Entry[] = listZodianCanonicalIdentityCohort12V1()): string {
  return JSON.stringify({ version: ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_APPROVED, entries: entries.map((entry) => ({ identity: entry.identity, status: entry.status, reviewState: entry.reviewState, approvalEvidence: entry.approvalEvidence, provenance: entry.profile?.provenance?.sourceIds ?? [], noteCounts: entry.profile ? [entry.profile.coreMotivations.length, entry.profile.recurringStrengths.length, entry.profile.recurringFriction.length, entry.profile.commonBlindSpots.length, entry.profile.interpersonalPatterns.length, entry.profile.emotionalPatterns.length] : [], profile: entry.profile })) });
}

export async function fingerprintZodianCanonicalIdentityCohort12V1(entries?: readonly ZodianCohort12Entry[]): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(canonicalizeZodianCanonicalIdentityCohort12V1(entries)));
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

export const ZODIAN_CANONICAL_IDENTITY_COHORT_12_V1_FINGERPRINT = await fingerprintZodianCanonicalIdentityCohort12V1();
