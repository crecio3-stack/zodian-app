const migrationDirectory = new URL(
  "../../../supabase/migrations/",
  import.meta.url,
);
const artifacts = new URL("./artifacts/", import.meta.url);
const expectedMigrations = [
  "20260504_generate_daily_rituals_unique.sql",
  "20260512_daily_ritual_structured_read.sql",
  "20260706_daily_ritual_pattern_intelligence.sql",
  "20260711220000_canonical_lens_v3_2_shadow.sql",
  "20260711220500_canonical_lens_v3_2_shadow_claim.sql",
  "20260713090000_production_candidate_v1_isolated_storage.sql",
];

async function sha256(path: URL): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    await Deno.readFile(path),
  );
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

async function gitOutput(args: string[]): Promise<string> {
  const result = await new Deno.Command("git", {
    args,
    cwd: Deno.cwd(),
    stdout: "piped",
    stderr: "piped",
  }).output();
  if (!result.success) {
    throw new Error(
      `Git history check failed: ${new TextDecoder().decode(result.stderr)}`,
    );
  }
  return new TextDecoder().decode(result.stdout).trim();
}

async function writeFrozen(path: URL, value: unknown) {
  const serialized = JSON.stringify(value, null, 2) + "\n";
  try {
    const existing = await Deno.readTextFile(path);
    if (existing !== serialized) {
      throw new Error(`Existing frozen audit differs: ${path.pathname}`);
    }
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      await Deno.writeTextFile(path, serialized);
      return;
    }
    throw error;
  }
}

const migrationEntries = await Promise.all(
  expectedMigrations.map(async (name) => {
    const path = new URL(name, migrationDirectory);
    return {
      name,
      path,
      sql: await Deno.readTextFile(path),
      sha256: await sha256(path),
    };
  }),
);
const allSql = migrationEntries.map((entry) => entry.sql).join("\n");
const createsDailyRituals =
  /create\s+table\s+(?:if\s+not\s+exists\s+)?(?:public\.)?daily_rituals\b/i
    .test(allSql);
