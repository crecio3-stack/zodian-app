/**
 * Provider-free boundary between approved upstream reasoning and v4 writer
 * eligibility. This module never selects evidence, writes prose, or calls a
 * provider. A proposed second beat must already have been separately reviewed.
 */

export const COMPLETENESS_OUTCOMES = [
  "SECOND_BEAT_SUPPORTED",
  "ONE_BEAT_COMPLETE",
  "TOO_THIN",
  "BLOCKED",
] as const;
export type CompletenessOutcome = typeof COMPLETENESS_OUTCOMES[number];

export const ALLOWED_SECOND_BEAT_TYPES = [
  "consequence",
  "tension",
  "contrast",
  "action",
  "effect",
] as const;
export type SecondBeatType = typeof ALLOWED_SECOND_BEAT_TYPES[number];

export type EvidenceCitation = { path: string; claim: string };
export type CandidateEvidence = EvidenceCitation & { source?: string };

export type SecondBeatSupport =
  | "DIRECTLY_CITED"
  | "INFERRED_MOTIVE_OR_PSYCHOLOGY"
  | "GENERIC_ADVICE"
  | "SCENARIO_INFERRED_CONSEQUENCE"
  | "RESTATEMENT_OF_FIRST_BEAT"
  | "LENGTH_PADDING";

export type ApprovedPrimaryBeat = {
  proposition: string;
  evidence: EvidenceCitation;
  evidencePassed: boolean;
  applicabilityPassed: boolean;
  personFirstPassed: boolean;
  humanLanguagePassed: boolean;
  approvalStatus: "APPROVED" | "REJECTED";
};

export type RecordedSecondBeat = {
  type: SecondBeatType;
  proposition: string;
  evidence: EvidenceCitation;
  support: SecondBeatSupport;
  approvalStatus: "APPROVED" | "PENDING" | "REJECTED";
};

export type OneBeatCompletion = {
  type: Extract<SecondBeatType, "consequence" | "action" | "effect">;
  evidence: EvidenceCitation;
  support: "DIRECTLY_CITED";
  approvalStatus: "APPROVED";
};

export type CompletenessGateInput = {
  stableCaseId: string;
  proposedOutcome: CompletenessOutcome;
  primaryBeat: ApprovedPrimaryBeat;
  candidateEvidence: CandidateEvidence[];
  secondBeat?: RecordedSecondBeat;
  oneBeatCompletion?: OneBeatCompletion;
};

export type CompletenessRoute = {
  writerEligibility: "ELIGIBLE" | "INELIGIBLE";
  writerCallAllowed: boolean;
  persistCopy: boolean;
  nextStep:
    | "HUMAN_APPROVED_SECOND_BEAT_TO_WRITER"
    | "APPROVED_ONE_BEAT_TO_WRITER"
    | "RESELECT_SUPPORTED_INSIGHT_UNDER_NEW_VERSION"
    | "TERMINAL_NO_COPY";
};

export type CompletenessGateResult = {
  classification: CompletenessOutcome;
  route: CompletenessRoute;
  errors: string[];
};

const NO_COPY_ROUTE: CompletenessRoute = {
  writerEligibility: "INELIGIBLE",
  writerCallAllowed: false,
  persistCopy: false,
  nextStep: "TERMINAL_NO_COPY",
};

const TOO_THIN_ROUTE: CompletenessRoute = {
  writerEligibility: "INELIGIBLE",
  writerCallAllowed: false,
  persistCopy: false,
  nextStep: "RESELECT_SUPPORTED_INSIGHT_UNDER_NEW_VERSION",
};

function sameCitation(left: EvidenceCitation, right: EvidenceCitation): boolean {
  return left.path === right.path && left.claim === right.claim;
}

function citedIn(
  citation: EvidenceCitation,
  candidateEvidence: CandidateEvidence[],
): boolean {
  return candidateEvidence.some((candidate) => sameCitation(candidate, citation));
}

function primaryErrors(input: CompletenessGateInput): string[] {
  const primary = input.primaryBeat;
  const errors: string[] = [];
  if (!primary.proposition.trim()) errors.push("primary beat proposition is required");
  if (!citedIn(primary.evidence, input.candidateEvidence)) {
    errors.push("primary beat citation is not present in candidate evidence");
  }
  if (!primary.evidencePassed) errors.push("primary beat did not pass evidence");
  if (!primary.applicabilityPassed) errors.push("primary beat did not pass applicability");
  if (!primary.personFirstPassed) errors.push("primary beat did not pass person-first");
  if (!primary.humanLanguagePassed) errors.push("primary beat did not pass human-language");
  if (primary.approvalStatus !== "APPROVED") {
    errors.push("primary beat is not approved");
  }
  return errors;
}

