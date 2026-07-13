/**
 * Development-only manual PCv1 shadow producer.
 *
 * It is deliberately isolated from daily_rituals, canonical shadow storage,
 * current Today’s Lens endpoints, scheduling, allowlists, and iOS consumers.
 */
import { createClient } from "npm:@supabase/supabase-js@2";
import snapshot from "../_shared/production-candidate-v1/producer_runtime_snapshot.json" with {
  type: "json",
};
import {
  buildV4WriterPrompt,
  frozenApprovedWriterInput,
  isDevelopmentProjectUrl,
  outputText,
  parseJson,
  parseProducerRequest,
  PCV1_DEVELOPMENT_PROJECT_REF,
  PCV1_PRODUCER_VERSION,
  sha256,
  stable,
  type RuntimeSnapshot,
  type RuntimeSnapshotCase,
} from "../_shared/production-candidate-v1/producer_contract.ts";
import {
  repetitionDisposition,
  validateWriterOutput,
} from "../_shared/production-candidate-v1/producer_validation.ts";

const runtime = snapshot as RuntimeSnapshot;
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

function configuredServiceRoleKey(): string | undefined {
  return Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
    JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;
}

function usageNumbers(usage: unknown) {
  const value = usage && typeof usage === "object" ? usage as Record<string, unknown> : {};
  return {
    input_tokens: Number(value.input_tokens ?? 0),
    output_tokens: Number(value.output_tokens ?? 0),
    total_tokens: Number(value.total_tokens ?? 0),
  };
}

async function callJsonModel(
  apiKey: string,
  model: string,
  input: string,
  instructions?: string,
) {
  const started = performance.now();
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      ...(instructions ? { instructions } : {}),
      input,
      text: { format: { type: "json_object" } },
    }),
  });
  const body = await response.text();
  const latency_ms = Math.round(performance.now() - started);
  if (!response.ok) {
    throw new Error(`provider_http_${response.status}:${body.slice(0, 500)}`);
  }
  const payload = JSON.parse(body) as Record<string, unknown>;
  return {
    payload,
    raw: outputText(payload),
    parsed: parseJson(outputText(payload)),
    usage: usageNumbers(payload.usage),
    latency_ms,
  };
}

function caseFor(stableCaseId: string): RuntimeSnapshotCase | undefined {
  return runtime.cases.find((item) => item.stable_case_id === stableCaseId);
}

function safeStatus(status: string, idempotent = false, reason_code?: string) {
  return {
    version: PCV1_PRODUCER_VERSION,
    status: status.toLowerCase(),
    idempotent,
    ...(reason_code ? { reason_code } : {}),
  };
}

function safeProviderFailureCode(stage: "writer", error: unknown): string {
  const message = error instanceof Error ? error.message : "";
  const httpStatus = /^provider_http_(\d{3}):/.exec(message)?.[1];
  return httpStatus
    ? `${stage}_provider_http_${httpStatus}`
    : `${stage}_transport_failed`;
}

