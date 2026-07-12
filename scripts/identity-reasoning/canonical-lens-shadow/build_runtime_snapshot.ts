// Produces the deployable, read-only input snapshot for the manual shadow path.
// It deliberately copies no generated Lens output and performs no provider calls.
import { V32_MODEL_WRITING_SYSTEM } from "../canonical-lens-production-preview/v3_prompt.ts";
import { buildV32EditorialBrief } from "../canonical-lens-production-preview/v3_sample_plan.ts";

const root = new URL("../canonical-lens-production-preview/", import.meta.url);
const artifacts = new URL("artifacts/", root);
const destination = new URL(
  "../../../supabase/functions/_shared/canonical-lens-v3-2/runtime_snapshot.json",
  import.meta.url,
);
const read = async (file: string) =>
  JSON.parse(await Deno.readTextFile(new URL(file, artifacts)));
const freeze = await read("v3.2-freeze.json");
const audit = await read("context-audit-v2.json");

const snapshot = {
  frozenVersion: "canonical-lens-v3.2",
  sourceSha256: freeze.sourceSha256,
  codeSha256: freeze.codeSha256,
  prompt: V32_MODEL_WRITING_SYSTEM,
  scenarios: audit.contexts.reduce((all: Record<string, unknown>, row: any) => {
    all[row.scenarioId] ??= row.context.scenario;
    return all;
  }, {}),
  contexts: audit.contexts.map((row: any) => ({
    key: `${row.identity}|${row.scenarioId}`,
    identity: row.identity,
    arena: row.arena,
    scenarioId: row.scenarioId,
    context: row.context,
    reasoning: row.reasoning,
    editorialBrief: buildV32EditorialBrief(row.identity, row.arena),
  })),
};

await Deno.mkdir(new URL(".", destination), { recursive: true });
await Deno.writeTextFile(destination, JSON.stringify(snapshot, null, 2) + "\n");
console.log(
  `Wrote ${snapshot.contexts.length} frozen contexts to ${destination.pathname}`,
);
