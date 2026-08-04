/** Shadow-only source-governance registry with no runtime or external dependencies. */
export const ZODIAN_CANONICAL_SOURCE_REGISTRY_V1 =
  "zodian-canonical-source-registry-v1" as const;

export type ZodianCanonicalSourceStatus = "approved" | "restricted" | "deprecated";
export type ZodianCanonicalSourceType = "book" | "internal-canonical" | "reference";
export type ZodianCanonicalSourceCoverage =
  | { type: "all-combined-identities" }
  | {
    type: "selected-combined-identities";
    identities: Array<{ westernSign: string; chineseSign: string }>;
  }
  | { type: "western-signs"; signs: string[] }
  | { type: "chinese-signs"; signs: string[] }
  | { type: "reference" };

export type ZodianCanonicalSourceRecordV1 = {
  registryVersion: typeof ZODIAN_CANONICAL_SOURCE_REGISTRY_V1;
  /** Stable provenance key for one approved source record. */
  sourceId: string;
  /** Source-record version; it never silently replaces historical provenance. */
  sourceVersion: string;
  title: string;
  author?: string;
  sourceType: ZodianCanonicalSourceType;
  status: ZodianCanonicalSourceStatus;
  coverage: ZodianCanonicalSourceCoverage;
  transformationPolicy: {
    mayInformDistilledEditorialProfiles: boolean;
    mayStoreRawPassages: false;
    mayPropagateSourceProse: false;
    requiresIndependentWording: true;
  };
  replacesSourceId?: string;
};

export type ZodianCanonicalSourceRegistryV1Finding = {
  field: string;
  index?: number;
  code:
    | "required"
    | "unknown_status"
    | "unknown_source_type"
    | "unknown_coverage"
    | "duplicate_identity"
    | "duplicate_sign"
    | "self_replacement"
    | "raw_passages_permitted"
    | "source_prose_permitted"
    | "independent_wording_not_required"
    | "approved_source_cannot_inform_profiles";
  message: string;
};

const SOURCE_STATUSES = new Set<ZodianCanonicalSourceStatus>([
  "approved",
  "restricted",
  "deprecated",
]);
const SOURCE_TYPES = new Set<ZodianCanonicalSourceType>([
  "book",
  "internal-canonical",
  "reference",
]);

const INITIAL_REGISTRY: readonly ZodianCanonicalSourceRecordV1[] = Object.freeze([Object.freeze({
  registryVersion: ZODIAN_CANONICAL_SOURCE_REGISTRY_V1,
  sourceId: "source:suzanne-white:new-astrology-21st-century",
  sourceVersion: "unverified-personal-use-copy-v1",
  title: "The New Astrology for the 21st Century",
  author: "Suzanne White",
  sourceType: "book",
  status: "approved",
  coverage: Object.freeze({ type: "all-combined-identities" }),
  transformationPolicy: Object.freeze({
    mayInformDistilledEditorialProfiles: true,
    mayStoreRawPassages: false,
    mayPropagateSourceProse: false,
    requiresIndependentWording: true,
  }),
})]);

function addFinding(
  findings: ZodianCanonicalSourceRegistryV1Finding[],
  field: string,
  code: ZodianCanonicalSourceRegistryV1Finding["code"],
  message: string,
  index?: number,
) {
  findings.push({ field, code, message, ...(index === undefined ? {} : { index }) });
}

function cloneCoverage(coverage: ZodianCanonicalSourceCoverage): ZodianCanonicalSourceCoverage {
  switch (coverage.type) {
    case "selected-combined-identities":
      return { type: coverage.type, identities: coverage.identities.map((identity) => ({ ...identity })) };
    case "western-signs":
    case "chinese-signs":
      return { type: coverage.type, signs: [...coverage.signs] };
    default:
      return { ...coverage };
  }
}

function cloneRecord(record: ZodianCanonicalSourceRecordV1): ZodianCanonicalSourceRecordV1 {
  return {
    ...record,
    coverage: cloneCoverage(record.coverage),
    transformationPolicy: { ...record.transformationPolicy },
  };
}

