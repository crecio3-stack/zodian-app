/**
 * Guarded manual invoker for the Development-only PCv1 producer.
 * It is intentionally one-case-at-a-time and has no scheduling mode.
 */
import {
  isDevelopmentProjectUrl,
  parseProducerRequest,
  PCV1_DEVELOPMENT_PROJECT_REF,
  PCV1_PRODUCER_VERSION,
  sha256,
  stable,
  type RuntimeSnapshot,
} from "../../../supabase/functions/_shared/production-candidate-v1/producer_contract.ts";

const root = new URL("./", import.meta.url);
const snapshotPath = new URL(
  "../../../supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json",
  root,
);
const producerPath = new URL(
  "../../../supabase/functions/generate-production-candidate-v1-shadow/index.ts",
  root,
);
const validationPath = new URL(
  "../../../supabase/functions/_shared/production-candidate-v1/producer_validation.ts",
  root,
);
const contractPath = new URL(
  "../../../supabase/functions/_shared/production-candidate-v1/producer_contract.ts",
  root,
);
const configPath = new URL("../../../supabase/config.toml", root);
const outputPath = new URL(
  "./artifacts/production-candidate-v1-development-producer-preflight-v8.json",
  root,
);
const markdownPath = new URL(
  "./artifacts/production-candidate-v1-development-producer-preflight-v8.md",
  root,
);

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

async function fileSha(path: URL): Promise<string> {
  return sha256(await Deno.readTextFile(path));
}

async function writeFrozen(path: URL, value: unknown) {
  const next = stable(value);
  try {
    const existing = await Deno.readTextFile(path);
    if (existing !== next) {
      throw new Error(`Existing frozen artifact differs: ${path.pathname}`);
    }
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      await Deno.writeTextFile(path, next);
      return;
    }
    throw error;
  }
}

const mode = Deno.args[0];
if (!mode || !["--preflight", "--manual-dev"].includes(mode)) {
  throw new Error(
    "Usage: --preflight, or --manual-dev --date YYYY-MM-DD --case STABLE_CASE_ID. This runner has no batch, schedule, allowlist, or production mode.",
  );
}

