export type PersonFirstStatus = "PASS" | "NARROW" | "BLOCKED";

export type PersonFirstAssessment = {
  status: PersonFirstStatus;
  reasons: string[];
  evidenceRequirement: "observable_behavior";
  requiresHumanRewrite: boolean;
};

// This gate deliberately evaluates only the supplied plain insight. It does not
// infer a motive, rewrite the insight, or decide whether the resulting prose is good.
const explicitPersonalPattern =
  /\byou\s+(?:may|notice|often|tend to|keep|compare|wait|move|finish|leave|look|avoid|check|repeat|react|hesitate)\b/i;
const capabilityFraming = /\byou can\b/i;
const adviceFirst =
  /^(?:when|after|before)\b[^,]*,\s*(?:say|name|ask|change|take|think|let|look|notice|make|keep)\b|^(?:say|name|ask|change|take|think|let|look|notice|make|keep)\b/i;
const situationFirst = /^(?:a|an|the|this|that|one)\b/i;

export function assessPersonFirstSpecificity(
  plainInsight: string,
  observableEvidenceCount: number,
): PersonFirstAssessment {
  const insight = plainInsight.trim();
  const reasons: string[] = [];

  if (observableEvidenceCount < 1) {
    return {
      status: "BLOCKED",
      reasons: [
        "No cited observable behavior supports a personal observation.",
      ],
      evidenceRequirement: "observable_behavior",
      requiresHumanRewrite: false,
    };
  }

  if (capabilityFraming.test(insight)) {
    reasons.push(
      "Capability framing describes what a person could do, not a pattern they do.",
    );
  }
  if (adviceFirst.test(insight)) {
    reasons.push(
      "Advice-first framing gives an instruction before identifying the user's pattern.",
    );
  }
  if (situationFirst.test(insight) && !/\byou\b/i.test(insight)) {
    reasons.push(
      "Situation-first framing describes the circumstance rather than the user's behavior.",
    );
  }

  if (reasons.length > 0) {
    return {
      status: "NARROW",
      reasons,
      evidenceRequirement: "observable_behavior",
      requiresHumanRewrite: true,
    };
  }

  if (!explicitPersonalPattern.test(insight)) {
    return {
      status: "NARROW",
      reasons: [
        "The insight does not plainly name a concrete behavior, attention pattern, reaction, hesitation, or decision pattern belonging to the user.",
      ],
      evidenceRequirement: "observable_behavior",
      requiresHumanRewrite: true,
    };
  }

  return {
    status: "PASS",
    reasons: [
      "The insight names a user-owned observable pattern and cites at least one observable behavior.",
    ],
    evidenceRequirement: "observable_behavior",
    requiresHumanRewrite: false,
  };
}

export function outputKeepsPersonalActor(read: string): boolean {
  return /\byou\b/i.test(read);
}
