function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function assertIncludes(haystack: string, needle: string): void {
  assert(haystack.includes(needle), `Expected source to include: ${needle}`);
}

function mutatesControlTable(sql: string): boolean {
  return /\b(?:alter\s+table|insert\s+into|update|delete\s+from|truncate\s+table)\s+(?:public\.)?daily_rituals\b/i
    .test(sql);
}

const root = new URL("../../../", import.meta.url);
const migration = new URL(
  "supabase/migrations/20260713090000_production_candidate_v1_isolated_storage.sql",
  root,
);
const endpoint = new URL(
  "supabase/functions/get-production-candidate-v1/index.ts",
  root,
);
const config = new URL("supabase/config.toml", root);

Deno.test("integration slice remains isolated from current Today’s Lens paths", async () => {
  const [migrationSql, endpointSource, configToml] = await Promise.all([
    Deno.readTextFile(migration),
    Deno.readTextFile(endpoint),
    Deno.readTextFile(config),
  ]);
  assertIncludes(migrationSql, "production_candidate_v1_generations");
  assertIncludes(migrationSql, "enable row level security");
  assertIncludes(migrationSql, "candidate_title is null");
  assertIncludes(migrationSql, "candidate_read is null");
  assertIncludes(migrationSql, "selector_eligibility");
  assertIncludes(migrationSql, "validator_rejection_reasons");
  assertIncludes(migrationSql, "repetition_disposition");
  assert(
    !mutatesControlTable(migrationSql),
    "Migration must not mutate daily_rituals.",
  );
  assert(
    !endpointSource.includes("daily_rituals"),
    "Endpoint must not reference daily_rituals.",
  );
  assert(
    !endpointSource.includes("get-daily-ritual"),
    "Endpoint must remain separate from get-daily-ritual.",
  );
  assertIncludes(endpointSource, "x-production-candidate-v1-internal-secret");
  assertIncludes(configToml, "[functions.get-production-candidate-v1]");
});

Deno.test("endpoint source returns no raw evidence or provider trace fields", async () => {
  const endpointSource = await Deno.readTextFile(endpoint);
  for (
    const forbiddenField of [
      "selector_trace",
      "writer_trace",
      "validator_trace",
      "repetition_trace",
      "raw_provider",
      "canonical_evidence",
    ]
  ) {
    assert(
      !endpointSource.includes(`\"${forbiddenField}\"`),
      `${forbiddenField} must not be selected or returned by the endpoint`,
    );
  }
});
