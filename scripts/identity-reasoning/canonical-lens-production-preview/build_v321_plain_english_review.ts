import { meaningFlags, styleFlags } from "./v321_plain_english_validate.ts";
const dir = new URL("artifacts/", import.meta.url),
  cohort = JSON.parse(
    await Deno.readTextFile(new URL("v321-plain-english-cohort.json", dir)),
  );
const rows = cohort.rows.filter((r: any) => r.accepted).map((r: any) => ({
  id: r.id,
  identity: r.identity,
  scenario: r.scenarioId,
  original: r.original,
  rewrite: r.rewrite,
  meaningFlags: meaningFlags(r.original, r.rewrite),
  styleFlags: styleFlags(r.rewrite),
  attempts: r.attempts,
  latencyMs: r.latencyMs,
}));
if (rows.length !== 30) {
  throw new Error(`expected 30 active accepted rows, found ${rows.length}`);
}
const review = { developmentOnly: true, version: cohort.version, rows };
await Deno.writeTextFile(
  new URL("v321-plain-english-comparison.json", dir),
  JSON.stringify(review, null, 2) + "\n",
);
const md = [
  "# v3.2.1 plain-English human review",
  "",
  ...rows.flatMap((
    r: any,
  ) => [
    `## ${r.identity} · ${r.scenario}`,
    "",
    "### Original v3.2.1",
    "",
    ...Object.entries(r.original).map(([k, v]) => `- **${k}:** ${v}`),
    "",
    "### Plain-English rewrite",
    "",
    ...Object.entries(r.rewrite).map(([k, v]) => `- **${k}:** ${v}`),
    "",
    `- Schema: accepted`,
    `- Meaning flags: ${r.meaningFlags.join("; ") || "none"}`,
    `- Style flags: ${r.styleFlags.join("; ") || "none"}`,
    `- Attempts: ${r.attempts.length}; latency: ${r.latencyMs} ms`,
    "",
    "Review — Preferred: original / plain-English / tie · More natural: better / same / worse · Behavioral recognition: better / same / worse · Identity specificity: better / same / worse · Meaning preserved: yes / no · Notes: ____",
    "",
  ]),
].join("\n");
await Deno.writeTextFile(new URL("v321-plain-english-comparison.md", dir), md);
console.log(
  JSON.stringify(
    {
      rows: rows.length,
      markdown: new URL("v321-plain-english-comparison.md", dir).pathname,
    },
    null,
    2,
  ),
);
