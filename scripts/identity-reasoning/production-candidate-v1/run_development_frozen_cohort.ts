/**
 * One-time completion runner for the already-frozen 24-case Development cohort.
 * It deliberately has no case arguments, scheduling mode, or production target.
 */
import {
  isDevelopmentProjectUrl,
  PCV1_DEVELOPMENT_PROJECT_REF,
  PCV1_PRODUCER_VERSION,
  sha256,
  stable,
  type RuntimeSnapshot,
  type RuntimeSnapshotCase,
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
const cohortCheckpointPath = new URL(
  "./artifacts/production-candidate-v1-development-frozen-cohort-v1-checkpoint.json",
  root,
);
const reportPath = new URL(
  "./artifacts/production-candidate-v1-development-frozen-cohort-v1.json",
  root,
);
const reportMarkdownPath = new URL(
  "./artifacts/production-candidate-v1-development-frozen-cohort-v1.md",
  root,
);
const blindReviewPath = new URL(
  "./artifacts/production-candidate-v1-development-frozen-cohort-v1-blind-review.md",
  root,
);

const candidateDate = "2026-07-13";
const completedSlice = new Map<string, "accepted" | "blocked">([
  ["pcv1-unseen-24-virgo-x-dragon-work-deadline-moves-earlier-neutral", "accepted"],
  ["pcv1-unseen-24-virgo-x-dragon-home-guests-shared-room-neutral", "accepted"],
  ["pcv1-unseen-24-cancer-x-pig-routine-tool-change-neutral", "blocked"],
]);

type EndpointBody = Record<string, unknown>;
type Projection = { http_status: number; body: EndpointBody };
type DbRow = Record<string, unknown>;

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

function text(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function keyOf(item: RuntimeSnapshotCase): string {
  return [item.western_sign, item.eastern_sign, item.source_context]
    .map((value) => value.toLowerCase()).join("|");
}

function candidatePayload(item: RuntimeSnapshotCase) {
  return {
    candidate_version: PCV1_PRODUCER_VERSION,
    candidate_date: candidateDate,
    western_sign: item.western_sign,
    eastern_sign: item.eastern_sign,
    source_context: item.source_context,
  };
}

async function writeFrozen(path: URL, value: unknown): Promise<void> {
  const next = stable(value);
  try {
    const existing = await Deno.readTextFile(path);
    if (existing !== next) throw new Error(`Existing frozen artifact differs: ${path.pathname}`);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      await Deno.writeTextFile(path, next);
      return;
    }
    throw error;
  }
}

async function writeFrozenText(path: URL, value: string): Promise<void> {
  try {
    const existing = await Deno.readTextFile(path);
    if (existing !== value) throw new Error(`Existing frozen artifact differs: ${path.pathname}`);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      await Deno.writeTextFile(path, value);
      return;
    }
    throw error;
  }
}

function responseStatus(projection: Projection): string {
  return text(projection.body.status).toLowerCase();
}

function isTerminal(status: string): boolean {
  return [
    "accepted",
    "blocked",
    "writer_rejected",
    "validator_rejected",
    "repetition_hold",
  ].includes(status);
}

function hasCopy(body: EndpointBody): boolean {
  return typeof body.title === "string" && typeof body.read === "string";
}

async function internalProjection(
  url: string,
  secret: string | undefined,
  item: RuntimeSnapshotCase,
): Promise<Projection> {
  const response = await fetch(`${url}/functions/v1/get-production-candidate-v1`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(secret ? { "x-production-candidate-v1-internal-secret": secret } : {}),
    },
    body: JSON.stringify(candidatePayload(item)),
  });
  const body = await response.json().catch(() => ({ error: "non-json response" })) as EndpointBody;
  return { http_status: response.status, body };
}

async function invokeProducer(
  url: string,
  secret: string,
  item: RuntimeSnapshotCase,
): Promise<Projection> {
  const response = await fetch(`${url}/functions/v1/generate-production-candidate-v1-shadow`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-production-candidate-v1-producer-secret": secret,
    },
    body: JSON.stringify({ candidate_date: candidateDate, stable_case_id: item.stable_case_id }),
  });
  const body = await response.json().catch(() => ({ error: "non-json response" })) as EndpointBody;
  return { http_status: response.status, body };
}

