export type SelectorEvidence = { path: string; claim: string };
export type NeutralInsightSelectorResult = {
  status: "SELECTED" | "BLOCKED";
  behavior: string | null;
  supporting_evidence: SelectorEvidence[];
  applicability: string | null;
  unsupported_claims_added: [];
};

const exactKeys = [
  "status",
  "behavior",
  "supporting_evidence",
  "applicability",
  "unsupported_claims_added",
].sort();

export function validateNeutralInsightSelectorResult(
  value: unknown,
  allowedEvidence: SelectorEvidence[],
): string[] {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return ["result must be an object"];
  }
  const result = value as Record<string, unknown>;
  const keys = Object.keys(result).sort();
  const errors: string[] = [];
  if (JSON.stringify(keys) !== JSON.stringify(exactKeys)) {
    errors.push("result must contain exactly the required fields");
  }
  if (result.status !== "SELECTED" && result.status !== "BLOCKED") {
    errors.push("status must be SELECTED or BLOCKED");
  }
  if (!Array.isArray(result.supporting_evidence)) {
    errors.push("supporting_evidence must be an array");
  }
  if (
    !Array.isArray(result.unsupported_claims_added) ||
    result.unsupported_claims_added.length !== 0
  ) {
    errors.push("unsupported_claims_added must be an empty array");
  }
  const allowed = new Set(
    allowedEvidence.map((item) => `${item.path}\u0000${item.claim}`),
  );
  const citations = Array.isArray(result.supporting_evidence)
    ? result.supporting_evidence
    : [];
  const seen = new Set<string>();
  for (const citation of citations) {
    if (!citation || typeof citation !== "object") {
      errors.push("each supporting evidence entry must be an object");
      continue;
    }
    const path = (citation as Record<string, unknown>).path;
    const claim = (citation as Record<string, unknown>).claim;
    if (typeof path !== "string" || typeof claim !== "string") {
      errors.push(
        "each supporting evidence entry must have string path and claim",
      );
      continue;
    }
    const key = `${path}\u0000${claim}`;
    if (!allowed.has(key)) {
      errors.push(
        `citation is not in the supplied canonical evidence: ${path}`,
      );
    }
    if (seen.has(key)) errors.push(`duplicate citation: ${path}`);
    seen.add(key);
  }
  if (result.status === "SELECTED") {
    if (typeof result.behavior !== "string" || !result.behavior.trim()) {
      errors.push("SELECTED requires a behavior");
    }
    if (
      typeof result.applicability !== "string" || !result.applicability.trim()
    ) errors.push("SELECTED requires an applicability explanation");
    if (citations.length < 1) {
      errors.push("SELECTED requires at least one canonical citation");
    }
    if (
      typeof result.behavior === "string" && !/\byou\b/i.test(result.behavior)
    ) errors.push("SELECTED behavior must be a user-owned observation");
    if (
      typeof result.behavior === "string" &&
      /\b(?:should|need to|try|make sure|remember to)\b/i.test(result.behavior)
    ) {
      errors.push(
        "SELECTED behavior must not include advice or a corrective action",
      );
    }
  }
  if (result.status === "BLOCKED") {
    if (result.behavior !== null) {
      errors.push("BLOCKED requires behavior to be null");
    }
    if (result.applicability !== null) {
      errors.push("BLOCKED requires applicability to be null");
    }
    if (citations.length !== 0) {
      errors.push("BLOCKED requires no selected evidence citations");
    }
  }
  return errors;
}
