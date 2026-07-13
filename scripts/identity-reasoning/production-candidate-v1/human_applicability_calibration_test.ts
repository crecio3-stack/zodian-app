const artifact = new URL(
  "artifacts/production-candidate-v1-human-applicability-calibration-v1.json",
  import.meta.url,
);

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

Deno.test("human applicability calibration retains the strict no-direct-alternative result", async () => {
  const calibration = JSON.parse(await Deno.readTextFile(artifact));
  assert(calibration.status === "FROZEN_PROVIDER_FREE_HUMAN_APPLICABILITY_CALIBRATION", "calibration status must remain frozen provider-free");
  assert(calibration.providerCalls === 0 && calibration.writerCalls === 0 && calibration.copyPersistenceCalls === 0, "calibration must remain provider and copy free");
  assert(calibration.totals.cases === 6, "six TOO_THIN cases must remain calibrated");
  assert(calibration.totals.directlyApplicable === 0, "no direct alternative may be introduced without a new calibration");
  assert(calibration.totals.notApplicable === 37 && calibration.totals.blocked === 2, "full 39-candidate classification must remain intact");
  assert(calibration.cases_with_direct_alternatives.length === 0, "no case may bypass human selection with a direct alternative");
  assert(calibration.cases_with_no_direct_alternatives.length === 6, "every frozen thin case must remain terminal at applicability");
  assert(calibration.ambiguous_candidates_requiring_policy_clarification.length === 2, "only the two documented policy ambiguities may remain blocked");
  for (const item of calibration.cases) {
    assert(item.direct_alternatives.length === 0, `case has unexpected direct alternative: ${item.stable_case_id}`);
    assert(item.result === "NO_DIRECTLY_APPLICABLE_ALTERNATIVE", `case must terminate cleanly: ${item.stable_case_id}`);
    assert(item.classifications.every((entry: { classification: string }) => entry.classification !== "DIRECTLY_APPLICABLE"), `direct classification leaked into ${item.stable_case_id}`);
  }
});
