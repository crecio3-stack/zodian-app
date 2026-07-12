import { writeModelLensV3 } from "./v3_model_writer.ts";
import { buildReliableOpenAIProvider } from "./reliable_provider.ts";
import { buildV32EditorialBrief } from "./v3_sample_plan.ts";
import {
  buildV321SystemPrompt,
  V321_COHORT_IDENTITIES,
  V321_VERSION,
} from "./v321_editorial.ts";
import { auditV321Cohort } from "./v321_cohort_qa.ts";

const root = new URL("./", import.meta.url);
const artifacts = new URL("artifacts/", root);
const checkpointUrl = new URL("v321-cohort-checkpoint.json", artifacts);
const outputUrl = new URL("v321-cohort.json", artifacts);
const qaUrl = new URL("v321-cohort-qa.json", artifacts);
const real = Deno.args.includes("--real");
const preflight = Deno.args.includes("--preflight");
const apiKey = Deno.env.get("OPENAI_API_KEY");
const model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL");
const contextsArtifact = JSON.parse(
  await Deno.readTextFile(new URL("context-audit-v2.json", artifacts)),
);
const freeze = JSON.parse(
  await Deno.readTextFile(new URL("v3.2-freeze.json", artifacts)),
);
const contexts = contextsArtifact.contexts.filter((row: any) =>
  V321_COHORT_IDENTITIES.includes(row.identity)
);
if (
  contexts.length !== 30 ||
  new Set(contexts.map((row: any) => `${row.identity}|${row.scenarioId}`))
      .size !== 30
) throw new Error("v3.2.1 exact cohort preflight failed");
if (preflight) {
  console.log(JSON.stringify(
    {
      passed: true,
      developmentOnly: true,
      version: V321_VERSION,
      providerCalls: 0,
      contexts: contexts.length,
      sourceSha256: freeze.sourceSha256,
      model,
      output: outputUrl.pathname,
      productionWritePaths: [],
    },
    null,
    2,
  ));
  Deno.exit(0);
}
if (!real || !apiKey || model !== "gpt-5.6-terra") {
  throw new Error(
    "Use --real with OPENAI_API_KEY and OPENAI_IDENTITY_LENS_MODEL=gpt-5.6-terra.",
  );
}
await Deno.mkdir(artifacts, { recursive: true });
let outputs: any[] = [];
try {
  outputs = JSON.parse(await Deno.readTextFile(checkpointUrl)).outputs;
} catch { /* first run */ }
for (const row of contexts) {
  const key = `${row.identity}|${row.scenarioId}`;
  if (outputs.some((output) => output.key === key && output.result.accepted)) {
    continue;
  }
  const events: any[] = [];
  const provider = buildReliableOpenAIProvider({
    apiKey,
    model,
    instructions: buildV321SystemPrompt(),
    events,
  });
  const result = await writeModelLensV3({
    request: {
      context: row.context,
      reasoning: row.reasoning,
      scenario: row.context.scenario,
    },
    provider,
    brief: buildV32EditorialBrief(row.identity, row.arena),
    promptVersion: "v3.2",
  });
  outputs = outputs.filter((output) => output.key !== key);
  outputs.push({
    key,
    identity: row.identity,
    arena: row.arena,
    scenarioId: row.scenarioId,
    result,
    transportEvents: events,
  });
  await Deno.writeTextFile(
    checkpointUrl,
    JSON.stringify(
      { version: V321_VERSION, sourceSha256: freeze.sourceSha256, outputs },
      null,
      2,
    ) + "\n",
  );
  console.log(`${key}: ${result.accepted ? "accepted" : "rejected"}`);
}
const accepted = outputs.filter((output) => output.result.accepted);
const attempts = outputs.flatMap((output) => output.result.attempts);
const qa = auditV321Cohort(
  accepted.map((output) => ({
    identity: output.identity,
    scenarioId: output.scenarioId,
    arena: output.arena,
    lens: output.result.finalLens,
  })),
);
const summary = {
  developmentOnly: true,
  version: V321_VERSION,
  sourceSha256: freeze.sourceSha256,
  model,
  outputCount: outputs.length,
  accepted: accepted.length,
  rejected: outputs.length - accepted.length,
  providerCalls: attempts.length,
  schemaRetries: accepted.reduce(
    (sum, output) => sum + output.result.retryCount,
    0,
  ),
  totalTokens: attempts.reduce(
    (sum, attempt) => sum + Number(attempt.usage?.total_tokens ?? 0),
    0,
  ),
  validFieldPreservation: attempts.every((attempt) =>
    attempt.validFieldsPreserved
  ),
  outputs,
};
await Deno.writeTextFile(outputUrl, JSON.stringify(summary, null, 2) + "\n");
await Deno.writeTextFile(qaUrl, JSON.stringify(qa, null, 2) + "\n");
console.log(JSON.stringify(summary, null, 2));
