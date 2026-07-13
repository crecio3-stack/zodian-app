import {
  routeInsightReselection,
  type InsightReselectionRequest,
} from "./insight_reselection_contract.ts";

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

const original = {
  path: "evidence.observableBehaviors[3]",
  claim: "You struggle to slow down.",
};
const alternate = {
  path: "evidence.observableBehaviors[2]",
  claim: "You push through resistance.",
};

function request(overrides: Partial<InsightReselectionRequest> = {}): InsightReselectionRequest {
  return {
    stableCaseId: "pcv1-unseen-24-taurus-x-horse-rest-open-evening-neutral",
    rejectedCandidateVersion: "pcv1-completeness-v1",
    nextCandidateVersion: "pcv1-insight-reselection-v1",
    tooThinConfirmed: true,
    attemptState: "NOT_STARTED",
    rejectedInsights: [{
      propositionKey: "taurus-horse-rest-struggle-to-slow-down",
      proposition: "When your evening opens up, you may find it hard to slow down.",
      evidence: original,
    }],
    candidateEvidence: [original, alternate],
    ...overrides,
  };
}

Deno.test("TOO_THIN exposes remaining evidence but is never writer eligible", () => {
  const result = routeInsightReselection(request());
  assert(result.status === "READY_FOR_NEW_SUPPORTED_SELECTION", "first bounded attempt should open a new selection pass");
  assert(result.remainingEvidence.length === 1 && result.remainingEvidence[0].path === alternate.path, "rejected evidence must be excluded");
  assert(!result.writerCallAllowed && !result.persistCopy, "reselection must remain upstream of writer and persistence");
});

Deno.test("approved distinct replacement returns to completeness, not directly to writer", () => {
  const result = routeInsightReselection(request({
    proposedReplacement: {
      propositionKey: "taurus-horse-rest-push-through-resistance",
      proposition: "When the evening opens up, you may push through resistance instead of stopping.",
      evidence: alternate,
      evidencePassed: true,
      applicabilityPassed: true,
      personFirstPassed: true,
      humanLanguagePassed: true,
      approvalStatus: "APPROVED_FOR_COMPLETENESS",
    },
  }));
  assert(result.status === "READY_FOR_COMPLETENESS_GATE", "new insight must return through completeness");
  assert(!result.writerCallAllowed, "reselection cannot bypass completeness into writer");
});

Deno.test("recycling the same citation or proposition fails closed", () => {
  const sameCitation = routeInsightReselection(request({
    proposedReplacement: {
      propositionKey: "taurus-horse-rest-struggle-to-slow-down",
      proposition: "When the evening opens up, you may have trouble slowing down.",
      evidence: original,
      evidencePassed: true,
      applicabilityPassed: true,
      personFirstPassed: true,
      humanLanguagePassed: true,
      approvalStatus: "APPROVED_FOR_COMPLETENESS",
    },
  }));
  assert(sameCitation.status === "BLOCKED", "rejected evidence cannot be reused");

  const sameProposition = routeInsightReselection(request({
    proposedReplacement: {
      propositionKey: "taurus-horse-rest-push-through-resistance",
      proposition: "When your evening opens up, you may find it hard to slow down.",
      evidence: alternate,
      evidencePassed: true,
      applicabilityPassed: true,
      personFirstPassed: true,
      humanLanguagePassed: true,
      approvalStatus: "APPROVED_FOR_COMPLETENESS",
    },
  }));
  assert(sameProposition.status === "BLOCKED", "rejected proposition cannot be recycled with a new citation");
});

Deno.test("weakened evidence gates and consumed empty attempt are terminal", () => {
  const weak = routeInsightReselection(request({
    proposedReplacement: {
      propositionKey: "taurus-horse-rest-push-through-resistance",
      proposition: "When the evening opens up, you may push through resistance instead of stopping.",
      evidence: alternate,
      evidencePassed: true,
      applicabilityPassed: false,
      personFirstPassed: true,
      humanLanguagePassed: true,
      approvalStatus: "APPROVED_FOR_COMPLETENESS",
    },
  }));
  assert(weak.status === "BLOCKED", "failed applicability cannot be weakened during reselection");

  const recycledKey = routeInsightReselection(request({
    proposedReplacement: {
      propositionKey: "taurus-horse-rest-struggle-to-slow-down",
      proposition: "When the evening opens up, you may push through resistance instead of stopping.",
      evidence: alternate,
      evidencePassed: true,
      applicabilityPassed: true,
      personFirstPassed: true,
      humanLanguagePassed: true,
      approvalStatus: "APPROVED_FOR_COMPLETENESS",
    },
  }));
  assert(recycledKey.status === "BLOCKED", "a rejected proposition key cannot be recycled through paraphrase");

  const exhausted = routeInsightReselection(request({ attemptState: "CONSUMED" }));
  assert(exhausted.status === "EXHAUSTED_NO_ALTERNATE_SUPPORTED_INSIGHT", "the contract must not retry indefinitely");
  assert(!exhausted.writerCallAllowed && !exhausted.persistCopy, "exhaustion must remain no-copy");
});
