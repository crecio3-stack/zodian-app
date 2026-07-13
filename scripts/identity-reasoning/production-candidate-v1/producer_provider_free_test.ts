import {
  buildSelectorInput,
  buildV4WriterPrompt,
  frozenApprovedWriterInput,
  isDevelopmentProjectUrl,
  parseProducerRequest,
  PCV1_DEVELOPMENT_PROJECT_REF,
  type RuntimeSnapshot,
} from "../../../supabase/functions/_shared/production-candidate-v1/producer_contract.ts";
import {
  calibrationMatchesSelector,
  gateResults,
  isBehaviorBearingCanonicalPath,
  repetitionDisposition,
  validateSelector,
  validateWriterOutput,
} from "../../../supabase/functions/_shared/production-candidate-v1/producer_validation.ts";

const snapshotPath = new URL(
  "../../../supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json",
  import.meta.url,
);
const producerPath = new URL(
  "../../../supabase/functions/generate-production-candidate-v1-shadow/index.ts",
  import.meta.url,
);
const configPath = new URL("../../../supabase/config.toml", import.meta.url);
const snapshot = JSON.parse(await Deno.readTextFile(snapshotPath)) as RuntimeSnapshot;
const calibrated = snapshot.cases.find((item) => item.approved_calibration !== null)!;
const uncalibrated = snapshot.cases.find((item) => item.approved_calibration === null)!;

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

function selectedFor(item = calibrated) {
  const citation = item.approved_calibration!.selected_evidence[0];
  return {
    status: "SELECTED" as const,
    behavior: citation.claim,
    supporting_evidence: [citation],
    applicability: "The neutral situation creates a concrete place for this observed behavior to show up.",
    unsupported_claims_added: [] as [],
  };
}

Deno.test("producer snapshot is development-only and has stable isolated cases", () => {
  assert(snapshot.development_only, "Runtime snapshot must remain development-only.");
  assert(snapshot.cases.length === 24, "Runtime snapshot must retain all 24 cases.");
  assert(new Set(snapshot.cases.map((item) => item.stable_case_id)).size === 24, "Stable case IDs must remain unique.");
  assert(snapshot.cases.filter((item) => item.approved_calibration).length === 19, "Only 19 human-approved writer inputs may proceed.");
  assert(snapshot.gold_examples.length === 5, "Frozen Gold examples must remain available only to v4.");
});

Deno.test("frozen approved inputs bypass reselection and terminal blocks have no writer input", () => {
  const input = frozenApprovedWriterInput(calibrated);
  assert(input, "A human-approved case must resolve to one frozen writer input.");
  assert(input.plain_insight === calibrated.approved_calibration!.plain_insight, "Frozen plain insight must be used byte-for-byte.");
  assert(input.plain_action === calibrated.approved_calibration!.plain_action, "Frozen plain action must be used byte-for-byte.");
  assert(frozenApprovedWriterInput(uncalibrated) === null, "A terminal block must not receive an improvised writer input.");
});

Deno.test("project guard refuses current production and accepts Development only", () => {
  assert(isDevelopmentProjectUrl(`https://${PCV1_DEVELOPMENT_PROJECT_REF}.supabase.co`), "Development URL should pass.");
  assert(!isDevelopmentProjectUrl("https://xyyahrqfmdblvonnaifi.supabase.co"), "Current backend must be refused.");
  assert(!isDevelopmentProjectUrl(undefined), "Missing project URL must be refused.");
});

Deno.test("request requires an addressable date and frozen case id", () => {
  assert(parseProducerRequest({ candidate_date: "2026-07-13", stable_case_id: calibrated.stable_case_id }).value, "Valid request should parse.");
  assert(!parseProducerRequest({ candidate_date: "today", stable_case_id: "" }).value, "Invalid request must fail.");
});

Deno.test("valid selector passes direct applicability, clarity, person-first, and calibration gates", () => {
  const selector = selectedFor();
  const validation = validateSelector(selector, calibrated);
  assert(validation.value, `Selector fixture should validate: ${validation.errors.join(", ")}`);
  const gates = gateResults(validation.value, calibrated);
  assert(gates.direct_applicability.passed, "Applicability must pass.");
  assert(gates.person_first.passed, "Person-first must pass.");
  assert(calibrationMatchesSelector(validation.value, calibrated).length === 0, "Calibration must retain selected evidence.");
  assert(buildSelectorInput(calibrated).includes("candidate_evidence"), "Selector receives canonical evidence.");
});

