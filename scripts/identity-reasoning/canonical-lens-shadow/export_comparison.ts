/** Service-role-only export; it is intentionally not a user-facing API. */
const date = Deno.args[0];
if (!/^\d{4}-\d{2}-\d{2}$/.test(date ?? "")) {
  throw new Error("Usage: export_comparison.ts YYYY-MM-DD");
}
const url = Deno.env.get("SUPABASE_URL");
const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
if (!url || !key) {
  throw new Error("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required");
}
const headers = { apikey: key, Authorization: `Bearer ${key}` };
const shadows = await (await fetch(
  `${url}/rest/v1/canonical_lens_shadow_generations?generation_date=eq.${date}&select=*`,
  { headers },
)).json();
const production = await (await fetch(
  `${url}/rest/v1/daily_rituals?ritual_date=eq.${date}&select=id,western_sign,eastern_sign,title,intro,pull_quote,deeper_read,watch_for,move`,
  { headers },
)).json();
const byId = new Map(production.map((row: any) => [String(row.id), row]));
const rows = shadows.map((shadow: any) => ({
  date,
  identity: `${shadow.western_sign} × ${shadow.eastern_sign}`,
  scenario_id: shadow.scenario_id,
  status: shadow.status,
  retries: shadow.schema_retry_count,
  tokens: shadow.total_tokens,
  latency_ms: shadow.latency_ms,
  source_sha256: shadow.source_sha256,
  config_fingerprint: shadow.config_fingerprint,
  production_lens: byId.get(String(shadow.production_daily_ritual_id)) ?? null,
  shadow_lens: shadow.lens,
}));
console.log(
  JSON.stringify(
    {
      development_only: true,
      pairing:
        "Production Lens for this identity/date versus v3.2 shadow Lens generated with explicit scenario ID",
      rows,
    },
    null,
    2,
  ),
);
