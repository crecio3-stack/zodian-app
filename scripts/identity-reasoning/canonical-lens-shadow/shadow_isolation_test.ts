import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

Deno.test("shadow implementation cannot reach user-facing reads or production writes", async () => {
  const source = await Deno.readTextFile(
    new URL(
      "../../../supabase/functions/generate-canonical-lens-shadow/index.ts",
      import.meta.url,
    ),
  );
  const productionTableWrite =
    /from\(\s*"daily_rituals",?\s*\)\s*\.(upsert|update)/;
  const productionTableRead = /from\(\s*"daily_rituals",?\s*\)\s*\.select/;
  assert(!productionTableWrite.test(source));
  assert(productionTableRead.test(source));
  const reader = await Deno.readTextFile(
    new URL(
      "../../../supabase/functions/get-daily-ritual/index.ts",
      import.meta.url,
    ),
  );
  assert(!reader.includes("canonical_lens_shadow_generations"));
});

Deno.test("manual manifest remains a 3 by 10 non-scheduled matrix", async () => {
  const manifest = JSON.parse(
    await Deno.readTextFile(
      new URL("controlled-cohort-manifest.json", import.meta.url),
    ),
  );
  assertEquals(manifest.execution, "manual-only");
  assertEquals(
    manifest.intendedInvocations,
    manifest.identities.length * manifest.scenarioIds.length,
  );
  assertEquals(manifest.invocations.length, 30);
  assertEquals(manifest.automaticDateScenarioMapping, false);
});

Deno.test("fingerprint verification precedes every provider call", async () => {
  const source = await Deno.readTextFile(
    new URL(
      "../../../supabase/functions/generate-canonical-lens-shadow/index.ts",
      import.meta.url,
    ),
  );
  assert(
    source.indexOf("fingerprint verification failed") <
      source.indexOf("await callModel("),
  );
  assert(source.includes("CANONICAL_LENS_V3_2_SOURCE_SHA256"));
  assert(source.includes("CANONICAL_LENS_V3_2_RUNTIME_SHA256"));
});