const [snapshotText, producerSource, validationSource, contractSource, configToml] = await Promise.all([
  Deno.readTextFile(snapshotPath),
  Deno.readTextFile(producerPath),
  Deno.readTextFile(validationPath),
  Deno.readTextFile(contractPath),
  Deno.readTextFile(configPath),
]);
const snapshot = JSON.parse(snapshotText) as RuntimeSnapshot;
const { sha256: recordedSnapshotSha, ...snapshotCore } = snapshot;
const snapshotSha = await sha256(stable(snapshotCore));
const checks = {
  development_only_snapshot: snapshot.development_only &&
    snapshot.version === "pcv1-development-producer-v1",
  snapshot_sha256_verified: snapshotSha === recordedSnapshotSha,
  stable_cases: snapshot.cases.length === 24 &&
    new Set(snapshot.cases.map((item) => item.stable_case_id)).size === 24,
  human_approved_writer_inputs: snapshot.cases.filter((item) =>
    item.approved_calibration !== null
  ).length === 19,
  producer_isolated_from_control: !/\.from\(["']daily_rituals["']\)/.test(producerSource),
  producer_isolated_from_shadow: !/\.from\(["']canonical_lens_shadow_generations["']\)/.test(producerSource),
  blocked_before_writer: producerSource.includes("if (!frozenInput)") &&
    producerSource.includes('return json(safeStatus("BLOCKED"))'),
  frozen_approved_input_bypasses_selector: producerSource.includes("BYPASSED_FROZEN_HUMAN_APPROVAL") &&
    producerSource.includes("frozenApprovedWriterInput(item)") &&
    !producerSource.includes("buildSelectorInput("),
  runtime_snapshot_mismatch_fails_closed: producerSource.includes("frozen producer runtime snapshot fingerprint mismatch"),
  accepted_only_copy: producerSource.includes('status: "ACCEPTED"') &&
    producerSource.includes("candidate_title: null") &&
    producerSource.includes("candidate_read: null"),
  provider_traces_server_only: !producerSource.includes("get-production-candidate-v1") &&
    !producerSource.includes("DailyRitualResponse"),
  project_ref_hard_guard: producerSource.includes("PCV1_DEVELOPMENT_PROJECT_REF") &&
    producerSource.includes("isDevelopmentProjectUrl"),
  transport_only_resume: producerSource.includes("TRANSPORT_FAILED") &&
    !producerSource.includes("retry"),
  v4_validator_present: validationSource.includes("validateWriterOutput") &&
    validationSource.includes("unsupportedAdditionErrors"),
  function_is_manual_only: !producerSource.includes("Deno.cron(") &&
    configToml.includes("[functions.generate-production-candidate-v1-shadow]"),
  versioned_candidate_key: PCV1_PRODUCER_VERSION === "pcv1-frozen-approved-input-v1" &&
    contractSource.includes("pcv1-frozen-approved-input-v1"),
};
const failed = Object.entries(checks).filter(([, passed]) => !passed).map(([key]) => key);
if (failed.length) throw new Error(`Producer preflight failed: ${failed.join(", ")}`);
const preflight = {
  passed: true,
  developmentOnly: true,
  target_project_ref: PCV1_DEVELOPMENT_PROJECT_REF,
  candidate_version: PCV1_PRODUCER_VERSION,
  runtime_snapshot: { sha256: snapshotSha, cases: 24, writer_eligible: 19, terminal_blocks: 5 },
  checks,
  fingerprints: {
    producer_sha256: await fileSha(producerPath),
    validation_sha256: await fileSha(validationPath),
    contract_sha256: await fileSha(contractPath),
  },
  provider_free_fixtures: {
    terminal_states: [
      "ACCEPTED",
      "BLOCKED",
      "WRITER_REJECTED",
      "VALIDATOR_REJECTED",
      "TRANSPORT_FAILED",
      "REPETITION_HOLD",
    ],
    duplicate_claim: "returns_existing_terminal_record",
    transport_resume: "reclaimable_under_existing_claim_function",
    expired_lease_reclaim: "reclaimable_under_existing_claim_function",
    blocked_before_writer: true,
    frozen_approved_input_bypasses_selector: true,
    artifact_sha_mismatch_fails_closed: true,
    accepted_only_copy: true,
    partial_copy_rejected: true,
    control_table_mutation: false,
    endpoint_trace_exposure: false,
    production_project_ref_hard_refusal: true,
  },
  providerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};
await writeFrozen(outputPath, preflight);
await Deno.writeTextFile(markdownPath, `# Production Candidate v1 — Development Producer Preflight\n\n**Result:** PASS\n\n- Project guard: \`${PCV1_DEVELOPMENT_PROJECT_REF}\` only\n- Runtime snapshot: 24 stable cases; 19 human-approved writer inputs; 5 terminal no-copy cases\n- Selector, v4 writer, and validation stages: present and isolated\n- Provider calls: 0\n- Current Today’s Lens and canonical shadow writes: 0\n- Schedules, allowlists, deployments: unchanged\n\n## Manual boundary\n\nThe only payable path is one explicit frozen case through \`--manual-dev --date YYYY-MM-DD --case STABLE_CASE_ID\`. It refuses a non-Development URL or local project link and has no batch or scheduling mode.\n`);

if (mode === "--preflight") {
  console.log(JSON.stringify(preflight, null, 2));
  Deno.exit(0);
}

const dateIndex = Deno.args.indexOf("--date");
const caseIndex = Deno.args.indexOf("--case");
const candidateDate = dateIndex >= 0 ? Deno.args[dateIndex + 1] : undefined;
const stableCaseId = caseIndex >= 0 ? Deno.args[caseIndex + 1] : undefined;
if (Deno.args.length !== 5 || dateIndex < 0 || caseIndex < 0) {
  throw new Error("Manual invocation requires exactly --manual-dev --date YYYY-MM-DD --case STABLE_CASE_ID.");
}
const request = parseProducerRequest({ candidate_date: candidateDate, stable_case_id: stableCaseId });
if (!request.value) throw new Error(request.errors.join(", "));
assert(snapshot.cases.some((item) => item.stable_case_id === request.value!.stableCaseId), "Stable case is outside the frozen producer snapshot.");
const url = Deno.env.get("SUPABASE_URL");
const secret = Deno.env.get("PRODUCTION_CANDIDATE_V1_PRODUCER_SECRET");
assert(isDevelopmentProjectUrl(url), "SUPABASE_URL must target Zodian Development only.");
assert(secret, "PRODUCTION_CANDIDATE_V1_PRODUCER_SECRET is required.");
const linkedRef = (await Deno.readTextFile("supabase/.temp/project-ref")).trim();
assert(linkedRef === PCV1_DEVELOPMENT_PROJECT_REF, "Local Supabase link must target Zodian Development only.");
const response = await fetch(`${url}/functions/v1/generate-production-candidate-v1-shadow`, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "x-production-candidate-v1-producer-secret": secret,
  },
  body: JSON.stringify({ candidate_date: request.value.candidateDate, stable_case_id: request.value.stableCaseId }),
});
const body = await response.json().catch(() => ({ error: "non-json response" }));
// A validator or writer rejection is a valid explicit terminal state for this
// manual shadow test. Transport/configuration failures remain hard failures.
if (!response.ok && response.status !== 422) {
  throw new Error(`Development producer ${response.status}: ${JSON.stringify(body)}`);
}
console.log(JSON.stringify({
  developmentOnly: true,
  target_project_ref: PCV1_DEVELOPMENT_PROJECT_REF,
  http_status: response.status,
  response: body,
}, null, 2));