function secondBeatErrors(
  secondBeat: RecordedSecondBeat | undefined,
  input: CompletenessGateInput,
): string[] {
  if (!secondBeat) return ["SECOND_BEAT_SUPPORTED requires a recorded second beat"];
  const errors: string[] = [];
  if (!ALLOWED_SECOND_BEAT_TYPES.includes(secondBeat.type)) {
    errors.push("second beat type is not recognized");
  }
  if (!secondBeat.proposition.trim()) errors.push("second beat proposition is required");
  if (!citedIn(secondBeat.evidence, input.candidateEvidence)) {
    errors.push("second beat citation is not present in candidate evidence");
  }
  if (sameCitation(secondBeat.evidence, input.primaryBeat.evidence)) {
    errors.push("second beat must have a separately recorded evidence citation");
  }
  if (secondBeat.support !== "DIRECTLY_CITED") {
    errors.push(`second beat is not directly cited: ${secondBeat.support}`);
  }
  if (secondBeat.approvalStatus !== "APPROVED") {
    errors.push("second beat is not approved");
  }
  return errors;
}

function oneBeatCompletionErrors(
  completion: OneBeatCompletion | undefined,
  input: CompletenessGateInput,
): string[] {
  if (!completion) return ["ONE_BEAT_COMPLETE requires directly cited completion evidence"];
  const errors: string[] = [];
  if (!citedIn(completion.evidence, input.candidateEvidence)) {
    errors.push("one-beat completion citation is not present in candidate evidence");
  }
  if (completion.support !== "DIRECTLY_CITED") {
    errors.push("one-beat completion is not directly cited");
  }
  if (completion.approvalStatus !== "APPROVED") {
    errors.push("one-beat completion is not approved");
  }
  return errors;
}

/**
 * Fail closed. The only two writer-eligible routes are an approved, separately
 * cited second beat or an approved directly complete one beat.
 */
export function routeUpstreamCompleteness(
  input: CompletenessGateInput,
): CompletenessGateResult {
  if (input.proposedOutcome === "BLOCKED") {
    return { classification: "BLOCKED", route: NO_COPY_ROUTE, errors: [] };
  }

  const errors = primaryErrors(input);
  if (errors.length > 0) {
    return { classification: "BLOCKED", route: NO_COPY_ROUTE, errors };
  }

  if (input.proposedOutcome === "TOO_THIN") {
    if (input.secondBeat || input.oneBeatCompletion) {
      errors.push("TOO_THIN must not carry a second beat or one-beat completion");
      return { classification: "BLOCKED", route: NO_COPY_ROUTE, errors };
    }
    return { classification: "TOO_THIN", route: TOO_THIN_ROUTE, errors };
  }

  if (input.proposedOutcome === "ONE_BEAT_COMPLETE") {
    errors.push(...oneBeatCompletionErrors(input.oneBeatCompletion, input));
    if (input.secondBeat) errors.push("ONE_BEAT_COMPLETE must not carry a second beat");
    return errors.length
      ? { classification: "BLOCKED", route: NO_COPY_ROUTE, errors }
      : {
        classification: "ONE_BEAT_COMPLETE",
        route: {
          writerEligibility: "ELIGIBLE",
          writerCallAllowed: true,
          persistCopy: true,
          nextStep: "APPROVED_ONE_BEAT_TO_WRITER",
        },
        errors,
      };
  }

  errors.push(...secondBeatErrors(input.secondBeat, input));
  if (input.oneBeatCompletion) {
    errors.push("SECOND_BEAT_SUPPORTED must not carry one-beat completion evidence");
  }
  return errors.length
    ? { classification: "BLOCKED", route: NO_COPY_ROUTE, errors }
    : {
      classification: "SECOND_BEAT_SUPPORTED",
      route: {
        writerEligibility: "ELIGIBLE",
        writerCallAllowed: true,
        persistCopy: true,
        nextStep: "HUMAN_APPROVED_SECOND_BEAT_TO_WRITER",
      },
      errors,
    };
}
