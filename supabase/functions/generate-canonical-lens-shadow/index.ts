import { createClient } from "npm:@supabase/supabase-js@2";
import snapshot from "../_shared/canonical-lens-v3-2/runtime_snapshot.json" with {
  type: "json",
};
import {
  cohortEligible,
  FROZEN_VERSION,
  identityKey,
  parseAllowlist,
  type ShadowMode,
  validateRequest,
} from "../_shared/canonical-lens-v3-2/shadow_contract.ts";

const fields = [
  "title",
  "intro",
  "pull_quote",
  "deeper_read",
  "watch_for",
  "move",
] as const;
type Field = typeof fields[number];
type Lens = Record<Field, string>;
const snapshotHash =
  "bf88e66dd8ebfb5977e6223edd73bf12574317c7248c5e553380f11a14d32d4d";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
const text = (value: unknown) => typeof value === "string" ? value.trim() : "";
const normalize = (value: string) =>
  value.toLowerCase().replace(/[^a-z0-9\s]/g, " ").replace(/\s+/g, " ").trim();
const words = (value: string) =>
  value.trim().split(/\s+/).filter(Boolean).length;
const sentences = (value: string) =>
  value.split(/[.!?]+/).filter((part) => part.trim()).length;

function validateLens(candidate: unknown): { lens?: Lens; errors: string[] } {
  if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
    return { errors: ["response was not an object"] };
  }
  const row = candidate as Record<string, unknown>;
  if (
    JSON.stringify(Object.keys(row).sort()) !==
      JSON.stringify([...fields].sort())
  ) return { errors: ["response must contain exactly the six Lens fields"] };
  if (fields.some((field) => typeof row[field] !== "string")) {
    return { errors: ["all Lens fields must be strings"] };
  }
  const lens = row as Lens;
  const errors: string[] = [];
  if (
    words(lens.title) < 2 || words(lens.title) > 4 || /[.!?]$/.test(lens.title)
  ) errors.push("title must be 2-4 words without terminal punctuation");
  for (const field of ["intro", "pull_quote"] as const) {
    if (
      sentences(lens[field]) !== 1 || words(lens[field]) < 12 ||
      words(lens[field]) > 22 || !/^[^.!?]*\.$/.test(lens[field])
    ) {
      errors.push(
        `${field} must be one sentence of 12-22 words with one final period`,
      );
    }
  }
  for (const field of ["watch_for", "move"] as const) {
    if (
      sentences(lens[field]) !== 1 || words(lens[field]) < 10 ||
      words(lens[field]) > 24 || !/^[^.!?]*\.$/.test(lens[field])
    ) {
      errors.push(
        `${field} must be one sentence of 10-24 words with one final period`,
      );
    }
  }
  if (
    sentences(lens.deeper_read) < 1 || sentences(lens.deeper_read) > 2 ||
    words(lens.deeper_read) < 30 || words(lens.deeper_read) > 60
  ) errors.push("deeper_read must be 1-2 sentences of 30-60 words");
  if (lens.watch_for === lens.move) {
    errors.push("watch_for and move must differ");
  }
  if (
    [lens.pull_quote, lens.watch_for, lens.move].some((value) =>
      /[;:\"“”]/.test(value)
    )
  ) {
    errors.push(
      "short fields must not contain dialogue punctuation, a colon, or a semicolon",
    );
  }
  return errors.length ? { errors } : { lens, errors };
}

function failedFields(errors: string[]): Field[] {
  const direct = fields.filter((field) =>
    errors.some((error) => error.startsWith(field))
  );
  return direct.length ? direct : [...fields];
}

function writingPrompt(
  row: any,
  existing?: Partial<Lens>,
  errors: string[] = [],
  failed: Field[] = [...fields],
) {
  const focused = {
    dailyInput: row.context.scenario,
    selectedCanonicalContext: row.context.selected,
    reasoningPlan: row.reasoning,
  };
  const contract =
    `Return exactly title, intro, pull_quote, deeper_read, watch_for, and move.\n- title: 2–4 words; no terminal punctuation.\n- intro and pull_quote: one sentence, 12–22 words, one final period.\n- deeper_read: one or two sentences, 30–60 words total.\n- watch_for and move: one sentence, 10–24 words, one final period; move is imperative and distinct from watch_for.`;
  if (!existing) {
    return `${snapshot.prompt}\n\nFocused input:\n${
      JSON.stringify(focused, null, 2)
    }\n\nEditorial brief (form only; it adds no identity claims):\n${
      JSON.stringify(row.editorialBrief, null, 2)
    }\n\nOutput contract:\n${contract}`;
  }
  return `${snapshot.prompt}\n\nThis is a surgical validation repair. Return a JSON patch containing exactly these keys:\n${
    JSON.stringify(failed)
  }\n\nFocused input (do not broaden it):\n${
    JSON.stringify(focused, null, 2)
  }\n\nCurrent complete Lens (valid fields must remain unchanged outside this patch):\n${
    JSON.stringify(existing, null, 2)
  }\n\nValidation errors:\n${
    JSON.stringify(errors)
  }\n\nField contract:\n${contract}`;
}

