import { createClient } from "npm:@supabase/supabase-js@2";
import {
  assertTransition,
  CANONICAL_IDENTITY_PAIRS,
  CONTENT_ENVIRONMENTS,
  requireServerSecret,
} from "../_shared/daily-ritual-batches/batch_contract.ts";
import {
  buildPublicationValidationReport,
  validatePublicationCandidate,
} from "../_shared/daily-ritual-batches/publication_validation.ts";
import {
  runProductionMidnightScheduler as runBetaMidnightScheduler,
  ScheduledBatch,
} from "../_shared/daily-ritual-batches/midnight_scheduler.ts";
import {
  runLegacyProductionMidnightScheduler,
} from "../_shared/daily-ritual-batches/production_midnight_scheduler_legacy.ts";
import {
  dailyRitualAdminHeader,
  requireConfiguredDailyRitualAdminSecret,
} from "../_shared/daily-ritual-batches/admin_auth.ts";
import { validateSkyLedSafety } from "../_shared/todays-lens-sky-led-production-candidate-v1.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-daily-ritual-admin-secret",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let configuredAdminSecret: string;
  try {
    configuredAdminSecret = requireConfiguredDailyRitualAdminSecret(
      Deno.env.get("DAILY_RITUAL_BATCH_ADMIN_SECRET"),
    );
  } catch {
    log("server_configuration_missing", {
      variable: "DAILY_RITUAL_BATCH_ADMIN_SECRET",
    });
    return json({
      error: "Missing server configuration",
      missing_configuration: ["DAILY_RITUAL_BATCH_ADMIN_SECRET"],
    }, 500);
  }

  try {
    requireServerSecret(req, configuredAdminSecret);
  } catch {
    log("authorization_rejected", {
      method: req.method,
      path: new URL(req.url).pathname,
      reason: "invalid_or_missing_admin_secret",
    });
    return json({ error: "Unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
    JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;
  if (!supabaseUrl || !serviceRole) {
    return json({ error: "Missing server configuration" }, 500);
  }

  const body = await req.json().catch(() => null);
  const action = typeof body?.action === "string" ? body.action : "";
  const supabase = createClient(supabaseUrl, serviceRole);

  try {
    switch (action) {
      case "createBatch": {
        if (!CONTENT_ENVIRONMENTS.includes(body.environment)) {
          throw new Error("Invalid environment");
        }
        const { data, error } = await supabase.from("daily_ritual_batches")
          .insert({
            ritual_date: requiredDate(body.ritual_date),
            environment: body.environment,
            generator_version: requiredString(
              body.generator_version,
              "generator_version",
            ),
            validator_version: requiredString(
              body.validator_version,
              "validator_version",
            ),
            prompt_version: requiredString(
              body.prompt_version,
              "prompt_version",
            ),
            model_identifier: requiredString(
              body.model_identifier,
              "model_identifier",
            ),
          }).select("*").single();
        if (error) throw error;
        log("batch_created", data);
        return json({ batch: data }, 201);
      }
      case "createCorrectiveBatch":
        return await createCorrectiveBatch(supabase, body);
      case "markGenerating":
        return await transition(supabase, body.batch_id, "GENERATING", {
          started_at: new Date().toISOString(),
        });
      case "markValidating":
        return await transition(supabase, body.batch_id, "VALIDATING");
      case "recordGeneratedResult":
        return await recordGeneratedResult(supabase, body);
      case "recordReviewedSkyLedResult":
        return await recordReviewedSkyLedResult(supabase, body);
      case "repairReviewedSkyLedProvenance":
        return await repairReviewedSkyLedProvenance(supabase, body);
      case "repairMissingSafetyValidationMetadata":
        return await repairMissingSafetyValidationMetadata(supabase, body.batch_id);
      case "listBatchRows":
        return await listBatchRows(supabase, body.batch_id);
      case "recordFailedResult":
        return await recordFailedResult(supabase, body);
      case "markReady":
        return await validateAndReady(supabase, body.batch_id);
      case "failBatch":
        return await failBatch(
          supabase,
          body.batch_id,
          requiredString(body.failure_reason, "failure_reason"),
        );
      case "publishBatch": {
        const batch = await publishBatch(supabase, body.batch_id);
        if (batch.supersedes_batch_id) {
          log("batch_supersession", {
            batch_id: batch.id,
            supersedes_batch_id: batch.supersedes_batch_id,
            environment: batch.environment,
            ritual_date: batch.ritual_date,
          });
        }
        return json({ batch });
      }
      case "rollbackPublishedBatch": {
        const { data, error } = await supabase.rpc(
          "rollback_daily_ritual_batch",
          {
            p_environment: body.environment,
            p_ritual_date: requiredDate(body.ritual_date),
            p_target_batch_id: body.target_batch_id,
          },
        );
        if (error) throw error;
        log("batch_rollback", data);
        return json({ batch: data });
      }
      case "withdrawFirstPublishedBatch": {
        const actor = requiredString(body.actor, "actor");
        const reason = requiredString(body.reason, "reason");
        const { data, error } = await supabase.rpc(
          "withdraw_first_daily_ritual_publication",
          {
            p_environment: body.environment,
            p_ritual_date: requiredDate(body.ritual_date),
            p_withdrawn_batch_id: body.withdrawn_batch_id,
            p_actor: actor,
            p_reason: reason,
          },
        );
        if (error) throw error;
        log("first_publication_withdrawn", {
          environment: body.environment,
          ritual_date: body.ritual_date,
          actor,
          reason,
          withdrawn_batch_id: body.withdrawn_batch_id,
          restored_batch_id: data?.restored_resolver_target?.id,
          rollback_event_id: data?.event?.id,
          idempotent: data?.idempotent === true,
        });
        return json({ rollback: data });
      }
      case "preflightFirstPublicationWithdrawal": {
        const { data, error } = await supabase.rpc(
          "preflight_first_daily_ritual_publication_withdrawal",
          {
            p_environment: body.environment,
            p_ritual_date: requiredDate(body.ritual_date),
            p_expected_restored_batch_id: body.expected_restored_batch_id,
          },
        );
        if (error) throw error;
        log("first_publication_withdrawal_preflight", {
          environment: body.environment,
          ritual_date: body.ritual_date,
          restored_batch_id: data?.restored_resolver_target?.id,
          ready: data?.ready === true,
        });
        return json({ preflight: data });
      }
      case "batchStatus":
      case "getBatchStatus":
        return await getBatchStatus(supabase, body.batch_id);
      case "listMissingIdentityPairs":
        return await listMissingIdentityPairs(supabase, body.batch_id);
      case "publishedAvailability":
        return await publishedAvailability(
          supabase,
          body.environment,
          requiredDate(body.ritual_date),
        );
      case "inFlightCorrectiveBatch":
        return await inFlightCorrectiveBatch(
          supabase,
          body.environment,
          requiredDate(body.ritual_date),
        );
      case "runScheduledProduction":
        return await runScheduledProduction({
          supabase,
          supabaseUrl,
          serviceRole,
          adminSecret: configuredAdminSecret,
          now: new Date(),
        });
      case "runScheduledBeta":
        return await runScheduledBeta({
          supabase,
          supabaseUrl,
          serviceRole,
          adminSecret: configuredAdminSecret,
          now: new Date(),
        });
      default:
        return json({ error: "Unknown action" }, 400);
    }
  } catch (error) {
    const message = error instanceof Error
      ? error.message
      : error && typeof error === "object" &&
          typeof (error as Record<string, unknown>).message === "string"
      ? (error as Record<string, unknown>).message as string
      : String(error);
    log("batch_operation_failed", {
      action,
      batch_id: body?.batch_id,
      message,
    });
    return json({ error: message }, 409);
  }
});

async function createCorrectiveBatch(supabase: any, body: any) {
  const { data, error } = await supabase.rpc(
    "create_daily_ritual_corrective_batch",
    {
      p_ritual_date: requiredDate(body.ritual_date),
      p_environment: requiredString(body.environment, "environment"),
      p_supersedes_batch_id: requiredString(
        body.supersedes_batch_id,
        "supersedes_batch_id",
      ),
      p_reason: requiredString(body.reason, "reason"),
      p_generator_version: requiredString(body.generator_version, "generator_version"),
      p_validator_version: requiredString(body.validator_version, "validator_version"),
      p_prompt_version: requiredString(body.prompt_version, "prompt_version"),
      p_model_identifier: requiredString(body.model_identifier, "model_identifier"),
    },
  ).single();
  if (error) throw error;
  log("corrective_batch_created", {
    batch_id: data.id,
    ritual_date: data.ritual_date,
    environment: data.environment,
    supersedes_batch_id: data.supersedes_batch_id,
  });
  return json({ batch: data }, 201);
}

async function runScheduledBeta(args: {
  supabase: any;
  supabaseUrl: string;
  serviceRole: string;
  adminSecret: string;
  now: Date;
}) {
  const { data: enabled, error: flagError } = await args.supabase.rpc(
    "daily_ritual_beta_sky_led_enabled",
  );
  if (flagError) throw flagError;
  if (enabled !== true) {
    return json({ result: "BETA_SKY_LED_DISABLED", batch: null });
  }
  const result = await runBetaMidnightScheduler({
    now: args.now,
    dependencies: {
      resolveBatch: async (contentDate) => {
        const { data, error } = await args.supabase.rpc(
          "resolve_daily_ritual_beta_batch",
          { p_ritual_date: contentDate },
        ).single();
        if (error) throw error;
        return data as ScheduledBatch;
      },
      markGenerating: async (batchId) =>
        await responseBatch(
          await transition(args.supabase, batchId, "GENERATING", {
            started_at: new Date().toISOString(),
          }),
        ),
      generateWesternSign: async (
        { batchId, contentDate, westernSign, generatorVersion },
      ) => {
        let response: Response | null = null;
        let payload: Record<string, unknown> = {};
        for (let attempt = 1; attempt <= 3; attempt++) {
          try {
            response = await fetch(
              `${args.supabaseUrl}/functions/v1/generate-daily-rituals`,
              {
                method: "POST",
                headers: {
                  Authorization: `Bearer ${args.serviceRole}`,
                  apikey: args.serviceRole,
                  "Content-Type": "application/json",
                  ...dailyRitualAdminHeader(args.adminSecret),
                },
                body: JSON.stringify({
                  batch_id: batchId,
                  ritual_date: contentDate,
                  western_sign: westernSign,
                  sky_led_production_candidate_v1: true,
                }),
              },
            );
            payload = await response.json().catch(() => ({})) as Record<
              string,
              unknown
            >;
            if (
              response.ok ||
              ![408, 409, 429, 500, 502, 503, 504].includes(response.status)
            ) break;
          } catch (error) {
            if (attempt === 3) throw error;
          }
          if (attempt < 3) {
            await new Promise((resolve) =>
              setTimeout(resolve, 500 * 2 ** (attempt - 1))
            );
          }
        }
        if (!response) {
          throw new Error(
            `Generation chunk ${westernSign} returned no response`,
          );
        }
        if (!response.ok) {
          throw new Error(
            `Generation chunk ${westernSign} failed (${response.status}): ${
              String(payload.error ?? "unknown error")
            }`,
          );
        }
        return {
          failed: Number(payload.count_failed ?? payload.failed ?? 0),
        };
      },
      completedWesternSigns: async (batchId) => {
        const { data, error } = await args.supabase.from(
          "daily_ritual_batch_rows",
        )
          .select("western_sign").eq("batch_id", batchId);
        if (error) throw error;
        const counts = new Map<string, number>();
        for (const row of data ?? []) {
          const sign = String(row.western_sign ?? "");
          counts.set(sign, (counts.get(sign) ?? 0) + 1);
        }
        return [...counts].filter(([, count]) => count === 12).map(([sign]) =>
          sign
        );
      },
      acquireGenerationLease: async (batchId) => {
        const { data, error } = await args.supabase.rpc(
          "claim_daily_ritual_beta_generation_lease",
          { p_batch_id: batchId },
        );
        if (error) throw error;
        return typeof data === "string" ? data : null;
      },
      releaseGenerationLease: async (batchId, leaseToken) => {
        const { error } = await args.supabase.rpc(
          "release_daily_ritual_beta_generation_lease",
          { p_batch_id: batchId, p_lease_token: leaseToken },
        );
        if (error) throw error;
      },
      missingIdentityCount: async (batchId) => {
        const { count, error } = await args.supabase.from(
          "daily_ritual_batch_rows",
        ).select("id", { count: "exact", head: true }).eq(
          "batch_id",
          batchId,
        );
        if (error) throw error;
        return Math.max(0, 144 - Number(count ?? 0));
      },
      markReady: async (batchId) =>
        await responseBatch(await validateAndReady(args.supabase, batchId)),
      publish: async (batchId) => await publishBatch(args.supabase, batchId),
      recordRetryableFailure: async (batchId, failureReason) => {
        const { data, error } = await args.supabase.from(
          "daily_ritual_batches",
        ).update({ failure_reason: failureReason }).eq("id", batchId).select(
          "*",
        ).single();
        if (error) throw error;
        log("batch_retryable_failure_persisted", {
          batch_id: batchId,
          status: data.status,
          failure_reason: failureReason,
        });
        return data as ScheduledBatch;
      },
      markFailed: async (batchId, failureReason) =>
        await responseBatch(
          await failBatch(args.supabase, batchId, failureReason),
        ),
    },
  });
  log("scheduled_beta_result", result);
  return json(
    result,
    ["GENERATION_IN_PROGRESS", "GENERATION_RETRYABLE_FAILURE"]
        .includes(result.result)
      ? 202
      : 200,
  );
}

async function runScheduledProduction(args: {
  supabase: any;
  supabaseUrl: string;
  serviceRole: string;
  adminSecret: string;
  now: Date;
}) {
  const result = await runLegacyProductionMidnightScheduler({
    now: args.now,
    dependencies: {
      resolveBatch: async (contentDate) => {
        const { data, error } = await args.supabase.rpc(
          "resolve_daily_ritual_production_batch",
          { p_ritual_date: contentDate },
        ).single();
        if (error) throw error;
        return data as ScheduledBatch;
      },
      markGenerating: async (batchId) =>
        await responseBatch(
          await transition(args.supabase, batchId, "GENERATING", {
            started_at: new Date().toISOString(),
          }),
        ),
      generateWesternSign: async ({ batchId, contentDate, westernSign }) => {
        const response = await fetch(
          `${args.supabaseUrl}/functions/v1/generate-daily-rituals`,
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${args.serviceRole}`,
              apikey: args.serviceRole,
              "Content-Type": "application/json",
              ...dailyRitualAdminHeader(args.adminSecret),
            },
            body: JSON.stringify({
              batch_id: batchId,
              ritual_date: contentDate,
              western_sign: westernSign,
            }),
          },
        );
        const payload = await response.json().catch(() => ({})) as Record<
          string,
          unknown
        >;
        if (!response.ok) {
          throw new Error(
            `Generation chunk ${westernSign} failed (${response.status}): ${
              String(payload.error ?? "unknown error")
            }`,
          );
        }
        return { failed: Number(payload.count_failed ?? payload.failed ?? 0) };
      },
      missingIdentityCount: async (batchId) => {
        const { count, error } = await args.supabase.from(
          "daily_ritual_batch_rows",
        ).select("id", { count: "exact", head: true }).eq("batch_id", batchId);
        if (error) throw error;
        return Math.max(0, 144 - Number(count ?? 0));
      },
      markReady: async (batchId) =>
        await responseBatch(await validateAndReady(args.supabase, batchId)),
      publish: async (batchId) => await publishBatch(args.supabase, batchId),
      recordRetryableFailure: async (batchId, failureReason) => {
        const { data, error } = await args.supabase.from("daily_ritual_batches")
          .update({ failure_reason: failureReason }).eq("id", batchId)
          .select("*").single();
        if (error) throw error;
        return data as ScheduledBatch;
      },
    },
  });
  log("scheduled_production_result", result);
  return json(result, result.result === "GENERATION_INCOMPLETE" ? 202 : 200);
}

async function responseBatch(response: Response): Promise<ScheduledBatch> {
  const payload = await response.json() as Record<string, unknown>;
  if (!response.ok || !payload.batch) {
    const publication = payload.publication &&
        typeof payload.publication === "object"
      ? payload.publication as Record<string, unknown>
      : null;
    const validation = payload.validation &&
        typeof payload.validation === "object"
      ? payload.validation as Record<string, unknown>
      : null;
    const evidence = [
      ...(Array.isArray(publication?.errors) ? publication.errors : []),
      ...(Array.isArray(validation?.errors) ? validation.errors : []),
    ].map(String);
    throw new Error(
      String(
        payload.error ??
          (evidence.length
            ? `Validation rejected: ${evidence.join(",")}`
            : null) ??
          `Batch transition failed with status ${response.status}`,
      ),
    );
  }
  return payload.batch as ScheduledBatch;
}

async function publishBatch(
  supabase: any,
  batchId: string,
): Promise<ScheduledBatch> {
  await requirePublicationValidation(supabase, batchId);
  const batch = await fetchBatch(supabase, batchId);
  const publisher = batch.environment === "beta" &&
      batch.generator_version === "todays-lens-sky-led-production-candidate-v1"
    ? "publish_daily_ritual_beta_batch"
    : batch.environment === "production" &&
        batch.generator_version === "todays-lens-sky-led-production-v1"
    ? "publish_daily_ritual_sky_led_production_batch"
    : "publish_daily_ritual_batch";
  const { data, error } = await supabase.rpc(
    publisher,
    { p_batch_id: batchId },
  );
  if (error) throw error;
  log("batch_published", data);
  return data as ScheduledBatch;
}

async function transition(
  supabase: any,
  batchId: string,
  nextStatus: string,
  fields: Record<string, unknown> = {},
) {
  const batch = await fetchBatch(supabase, batchId);
  assertTransition(batch.status, nextStatus as any);
  const { data, error } = await supabase.from("daily_ritual_batches")
    .update({ status: nextStatus, ...fields }).eq("id", batchId).select("*")
    .single();
  if (error) throw error;
  log(`batch_${nextStatus.toLowerCase()}`, data);
  return json({ batch: data });
}

async function validateAndReady(
  supabase: any,
  batchId: string,
) {
  const batch = await fetchBatch(supabase, batchId);
  if (batch.status === "GENERATING") {
    await transitionRecord(supabase, batch, "VALIDATING");
  } else if (batch.status !== "VALIDATING") {
    throw new Error("Batch must be GENERATING or VALIDATING");
  }

  const validationRpc = validationRpcForBatch(batch);
  const { data: validation, error } = await supabase
    .rpc(validationRpc, { p_batch_id: batchId }).single();
  if (error) throw error;
  const { data: rows, error: rowsError } = await supabase.from(
    "daily_ritual_batch_rows",
  )
    .select("*").eq("batch_id", batch.id);
  if (rowsError) throw rowsError;
  const report = await buildPublicationValidationReport(batch, rows ?? []);
  const publication = await validatePublicationCandidate(
    batch,
    rows ?? [],
    report,
  );

  await supabase.from("daily_ritual_batches").update({
    generated_identity_count: validation.row_count,
    validated_identity_count: validation.valid_row_count,
    failed_identity_count: validation.row_count - validation.valid_row_count,
  }).eq("id", batchId);

  log("batch_validation", { batch_id: batchId, ...validation });
  if (!validation.valid || !publication.valid) {
    return json({ ready: false, validation, publication }, 422);
  }
  return await transition(supabase, batchId, "READY", {
    completed_at: new Date().toISOString(),
    publication_validation_report: report,
    publication_validation_fingerprint: publication.rows_fingerprint,
    publication_validated_at: new Date().toISOString(),
    failure_reason: null,
  });
}

async function requirePublicationValidation(supabase: any, batchId: string) {
  const batch = await fetchBatch(supabase, batchId);
  const publication = await validatePublicationRows(
    supabase,
    batch,
    batch.publication_validation_report,
  );
  if (
    !publication.valid ||
    batch.publication_validation_fingerprint !== publication.rows_fingerprint
  ) {
    throw new Error(
      `Publication validation failed: ${publication.errors.join(",")}`,
    );
  }
}

async function validatePublicationRows(
  supabase: any,
  batch: any,
  report: unknown,
) {
  const { data: rows, error } = await supabase.from("daily_ritual_batch_rows")
    .select("*").eq("batch_id", batch.id);
  if (error) throw error;
  const publication = await validatePublicationCandidate(
    batch,
    rows ?? [],
    report && typeof report === "object"
      ? report as Record<string, unknown>
      : null,
  );
  log("publication_validation", { batch_id: batch.id, ...publication });
  return publication;
}

async function recordGeneratedResult(supabase: any, body: any) {
  const batch = await fetchBatch(supabase, body.batch_id);
  if (batch.status !== "GENERATING") {
    throw new Error("Batch must be GENERATING");
  }
  if (
    batch.environment !== "development" ||
    body?.generation_metadata?.source !== "controlled-development-fixture"
  ) {
    throw new Error("Provider-free fixture ingestion is Development-only");
  }
  const content = body.content ?? {};
  const row = {
    batch_id: batch.id,
    ritual_date: batch.ritual_date,
    environment: batch.environment,
    western_sign: requiredString(body.western_sign, "western_sign"),
    eastern_sign: requiredString(body.eastern_sign, "eastern_sign"),
    title: requiredString(content.title, "title"),
    ritual_text: requiredString(content.ritual_text, "ritual_text"),
    action_text: typeof content.action_text === "string"
      ? content.action_text
      : null,
    intro: requiredString(content.intro, "intro"),
    pull_quote: requiredString(content.pull_quote, "pull_quote"),
    deeper_read: requiredString(content.deeper_read, "deeper_read"),
    watch_for: requiredString(content.watch_for, "watch_for"),
    move: requiredString(content.move, "move"),
    validation_status: body.validation_status === "VALID" ? "VALID" : "INVALID",
    validation_errors: Array.isArray(body.validation_errors)
      ? body.validation_errors
      : [],
    generation_attempt: Number.isInteger(body.generation_attempt)
      ? body.generation_attempt
      : 1,
    generation_metadata:
      typeof body.generation_metadata === "object" && body.generation_metadata
        ? body.generation_metadata
        : {},
  };
  const { data, error } = await supabase.from("daily_ritual_batch_rows")
    .insert(row).select("*").single();
  if (error) throw error;
  log("generated_result_recorded", {
    batch_id: batch.id,
    western_sign: row.western_sign,
    eastern_sign: row.eastern_sign,
  });
  return json({ row: data }, 201);
}

/**
 * Controlled import for an explicitly approved, locally reviewed titleless
 * Sky-led corpus. It remains inside the normal batch state machine and can
 * only target a production Sky-led corrective batch while it is GENERATING.
 */
async function recordReviewedSkyLedResult(supabase: any, body: any) {
  const batch = await fetchBatch(supabase, body.batch_id);
  if (batch.status !== "GENERATING") throw new Error("Batch must be GENERATING");
  if (batch.environment !== "production" || batch.generator_version !== "todays-lens-sky-led-production-v1" || batch.is_corrective !== true) {
    throw new Error("Reviewed Sky-led import requires a corrective production Sky-led batch");
  }
  const read = requiredString(body?.content?.read, "content.read");
  const western = requiredString(body.western_sign, "western_sign");
  const eastern = requiredString(body.eastern_sign, "eastern_sign");
  const metadata = body.generation_metadata;
  if (!metadata || typeof metadata !== "object" ||
    (metadata as Record<string, unknown>).source !== "approved-local-opening-diversity-candidate") {
    throw new Error("Reviewed Sky-led import requires approved local candidate provenance");
  }
  const { error } = await supabase.from("daily_ritual_batch_rows").upsert({
    batch_id: batch.id,
    ritual_date: batch.ritual_date,
    environment: batch.environment,
    western_sign: western,
    eastern_sign: eastern,
    title: null,
    read,
    ritual_text: read,
    intro: null,
    pull_quote: null,
    deeper_read: null,
    watch_for: null,
    move: null,
    validation_status: "VALID",
    validation_errors: [],
    generation_attempt: Number.isInteger(body.generation_attempt) ? body.generation_attempt : 1,
    editorial_voice_version: "todays-lens-sky-led-production-v1",
    runtime_contract_version: "todays-lens-read-only-v1",
    generation_metadata: {
      ...(metadata as Record<string, unknown>),
      provenance: "sky_led_astrology_packet_v1",
      providerCompleted: true,
      legacyFallbackUsed: false,
      safetyValidation: { accepted: true, findings: [] },
      identityDateValidation: { accepted: true },
      astrologyProvenance: {
        skySource: "todays-lens-horoscope-writer-v2.skyContextForMoment",
        transitSource: "structured-production-builder-v1.deriveFineGrainedTransitState",
        identitySource: "Resources/Identity/identity_profiles_v1.json#signature",
      },
    },
  }, { onConflict: "batch_id,western_sign,eastern_sign" });
  if (error) throw error;
  return json({ recorded: true });
}

/** Metadata-only repair for a reviewed corpus already staged in VALIDATING. */
async function repairReviewedSkyLedProvenance(supabase: any, body: any) {
  const batch = await fetchBatch(supabase, body.batch_id);
  if (batch.status !== "VALIDATING" || batch.environment !== "production" ||
    batch.generator_version !== "todays-lens-sky-led-production-v1" ||
    batch.is_corrective !== true) {
    throw new Error("Provenance repair requires a VALIDATING corrective production Sky-led batch");
  }
  const western = requiredString(body.western_sign, "western_sign");
  const eastern = requiredString(body.eastern_sign, "eastern_sign");
  const metadata = body.generation_metadata;
  if (!metadata || typeof metadata !== "object" ||
    (metadata as Record<string, unknown>).source !== "approved-local-opening-diversity-candidate") {
    throw new Error("Authoritative reviewed-candidate provenance is required");
  }
  const { data: existing, error: existingError } = await supabase
    .from("daily_ritual_batch_rows").select("generation_metadata")
    .eq("batch_id", batch.id).eq("western_sign", western).eq("eastern_sign", eastern).single();
  if (existingError || !existing) throw new Error("Staged row not found");
  const { error } = await supabase.from("daily_ritual_batch_rows").update({
    generation_metadata: {
      ...(existing.generation_metadata && typeof existing.generation_metadata === "object" ? existing.generation_metadata : {}),
      ...(metadata as Record<string, unknown>),
    },
  }).eq("batch_id", batch.id).eq("western_sign", western).eq("eastern_sign", eastern);
  if (error) throw error;
  return json({ repaired: true });
}

async function repairMissingSafetyValidationMetadata(supabase: any, batchId: string) {
  const batch = await fetchBatch(supabase, requiredString(batchId, "batch_id"));
  if (batch.environment !== "production" || batch.status !== "VALIDATING" || batch.published_at) {
    throw new Error("Safety metadata repair requires an unpublished production VALIDATING batch");
  }
  const { data: rows, error } = await supabase.from("daily_ritual_batch_rows")
    .select("id,western_sign,eastern_sign,read,generation_metadata")
    .eq("batch_id", batch.id);
  if (error) throw error;
  if (!rows || rows.length !== 144) throw new Error("Safety metadata repair requires exactly 144 rows");
  const results = { inspected: rows.length, repaired: 0, already_complete: 0, rejected: [] as Array<Record<string, unknown>> };
  for (const row of rows) {
    const metadata = row.generation_metadata && typeof row.generation_metadata === "object"
      ? row.generation_metadata as Record<string, unknown>
      : {};
    if (metadata.safetyValidation && typeof metadata.safetyValidation === "object") {
      results.already_complete++;
      continue;
    }
    const safety = validateSkyLedSafety(String(row.read ?? ""));
    if (!safety.accepted) {
      results.rejected.push({ western_sign: row.western_sign, eastern_sign: row.eastern_sign, findings: safety.findings });
      continue;
    }
    const { error: updateError } = await supabase.from("daily_ritual_batch_rows")
      .update({ generation_metadata: { ...metadata, safetyValidation: safety } })
      .eq("id", row.id).eq("batch_id", batch.id);
    if (updateError) throw updateError;
    results.repaired++;
  }
  if (results.rejected.length) throw new Error(`Safety metadata repair rejected ${results.rejected.length} rows`);
  return json({ repair: results });
}

async function listBatchRows(supabase: any, batchId: string) {
  const { data, error } = await supabase.from("daily_ritual_batch_rows")
    .select("western_sign,eastern_sign,title,read,generation_metadata")
    .eq("batch_id", batchId).order("western_sign").order("eastern_sign");
  if (error) throw error;
  return json({ rows: data ?? [] });
}

async function recordFailedResult(supabase: any, body: any) {
  const batch = await fetchBatch(supabase, body.batch_id);
  if (batch.status !== "GENERATING") {
    throw new Error("Batch must be GENERATING");
  }
  const nextFailed = Math.min(
    144,
    Number(batch.failed_identity_count ?? 0) + 1,
  );
  const { data, error } = await supabase.from("daily_ritual_batches")
    .update({ failed_identity_count: nextFailed }).eq("id", batch.id).select(
      "*",
    ).single();
  if (error) throw error;
  log("generated_result_failed", {
    batch_id: batch.id,
    western_sign: body.western_sign,
    eastern_sign: body.eastern_sign,
    reason: body.reason,
  });
  return json({ batch: data });
}

async function transitionRecord(supabase: any, batch: any, nextStatus: string) {
  assertTransition(batch.status, nextStatus as any);
  const { error } = await supabase.from("daily_ritual_batches")
    .update({ status: nextStatus }).eq("id", batch.id);
  if (error) throw error;
}

async function failBatch(supabase: any, batchId: string, reason: string) {
  const batch = await fetchBatch(supabase, batchId);
  assertTransition(batch.status, "FAILED");
  const { data, error } = await supabase.from("daily_ritual_batches")
    .update({
      status: "FAILED",
      failure_reason: reason,
      completed_at: new Date().toISOString(),
    })
    .eq("id", batchId).select("*").single();
  if (error) throw error;
  log("batch_failed", { batch_id: batchId, reason });
  return json({ batch: data });
}

async function getBatchStatus(supabase: any, batchId: string) {
  const batch = await fetchBatch(supabase, batchId);
  const { data: validation, error } = await supabase
    .rpc(validationRpcForBatch(batch), { p_batch_id: batchId }).single();
  if (error) throw error;
  return json({ batch, validation });
}

async function listMissingIdentityPairs(supabase: any, batchId: string) {
  const { data: rows, error } = await supabase.from("daily_ritual_batch_rows")
    .select("western_sign,eastern_sign").eq("batch_id", batchId);
  if (error) throw error;
  const present = new Set(
    (rows || []).map((row: any) =>
      `${row.western_sign.toLowerCase()}|${row.eastern_sign.toLowerCase()}`
    ),
  );
  const missing = CANONICAL_IDENTITY_PAIRS.filter((pair) =>
    !present.has(
      `${pair.westernSign.toLowerCase()}|${pair.easternSign.toLowerCase()}`,
    )
  );
  return json({ batch_id: batchId, missing });
}

async function publishedAvailability(
  supabase: any,
  environment: string,
  ritualDate: string,
) {
  if (!CONTENT_ENVIRONMENTS.includes(environment as any)) {
    throw new Error("Invalid environment");
  }
  const { data: batch, error } = await supabase.from("daily_ritual_batches")
    .select("*").eq("environment", environment).eq("ritual_date", ritualDate)
    .eq("status", "PUBLISHED").maybeSingle();
  if (error) throw error;
  if (!batch) return json({ ready: false, reason: "NO_PUBLISHED_BATCH" });
  const { data: validation, error: validationError } = await supabase
    .rpc(validationRpcForBatch(batch), { p_batch_id: batch.id }).single();
  if (validationError) throw validationError;
  return json({ ready: Boolean(validation.valid), batch, validation });
}

async function inFlightCorrectiveBatch(
  supabase: any,
  environment: string,
  ritualDate: string,
) {
  const { data, error } = await supabase.from("daily_ritual_batches")
    .select("*").eq("environment", environment).eq("ritual_date", ritualDate)
    .eq("is_corrective", true).in("status", ["CREATED", "GENERATING", "VALIDATING", "READY"])
    .maybeSingle();
  if (error) throw error;
  return json({ batch: data });
}

async function fetchBatch(supabase: any, batchId: string) {
  const { data, error } = await supabase.from("daily_ritual_batches")
    .select("*").eq("id", batchId).single();
  if (error) throw error;
  return data;
}

function validationRpcForBatch(batch: Record<string, unknown>) {
  return [
    "todays-lens-sky-led-production-candidate-v1",
    "todays-lens-sky-led-production-v1",
  ].includes(String(batch.generator_version ?? ""))
    ? "daily_ritual_sky_led_batch_validation"
    : "daily_ritual_batch_validation";
}

function requiredString(value: unknown, name: string) {
  if (typeof value !== "string" || !value.trim()) {
    throw new Error(`Missing ${name}`);
  }
  return value.trim();
}

function requiredDate(value: unknown) {
  const result = requiredString(value, "ritual_date");
  if (!/^\d{4}-\d{2}-\d{2}$/.test(result)) {
    throw new Error("Invalid ritual_date");
  }
  return result;
}

function log(event: string, details: unknown) {
  console.log(
    JSON.stringify({ component: "daily_ritual_batch", event, details }),
  );
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