async function queryLinkedDatabase(sql: string): Promise<DbRow[]> {
  const result = await new Deno.Command("supabase", {
    args: ["db", "query", "--linked", "--output", "json", sql],
  }).output();
  if (!result.success) {
    throw new Error(`Read-only linked database query failed: ${new TextDecoder().decode(result.stderr).trim()}`);
  }
  const stdout = new TextDecoder().decode(result.stdout).trim();
  const start = Math.min(
    ...[stdout.indexOf("{"), stdout.indexOf("[")].filter((index) => index >= 0),
  );
  if (!Number.isFinite(start)) throw new Error("Linked database query did not return JSON.");
  const parsed = JSON.parse(stdout.slice(start)) as unknown;
  if (Array.isArray(parsed)) return parsed as DbRow[];
  if (parsed && typeof parsed === "object" && Array.isArray((parsed as { rows?: unknown }).rows)) {
    return (parsed as { rows: DbRow[] }).rows;
  }
  throw new Error("Linked database query returned an unsupported JSON shape.");
}

async function countRows(): Promise<{ daily_rituals_rows: number; canonical_shadow_rows: number }> {
  const rows = await queryLinkedDatabase(
    "select (select count(*)::int from public.daily_rituals) as daily_rituals_rows, (select count(*)::int from public.canonical_lens_shadow_generations) as canonical_shadow_rows;",
  );
  const row = rows[0] ?? {};
  return {
    daily_rituals_rows: Number(row.daily_rituals_rows ?? 0),
    canonical_shadow_rows: Number(row.canonical_shadow_rows ?? 0),
  };
}

