import {
  type ZodianIdentityEditorialProfile,
  validateZodianIdentityEditorialProfile,
} from "./zodian-identity-editorial-layer-v1.ts";
import {
  sourceMayInformDistilledEditorialProfiles,
  zodianCanonicalSourceExistsV1,
} from "./zodian-canonical-source-registry-v1.ts";

export const ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1_VERSION = "zodian-canonical-identity-distillation-pilot-v1" as const;
export const ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID =
  "source:suzanne-white:new-astrology-21st-century" as const;

export type ZodianCanonicalIdentityDistillationPilotV1Finding = {
  field: string;
  code:
    | "duplicate_identity"
    | "duplicate_note"
    | "normalized_duplicate_note"
    | "repeated_note_opening"
    | "missing_editorial_category"
    | "note_count_out_of_bounds"
    | "invalid_editorial_profile"
    | "unknown_provenance_source"
    | "unapproved_provenance_source";
  message: string;
  index?: number;
};

const EDITORIAL_FIELDS = [
  "coreMotivations",
  "recurringStrengths",
  "recurringFriction",
  "commonBlindSpots",
  "interpersonalPatterns",
  "emotionalPatterns",
] as const;

export const ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1: readonly ZodianIdentityEditorialProfile[] = Object.freeze([
  Object.freeze({
    version: "zodian-identity-editorial-layer-v1",
    identity: Object.freeze({ westernSign: "Libra", chineseSign: "Snake" }),
    coreMotivations: Object.freeze([
      "Seeks influence through rapport rather than force.",
      "Wants admiration and comfort while keeping influence indirect.",
    ]),
    recurringStrengths: Object.freeze([
      "Reads what will make an audience feel included.",
      "Turns difficult differences into calm appeals.",
    ]),
    recurringFriction: Object.freeze([
      "Comfort and indulgence can compete with follow-through.",
      "Wants leadership without the strain of open conflict.",
    ]),
    commonBlindSpots: Object.freeze([
      "Charm can obscure when a firmer boundary is needed.",
      "Generosity of attention can become managing everyone.",
    ]),
    interpersonalPatterns: Object.freeze([
      "Builds loyalty through warmth, tact, and visible care.",
      "Guides groups by persuasion rather than rank.",
    ]),
    emotionalPatterns: Object.freeze([
      "Can drift toward comfort when ordinary demands feel dull.",
      "Feels pulled between caring for others and protecting personal comfort.",
    ]),
    provenance: Object.freeze({ sourceIds: Object.freeze([ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID]) }),
  }),
  Object.freeze({
    version: "zodian-identity-editorial-layer-v1",
    identity: Object.freeze({ westernSign: "Taurus", chineseSign: "Horse" }),
    coreMotivations: Object.freeze([
      "Wants visible proof that ability has weight.",
      "Seeks a life that feels both exceptional and secure.",
    ]),
    recurringStrengths: Object.freeze([
      "Brings discipline and high standards to a chosen craft.",
      "Pairs practical follow-through with strong instincts.",
    ]),
    recurringFriction: Object.freeze([
      "Confidence in talent can collide with the slow work of earning trust.",
      "Desire for recognition can compete with ordinary social effort.",
    ]),
    commonBlindSpots: Object.freeze([
      "May mistake being overlooked for being undervalued.",
      "May wait for the right status instead of building momentum.",
    ]),
    interpersonalPatterns: Object.freeze([
      "Keeps private matters guarded while caring about public regard.",
      "Responds best to respect for ability without constant praise.",
    ]),
    emotionalPatterns: Object.freeze([
      "Feels steadier when effort is recognized.",
      "Can become withdrawn or irritable when feeling misunderstood.",
    ]),
    provenance: Object.freeze({ sourceIds: Object.freeze([ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID]) }),
  }),
  Object.freeze({
    version: "zodian-identity-editorial-layer-v1",
    identity: Object.freeze({ westernSign: "Sagittarius", chineseSign: "Monkey" }),
    coreMotivations: Object.freeze([
      "Wants influence that advances a large purpose.",
      "Seeks independence, leverage, and a place near decisions.",
    ]),
    recurringStrengths: Object.freeze([
      "Organizes large aims into clear action.",
      "Makes a convincing case without open confrontation.",
    ]),
    recurringFriction: Object.freeze([
      "Public ambition can conflict with emotional closeness.",
      "Long-range goals can outweigh the demands of closeness.",
    ]),
    commonBlindSpots: Object.freeze([
      "May treat intimacy as a threat to independence.",
      "May hide self-interest behind a larger mission.",
    ]),
    interpersonalPatterns: Object.freeze([
      "Uses timing, competence, and persuasion to build authority.",
      "Keeps a lighter, playful side for trusted company.",
    ]),
    emotionalPatterns: Object.freeze([
      "Keeps feelings private until trust and purpose align.",
      "Keeps emotional obligations secondary to larger aims.",
    ]),
    provenance: Object.freeze({ sourceIds: Object.freeze([ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID]) }),
  }),
  Object.freeze({
    version: "zodian-identity-editorial-layer-v1",
    identity: Object.freeze({ westernSign: "Gemini", chineseSign: "Dragon" }),
    coreMotivations: Object.freeze([
      "Seeks momentum, attention, and the thrill of a new possibility.",
      "Wants close bonds to feel vivid and unmistakably loyal.",
    ]),
    recurringStrengths: Object.freeze([
      "Generates contagious ideas and gathers people around them.",
      "Rallies energy quickly when a situation needs a spark.",
    ]),
    recurringFriction: Object.freeze([
      "Craves novelty yet resists the sustained work behind a plan.",
      "Strong need for attention can conflict with another person's spotlight.",
    ]),
    commonBlindSpots: Object.freeze([
      "May confuse a bold first move with durable commitment.",
      "May read ordinary distance as a loss of loyalty.",
    ]),
    interpersonalPatterns: Object.freeze([
      "Uses presence, humor, and confidence to draw attention.",
      "Shows fierce care for close people while asking a lot of them.",
    ]),
    emotionalPatterns: Object.freeze([
      "Reacts intensely to rejection, failure, or feeling overlooked.",
      "A commanding front can hide a more easily wounded core.",
    ]),
    provenance: Object.freeze({ sourceIds: Object.freeze([ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_SOURCE_ID]) }),
  }),
]) as unknown as readonly ZodianIdentityEditorialProfile[];

