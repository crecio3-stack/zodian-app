import type { CanonicalIdentityModel } from "./types.ts";

export interface CanonicalValidationResult {
  valid: boolean;
  errors: string[];
}

const reviewedStatuses = new Set(["reviewed", "frozen"]);
const genericClaims = new Set([
  "observant",
  "loyal",
  "independent",
  "intuitive",
  "reliable",
]);

function nonEmpty(value: unknown): boolean {
  if (typeof value === "string") return value.trim().length > 0;
  if (Array.isArray(value)) return value.length > 0 && value.every(nonEmpty);
  if (value && typeof value === "object") {
    const nested = Object.values(value);
    return nested.length > 0 && nested.every(nonEmpty);
  }
  return value !== null && value !== undefined;
}

function requireNonEmpty(errors: string[], path: string, value: unknown): void {
  if (!nonEmpty(value)) errors.push(`${path} must be non-empty`);
}

export function validateCanonicalIdentity(
  model: CanonicalIdentityModel,
): CanonicalValidationResult {
  const errors: string[] = [];
  for (
    const key of [
      "signPair",
      "westernSign",
      "chineseSign",
      "archetypeName",
      "version",
    ] as const
  ) {
    requireNonEmpty(errors, key, model[key]);
  }
  for (
    const key of [
      "core",
      "sourceReasoning",
      "perception",
      "decision",
      "social",
      "relationships",
      "work",
      "pressure",
      "growth",
      "evidence",
    ] as const
  ) {
    requireNonEmpty(errors, key, model[key]);
  }

  const themes = (model.core?.recurringThemes ?? []).map((theme) =>
    theme.trim().toLowerCase()
  );
  if (themes.length < 3 || themes.length > 5) {
    errors.push("core.recurringThemes must contain 3–5 themes");
  }
  if (new Set(themes).size !== themes.length) {
    errors.push("core.recurringThemes must not contain duplicates");
  }
  if (!model.sourceReasoning?.emergentSynthesis?.trim()) {
    errors.push("sourceReasoning.emergentSynthesis is required");
  }
  if ((model.evidence?.observableBehaviors?.length ?? 0) < 5) {
    errors.push("evidence.observableBehaviors requires at least 5 items");
  }
  if ((model.evidence?.everydaySituations?.length ?? 0) < 4) {
    errors.push("evidence.everydaySituations requires at least 4 items");
  }

  for (
    const [index, claim] of (model.evidence?.prohibitedGenericClaims ?? [])
      .entries()
  ) {
    if (!genericClaims.has(claim.trim().toLowerCase())) {
      errors.push(
        `evidence.prohibitedGenericClaims[${index}] is not an approved generic-claim guardrail`,
      );
    }
  }

  if (reviewedStatuses.has(model.status)) {
    if ((model.evidence?.observableBehaviors?.length ?? 0) < 7) {
      errors.push(
        "reviewed/frozen fixtures require at least 7 observable behaviors",
      );
    }
    if ((model.evidence?.signatureContrasts?.length ?? 0) < 3) {
      errors.push(
        "reviewed/frozen fixtures require at least 3 signature contrasts",
      );
    }
    if (
      (model.relationships?.trustBuilders?.length ?? 0) < 3 ||
      (model.relationships?.trustBreakers?.length ?? 0) < 3
    ) {
      errors.push(
        "reviewed/frozen fixtures require at least 3 trust builders and breakers",
      );
    }
    if ((model.pressure?.visibleBehaviors?.length ?? 0) < 3) {
      errors.push(
        "reviewed/frozen fixtures require at least 3 pressure behaviors",
      );
    }
    if ((model.growth?.groundingBehaviors?.length ?? 0) < 3) {
      errors.push(
        "reviewed/frozen fixtures require at least 3 grounding behaviors",
      );
    }
  }

  return { valid: errors.length === 0, errors };
}