Deno.test("person-first accepts approved behavior-bearing evidence sources without admitting traits or motives", () => {
  const careerCase = snapshot.cases.find((item) =>
    item.stable_case_id === "pcv1-unseen-24-virgo-x-dragon-work-deadline-moves-earlier-neutral"
  )!;
  const careerSelector = selectedFor(careerCase);
  assert(careerSelector.supporting_evidence[0].path === "work.careerBlindSpot", "Regression fixture must cite careerBlindSpot.");
  assert(gateResults(careerSelector, careerCase).person_first.passed, "Directly cited careerBlindSpot behavior must pass person-first.");
  assert(isBehaviorBearingCanonicalPath("evidence.observableBehaviors[0]"), "Observable behavior must remain eligible.");
  assert(isBehaviorBearingCanonicalPath("work.careerBlindSpot"), "careerBlindSpot must be eligible.");
  assert(!isBehaviorBearingCanonicalPath("core.identitySummary"), "Trait or identity-summary fields must remain ineligible.");
  assert(!isBehaviorBearingCanonicalPath("core.motive"), "Motive fields must remain ineligible.");

  const traitSelector = {
    ...careerSelector,
    supporting_evidence: [{ path: "core.identitySummary", claim: "You are precise." }],
  };
  assert(!gateResults(traitSelector, careerCase).person_first.passed, "Trait-only evidence must fail person-first.");
  const motiveSelector = {
    ...careerSelector,
    supporting_evidence: [{ path: "core.motive", claim: "You want control." }],
  };
  assert(!gateResults(motiveSelector, careerCase).person_first.passed, "Motive-only evidence must fail person-first.");
  const abstractSelector = {
    ...careerSelector,
    behavior: "Perfectionism under pressure.",
  };
  assert(!gateResults(abstractSelector, careerCase).person_first.passed, "Non-user-owned abstract output must fail person-first.");
});

Deno.test("BLOCKED is terminal before writer and uncalibrated cases cannot use generic fallback", () => {
  const blocked = {
    status: "BLOCKED" as const,
    behavior: null,
    supporting_evidence: [],
    applicability: null,
    unsupported_claims_added: [] as [],
  };
  const validation = validateSelector(blocked, uncalibrated);
  assert(validation.value?.status === "BLOCKED", "BLOCKED must remain valid.");
  assert(gateResults(validation.value!, uncalibrated).reasoning_clarity.status === "BLOCKED", "BLOCKED must stop before writer.");
  assert(calibrationMatchesSelector(selectedFor(calibrated), uncalibrated).length > 0, "Uncalibrated case must not get fallback copy.");
});

Deno.test("writer accepts only complete title/read and preserves user actor", () => {
  const input = calibrated.approved_calibration!;
  const valid = {
    title: "Keep It Simple",
    read: `${input.plain_insight} ${input.plain_action ?? ""}`.trim(),
  };
  const output = validateWriterOutput(valid, input.plain_insight, input.plain_action);
  assert(output.lens, `Complete user-owned Lens should pass: ${output.errors.join(", ")}`);
  const invalid = validateWriterOutput({ title: "Partial" }, input.plain_insight, input.plain_action);
  assert(!invalid.lens, "Partial copy must be rejected.");
  const prompt = buildV4WriterPrompt(input.plain_insight, input.plain_action, snapshot.gold_examples);
  assert(!prompt.includes(calibrated.western_sign), "Writer prompt must withhold identity.");
  assert(!prompt.includes(calibrated.neutral_situation.situation), "Writer prompt must withhold situation.");
});

Deno.test("repetition audit holds duplicates and never rewrites", () => {
  const result = repetitionDisposition(
    { title: "Keep It Simple", read: "You may pause before you decide." },
    [{ candidate_title: "Keep It Simple", candidate_read: "You may pause before you decide." }],
  );
  assert(result.disposition === "HOLD", "Exact duplicate must hold.");
  assert(result.findings.length === 1, "Audit must report but not rewrite duplicate copy.");
});

Deno.test("producer source stays isolated from legacy Today’s Lens and scheduling", async () => {
  const [source, config] = await Promise.all([
    Deno.readTextFile(producerPath),
    Deno.readTextFile(configPath),
  ]);
  for (const forbidden of [
    /\.from\(["']daily_rituals["']\)/,
    /\.from\(["']canonical_lens_shadow_generations["']\)/,
    /get-daily-ritual/,
    /Deno\.cron\(/,
    /CANONICAL_LENS_V3_2_SHADOW_ALLOWLIST/,
  ]) assert(!forbidden.test(source), `Producer must not use ${forbidden}.`);
  assert(source.includes("PCV1_DEVELOPMENT_PROJECT_REF"), "Producer must carry the development project guard.");
  assert(source.includes("BYPASSED_FROZEN_HUMAN_APPROVAL"), "Producer must record the frozen approval bypass.");
  assert(!source.includes("buildSelectorInput("), "Frozen cohort producer must not call the live selector.");
  assert(!source.includes("selectorInstructions"), "Frozen cohort producer must not send a selector prompt.");
  assert(source.includes("frozen producer runtime snapshot fingerprint mismatch"), "Snapshot fingerprint mismatch must fail closed.");
  for (const parameter of [
    "p_selector_fingerprint",
    "p_writer_prompt_fingerprint",
    "p_validator_fingerprint",
    "p_repetition_fingerprint",
    "p_configuration_fingerprint",
  ]) assert(source.includes(parameter), `Producer claim must use ${parameter}.`);
  assert(config.includes("[functions.generate-production-candidate-v1-shadow]"), "Function must have its own gateway config.");
});
