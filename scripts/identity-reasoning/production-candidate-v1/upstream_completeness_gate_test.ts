import {
  routeUpstreamCompleteness,
  type CompletenessGateInput,
} from "./upstream_completeness_gate.ts";

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

const primaryCitation = {
  path: "evidence.observableBehaviors[1]",
  claim: "You notice as the balance is off.",
};
const directSecondCitation = {
  path: "evidence.observableBehaviors[4]",
  claim: "You let people guess instead of naming it.",
};

function approvedInput(
  overrides: Partial<CompletenessGateInput> = {},
): CompletenessGateInput {
  return {
    stableCaseId: "provider-free-gate-fixture",
    proposedOutcome: "SECOND_BEAT_SUPPORTED",
    primaryBeat: {
      proposition: "When a shared plan changes, you may notice quickly if it no longer feels balanced.",
      evidence: primaryCitation,
      evidencePassed: true,
      applicabilityPassed: true,
      personFirstPassed: true,
      humanLanguagePassed: true,
      approvalStatus: "APPROVED",
    },
    candidateEvidence: [primaryCitation, directSecondCitation],
    secondBeat: {
      type: "contrast",
      proposition: "You let people guess instead of naming it.",
      evidence: directSecondCitation,
      support: "DIRECTLY_CITED",
      approvalStatus: "APPROVED",
    },
    ...overrides,
  };
}

Deno.test("Libra × Snake reaches writer eligibility only with separately cited approved contrast", () => {
  const result = routeUpstreamCompleteness(approvedInput());
  assert(result.classification === "SECOND_BEAT_SUPPORTED", "exact supported contrast must classify as supported");
  assert(result.route.writerCallAllowed, "approved second beat should be writer eligible");
  assert(result.route.nextStep === "HUMAN_APPROVED_SECOND_BEAT_TO_WRITER", "must retain the approval boundary");
});

Deno.test("TOO_THIN cannot call writer, persist copy, or repair the same insight", () => {
  const result = routeUpstreamCompleteness(approvedInput({
    proposedOutcome: "TOO_THIN",
    secondBeat: undefined,
  }));
  assert(result.classification === "TOO_THIN", "valid thin insight must remain TOO_THIN");
  assert(!result.route.writerCallAllowed, "TOO_THIN must stop before writer");
  assert(!result.route.persistCopy, "TOO_THIN must not persist copy");
  assert(result.route.nextStep === "RESELECT_SUPPORTED_INSIGHT_UNDER_NEW_VERSION", "TOO_THIN must seek another insight under a new version");
});

Deno.test("ONE_BEAT_COMPLETE allows an approved directly cited complete beat", () => {
  const result = routeUpstreamCompleteness(approvedInput({
    proposedOutcome: "ONE_BEAT_COMPLETE",
    secondBeat: undefined,
    oneBeatCompletion: {
      type: "effect",
      evidence: primaryCitation,
      support: "DIRECTLY_CITED",
      approvalStatus: "APPROVED",
    },
  }));
  assert(result.classification === "ONE_BEAT_COMPLETE", "approved direct completion should be eligible");
  assert(result.route.writerCallAllowed, "one complete beat may reach writer");
});

Deno.test("BLOCKED is terminal no-copy", () => {
  const result = routeUpstreamCompleteness(approvedInput({ proposedOutcome: "BLOCKED" }));
  assert(result.classification === "BLOCKED", "BLOCKED must remain terminal");
  assert(!result.route.writerCallAllowed && !result.route.persistCopy, "BLOCKED must never produce copy");
});

for (const [name, support, proposition] of [
  [
    "inferred interpersonal consequence",
    "SCENARIO_INFERRED_CONSEQUENCE",
    "This can leave the other person unaware that the change bothered you.",
  ],
  [
    "scenario-inferred tension",
    "SCENARIO_INFERRED_CONSEQUENCE",
    "You may avoid talking about the tension around what to replace.",
  ],
  [
    "inferred motive",
    "INFERRED_MOTIVE_OR_PSYCHOLOGY",
    "You keep moving because you need to prove you are useful.",
  ],
] as const) {
  Deno.test(`documented unsupported example remains rejected: ${name}`, () => {
    const result = routeUpstreamCompleteness(approvedInput({
      secondBeat: {
        type: "consequence",
        proposition,
        evidence: directSecondCitation,
        support,
        approvalStatus: "APPROVED",
      },
    }));
    assert(result.classification === "BLOCKED", "unsupported second beat must fail closed");
    assert(!result.route.writerCallAllowed, "rejected second beat must not call writer");
  });
}

Deno.test("generic advice, restatement, length padding, and pending approval remain ineligible", () => {
  for (const support of ["GENERIC_ADVICE", "RESTATEMENT_OF_FIRST_BEAT", "LENGTH_PADDING"] as const) {
    const result = routeUpstreamCompleteness(approvedInput({
      secondBeat: { ...approvedInput().secondBeat!, support },
    }));
    assert(result.classification === "BLOCKED", `${support} must fail closed`);
  }
  const result = routeUpstreamCompleteness(approvedInput({
    secondBeat: { ...approvedInput().secondBeat!, approvalStatus: "PENDING" },
  }));
  assert(result.classification === "BLOCKED", "unapproved second beat must fail closed");
});
