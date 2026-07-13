/**
 * Provider-free static validation for the recovered daily_rituals baseline.
 * It deliberately validates migration composition only; a disposable Supabase
 * replay remains required before any development deployment.
 */

const root = new URL("../../..", import.meta.url);
const baselinePath = new URL("../../../supabase/migrations/20260503090000_daily_rituals_baseline.sql", import.meta.url);
const uniquePath = new URL("../../../supabase/migrations/20260504_generate_daily_rituals_unique.sql", import.meta.url);
const structuredPath = new URL("../../../supabase/migrations/20260512_daily_ritual_structured_read.sql", import.meta.url);
const intelligencePath = new URL("../../../supabase/migrations/20260706_daily_ritual_pattern_intelligence.sql", import.meta.url);
const artifactsPath = new URL("./artifacts/", import.meta.url);

const baseline = await Deno.readTextFile(baselinePath);
const unique = await Deno.readTextFile(uniquePath);
const structured = await Deno.readTextFile(structuredPath);
const intelligence = await Deno.readTextFile(intelligencePath);

const baselineColumns = [
  "id", "ritual_date", "western_sign", "eastern_sign", "title",
  "ritual_text", "action_text", "model", "created_at",
];
const structuredColumns = ["intro", "pull_quote", "deeper_read", "watch_for", "move"];
const intelligenceColumns = [
  "confidence", "reflection", "connection", "growth", "momentum",
  "primary_signal", "secondary_signal", "emotional_tone", "theme_tags",
];

const sourceSha256 = async (text: string) => {
  const bytes = new TextEncoder().encode(text);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)].map((value) => value.toString(16).padStart(2, "0")).join("");
};

const includes = (source: string, fragment: string) => source.toLowerCase().includes(fragment.toLowerCase());
const checks = {
  baselineCreatesTable: includes(baseline, "create table public.daily_rituals"),
  baselineHasOnlyRecoveredColumns: baselineColumns.every((column) => includes(baseline, column)) &&
    [...structuredColumns, ...intelligenceColumns].every((column) => !includes(baseline, `  ${column} `)),
  baselineHasUuidPrerequisite: includes(baseline, "create extension if not exists pgcrypto") &&
    includes(baseline, "default gen_random_uuid()"),
  baselineHasPrimaryKey: includes(baseline, "id uuid primary key"),
  baselineHasRlsWithoutPolicies: includes(baseline, "enable row level security") && !includes(baseline, "create policy"),
  baselineHasProductionGrants: includes(baseline, "to anon, authenticated, service_role"),
  uniqueMigrationOwnsCompositeKey: includes(unique, "unique (ritual_date, western_sign, eastern_sign)") &&
    !includes(baseline, "daily_rituals_ritual_date_western_sign_eastern_sign_key"),
  structuredMigrationOwnsStructuredColumns: structuredColumns.every((column) => includes(structured, `add column if not exists ${column}`)),
  intelligenceMigrationOwnsIntelligenceColumns: intelligenceColumns.every((column) => includes(intelligence, `add column if not exists ${column}`)),
  noDataOrExternalSideEffects: !/^\s*(insert|update|delete|copy)\b/im.test(baseline) &&
    !/\b(http|net\.http|cron\.schedule)\b/i.test(baseline),
};

const expectedFinalColumns = [...baselineColumns, ...structuredColumns, ...intelligenceColumns];
const passed = Object.values(checks).every(Boolean);
const output = {
  developmentOnly: true,
  decision: passed ? "READY_FOR_DISPOSABLE_VALIDATION" : "BLOCKED",
  staticOnly: true,
  requiredNextStep: "Replay the complete seven-migration chain in a disposable Supabase database, then compare the relevant schema with production before any remote push.",
  baselineMigration: "20260503090000_daily_rituals_baseline.sql",
  chain: [
    "20260503090000_daily_rituals_baseline.sql",
    "20260504_generate_daily_rituals_unique.sql",
    "20260512_daily_ritual_structured_read.sql",
    "20260706_daily_ritual_pattern_intelligence.sql",
    "20260711220000_canonical_lens_v3_2_shadow.sql",
    "20260711220500_canonical_lens_v3_2_shadow_claim.sql",
    "20260713090000_production_candidate_v1_isolated_storage.sql",
  ],
  checks,
  expectedFinalDailyRituals: {
    columns: expectedFinalColumns,
    constraints: ["daily_rituals_pkey", "daily_rituals_ritual_date_western_sign_eastern_sign_key"],
    rlsEnabled: true,
    policies: [],
    triggers: [],
    foreignKeys: [],
  },
  sourceSha256: {
    baseline: await sourceSha256(baseline),
    unique: await sourceSha256(unique),
    structured: await sourceSha256(structured),
    intelligence: await sourceSha256(intelligence),
  },
};

await Deno.mkdir(artifactsPath, { recursive: true });
await Deno.writeTextFile(new URL("production-candidate-v1-daily-rituals-baseline-static-validation-v1.json", artifactsPath), `${JSON.stringify(output, null, 2)}\n`);

const markdown = `# Daily Rituals Recovered Baseline Static Validation\n\n` +
  `Decision: **${output.decision}**\n\n` +
  `This is a static composition check, not a database replay. A Docker-backed disposable Supabase replay is still required before any remote deployment.\n\n` +
  `## Expected final \`public.daily_rituals\` shape\n\n` +
  `- Columns: ${expectedFinalColumns.map((column) => `\`${column}\``).join(", ")}\n` +
  `- Constraints: \`daily_rituals_pkey\`, \`daily_rituals_ritual_date_western_sign_eastern_sign_key\`\n` +
  `- RLS enabled; no policies, triggers, or foreign keys.\n\n` +
  `## Checks\n\n` +
  Object.entries(checks).map(([name, value]) => `- ${value ? "PASS" : "FAIL"}: ${name}`).join("\n") + "\n";
await Deno.writeTextFile(new URL("production-candidate-v1-daily-rituals-baseline-static-validation-v1.md", artifactsPath), markdown);

console.log(JSON.stringify(output, null, 2));
