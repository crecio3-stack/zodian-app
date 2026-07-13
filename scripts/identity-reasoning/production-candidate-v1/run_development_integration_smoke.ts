/**
 * Development-only PCv1 storage/endpoint smoke test.
 *
 * This never calls an AI provider. It creates isolated synthetic candidate rows,
 * verifies the endpoint and claim-state machine, proves the control table stayed
 * unchanged, then deletes only its own synthetic candidate rows.
 */
import { createClient } from "npm:@supabase/supabase-js@2";

const developmentProjectRef = "wlsewblvpyeanfganbkc";
const candidateVersion = "pcv1";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function configuredServiceRoleKey(): string | undefined {
  return Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
    JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;
}

function canonical(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonical).join(",")}]`;
  if (value && typeof value === "object") {
    const record = value as Record<string, unknown>;
    return `{${
      Object.keys(record).sort().map((key) =>
        `${JSON.stringify(key)}:${canonical(record[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

if (!Deno.args.includes("--live-dev")) {
  throw new Error("Refusing to run without --live-dev.");
}

const url = Deno.env.get("SUPABASE_URL");
const serviceRole = configuredServiceRoleKey();
const internalSecret = Deno.env.get("PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET");
assert(
  url && new URL(url).hostname === `${developmentProjectRef}.supabase.co`,
  "SUPABASE_URL must point to the designated Zodian Development project.",
);
assert(
  serviceRole,
  "SUPABASE_SERVICE_ROLE_KEY is required for development fixtures.",
);
assert(internalSecret, "PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET is required.");
const linkedRef = (await Deno.readTextFile("supabase/.temp/project-ref"))
  .trim();
assert(
  linkedRef === developmentProjectRef,
  "The local Supabase link must point to the designated Zodian Development project.",
);

const supabase = createClient(url, serviceRole);
const runId = crypto.randomUUID();
const sourcePrefix = `pcv1-smoke-${runId}`;
const candidateDate = "2099-12-31";
const base = {
  candidate_version: candidateVersion,
  candidate_date: candidateDate,
  western_sign: "Aries",
  eastern_sign: "Rat",
  control_daily_ritual_id: null,
  selector_eligibility: "ELIGIBLE",
  selector_fingerprint: "smoke-selector",
  writer_prompt_fingerprint: "smoke-writer",
  validator_fingerprint: "smoke-validator",
  repetition_fingerprint: "smoke-repetition",
  configuration_fingerprint: "smoke-configuration",
  provider: "none",
  model: "none",
  provider_call_count: 0,
  input_tokens: 0,
  output_tokens: 0,
  total_tokens: 0,
  latency_ms: 0,
  estimated_cost_usd: 0,
  selector_trace: { raw_evidence: "must never reach endpoint" },
  writer_trace: { raw_provider_payload: "must never reach endpoint" },
  validator_trace: { internal_rule: "smoke" },
  repetition_trace: { disposition: "ALLOW" },
  validator_rejection_reasons: [],
  repetition_disposition: "ALLOW",
};

const fixtureStatuses = [
  "ACCEPTED",
  "BLOCKED",
  "WRITER_REJECTED",
  "VALIDATOR_REJECTED",
  "TRANSPORT_FAILED",
  "REPETITION_HOLD",
] as const;

async function controlSnapshot() {
  const { data, error, count } = await supabase.from("daily_rituals")
    .select("*", { count: "exact" })
    .order("id", { ascending: true })
    .range(0, 9999);
  if (error) throw new Error(`Control-table snapshot failed: ${error.message}`);
  if ((count ?? 0) > (data?.length ?? 0)) {
    throw new Error(
      "Control-table snapshot exceeded the safe 10,000-row proof limit.",
    );
  }
  return { count: count ?? 0, sha256: await sha256(canonical(data ?? [])) };
}

function sourceContext(status: string) {
  return `${sourcePrefix}-${status.toLowerCase()}`;
}

async function callEndpoint(
  source_context: string,
  secret?: string,
): Promise<{ status: number; body: Record<string, unknown> }> {
  const response = await fetch(
    `${url}/functions/v1/get-production-candidate-v1`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(secret
          ? { "x-production-candidate-v1-internal-secret": secret }
          : {}),
      },
      body: JSON.stringify({
        candidate_version: candidateVersion,
        candidate_date: candidateDate,
        western_sign: base.western_sign,
        eastern_sign: base.eastern_sign,
        source_context,
      }),
    },
  );
  return { status: response.status, body: await response.json() };
}

async function claim(source_context: string) {
  const { data, error } = await supabase.rpc(
    "claim_production_candidate_v1_generation",
    {
      p_candidate_version: candidateVersion,
      p_candidate_date: candidateDate,
      p_western_sign: base.western_sign,
      p_eastern_sign: base.eastern_sign,
      p_source_context: source_context,
      p_control_daily_ritual_id: null,
      p_selector_fingerprint: base.selector_fingerprint,
      p_writer_prompt_fingerprint: base.writer_prompt_fingerprint,
      p_validator_fingerprint: base.validator_fingerprint,
      p_repetition_fingerprint: base.repetition_fingerprint,
      p_configuration_fingerprint: base.configuration_fingerprint,
    },
  );
  if (error) throw new Error(`Candidate claim failed: ${error.message}`);
  const row = data?.[0] as { status: string; claimed: boolean } | undefined;
  assert(row, "Candidate claim returned no row.");
  return row;
}

const before = await controlSnapshot();
const report: Record<string, unknown> = {
  developmentOnly: true,
  project_ref: developmentProjectRef,
  run_id: runId,
  fixture_statuses: fixtureStatuses,
  providerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
};

try {
  const fixtures = fixtureStatuses.map((status) => ({
    ...base,
    source_context: sourceContext(status),
    status,
    candidate_title: status === "ACCEPTED" ? "Let It Land" : null,
    candidate_read: status === "ACCEPTED"
      ? "You can let the work be finished after you receive credit for it."
      : null,
    error_code: status === "ACCEPTED"
      ? null
      : `synthetic_${status.toLowerCase()}`,
  }));
  const { error: insertError } = await supabase
    .from("production_candidate_v1_generations")
    .insert(fixtures);
  if (insertError) {
    throw new Error(`Synthetic fixture insert failed: ${insertError.message}`);
  }

  const unauthorized = await callEndpoint(sourceContext("ACCEPTED"));
  assert(
    unauthorized.status === 401,
    "Endpoint must reject a request without the internal secret.",
  );

  const endpointResults: Record<string, unknown> = {};
  for (const status of fixtureStatuses) {
    const result = await callEndpoint(sourceContext(status), internalSecret);
    assert(
      result.status === 200,
      `${status} endpoint response should succeed for the internal caller.`,
    );
    assert(
      result.body.version === candidateVersion,
      `${status} must return the candidate version.`,
    );
    assert(
      result.body.status === status.toLowerCase(),
      `${status} returned the wrong safe status.`,
    );
    for (
      const forbidden of [
        "selector_trace",
        "writer_trace",
        "validator_trace",
        "repetition_trace",
        "input_tokens",
        "total_tokens",
        "configuration_fingerprint",
      ]
    ) {
      assert(
        !(forbidden in result.body),
        `${status} response leaked ${forbidden}.`,
      );
    }
    if (status === "ACCEPTED") {
      assert(
        typeof result.body.title === "string" &&
          typeof result.body.read === "string",
        "Accepted response must contain complete title/read.",
      );
    } else {
      assert(
        !("title" in result.body) && !("read" in result.body),
        `${status} must not expose candidate copy.`,
      );
    }
    endpointResults[status] = result.body;
  }

  const immutableStatuses = fixtureStatuses.filter((status) =>
    status !== "TRANSPORT_FAILED"
  );
  for (const status of immutableStatuses) {
    const result = await claim(sourceContext(status));
    assert(
      !result.claimed && result.status === status,
      `${status} must return its immutable existing record on repeat claim.`,
    );
  }
  const transport = await claim(sourceContext("TRANSPORT_FAILED"));
  assert(
    transport.claimed && transport.status === "RUNNING",
    "Transport failure must be the only terminal state that resumes.",
  );

  const expiredContext = sourceContext("RUNNING_EXPIRED");
  const { error: expiredInsertError } = await supabase
    .from("production_candidate_v1_generations")
    .insert({
      ...base,
      source_context: expiredContext,
      status: "RUNNING",
      candidate_title: null,
      candidate_read: null,
      lease_expires_at: "2000-01-01T00:00:00.000Z",
    });
  if (expiredInsertError) {
    throw new Error(
      `Expired lease fixture insert failed: ${expiredInsertError.message}`,
    );
  }
  const expired = await claim(expiredContext);
  assert(
    expired.claimed && expired.status === "RUNNING",
    "Only an expired running lease may be reclaimed.",
  );

  const after = await controlSnapshot();
  assert(
    before.count === after.count && before.sha256 === after.sha256,
    "daily_rituals changed during the PCv1 smoke test.",
  );
  report.endpoint_results = endpointResults;
  report.claims = {
    immutable_statuses: immutableStatuses,
    transport_resumed: true,
    expired_lease_reclaimed: true,
  };
  report.control_table = { before, after, unchanged: true };
  report.passed = true;
} finally {
  const { error } = await supabase.from("production_candidate_v1_generations")
    .delete()
    .like("source_context", `${sourcePrefix}%`);
  if (error) {
    throw new Error(`Synthetic fixture cleanup failed: ${error.message}`);
  }
}

const output = new URL(
  `./artifacts/production-candidate-v1-development-smoke-${runId}.json`,
  import.meta.url,
);
await Deno.writeTextFile(output, JSON.stringify(report, null, 2) + "\n");
console.log(JSON.stringify({ ...report, artifact: output.pathname }, null, 2));