async function runtimeConfiguration() {
  const selector_fingerprint = await sha256("BYPASSED_FROZEN_HUMAN_APPROVAL");
  const writer_prompt_fingerprint = await sha256(
    buildV4WriterPrompt(
      "You may notice a clear pattern.",
      null,
      runtime.gold_examples,
    ),
  );
  const validator_fingerprint = await sha256("pcv1-producer-validation-v1");
  const repetition_fingerprint = await sha256("pcv1-lightweight-repetition-v1");
  const configuration_fingerprint = await sha256(stable({
    producer_version: PCV1_PRODUCER_VERSION,
    runtime_snapshot_sha256: runtime.sha256,
    selector_fingerprint,
    writer_prompt_fingerprint,
    validator_fingerprint,
    repetition_fingerprint,
  }));
  return {
    selector_fingerprint,
    writer_prompt_fingerprint,
    validator_fingerprint,
    repetition_fingerprint,
    configuration_fingerprint,
  };
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return json({ error: "POST required" }, 405);
  const secret = Deno.env.get("PRODUCTION_CANDIDATE_V1_PRODUCER_SECRET");
  if (
    !secret ||
    request.headers.get("x-production-candidate-v1-producer-secret") !== secret
  ) return json({ error: "producer authentication failed" }, 401);
  if (Deno.env.get("PRODUCTION_CANDIDATE_V1_DEVELOPMENT_ONLY") !== "true") {
    return json({ error: "development-only producer is disabled" }, 403);
  }
  const url = Deno.env.get("SUPABASE_URL");
  const serviceRole = configuredServiceRoleKey();
  if (!isDevelopmentProjectUrl(url)) {
    return json({ error: "producer hard-refuses non-development Supabase project" }, 412);
  }
  if (!serviceRole) return json({ error: "candidate store configuration is incomplete" }, 500);
  const parsedRequest = parseProducerRequest(
    await request.json().catch(() => ({})),
  );
  if (!parsedRequest.value) return json({ error: "invalid invocation", details: parsedRequest.errors }, 400);
  const item = caseFor(parsedRequest.value.stableCaseId);
  if (!item) return json({ error: "stable case is outside frozen producer snapshot" }, 404);
  const expectedHost = `${PCV1_DEVELOPMENT_PROJECT_REF}.supabase.co`;
  if (new URL(url!).hostname !== expectedHost) {
    return json({ error: "producer project-reference guard failed" }, 412);
  }
  if (!runtime.development_only || runtime.version !== "pcv1-development-producer-v1") {
    return json({ error: "frozen producer runtime snapshot is invalid" }, 412);
  }
  const { sha256: recordedRuntimeSha, ...runtimePayload } = runtime;
  if (await sha256(stable(runtimePayload)) !== recordedRuntimeSha) {
    return json({ error: "frozen producer runtime snapshot fingerprint mismatch" }, 412);
  }
  const configuration = await runtimeConfiguration();
  const supabase = createClient(url!, serviceRole);
  const { data: claimRows, error: claimError } = await supabase.rpc(
    "claim_production_candidate_v1_generation",
    {
      p_candidate_version: PCV1_PRODUCER_VERSION,
      p_candidate_date: parsedRequest.value.candidateDate,
      p_western_sign: item.western_sign,
      p_eastern_sign: item.eastern_sign,
      p_source_context: item.source_context,
      p_control_daily_ritual_id: null,
      p_selector_fingerprint: configuration.selector_fingerprint,
      p_writer_prompt_fingerprint: configuration.writer_prompt_fingerprint,
      p_validator_fingerprint: configuration.validator_fingerprint,
      p_repetition_fingerprint: configuration.repetition_fingerprint,
      p_configuration_fingerprint: configuration.configuration_fingerprint,
    },
  );
  const claim = claimRows?.[0] as { id: string; status: string; claimed: boolean } | undefined;
  if (claimError || !claim) return json({ error: "candidate claim failed" }, 500);
  if (!claim.claimed) {
    const { data: existing, error: existingError } = await supabase
      .from("production_candidate_v1_generations")
      .select("status,error_code")
      .eq("id", claim.id)
      .maybeSingle();
    if (existingError || !existing) {
      return json({ error: "idempotent candidate lookup failed" }, 500);
    }
    return json(safeStatus(existing.status, true, existing.error_code ?? undefined));
  }

  const updateTerminal = async (
    status: "BLOCKED" | "WRITER_REJECTED" | "VALIDATOR_REJECTED" | "TRANSPORT_FAILED" | "REPETITION_HOLD",
    trace: Record<string, unknown>,
    errorCode: string,
    totals: { provider_call_count: number; input_tokens: number; output_tokens: number; total_tokens: number; latency_ms: number },
  ) => {
    const { error } = await supabase.from("production_candidate_v1_generations").update({
      status,
      candidate_title: null,
      candidate_read: null,
      selector_eligibility: status === "BLOCKED" ? "INELIGIBLE" : "ELIGIBLE",
      selector_trace: trace.selector_trace ?? null,
      writer_trace: trace.writer_trace ?? null,
      validator_trace: trace.validator_trace ?? null,
      repetition_trace: trace.repetition_trace ?? null,
      validator_rejection_reasons: trace.validator_rejection_reasons ?? [],
      repetition_disposition: trace.repetition_disposition ?? null,
      provider: trace.provider ?? "openai",
      model: trace.model ?? Deno.env.get("OPENAI_IDENTITY_LENS_MODEL") ?? null,
      provider_call_count: totals.provider_call_count,
      input_tokens: totals.input_tokens,
      output_tokens: totals.output_tokens,
      total_tokens: totals.total_tokens,
      latency_ms: totals.latency_ms,
      estimated_cost_usd: null,
      error_code: errorCode,
      lease_expires_at: null,
      completed_at: status === "TRANSPORT_FAILED" ? null : new Date().toISOString(),
    }).eq("id", claim.id);
    if (error) throw new Error(`candidate terminal persistence failed: ${error.message}`);
  };

  const totals = { provider_call_count: 0, input_tokens: 0, output_tokens: 0, total_tokens: 0, latency_ms: 0 };
  const frozenInput = frozenApprovedWriterInput(item);
  const frozenInputFingerprint = frozenInput
    ? await sha256(stable(frozenInput))
    : null;
  const selectorTrace = {
    stage: "BYPASSED_FROZEN_HUMAN_APPROVAL",
    stable_case_id: item.stable_case_id,
    frozen_input_artifact_sha256: runtime.sha256,
    frozen_input_fingerprint: frozenInputFingerprint,
    ...(frozenInput ? {
      selected_evidence: frozenInput.selected_evidence,
      source_calibration_status: frozenInput.source_calibration_status,
    } : {}),
  };
  if (!frozenInput) {
    await updateTerminal("BLOCKED", {
      selector_trace: selectorTrace,
      validator_trace: { blocked_before_writer: true, selector_stage: "BYPASSED_FROZEN_HUMAN_APPROVAL" },
    }, "frozen_human_review_blocked", totals);
    return json(safeStatus("BLOCKED"));
  }
  const writerInput = {
    plain_insight: frozenInput.plain_insight,
    plain_action: frozenInput.plain_action,
  };
  const apiKey = Deno.env.get("OPENAI_API_KEY");
  const model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL");
  if (!apiKey || model !== "gpt-5.6-terra") {
    await updateTerminal("TRANSPORT_FAILED", { selector_trace: selectorTrace }, "provider_configuration_incomplete", totals);
    return json(safeStatus("TRANSPORT_FAILED"), 500);
  }
  let writerCall: Awaited<ReturnType<typeof callJsonModel>>;
  try {
    writerCall = await callJsonModel(
      apiKey,
      model,
      buildV4WriterPrompt(writerInput.plain_insight, writerInput.plain_action, runtime.gold_examples),
    );
    totals.provider_call_count++;
    totals.input_tokens += writerCall.usage.input_tokens;
    totals.output_tokens += writerCall.usage.output_tokens;
    totals.total_tokens += writerCall.usage.total_tokens;
    totals.latency_ms += writerCall.latency_ms;
  } catch (error) {
    const errorCode = safeProviderFailureCode("writer", error);
    await updateTerminal("TRANSPORT_FAILED", {
      selector_trace: selectorTrace,
      writer_trace: { writer_input: writerInput, transport_error: error instanceof Error ? error.message : "transport failure" },
    }, errorCode, totals);
    return json(safeStatus("TRANSPORT_FAILED", false, errorCode), 502);
  }
  const writer = validateWriterOutput(
    writerCall.parsed,
    writerInput.plain_insight,
    writerInput.plain_action,
  );
  const writerTrace = {
    writer_input: writerInput,
    raw_provider_response: writerCall.payload,
    parsed: writerCall.parsed,
    validation: writer,
  };
  if (!writer.lens) {
    await updateTerminal("WRITER_REJECTED", {
      selector_trace: selectorTrace,
      writer_trace: writerTrace,
      validator_trace: { writer_errors: writer.errors, writer_flags: writer.flags },
      validator_rejection_reasons: writer.errors,
    }, "writer_validation_failed", totals);
    return json(safeStatus("WRITER_REJECTED"), 422);
  }
  const { data: existing, error: existingError } = await supabase
    .from("production_candidate_v1_generations")
    .select("candidate_title,candidate_read")
    .eq("candidate_version", PCV1_PRODUCER_VERSION)
    .eq("status", "ACCEPTED")
    .neq("id", claim.id);
  if (existingError) {
    await updateTerminal("TRANSPORT_FAILED", {
      selector_trace: selectorTrace,
      writer_trace: writerTrace,
    }, "repetition_lookup_failed", totals);
    return json(safeStatus("TRANSPORT_FAILED"), 500);
  }
  const repetition = repetitionDisposition(writer.lens, existing ?? []);
  if (repetition.disposition === "HOLD") {
    await updateTerminal("REPETITION_HOLD", {
      selector_trace: selectorTrace,
      writer_trace: writerTrace,
      validator_trace: { writer_errors: [], writer_flags: writer.flags },
      repetition_disposition: "HOLD",
      repetition_trace: repetition,
    }, "lazy_duplicate_hold", totals);
    return json(safeStatus("REPETITION_HOLD"));
  }
  const { error: acceptError } = await supabase.from("production_candidate_v1_generations").update({
    status: "ACCEPTED",
    candidate_title: writer.lens.title,
    candidate_read: writer.lens.read,
    selector_eligibility: "ELIGIBLE",
    selector_trace: selectorTrace,
    writer_trace: writerTrace,
    validator_trace: {
      selector_stage: "BYPASSED_FROZEN_HUMAN_APPROVAL",
      frozen_input_fingerprint: frozenInputFingerprint,
      writer_errors: [],
      writer_flags: writer.flags,
    },
    validator_rejection_reasons: [],
    repetition_disposition: "ALLOW",
    repetition_trace: repetition,
    provider: "openai",
    model,
    provider_call_count: totals.provider_call_count,
    input_tokens: totals.input_tokens,
    output_tokens: totals.output_tokens,
    total_tokens: totals.total_tokens,
    latency_ms: totals.latency_ms,
    estimated_cost_usd: null,
    error_code: null,
    lease_expires_at: null,
    completed_at: new Date().toISOString(),
  }).eq("id", claim.id);
  if (acceptError) return json({ error: "accepted candidate persistence failed" }, 500);
  return json({ version: PCV1_PRODUCER_VERSION, status: "accepted", candidate_id: claim.id });
});