const sideEffectPatterns = {
  schedules: /\b(?:cron\.schedule|pg_cron|create\s+extension\s+.*cron)\b/i,
  providers: /\b(?:openai|responses\s*api|api\.openai\.com)\b/i,
  externalHttp: /\b(?:net\.http|http_post|http_get|pg_net)\b/i,
  secrets: /\b(?:vault|current_setting\s*\(.*secret)\b/i,
};
const sideEffects = Object.fromEntries(
  Object.entries(sideEffectPatterns).map((
    [name, pattern],
  ) => [name, pattern.test(allSql)]),
);
const historicalCreationSearch = await gitOutput([
  "log",
  "--all",
  "-Screate table public.daily_rituals",
  "--oneline",
  "--",
  "supabase",
]);
const historicalMigrationPaths = await gitOutput([
  "log",
  "--all",
  "--name-only",
  "--pretty=format:",
  "--",
  "supabase",
]);
const findings = [
  {
    migration: "20260504_generate_daily_rituals_unique.sql",
    dependency:
      "public.daily_rituals with ritual_date, western_sign, and eastern_sign",
    fresh_project_result:
      "BLOCKED: table creation is not present in the local migration ledger.",
    side_effects:
      "adds one unique constraint only when its prerequisite table exists",
  },
  {
    migration: "20260512_daily_ritual_structured_read.sql",
    dependency: "public.daily_rituals",
    fresh_project_result: "BLOCKED by missing daily_rituals baseline.",
    side_effects:
      "adds structured-read columns and comments; no provider, schedule, or seed data",
  },
  {
    migration: "20260706_daily_ritual_pattern_intelligence.sql",
    dependency: "public.daily_rituals",
    fresh_project_result: "BLOCKED by missing daily_rituals baseline.",
    side_effects:
      "adds optional metadata columns and comments; no provider, schedule, or seed data",
  },
  {
    migration: "20260711220000_canonical_lens_v3_2_shadow.sql",
    dependency: "Supabase UUID support for gen_random_uuid",
    fresh_project_result:
      "Structurally independent of daily_rituals; creates an inert RLS-protected shadow table with no policies.",
    side_effects:
      "no provider invocation, schedule, secret access, or data seed",
  },
  {
    migration: "20260711220500_canonical_lens_v3_2_shadow_claim.sql",
    dependency:
      "canonical_lens_shadow_generations from the immediately preceding migration",
    fresh_project_result: "Order is valid after its table exists.",
    side_effects:
      "creates an idempotent claim function only; no schedule or provider invocation",
  },
  {
    migration: "20260713090000_production_candidate_v1_isolated_storage.sql",
    dependency: "Supabase UUID support for gen_random_uuid",
    fresh_project_result:
      "Structurally independent of daily_rituals; creates inert RLS-protected PCv1 storage and claim function.",
    side_effects:
      "no provider invocation, schedule, secret access, control-table mutation, or data seed",
  },
];

const audit = {
  developmentOnly: true,
  targetProject: {
    ref: "wlsewblvpyeanfganbkc",
    name: "Zodian Development",
    migrationLedger: "empty",
  },
  migrationChain: migrationEntries.map(({ name, sha256 }) => ({
    name,
    sha256,
  })),
  dependencyGraph: [
    "missing daily_rituals creation baseline -> 20260504 -> 20260512 -> 20260706",
    "20260711220000 -> 20260711220500",
    "20260713090000 is separate from daily_rituals",
  ],
  findings,
  missingHistory: {
    daily_rituals_creation_migration_present: createsDailyRituals,
    accessible_git_history_creation_match: historicalCreationSearch || null,
    accessible_git_history_migration_paths: historicalMigrationPaths
      .split("\n")
      .filter((path) => path.startsWith("supabase/migrations/")),
    result: createsDailyRituals
      ? "No missing base-table creation migration detected."
      : "Missing: no local migration creates public.daily_rituals, though the first three files require it. No matching creation migration exists in accessible Git history.",
  },
  sideEffects,
  expectedSchemaIfBaselineWereRestored: {
    daily_rituals: [
      "unique ritual_date/western_sign/eastern_sign",
      "structured read columns",
      "pattern intelligence columns",
    ],
    shadow: [
      "canonical_lens_shadow_generations with RLS and no policies",
      "claim_canonical_lens_shadow_generation function",
    ],
    pcv1: [
      "production_candidate_v1_generations with RLS and no policies",
      "claim_production_candidate_v1_generation function",
    ],
  },
  localDisposableValidation: {
    status: "NOT_RUN",
    reason:
      "Supabase db dump/local validation requires Docker, but the Docker daemon is unavailable in this workspace.",
  },
  rollbackAndReset: {
    status: "NOT_APPROVED",
    reason:
      "The available ledger lacks an initial daily_rituals creation migration and has no down migrations. A fresh bootstrap or reset cannot be proven safe from this repository alone.",
  },
  decision: "BLOCKED",
  requiredBeforeBootstrap: [
    "Recover or author a reviewed base migration that creates public.daily_rituals and its prerequisites for a fresh Supabase project.",
    "Verify the complete migration chain against a disposable database after that baseline is available.",
    "Only then rerun the development db push dry run and require it to show the reviewed full chain.",
  ],
  providerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  deploymentChanges: [],
};
await writeFrozen(
  new URL(
    "production-candidate-v1-bootstrap-readiness-audit-v2.json",
    artifacts,
  ),
  audit,
);

const markdown =
  `# PCv1 development bootstrap readiness audit\n\n**Decision: BLOCKED**\n\nThe empty Zodian Development ledger cannot be bootstrapped from the six local migrations. The repository has no migration that creates \`public.daily_rituals\`, while the first three migrations alter or constrain that table.\n\n## Dependency graph\n\n\`missing daily_rituals creation baseline → 20260504 → 20260512 → 20260706\`\n\n\`20260711220000 → 20260711220500\`\n\n\`20260713090000\` is structurally independent of \`daily_rituals\`.\n\n## Side effects\n\nNo reviewed migration schedules work, invokes a provider, accesses secrets, seeds data, or mutates an external system. The shadow and PCv1 tables are inert without separately deployed functions or schedulers.\n\n## Missing history\n\nThe base \`daily_rituals\` creation migration is absent. Do not use migration repair, mark history applied, or selectively push PCv1 to compensate.\n\n## Local validation\n\nA disposable local Supabase run was not possible because Docker is unavailable in this workspace. Static review is sufficient to identify the missing prerequisite but cannot certify a fresh bootstrap.\n\n## Required resolution\n\n1. Recover or author and review the missing base migration.\n2. Validate the complete chain on a disposable database.\n3. Re-run the development dry run before any deployment.\n`;
const markdownPath = new URL(
  "production-candidate-v1-bootstrap-readiness-audit-v2.md",
  artifacts,
);
try {
  const existing = await Deno.readTextFile(markdownPath);
  if (existing !== markdown) {
    throw new Error(`Existing frozen audit differs: ${markdownPath.pathname}`);
  }
} catch (error) {
  if (error instanceof Deno.errors.NotFound) {
    await Deno.writeTextFile(markdownPath, markdown);
  } else throw error;
}
console.log(JSON.stringify(audit, null, 2));
