import type { CanonicalIdentityModel } from "../canonical/types.ts";
import type { ArenaManifestation } from "./manifestations.ts";

const malformed = [
  /\bwhen\s+(state|talks|keeps|avoids|takes|makes|reads|finds)\b/i,
  /\bthis person\s+(avoids|takes|keeps|talks|makes)\b/i,
  /recovery starts when/i,
  /starts when\s+you know/i,
  /\bwhen\s+you\b[^.?!]{0,80}\bwhen\s+/i,
  /\b(?:by|of|through|habit of)\s+(?:state|talk|keep|avoid|read|make|use|push|adapt)\b/i,
  /\bground\s+(?:one|the|this)\b.*\bbehavior\b/i,
  /visible in a financial tradeoff/i,
  /has somewhere concrete to occur/i,
  /can be credited without becoming a demand/i,
  /\.{2,}|,{2,}/,
];

function allGeneratedStrings(model: CanonicalIdentityModel): string[] {
  const sections = [
    model.core,
    model.sourceReasoning,
    model.perception,
    model.decision,
    model.social,
    model.relationships,
    model.work,
    model.pressure,
    model.growth,
  ];
  return sections.flatMap((section) =>
    Object.values(section).flatMap((value) =>
      Array.isArray(value) ? value : [value]
    )
  ).filter((value): value is string => typeof value === "string");
}

export function validateCanonicalEditorial(
  model: CanonicalIdentityModel,
): string[] {
  const errors: string[] = [];
  for (const value of allGeneratedStrings(model)) {
    for (const pattern of malformed) {
      if (pattern.test(value)) errors.push(`${pattern}: ${value}`);
    }
    if (value.length > 320) {
      errors.push(`field exceeds 320 characters: ${value.slice(0, 80)}`);
    }
  }
  return errors;
}

export function validateManifestationEditorial(
  manifestation: ArenaManifestation,
): string[] {
  const errors: string[] = [];
  const fields = [
    manifestation.perception,
    manifestation.identitySpecificRole,
    manifestation.recognition,
    manifestation.ordinaryLifeExpression,
    manifestation.blindSpot,
    manifestation.naturalMove,
    ...manifestation.observableBehaviors,
  ];
  for (const value of fields) {
    for (const pattern of malformed) {
      if (pattern.test(value)) errors.push(`${pattern}: ${value}`);
    }
    if (!value.trim()) errors.push("empty manifestation field");
    if (value.length > 280) {
      errors.push(
        `manifestation field exceeds 280 characters: ${value.slice(0, 80)}`,
      );
    }
  }
  if (!/^[A-Z]/.test(manifestation.naturalMove)) {
    errors.push("naturalMove is not sentence-cased");
  }
  if (!/[.!?]$/.test(manifestation.naturalMove)) {
    errors.push("naturalMove is not a complete sentence");
  }
  return errors;
}

export function validateSourceFragmentNormalization(value: string): string[] {
  return malformed.filter((pattern) => pattern.test(value)).map(String);
}
