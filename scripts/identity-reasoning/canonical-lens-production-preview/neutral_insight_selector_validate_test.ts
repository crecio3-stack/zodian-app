import { validateNeutralInsightSelectorResult } from "./neutral_insight_selector_validate.ts";

const evidence = [{
  path: "evidence.observableBehaviors[0]",
  claim: "You avoid tension.",
}];

Deno.test("accepts a cited user-owned selected behavior", () => {
  const errors = validateNeutralInsightSelectorResult({
    status: "SELECTED",
    behavior: "You may hold back when a decision could create tension.",
    supporting_evidence: evidence,
    applicability:
      "The neutral work situation can make the cited hesitation relevant.",
    unsupported_claims_added: [],
  }, evidence);
  if (errors.length) throw new Error(JSON.stringify(errors));
});

Deno.test("rejects an unsupported citation and action language", () => {
  const errors = validateNeutralInsightSelectorResult({
    status: "SELECTED",
    behavior: "You should decide quickly.",
    supporting_evidence: [{ path: "made.up", claim: "invented" }],
    applicability: "Because meetings are boring.",
    unsupported_claims_added: [],
  }, evidence);
  if (errors.length < 2) throw new Error(JSON.stringify(errors));
});

Deno.test("accepts an explicit BLOCKED result", () => {
  const errors = validateNeutralInsightSelectorResult({
    status: "BLOCKED",
    behavior: null,
    supporting_evidence: [],
    applicability: null,
    unsupported_claims_added: [],
  }, evidence);
  if (errors.length) throw new Error(JSON.stringify(errors));
});