/** Validates metadata and transformation policy only; it never inspects source content. */
export function validateZodianCanonicalSourceRecordV1(
  record: ZodianCanonicalSourceRecordV1,
): ZodianCanonicalSourceRegistryV1Finding[] {
  const findings: ZodianCanonicalSourceRegistryV1Finding[] = [];
  for (const [field, value] of [
    ["sourceId", record.sourceId],
    ["sourceVersion", record.sourceVersion],
    ["title", record.title],
  ]) {
    if (!value.trim()) addFinding(findings, field, "required", `${field} is required.`);
  }
  if (record.author !== undefined && !record.author.trim()) {
    addFinding(findings, "author", "required", "author cannot be blank when present.");
  }
  if (!SOURCE_STATUSES.has(record.status)) addFinding(findings, "status", "unknown_status", "status is not supported.");
  if (!SOURCE_TYPES.has(record.sourceType)) addFinding(findings, "sourceType", "unknown_source_type", "sourceType is not supported.");
  if (record.replacesSourceId !== undefined) {
    if (!record.replacesSourceId.trim()) addFinding(findings, "replacesSourceId", "required", "replacesSourceId cannot be blank when present.");
    if (record.replacesSourceId === record.sourceId) addFinding(findings, "replacesSourceId", "self_replacement", "A source cannot replace itself.");
  }

  switch (record.coverage.type) {
    case "all-combined-identities":
    case "reference":
      break;
    case "selected-combined-identities": {
      if (record.coverage.identities.length === 0) addFinding(findings, "coverage.identities", "required", "Selected identity coverage cannot be empty.");
      const identities = new Set<string>();
      record.coverage.identities.forEach((identity, index) => {
        if (!identity.westernSign.trim()) addFinding(findings, "coverage.identities.westernSign", "required", "westernSign cannot be blank.", index);
        if (!identity.chineseSign.trim()) addFinding(findings, "coverage.identities.chineseSign", "required", "chineseSign cannot be blank.", index);
        const key = `${identity.westernSign}\u0000${identity.chineseSign}`;
        if (identities.has(key)) addFinding(findings, "coverage.identities", "duplicate_identity", "Selected identities must be distinct.", index);
        identities.add(key);
      });
      break;
    }
    case "western-signs":
    case "chinese-signs": {
      const field = "coverage.signs";
      if (record.coverage.signs.length === 0) addFinding(findings, field, "required", "Sign coverage cannot be empty.");
      const signs = new Set<string>();
      record.coverage.signs.forEach((sign, index) => {
        if (!sign.trim()) addFinding(findings, field, "required", "Sign values cannot be blank.", index);
        if (signs.has(sign)) addFinding(findings, field, "duplicate_sign", "Sign values must be distinct.", index);
        signs.add(sign);
      });
      break;
    }
    default:
      addFinding(findings, "coverage", "unknown_coverage", "coverage type is not supported.");
  }

  if (record.transformationPolicy.mayStoreRawPassages) addFinding(findings, "transformationPolicy.mayStoreRawPassages", "raw_passages_permitted", "Raw passages must not be permitted.");
  if (record.transformationPolicy.mayPropagateSourceProse) addFinding(findings, "transformationPolicy.mayPropagateSourceProse", "source_prose_permitted", "Source prose must not be permitted downstream.");
  if (!record.transformationPolicy.requiresIndependentWording) addFinding(findings, "transformationPolicy.requiresIndependentWording", "independent_wording_not_required", "Independent wording is required.");
  if (record.status === "approved" && !record.transformationPolicy.mayInformDistilledEditorialProfiles) {
    addFinding(findings, "transformationPolicy.mayInformDistilledEditorialProfiles", "approved_source_cannot_inform_profiles", "Approved sources must be able to inform distilled editorial profiles.");
  }
  return findings;
}

/** Returns a copy so callers cannot mutate canonical registry metadata. */
export function getZodianCanonicalSourceRecordV1(sourceId: string): ZodianCanonicalSourceRecordV1 | undefined {
  const record = INITIAL_REGISTRY.find((candidate) => candidate.sourceId === sourceId);
  return record ? cloneRecord(record) : undefined;
}

export function sourceMayInformDistilledEditorialProfiles(sourceId: string): boolean {
  const record = INITIAL_REGISTRY.find((candidate) => candidate.sourceId === sourceId);
  return Boolean(record && record.status === "approved" && record.transformationPolicy.mayInformDistilledEditorialProfiles);
}

export function listActiveApprovedZodianCanonicalSourceIdsV1(): string[] {
  return INITIAL_REGISTRY.filter((record) => record.status === "approved").map((record) => record.sourceId);
}

export function zodianCanonicalSourceExistsV1(sourceId: string): boolean {
  return INITIAL_REGISTRY.some((record) => record.sourceId === sourceId);
}
