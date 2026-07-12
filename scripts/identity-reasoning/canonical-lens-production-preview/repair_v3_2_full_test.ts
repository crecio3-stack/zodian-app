import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

const base = new URL("./artifacts/", import.meta.url);
const generation = JSON.parse(
  await Deno.readTextFile(new URL("generation-v3.2-full-sample.json", base)),
);
const qa = JSON.parse(
  await Deno.readTextFile(new URL("qa-report-v3.2-full-sample.json", base)),
);
const outputs = generation.identities.flatMap((
  identity: { outputs: unknown[] },
) => identity.outputs) as Array<Record<string, any>>;

Deno.test("repair scope derives exactly seven titles, three intros, and three literary fields", () => {
  const rejected = outputs.filter((output) => !output.result.accepted).map((
    output,
  ) => `${output.key}|title`);
  const conjunction = qa.standaloneOpeningFlags.map((flag: { key: string }) =>
    `${flag.key}|intro`
  );
  const literary = [
    "Libra × Tiger|work|title",
    "Aquarius × Dog|money|pull_quote",
    "Leo × Rat|money|pull_quote",
  ];
  const scope = [...rejected, ...conjunction, ...literary];
  assertEquals(rejected.length, 7);
  assertEquals(conjunction.length, 3);
  assertEquals(literary.length, 3);
  assertEquals(scope.length, 13);
  assertEquals(new Set(scope).size, 13);
});

Deno.test("all rejected final candidates have schema-valid preserved bodies", async () => {
  const { validateCanonicalLens } = await import(
    "../canonical-lens/validate.ts"
  );
  for (const output of outputs.filter((row) => !row.result.accepted)) {
    const candidate = output.result.attempts.at(-1).mergedCandidate;
    assert(validateCanonicalLens(candidate).accepted, output.key);
    assert(
      output.result.attempts.at(-1).validation.reasons.every((reason: string) =>
        reason.startsWith("title ")
      ),
      output.key,
    );
  }
});

Deno.test("repair implementation is isolated from production paths", async () => {
  const source = await Deno.readTextFile(
    new URL("./repair_v3_2_full.ts", import.meta.url),
  );
  assert(!source.includes("supabase/functions"));
  assert(!source.includes("daily_rituals"));
  assert(!source.includes("productionWrite" + "("));
  for (
    const artifact of [
      "generation-v3.2-full-repair.json",
      "generation-v3.2-full-repair-attempts.json",
      "generation-v3.2-full-repaired.json",
      "qa-report-v3.2-full-repaired.json",
    ]
  ) assert(source.includes(artifact));
});
