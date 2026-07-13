import { validateOneParagraphLens } from "../canonical-lens-production-preview/one_paragraph_writer_v4.ts";
import { outputKeepsPersonalActor } from "../canonical-lens-production-preview/person_first_specificity.ts";
import { unsupportedAdditionErrors } from "./v4_writer_unsupported_additions.ts";

const artifacts = new URL("./artifacts/", import.meta.url);
const generationPath = new URL(
  "production-candidate-v1-v4-writer-generation-v1.json",
  artifacts,
);
const outputPath = new URL(
  "production-candidate-v1-v4-writer-sample08-validator-revalidation-v1.json",
  artifacts,
);

function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}

async function writeFrozen(path: URL, value: unknown): Promise<void> {
  const next = stable(value);
  try {
    const existing = await Deno.readTextFile(path);
    if (existing !== next) {
      throw new Error(`Existing frozen artifact differs: ${path.pathname}`);
    }
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      await Deno.writeTextFile(path, next);
      return;
    }
    throw error;
  }
}

const generation = JSON.parse(await Deno.readTextFile(generationPath));
const sample = generation.rows.find((row: any) =>
  row.stable_case_id ===
    "pcv1-unseen-24-scorpio-x-dragon-recognition-public-credit-neutral"
);
if (!sample || !sample.parsed) {
  throw new Error("Frozen Sample 08 is unavailable.");
}
const structural = validateOneParagraphLens(sample.parsed, {
  blockedPhrases: [],
});
const actorErrors = outputKeepsPersonalActor(sample.parsed.read)
  ? []
  : ["read does not preserve an explicit user actor"];
const additionErrors = unsupportedAdditionErrors(
  sample.parsed,
  sample.writer_input,
);
const revalidation = {
  developmentOnly: true,
  purpose:
    "Provider-free validation overlay for frozen Sample 08. It does not change the original generation status or any stored provider output.",
  source_generation: generationPath.pathname,
  stable_case_id: sample.stable_case_id,
  original_status: sample.status,
  input_output_verbatim_match:
    sample.writer_input.plain_insight === sample.parsed.read,
  original_validation: sample.validation,
  revalidated: {
    schema_errors: structural.errors,
    actor_errors: actorErrors,
    unsupported_addition_errors: additionErrors,
    would_accept: structural.errors.length === 0 && actorErrors.length === 0 &&
      additionErrors.length === 0,
  },
  providerCalls: 0,
  writerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
};
await writeFrozen(outputPath, revalidation);
console.log(JSON.stringify(revalidation, null, 2));
