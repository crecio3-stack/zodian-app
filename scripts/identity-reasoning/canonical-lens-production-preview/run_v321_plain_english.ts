import {
  buildPlainEnglishPrompt,
  V321_PLAIN_ENGLISH_VERSION,
} from "./v321_plain_english.ts";
import {
  type Lens,
  meaningFlags,
  styleFlags,
} from "./v321_plain_english_validate.ts";
import { validateCanonicalLens } from "../canonical-lens/validate.ts";
const artifacts = new URL("artifacts/", import.meta.url),
  source = JSON.parse(
    await Deno.readTextFile(new URL("v321-cohort.json", artifacts)),
  );
const out = new URL("v321-plain-english-cohort.json", artifacts),
  checkpoint = new URL("v321-plain-english-checkpoints.json", artifacts);
const preflight = Deno.args.includes("--preflight"),
  real = Deno.args.includes("--real"),
  key = Deno.env.get("OPENAI_API_KEY"),
  model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL");
if (source.accepted !== 30 || source.outputs.length !== 30) {
  throw new Error("exact 30 source cohort required");
}
if (preflight) {
  console.log(
    JSON.stringify(
      {
        passed: true,
        version: V321_PLAIN_ENGLISH_VERSION,
        cases: 30,
        providerCalls: 0,
        output: out.pathname,
        productionWritePaths: [],
        shadowWritePaths: [],
      },
      null,
      2,
    ),
  );
  Deno.exit(0);
}
if (!real || !key || !model) {
  throw new Error(
    "Use --real with a rotated OPENAI_API_KEY and OPENAI_IDENTITY_LENS_MODEL.",
  );
}
let rows: any[] = [];
try {
  rows = JSON.parse(await Deno.readTextFile(checkpoint)).rows;
} catch {}
for (const item of source.outputs) {
  const id = item.key;
  if (rows.some((r) => r.id === id && r.accepted)) continue;
  const prior = rows.find((r) => r.id === id);
  const started = performance.now(), attempts: any[] = prior?.attempts ?? [];
  let candidate: Lens | null = prior?.rewrite ?? null,
    errors: string[] = prior?.errors ?? [];
  for (let attempt = 0; attempt < 3; attempt++) {
    const invalid = errors.flatMap((error) =>
      ["title", "intro", "pull_quote", "deeper_read", "watch_for", "move"]
        .filter((field) => error.startsWith(field))
    ).filter((value, index, all) => all.indexOf(value) === index);
    const prompt = candidate && invalid.length
      ? `${
        buildPlainEnglishPrompt(item.result.finalLens)
      }\n\nCurrent rewrite:\n${
        JSON.stringify(candidate)
      }\n\nRepair only these fields: ${JSON.stringify(invalid)}. Errors: ${
        JSON.stringify(errors)
      }. Return only those fields; preserve the same meaning and all other fields byte-for-byte.`
      : buildPlainEnglishPrompt(item.result.finalLens);
    const res = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        input: prompt,
        text: { format: { type: "json_object" } },
      }),
    });
    const body = await res.json();
    let value: any;
    try {
      value = JSON.parse(
        body.output?.flatMap((x: any) => x.content ?? []).find((x: any) =>
          x.type === "output_text"
        )?.text ?? "",
      );
    } catch {
      value = null;
    }
    if (
      candidate && invalid.length && value &&
      Object.keys(value).every((field) => invalid.includes(field))
    ) candidate = { ...candidate, ...value };
    else candidate = value;
    const complete = candidate && [
      "title",
      "intro",
      "pull_quote",
      "deeper_read",
      "watch_for",
      "move",
    ].every((field) => typeof (candidate as any)[field] === "string");
    const schema = complete ? validateCanonicalLens(candidate!) : {
      accepted: false,
      reasons: ["repair did not produce a complete six-field Lens"],
    };
    errors = [
      ...schema.reasons,
      ...(value
        ? meaningFlags(item.result.finalLens, candidate!)
        : ["meaning unavailable"]),
      ...(complete ? styleFlags(candidate!) : []),
    ];
    attempts.push({ attempt, schema, errors, usage: body.usage });
    if (schema.accepted && errors.length === 0) break;
  }
  rows = rows.filter((row) => row.id !== id);
  rows.push({
    id,
    identity: item.identity,
    scenarioId: item.scenarioId,
    original: item.result.finalLens,
    rewrite: candidate,
    accepted: errors.length === 0,
    errors,
    attempts,
    latencyMs: Math.round(performance.now() - started),
  });
  await Deno.writeTextFile(
    checkpoint,
    JSON.stringify({ version: V321_PLAIN_ENGLISH_VERSION, rows }, null, 2),
  );
}
await Deno.writeTextFile(
  out,
  JSON.stringify({ version: V321_PLAIN_ENGLISH_VERSION, rows }, null, 2),
);
console.log(
  JSON.stringify(
    {
      rows: rows.length,
      accepted: rows.filter((r) => r.accepted).length,
    },
    null,
    2,
  ),
);