async function callModel(apiKey: string, model: string, prompt: string) {
  const started = performance.now();
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      instructions: snapshot.prompt,
      input: prompt,
      text: { format: { type: "json_object" } },
    }),
  });
  const latencyMs = Math.round(performance.now() - started);
  const raw = await response.text();
  if (!response.ok) {
    throw new Error(`provider status ${response.status}: ${raw.slice(0, 500)}`);
  }
  const payload = JSON.parse(raw);
  const output =
    payload.output?.flatMap((item: any) => item.content ?? []).find((
      part: any,
    ) => part.type === "output_text")?.text ?? "";
  return { raw: output, usage: payload.usage ?? {}, latencyMs };
}

function usageNumbers(usage: Record<string, unknown>) {
  const details = (usage.input_tokens_details ?? {}) as Record<string, unknown>;
  const outputDetails = (usage.output_tokens_details ?? {}) as Record<
    string,
    unknown
  >;
  return {
    input_tokens: Number(usage.input_tokens ?? 0),
    cached_input_tokens: Number(details.cached_tokens ?? 0),
    output_tokens: Number(usage.output_tokens ?? 0),
    reasoning_tokens: Number(outputDetails.reasoning_tokens ?? 0),
    total_tokens: Number(usage.total_tokens ?? 0),
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "POST required" }, 405);
  const adminSecret = Deno.env.get("CANONICAL_LENS_V3_2_SHADOW_ADMIN_SECRET");
  if (
    !adminSecret ||
    req.headers.get("x-canonical-shadow-admin-secret") !== adminSecret
  ) return json({ error: "admin authentication failed" }, 401);
  const body = await req.json().catch(() => null);
  const parsed = validateRequest(body ?? {});
  if (!parsed.value) {
    return json({ error: "invalid invocation", details: parsed.errors }, 400);
  }
  const { generationDate, western, eastern, scenarioId, productionId, dryRun } =
    parsed.value;
  const mode = (Deno.env.get("CANONICAL_LENS_V3_2_SHADOW_MODE") ??
    "disabled") as ShadowMode;
  const eligible = cohortEligible({
    enabled: Deno.env.get("CANONICAL_LENS_V3_2_SHADOW_ENABLED") === "true",
    mode,
    allowlist: parseAllowlist(
      Deno.env.get("CANONICAL_LENS_V3_2_SHADOW_ALLOWLIST"),
    ),
    samplePercent: Number(
      Deno.env.get("CANONICAL_LENS_V3_2_SHADOW_SAMPLE_PERCENT") ?? 0,
    ),
    key: identityKey(western, eastern),
  });
  if (!eligible) {
    return json({
      error:
        "shadow mode is disabled or this identity is outside the configured cohort",
    }, 403);
  }
  if (
    Deno.env.get("CANONICAL_LENS_V3_2_SOURCE_SHA256") !==
      snapshot.sourceSha256 ||
    Deno.env.get("CANONICAL_LENS_V3_2_RUNTIME_SHA256") !== snapshotHash
  ) return json({ error: "frozen v3.2 fingerprint verification failed" }, 412);
  const row = (snapshot.contexts as any[]).find((candidate) =>
    candidate.identity.toLowerCase() ===
      `${western} × ${eastern}`.toLowerCase() &&
    candidate.scenarioId === scenarioId
  );
  if (!row) {
    return json({
      error:
        "frozen focused context missing for explicit identity and scenario",
    }, 412);
  }
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
    JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;
  const apiKey = Deno.env.get("OPENAI_API_KEY");
  const model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL");
  if (!url || !key || model !== "gpt-5.6-terra") {
    return json({
      error: "shadow provider or database configuration is incomplete",
    }, 500);
  }
  const supabase = createClient(url, key);
  const { data: production, error: productionError } = await supabase.from(
    "daily_rituals",
  ).select("id,title,intro,pull_quote,deeper_read,watch_for,move").eq(
    "ritual_date",
    generationDate,
  ).ilike("western_sign", western).ilike("eastern_sign", eastern).maybeSingle();
  if (
    productionError || !production ||
    (productionId && String(production.id) !== productionId)
  ) {
    return json({
      error: "matching production daily_rituals row was not found",
      details: productionError?.message,
    }, 404);
  }
  const base = {
    frozen_version: FROZEN_VERSION,
    generation_date: generationDate,
    western_sign: western,
    eastern_sign: eastern,
    identity_key: identityKey(western, eastern),
    scenario_id: scenarioId,
    arena: row.arena,
    production_daily_ritual_id: String(production.id),
    source_sha256: snapshot.sourceSha256,
    config_fingerprint: snapshotHash,
    status: "running",
    lease_expires_at: new Date(Date.now() + 10 * 60_000).toISOString(),
  };
  if (dryRun) {
    return json({
      dry_run: true,
      eligible: true,
      production_daily_ritual_id: production.id,
      scenario_id: scenarioId,
      identity: `${western} × ${eastern}`,
      arena: row.arena,
      frozen_version: FROZEN_VERSION,
    });
  }
  if (!apiKey) {
    return json({ error: "shadow provider configuration is incomplete" }, 500);
  }
  const { data: claimRows, error: claimError } = await supabase.rpc(
    "claim_canonical_lens_shadow_generation",
    {
      p_frozen_version: base.frozen_version,
      p_generation_date: base.generation_date,
      p_western_sign: base.western_sign,
      p_eastern_sign: base.eastern_sign,
      p_identity_key: base.identity_key,
      p_scenario_id: base.scenario_id,
      p_arena: base.arena,
      p_production_daily_ritual_id: base.production_daily_ritual_id,
      p_source_sha256: base.source_sha256,
      p_config_fingerprint: base.config_fingerprint,
    },
  );
  const claimed = claimRows?.[0] as {
    id: string;
    status: string;
    claimed: boolean;
  } | undefined;
  if (claimError || !claimed) {
    return json({
      error: "unable to claim shadow generation",
      details: claimError?.message,
    }, 500);
  }
  if (!claimed.claimed) {
    return json({
      idempotent: true,
      shadow_generation_id: claimed.id,
      status: claimed.status,
      production_daily_ritual_id: production.id,
    });
  }
  const attemptLog: unknown[] = [];
  let current: Partial<Lens> = {};
  let errors: string[] = [];
  let totalLatency = 0;
  let totals = {
    input_tokens: 0,
    cached_input_tokens: 0,
    output_tokens: 0,
    reasoning_tokens: 0,
    total_tokens: 0,
  };
  try {
    for (let attempt = 0; attempt <= 2; attempt++) {
      const needed = attempt ? failedFields(errors) : [...fields];
      const response = await callModel(
        apiKey,
        model,
        writingPrompt(row, attempt ? current : undefined, errors, needed),
      );
      totalLatency += response.latencyMs;
      const usage = usageNumbers(response.usage);
      for (const field of Object.keys(totals) as Array<keyof typeof totals>) {
        totals[field] += usage[field];
      }
      let parsedResponse: Record<string, unknown> | null = null;
      try {
        parsedResponse = JSON.parse(response.raw);
      } catch { /* validation records malformed JSON */ }
      if (
        attempt && parsedResponse &&
        JSON.stringify(Object.keys(parsedResponse).sort()) ===
          JSON.stringify([...needed].sort())
      ) current = { ...current, ...parsedResponse as Partial<Lens> };
      if (!attempt && parsedResponse) current = parsedResponse as Partial<Lens>;
      const validation = validateLens(current);
      errors = validation.errors;
      attemptLog.push({
        attempt,
        requested_fields: needed,
        validation_errors: errors,
        latency_ms: response.latencyMs,
        usage,
      });
      if (validation.lens) {
        await supabase.from("canonical_lens_shadow_generations").update({
          status: "accepted",
          provider: "openai",
          model,
          lens: validation.lens,
          provider_call_count: attempt + 1,
          schema_retry_count: attempt,
          editorial_title_retry_count: 0,
          ...totals,
          latency_ms: totalLatency,
          attempt_log: attemptLog,
          validation_errors: [],
          completed_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        }).eq("id", claimed.id);
        return json({
          shadow_generation_id: claimed.id,
          status: "accepted",
          retries: attempt,
          tokens: totals,
          latency_ms: totalLatency,
          production_daily_ritual_id: production.id,
        });
      }
    }
    await supabase.from("canonical_lens_shadow_generations").update({
      status: "rejected",
      provider: "openai",
      model,
      provider_call_count: 3,
      schema_retry_count: 2,
      ...totals,
      latency_ms: totalLatency,
      attempt_log: attemptLog,
      validation_errors: errors,
      completed_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }).eq("id", claimed.id);
    return json({
      shadow_generation_id: claimed.id,
      status: "rejected",
      validation_errors: errors,
    }, 422);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    await supabase.from("canonical_lens_shadow_generations").update({
      status: "failed",
      provider: "openai",
      model,
      ...totals,
      latency_ms: totalLatency,
      attempt_log: attemptLog,
      error_code: "provider_or_runtime_failure",
      error_message: message.slice(0, 1000),
      completed_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }).eq("id", claimed.id);
    return json({ shadow_generation_id: claimed.id, status: "failed" }, 502);
  }
});
