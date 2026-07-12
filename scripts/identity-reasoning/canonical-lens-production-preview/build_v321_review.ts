const preview = new URL("artifacts/", import.meta.url);
const shadow = new URL(
  "../canonical-lens-shadow/artifacts/comparison-2026-07-12.json",
  import.meta.url,
);
const v321 = JSON.parse(
  await Deno.readTextFile(new URL("v321-cohort.json", preview)),
);
const baseline = JSON.parse(await Deno.readTextFile(shadow));
const byKey = new Map(
  baseline.rows.map((row: any) => [`${row.identity}|${row.scenario_id}`, row]),
);
const rows = v321.outputs.map((output: any) => ({
  ...output,
  v32: (byKey.get(`${output.identity}|${output.scenarioId}`) as any)?.shadow_lens ??
    null,
}));
const md = [
  "# v3.2 → v3.2.1 controlled review",
  "",
  "Human review: Preferred: v3.2 / v3.2.1 / Tie; Behavioral recognition: better / same / worse; Identity specificity: better / same / worse; Move specificity: better / same / worse; Prose tightness: better / same / worse; Notes.",
  "",
  ...rows.flatMap((
    row: any,
  ) => [
    `## ${row.identity} · ${row.scenarioId}`,
    "",
    "### v3.2",
    "",
    ...Object.entries(row.v32 ?? {}).map(([k, v]) => `- **${k}:** ${v}`),
    "",
    "### v3.2.1",
    "",
    ...Object.entries(row.result.finalLens ?? {}).map(([k, v]) =>
      `- **${k}:** ${v}`
    ),
    "",
    "Review: Preferred: ___ · Behavioral: ___ · Identity: ___ · Move: ___ · Tightness: ___ · Notes: ___",
    "",
  ]),
].join("\n");
await Deno.writeTextFile(
  new URL("v321-comparison.json", preview),
  JSON.stringify(
    { version: v321.version, baseline: "v3.2 shadow", rows },
    null,
    2,
  ) + "\n",
);
await Deno.writeTextFile(new URL("v321-comparison.md", preview), md);
console.log(
  JSON.stringify(
    {
      rows: rows.length,
      markdown: new URL("v321-comparison.md", preview).pathname,
    },
    null,
    2,
  ),
);
