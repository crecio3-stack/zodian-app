const migration = new URL(
  "../../../supabase/migrations/20260713090000_production_candidate_v1_isolated_storage.sql",
  import.meta.url,
);
const endpoint = new URL(
  "../../../supabase/functions/get-production-candidate-v1/index.ts",
  import.meta.url,
);
const config = new URL("../../../supabase/config.toml", import.meta.url);
const output = new URL(
  "./artifacts/production-candidate-v1-integration-slice-preflight-v3.json",
  import.meta.url,
);

async function sha256(path: URL): Promise<string> {
  const data = await Deno.readFile(path);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(hash)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

function mutatesControlTable(sql: string): boolean {
  return /\b(?:alter\s+table|insert\s+into|update|delete\s+from|truncate\s+table)\s+(?:public\.)?daily_rituals\b/i
    .test(sql);
}

const [migrationSql, endpointSource, configToml] = await Promise.all([
  Deno.readTextFile(migration),
  Deno.readTextFile(endpoint),
  Deno.readTextFile(config),
]);
const checks = {
  separate_candidate_table: migrationSql.includes(
    "production_candidate_v1_generations",
  ),
  control_table_untouched: !mutatesControlTable(migrationSql),
  rls_enabled: migrationSql.includes("enable row level security"),
  accepted_only_content_constraint:
    migrationSql.includes("status = 'ACCEPTED'") &&
    migrationSql.includes("candidate_title is null") &&
    migrationSql.includes("candidate_read is null"),
  observability_fields: [
    "selector_eligibility",
    "validator_rejection_reasons",
    "repetition_disposition",
    "latency_ms",
    "total_tokens",
    "estimated_cost_usd",
  ].every((field) => migrationSql.includes(field)),
  deterministic_unique_key: migrationSql.includes(
    "unique (candidate_version, candidate_date, western_sign, eastern_sign, source_context)",
  ),
  transport_resume_only: migrationSql.includes("status = 'TRANSPORT_FAILED'"),
  endpoint_is_separate: !endpointSource.includes("get-daily-ritual") &&
    !endpointSource.includes("daily_rituals"),
  internal_secret_required: endpointSource.includes(
    "x-production-candidate-v1-internal-secret",
  ),
  candidate_version_allowlist: endpointSource.includes(
    "isReadableCandidateVersion(candidate_version)",
  ) && !endpointSource.includes("|| CANDIDATE_VERSION"),
  stored_version_returned: endpointSource.includes(
    "return json(internalCandidateResponse(record))",
  ),
  raw_traces_withheld: ![
    "selector_trace",
    "writer_trace",
    "validator_trace",
    "repetition_trace",
  ].some((field) => endpointSource.includes(`\"${field}\"`)),
  gateway_passes_to_internal_secret: configToml.includes(
    "[functions.get-production-candidate-v1]",
  ),
};
const failed = Object.entries(checks).filter(([, passed]) => !passed).map((
  [name],
) => name);
if (failed.length) {
  throw new Error(`Integration preflight failed: ${failed.join(", ")}`);
}

const result = {
  passed: true,
  developmentOnly: true,
  checks,
  fingerprints: {
    migration_sha256: await sha256(migration),
    endpoint_sha256: await sha256(endpoint),
  },
  providerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};
const serialized = JSON.stringify(result, null, 2) + "\n";
try {
  const existing = await Deno.readTextFile(output);
  if (existing !== serialized) {
    throw new Error(`Existing frozen preflight differs: ${output.pathname}`);
  }
} catch (error) {
  if (error instanceof Deno.errors.NotFound) {
    await Deno.writeTextFile(output, serialized);
  } else {
    throw error;
  }
}
console.log(serialized);