async function providerFreePreflight() {
  const [snapshotText, producerSource] = await Promise.all([
    Deno.readTextFile(snapshotPath),
    Deno.readTextFile(producerPath),
  ]);
  const snapshot = JSON.parse(snapshotText) as RuntimeSnapshot;
  const { sha256: recordedSha, ...snapshotPayload } = snapshot;
  const snapshotSha = await sha256(stable(snapshotPayload));
  const remaining = snapshot.cases.filter((item) => !completedSlice.has(item.stable_case_id));
  const checks = {
    development_only_snapshot: snapshot.development_only && snapshot.version === "pcv1-development-producer-v1",
    snapshot_sha256_verified: snapshotSha === recordedSha,
    exactly_24_stable_cases: snapshot.cases.length === 24 && new Set(snapshot.cases.map((item) => item.stable_case_id)).size === 24,
    completed_slice_is_exactly_three: completedSlice.size === 3 && [...completedSlice.keys()].every((id) => snapshot.cases.some((item) => item.stable_case_id === id)),
    exactly_21_remaining_cases: remaining.length === 21,
    candidate_version_is_frozen_input_version: PCV1_PRODUCER_VERSION === "pcv1-frozen-approved-input-v1",
    selector_is_bypassed_for_frozen_approvals: producerSource.includes("BYPASSED_FROZEN_HUMAN_APPROVAL") && !producerSource.includes("buildSelectorInput("),
    blocked_cases_stop_before_writer: producerSource.includes("if (!frozenInput)"),
    manual_producer_has_no_schedule: !producerSource.includes("Deno.cron("),
    control_and_shadow_storage_isolated: !/\.from\(["']daily_rituals["']\)/.test(producerSource) &&
      !/\.from\(["']canonical_lens_shadow_generations["']\)/.test(producerSource),
  };
  const failed = Object.entries(checks).filter(([, value]) => !value).map(([key]) => key);
  if (failed.length) throw new Error(`Frozen cohort preflight failed: ${failed.join(", ")}`);
  return { snapshot, snapshotSha, remaining, checks };
}

async function main() {
  const mode = Deno.args[0];
  if (mode !== "--preflight" && mode !== "--run-one-time-frozen-cohort") {
    throw new Error("Usage: --preflight or --run-one-time-frozen-cohort. This is a one-time frozen Development cohort runner, not a production batch mode.");
  }
  const preflight = await providerFreePreflight();
  const providerFreeResult = {
    passed: true,
    developmentOnly: true,
    target_project_ref: PCV1_DEVELOPMENT_PROJECT_REF,
    candidate_version: PCV1_PRODUCER_VERSION,
    runtime_snapshot_sha256: preflight.snapshotSha,
    cases: 24,
    completed_slice_cases: 3,
    remaining_cases: 21,
    checks: preflight.checks,
    providerCalls: 0,
    productionWritePaths: [],
    shadowWritePaths: [],
    scheduleChanges: [],
    allowlistChanges: [],
    deploymentChanges: [],
  };
  if (mode === "--preflight") {
    console.log(JSON.stringify(providerFreeResult, null, 2));
    return;
  }

  const url = Deno.env.get("SUPABASE_URL");
  const producerSecret = Deno.env.get("PRODUCTION_CANDIDATE_V1_PRODUCER_SECRET");
  const internalSecret = Deno.env.get("PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET");
  assert(isDevelopmentProjectUrl(url), "SUPABASE_URL must target Zodian Development only.");
  assert(producerSecret, "PRODUCTION_CANDIDATE_V1_PRODUCER_SECRET is required.");
  assert(internalSecret, "PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET is required.");
  const linkedRef = (await Deno.readTextFile("supabase/.temp/project-ref")).trim();
  assert(linkedRef === PCV1_DEVELOPMENT_PROJECT_REF, "Local Supabase link must target Zodian Development only.");

  const beforeCounts = await countRows();
  const initial = new Map<string, Projection>();
  for (const item of preflight.snapshot.cases) {
    const projection = await internalProjection(url!, internalSecret, item);
    initial.set(item.stable_case_id, projection);
  }
  for (const [stableCaseId, expectedStatus] of completedSlice) {
    const projection = initial.get(stableCaseId)!;
    assert(responseStatus(projection) === expectedStatus, `Completed slice case ${stableCaseId} is not its expected ${expectedStatus} state.`);
  }
  for (const item of preflight.remaining) {
    const status = responseStatus(initial.get(item.stable_case_id)!);
    assert(
      status === "not_found" || status === "transport_failed" || isTerminal(status),
      `Remaining case ${item.stable_case_id} has unexpected pre-run state: ${status || "unknown"}.`,
    );
  }

  const checkpoint: Array<Record<string, unknown>> = [];
  for (const item of preflight.remaining) {
    const existing = initial.get(item.stable_case_id)!;
    const existingStatus = responseStatus(existing);
    if (isTerminal(existingStatus)) {
      checkpoint.push({ stable_case_id: item.stable_case_id, disposition: "skipped_existing_terminal", response: existing.body });
      continue;
    }
    const invocation = await invokeProducer(url!, producerSecret!, item);
    checkpoint.push({ stable_case_id: item.stable_case_id, disposition: "invoked", http_status: invocation.http_status, response: invocation.body });
    await Deno.writeTextFile(cohortCheckpointPath, stable({
      developmentOnly: true,
      candidate_version: PCV1_PRODUCER_VERSION,
      date: candidateDate,
      completed: checkpoint,
    }));
    const status = responseStatus(invocation);
    if (invocation.http_status >= 500 || status === "transport_failed" || !isTerminal(status)) {
      throw new Error(`Cohort stopped after ${item.stable_case_id}: ${invocation.http_status} ${status || "unexpected response"}. Rerun resumes only through the existing transport claim contract.`);
    }
  }

  const projections = new Map<string, Projection>();
  for (const item of preflight.snapshot.cases) {
    const projection = await internalProjection(url!, internalSecret, item);
    const status = responseStatus(projection);
    assert(isTerminal(status), `Case ${item.stable_case_id} did not reach a terminal state: ${status || "unknown"}.`);
    if (status === "accepted") {
      assert(projection.http_status === 200 && hasCopy(projection.body), `Accepted case ${item.stable_case_id} lacks complete endpoint copy.`);
      assert(Object.keys(projection.body).sort().join(",") === "read,status,title,version", `Accepted endpoint projection leaked extra fields for ${item.stable_case_id}.`);
    } else {
      assert(!("title" in projection.body) && !("read" in projection.body), `Non-accepted endpoint projection exposed copy for ${item.stable_case_id}.`);
    }
    projections.set(item.stable_case_id, projection);
  }

  const idempotency: Array<Record<string, unknown>> = [];
  for (const item of preflight.snapshot.cases) {
    const repeat = await invokeProducer(url!, producerSecret!, item);
    assert(repeat.http_status === 200 && repeat.body.idempotent === true, `Idempotency failed for ${item.stable_case_id}.`);
    idempotency.push({ stable_case_id: item.stable_case_id, status: responseStatus(repeat), idempotent: true });
  }

  const unsupported = await fetch(`${url}/functions/v1/get-production-candidate-v1`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-production-candidate-v1-internal-secret": internalSecret!,
    },
    body: JSON.stringify({ ...candidatePayload(preflight.snapshot.cases[0]), candidate_version: "pcv1-unknown" }),
  });
  const unauthenticated = await internalProjection(url!, undefined, preflight.snapshot.cases[0]);
  assert(unsupported.status === 400, "Unsupported candidate version must be rejected.");
  assert(unauthenticated.http_status === 401, "Unauthenticated internal request must be rejected.");

  const rows = await queryLinkedDatabase(
    `select candidate_version,candidate_date,western_sign,eastern_sign,source_context,status,candidate_title,candidate_read,error_code,provider,model,provider_call_count,input_tokens,output_tokens,total_tokens,latency_ms,repetition_disposition,selector_trace->>'stage' as selector_stage,writer_trace->'writer_input'->>'plain_action' as plain_action from public.production_candidate_v1_generations where candidate_version = '${PCV1_PRODUCER_VERSION}' and candidate_date = '${candidateDate}' order by western_sign,eastern_sign,source_context;`,
  );
  assert(rows.length === 24, `Expected 24 rows for the frozen cohort, found ${rows.length}.`);
  const records = new Map(rows.map((row) => [
    [text(row.western_sign), text(row.eastern_sign), text(row.source_context)].map((value) => value.toLowerCase()).join("|"),
    row,
  ]));
  const cases = preflight.snapshot.cases.map((item) => {
    const row = records.get(keyOf(item));
    assert(row, `Database row missing for ${item.stable_case_id}.`);
    const projection = projections.get(item.stable_case_id)!;
    const status = text(row.status);
    const calls = Number(row.provider_call_count ?? 0);
    assert(calls <= 1, `Case ${item.stable_case_id} exceeded one writer call.`);
    if (item.approved_calibration === null) {
      assert(status === "BLOCKED" && calls === 0 && row.candidate_title === null && row.candidate_read === null, `Frozen blocked case ${item.stable_case_id} violated its no-copy contract.`);
    }
    return {
      stable_case_id: item.stable_case_id,
      identity: `${item.western_sign} × ${item.eastern_sign}`,
      source_context: item.source_context,
      status,
      reason_code: row.error_code ?? null,
      selector_stage: row.selector_stage ?? null,
      provider_calls: calls,
      input_tokens: Number(row.input_tokens ?? 0),
      output_tokens: Number(row.output_tokens ?? 0),
      total_tokens: Number(row.total_tokens ?? 0),
      latency_ms: Number(row.latency_ms ?? 0),
      repetition_disposition: row.repetition_disposition ?? null,
      action_preservation: row.plain_action === null ? "not_applicable" : status === "ACCEPTED" ? "validated" : "not_accepted",
      title: status === "ACCEPTED" ? projection.body.title : null,
      read: status === "ACCEPTED" ? projection.body.read : null,
    };
  });
  const afterCounts = await countRows();
  assert(stable(beforeCounts) === stable(afterCounts), "Control or canonical shadow counts changed during cohort execution.");
  const totals = cases.reduce((sum, row) => ({
    provider_calls: sum.provider_calls + row.provider_calls,
    input_tokens: sum.input_tokens + row.input_tokens,
    output_tokens: sum.output_tokens + row.output_tokens,
    total_tokens: sum.total_tokens + row.total_tokens,
    latency_ms: sum.latency_ms + row.latency_ms,
  }), { provider_calls: 0, input_tokens: 0, output_tokens: 0, total_tokens: 0, latency_ms: 0 });
  const report = {
    developmentOnly: true,
    target_project_ref: PCV1_DEVELOPMENT_PROJECT_REF,
    candidate_version: PCV1_PRODUCER_VERSION,
    runtime_snapshot_sha256: preflight.snapshotSha,
    date: candidateDate,
    result: "PASS",
    cases,
    totals,
    idempotency,
    endpoint_security: {
      accepted_projection: "version_status_title_read_only",
      nonaccepted_projection: "version_status_safe_reason_only",
      unsupported_version_http_status: unsupported.status,
      unauthenticated_http_status: unauthenticated.http_status,
      raw_trace_exposure: false,
    },
    counts: {
      before: beforeCounts,
      after: afterCounts,
      candidate_rows: rows.length,
    },
    productionWritePaths: [],
    shadowWritePaths: [],
    scheduleChanges: [],
    allowlistChanges: [],
    iosExposure: false,
  };
  await writeFrozen(reportPath, report);
  const accepted = cases.filter((row) => row.status === "ACCEPTED");
  const ordered = await Promise.all(accepted.map(async (row) => ({
    ...row,
    blind_key: await sha256(row.stable_case_id),
  })));
  ordered.sort((left, right) => left.blind_key.localeCompare(right.blind_key));
  const blind = [
    "# Production Candidate v1 — Development Frozen Cohort Blind Copy Review",
    "",
    "Review each title and read as product copy. Identity, situation, input, action source, and provider metadata are intentionally withheld.",
    "",
    ...ordered.flatMap((row, index) => [
      `## Sample ${String(index + 1).padStart(2, "0")}`,
      "",
      `**Title:** ${row.title}`,
      "",
      row.read as string,
      "",
      "- Natural and immediately understandable: PASS / MINOR / FAIL",
      "- Useful as a complete daily read: PASS / MINOR / FAIL",
      "- Notes:",
      "",
    ]),
  ].join("\n");
  await writeFrozenText(blindReviewPath, blind);
  console.log(JSON.stringify({
    developmentOnly: true,
    result: "PASS",
    cases: cases.length,
    accepted: accepted.length,
    terminal_nonaccepted: cases.length - accepted.length,
    provider_calls: totals.provider_calls,
    total_tokens: totals.total_tokens,
    report: reportPath.pathname,
    blind_review: blindReviewPath.pathname,
  }, null, 2));
}

await main();