function cloneProfile(profile: ZodianIdentityEditorialProfile): ZodianIdentityEditorialProfile {
  return {
    ...profile,
    identity: { ...profile.identity },
    coreMotivations: [...profile.coreMotivations],
    recurringStrengths: [...profile.recurringStrengths],
    recurringFriction: [...profile.recurringFriction],
    commonBlindSpots: [...profile.commonBlindSpots],
    interpersonalPatterns: [...profile.interpersonalPatterns],
    emotionalPatterns: [...profile.emotionalPatterns],
    ...(profile.provenance ? { provenance: { sourceIds: [...profile.provenance.sourceIds] } } : {}),
  };
}

function identityKey(profile: ZodianIdentityEditorialProfile): string {
  return `${profile.identity.westernSign}\u0000${profile.identity.chineseSign}`;
}

function normalizeNote(note: string): string {
  return note.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
}

function noteOpening(note: string): string {
  return normalizeNote(note).split(" ").slice(0, 3).join(" ");
}

function addFinding(
  findings: ZodianCanonicalIdentityDistillationPilotV1Finding[],
  field: string,
  code: ZodianCanonicalIdentityDistillationPilotV1Finding["code"],
  message: string,
  index?: number,
) {
  findings.push({ field, code, message, ...(index === undefined ? {} : { index }) });
}

/** Returns defensive copies of the proposed four-profile editorial pilot. */
export function listZodianCanonicalIdentityDistillationPilotV1(): ZodianIdentityEditorialProfile[] {
  return ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1.map(cloneProfile);
}

export function getZodianCanonicalIdentityDistillationPilotProfileV1(
  westernSign: string,
  chineseSign: string,
): ZodianIdentityEditorialProfile | undefined {
  const profile = ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1.find((candidate) =>
    candidate.identity.westernSign === westernSign && candidate.identity.chineseSign === chineseSign
  );
  return profile ? cloneProfile(profile) : undefined;
}

export function listZodianCanonicalIdentityDistillationPilotIdentitiesV1(): Array<{ westernSign: string; chineseSign: string }> {
  return ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1.map((profile) => ({ ...profile.identity }));
}

/** Narrow deterministic audit; passing it does not prove editorial distinctiveness. */
export function validateZodianCanonicalIdentityDistillationPilotV1(
  profiles: readonly ZodianIdentityEditorialProfile[] = ZODIAN_CANONICAL_IDENTITY_DISTILLATION_PILOT_V1,
): ZodianCanonicalIdentityDistillationPilotV1Finding[] {
  const findings: ZodianCanonicalIdentityDistillationPilotV1Finding[] = [];
  const identities = new Set<string>();
  const exactNotes = new Set<string>();
  const normalizedNotes = new Set<string>();
  const openings = new Set<string>();
  profiles.forEach((profile, profileIndex) => {
    const key = identityKey(profile);
    if (identities.has(key)) addFinding(findings, "identity", "duplicate_identity", "Identity records must be distinct.", profileIndex);
    identities.add(key);
    for (const field of EDITORIAL_FIELDS) {
      if (profile[field].length === 0) addFinding(findings, field, "missing_editorial_category", "Every editorial category requires notes.", profileIndex);
      if (profile[field].length > 4) addFinding(findings, field, "note_count_out_of_bounds", "Editorial categories support one to four notes.", profileIndex);
      for (const note of profile[field]) {
        if (exactNotes.has(note)) addFinding(findings, field, "duplicate_note", "Exact notes cannot repeat across profiles.", profileIndex);
        exactNotes.add(note);
        const normalized = normalizeNote(note);
        if (normalizedNotes.has(normalized)) addFinding(findings, field, "normalized_duplicate_note", "Normalized notes cannot repeat across profiles.", profileIndex);
        normalizedNotes.add(normalized);
        const opening = noteOpening(note);
        if (openings.has(opening)) addFinding(findings, field, "repeated_note_opening", "Note openings should not repeat across profiles.", profileIndex);
        openings.add(opening);
      }
    }
    for (const finding of validateZodianIdentityEditorialProfile(profile)) {
      addFinding(findings, finding.field, "invalid_editorial_profile", finding.code, profileIndex);
    }
    for (const sourceId of profile.provenance?.sourceIds ?? []) {
      if (!zodianCanonicalSourceExistsV1(sourceId)) addFinding(findings, "provenance.sourceIds", "unknown_provenance_source", "Provenance source is not in the registry.", profileIndex);
      else if (!sourceMayInformDistilledEditorialProfiles(sourceId)) addFinding(findings, "provenance.sourceIds", "unapproved_provenance_source", "Provenance source is not approved for editorial distillation.", profileIndex);
    }
  });
  return findings;
}
