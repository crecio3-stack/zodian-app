import { createClient } from "npm:@supabase/supabase-js@2";
import {
  isReadableCandidateVersion,
  type CandidateRecord,
  candidateRecordErrors,
  type CandidateStatus,
  candidateStatuses,
  internalCandidateResponse,
} from "../_shared/production-candidate-v1/candidate_contract.ts";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

function text(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function isDate(value: string): boolean {
  return /^\d{4}-\d{2}-\d{2}$/.test(value);
}

function configuredServiceRoleKey(): string | undefined {
  return Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
    JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return json({ error: "POST required" }, 405);

  const internalSecret = Deno.env.get(
    "PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET",
  );
  if (
    !internalSecret ||
    request.headers.get("x-production-candidate-v1-internal-secret") !==
      internalSecret
  ) {
    return json({ error: "internal authentication failed" }, 401);
  }

  const body = await request.json().catch(() => null) as
    | Record<string, unknown>
    | null;
  const candidate_version = text(body?.candidate_version);
  const candidate_date = text(body?.candidate_date);
  const western_sign = text(body?.western_sign);
  const eastern_sign = text(body?.eastern_sign);
  const source_context = text(body?.source_context);
  if (
    !isReadableCandidateVersion(candidate_version) || !isDate(candidate_date) ||
    !western_sign || !eastern_sign || !source_context
  ) {
    return json({ error: "invalid candidate lookup" }, 400);
  }

  const url = Deno.env.get("SUPABASE_URL");
  const key = configuredServiceRoleKey();
  if (!url || !key) {
    return json({ error: "candidate store configuration is incomplete" }, 500);
  }

  const supabase = createClient(url, key);
  const { data, error } = await supabase
    .from("production_candidate_v1_generations")
    .select(
      "candidate_version,candidate_date,western_sign,eastern_sign,source_context,status,candidate_title,candidate_read",
    )
    .eq("candidate_version", candidate_version)
    .eq("candidate_date", candidate_date)
    .ilike("western_sign", western_sign)
    .ilike("eastern_sign", eastern_sign)
    .eq("source_context", source_context)
    .maybeSingle();

  if (error) return json({ error: "candidate lookup failed" }, 500);
  if (!data) {
    return json({ version: candidate_version, status: "not_found" }, 404);
  }

  const record = data as CandidateRecord;
  if (!candidateStatuses.includes(record.status as CandidateStatus)) {
    return json({ error: "candidate store contains an invalid status" }, 500);
  }
  const errors = candidateRecordErrors(record);
  if (errors.length) {
    return json({ error: "candidate store contains invalid content" }, 500);
  }

  return json(internalCandidateResponse(record));
});
