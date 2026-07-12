/**
 * Produces a local development-only review package through the authenticated
 * Supabase CLI. It never writes to the linked database.
 */
const date = Deno.args[0] ?? "2026-07-12";
if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
  throw new Error("Usage: export_linked_comparison.ts YYYY-MM-DD");
}
const sql = `
select jsonb_build_object(
  'shadow_generation_id', s.id,
  'date', s.generation_date,
  'identity', s.western_sign || ' × ' || s.eastern_sign,
  'scenario_id', s.scenario_id,
  'arena', s.arena,
  'status', s.status,
  'provider_calls', s.provider_call_count,
  'schema_retries', s.schema_retry_count,
  'tokens', s.total_tokens,
  'latency_ms', s.latency_ms,
  'source_sha256', s.source_sha256,
  'config_fingerprint', s.config_fingerprint,
  'production_lens', jsonb_build_object('id', p.id, 'title', p.title, 'intro', p.intro, 'pull_quote', p.pull_quote, 'deeper_read', p.deeper_read, 'watch_for', p.watch_for, 'move', p.move),
  'shadow_lens', s.lens
) as row
from public.canonical_lens_shadow_generations s
join public.daily_rituals p on p.id::text = s.production_daily_ritual_id
where s.generation_date = '${date}'
  and s.frozen_version = 'canonical-lens-v3.2'
order by s.western_sign, s.eastern_sign, s.scenario_id;`;
const command = new Deno.Command("supabase", {
  args: ["db", "query", "--linked", "--agent=no", "--output", "json", sql],
  stdout: "piped",
  stderr: "piped",
});
const result = await command.output();
if (!result.success) throw new Error(new TextDecoder().decode(result.stderr));
const raw = JSON.parse(new TextDecoder().decode(result.stdout)) as Array<
  { row: unknown }
>;
const rows = raw.map(({ row }) => row as Record<string, any>);
if (rows.length !== 30 || rows.some((row) => row.status !== "accepted")) {
  throw new Error(`Expected 30 accepted rows, found ${rows.length}`);
}
const output = {
  development_only: true,
  pairing:
    "Production Lens for this identity/date versus v3.2 shadow Lens generated with explicit scenario ID",
  date,
  rows,
};
const directory = new URL("artifacts/", import.meta.url);
await Deno.mkdir(directory, { recursive: true });
await Deno.writeTextFile(
  new URL(`comparison-${date}.json`, directory),
  JSON.stringify(output, null, 2) + "\n",
);
const markdown = [
  "# Canonical Lens v3.2 controlled shadow comparison",
  "",
  `- Date: ${date}`,
  "- Pairing: Production Lens for this identity/date versus v3.2 shadow Lens generated with explicit scenario ID.",
  "- Rows: 30 accepted shadow outputs.",
  "",
  ...rows.flatMap((row) => [
    `## ${row.identity} · ${row.scenario_id}`,
    "",
    `- Status: ${row.status}; retries: ${row.schema_retries}; tokens: ${row.tokens}; latency: ${row.latency_ms} ms`,
    "",
    "### Production Lens",
    "",
    ...Object.entries(row.production_lens).filter(([key]) => key !== "id").map((
      [key, value],
    ) => `- **${key}:** ${value}`),
    "",
    "### v3.2 Shadow Lens",
    "",
    ...Object.entries(row.shadow_lens).map(([key, value]) =>
      `- **${key}:** ${value}`
    ),
    "",
  ]),
].join("\n");
await Deno.writeTextFile(new URL(`comparison-${date}.md`, directory), markdown);
console.log(
  JSON.stringify(
    {
      rows: rows.length,
      json: new URL(`comparison-${date}.json`, directory).pathname,
      markdown: new URL(`comparison-${date}.md`, directory).pathname,
    },
    null,
    2,
  ),
);
