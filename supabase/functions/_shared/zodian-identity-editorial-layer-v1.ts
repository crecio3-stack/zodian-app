/** Shadow-only identity editorial contract with no runtime or external dependencies. */
export const ZODIAN_IDENTITY_EDITORIAL_LAYER_V1 =
  "zodian-identity-editorial-layer-v1" as const;

export type ZodianIdentityEditorialProfile = {
  version: typeof ZODIAN_IDENTITY_EDITORIAL_LAYER_V1;
  identity: {
    westernSign: string;
    chineseSign: string;
  };
  /** Enduring needs or values that commonly shape choices. */
  coreMotivations: string[];
  /** Reliable capacities that help in difficult situations. */
  recurringStrengths: string[];
  /** Repeated internal conflicts or pressure points. */
  recurringFriction: string[];
  /** Tendencies that can hide a useful perspective from view. */
  commonBlindSpots: string[];
  /** Repeated ways of relating, responding, or negotiating with others. */
  interpersonalPatterns: string[];
  /** Repeated emotional responses or regulation tendencies. */
  emotionalPatterns: string[];
  provenance?: {
    sourceIds: string[];
  };
};

export type ZodianIdentityEditorialLayerV1Field =
  | "identity.westernSign"
  | "identity.chineseSign"
  | "coreMotivations"
  | "recurringStrengths"
  | "recurringFriction"
  | "commonBlindSpots"
  | "interpersonalPatterns"
  | "emotionalPatterns"
  | "provenance.sourceIds";

export type ZodianIdentityEditorialLayerV1Finding = {
  field: ZodianIdentityEditorialLayerV1Field;
  /** Present when a finding belongs to one entry in an editorial-note or source-ID array. */
  index?: number;
  code:
    | "required"
    | "blank_source_id"
    | "duplicate_source_id"
    | "too_long"
    | "copied_source_passage"
    | "astrology_mechanics"
    | "horoscope_prose"
    | "reader_advice"
    | "second_person";
  message: string;
};

const EDITORIAL_FIELDS = [
  "coreMotivations",
  "recurringStrengths",
  "recurringFriction",
  "commonBlindSpots",
  "interpersonalPatterns",
  "emotionalPatterns",
] as const;
const ASTROLOGY_MECHANICS = /\b(?:planet|transit|ascendant|rising sign|house|natal|retrograde|conjunction|opposition|trine|square|sextile|chart|zodiac|\d{1,2}\s*°|\d{1,2}\s*degrees?)\b/i;
const HOROSCOPE_PROSE = /\b(?:your horoscope|the stars say|today you will|the universe wants|a lucky|fortune)\b/i;
const READER_ADVICE = /^\s*(?:do not|don't|remember to|make sure|try to|be sure to|avoid|stop|start|choose|take|tell|ask|wait|let|keep)\b/i;
const SECOND_PERSON = /\b(?:you|your|yourself|yours)\b/i;
const MAX_NOTE_LENGTH = 160;
// This longer threshold is a deterministic source-passage tripwire. Notes beyond
// it intentionally receive both `too_long` and `copied_source_passage` findings.
const SOURCE_PASSAGE_LENGTH = 280;

function addFinding(
  findings: ZodianIdentityEditorialLayerV1Finding[],
  field: ZodianIdentityEditorialLayerV1Field,
  code: ZodianIdentityEditorialLayerV1Finding["code"],
  message: string,
  index?: number,
) {
  findings.push({ field, code, message, ...(index === undefined ? {} : { index }) });
}

/** Validates concise internal editorial notes, not source material or reader copy. */
export function validateZodianIdentityEditorialProfile(
  profile: ZodianIdentityEditorialProfile,
): ZodianIdentityEditorialLayerV1Finding[] {
  const findings: ZodianIdentityEditorialLayerV1Finding[] = [];
  const identityFields: Array<[ZodianIdentityEditorialLayerV1Field, string]> = [
    ["identity.westernSign", profile.identity.westernSign],
    ["identity.chineseSign", profile.identity.chineseSign],
  ];
  for (const [field, value] of identityFields) {
    if (!value.trim()) addFinding(findings, field, "required", "Identity is required.");
  }
  if (profile.provenance) {
    const sourceIds = profile.provenance.sourceIds;
    if (sourceIds.length === 0) {
      addFinding(findings, "provenance.sourceIds", "required", "Provenance source IDs cannot be empty when provenance is supplied.");
    }
    const seenSourceIds = new Set<string>();
    sourceIds.forEach((sourceId, index) => {
      if (!sourceId.trim()) {
        addFinding(findings, "provenance.sourceIds", "blank_source_id", "Provenance source IDs cannot be blank.", index);
      } else if (seenSourceIds.has(sourceId)) {
        addFinding(findings, "provenance.sourceIds", "duplicate_source_id", "Provenance source IDs must be distinct.", index);
      }
      seenSourceIds.add(sourceId);
    });
  }

  for (const field of EDITORIAL_FIELDS) {
    const notes = profile[field];
    if (notes.length === 0) {
      addFinding(findings, field, "required", "At least one editorial note is required.");
      continue;
    }
    for (const [index, note] of notes.entries()) {
      const value = note.trim();
      if (!value) addFinding(findings, field, "required", "Editorial notes cannot be empty.", index);
      if (value.length > MAX_NOTE_LENGTH) addFinding(findings, field, "too_long", "Editorial notes must be 160 characters or fewer.", index);
      if (value.length > SOURCE_PASSAGE_LENGTH) addFinding(findings, field, "copied_source_passage", "Long source passages must not enter the editorial profile.", index);
      if (ASTROLOGY_MECHANICS.test(value)) addFinding(findings, field, "astrology_mechanics", "Astrology mechanics do not belong in editorial notes.", index);
      if (HOROSCOPE_PROSE.test(value)) addFinding(findings, field, "horoscope_prose", "Editorial notes must not be horoscope prose.", index);
      if (READER_ADVICE.test(value)) addFinding(findings, field, "reader_advice", "Editorial notes must not give reader advice.", index);
      if (SECOND_PERSON.test(value)) addFinding(findings, field, "second_person", "Editorial notes must not address the reader directly.", index);
    }
  }
  return findings;
}
