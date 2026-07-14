/** Provider-free Validator Heuristic Correction v1 overlay for frozen Run 2. */
import { validateOneParagraphLens } from "../canonical-lens-production-preview/one_paragraph_writer_v4.ts";
import { outputKeepsPersonalActor } from "../canonical-lens-production-preview/person_first_specificity.ts";
import {
  unsupportedAdditionErrorsV1,
  VALIDATOR_HEURISTIC_CORRECTION_V1,
} from "./v4_writer_unsupported_additions_v1.ts";

const root = new URL("./", import.meta.url);
const run2Path = new URL(
  "./artifacts/development-editorial-reasoning-v1-four-case-v4-writer-pilot-run-2/output-qa.json",
  root,
);
const outputPath = new URL(
  "./artifacts/development-editorial-reasoning-v1-four-case-v4-writer-pilot-run-2-validator-heuristic-correction-v1.json",
  root,
);

function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}

async function writeFrozen(path: URL, value: unknown): Promise<void> {
  const next = stable(value);
  try {
    const existing = await Deno.readTextFile(path);
    if (existing !== next) throw new Error(`Existing frozen artifact differs: ${path.pathname}`);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      await Deno.writeTextFile(path, next);
      return;
    }
    throw error;
  }
}

const run2 = JSON.parse(await Deno.readTextFile(run2Path));
if (run2.run_version !== "pcv1-editorial-reasoning-v1-four-case-v4-writer-pilot-run-2" ||
  !Array.isArray(run2.cases) || run2.cases.length !== 4) {
  throw new Error("Frozen Run 2 four-case artifact is unavailable or has an unexpected shape.");
}

const cases = run2.cases.map((item: any) => {
  if (!item.parsed_output || !item.writer_input) {
    throw new Error(`Frozen Run 2 output is unavailable: ${item.stable_reasoning_record_id}`);
  }
  const structural = validateOneParagraphLens(item.parsed_output, { blockedPhrases: [] });
  const actorErrors = outputKeepsPersonalActor(item.parsed_output.read)
    ? []
    : ["read does not preserve an explicit user actor"];
  const additionErrors = unsupportedAdditionErrorsV1(item.parsed_output, item.writer_input);
  const errors = [...structural.errors, ...actorErrors, ...additionErrors];
  return {
    stable_reasoning_record_id: item.stable_reasoning_record_id,
    identity: item.identity,
    arena: item.arena,
    original_run2_result: item.result,
    original_validation: item.validation,
    frozen_output: item.parsed_output,
    corrected_validator: {
      version: VALIDATOR_HEURISTIC_CORRECTION_V1,
      schema_errors: structural.errors,
      actor_errors: actorErrors,
      unsupported_addition_errors: additionErrors,
      would_accept: errors.length === 0,
      errors,
    },
  };
});

const revalidation = {
  developmentOnly: true,
  purpose:
    "Provider-free Validator Heuristic Correction v1 overlay. It does not modify frozen Run 2 results, outputs, prompts, provider metadata, or artifacts.",
  validator_version: VALIDATOR_HEURISTIC_CORRECTION_V1,
  source_run2_artifact: run2Path.pathname,
  original_run2_result: run2.summary.result,
  cases,
  summary: {
    original_accepted: run2.summary.passed_cases,
    original_rejected: run2.summary.failed_cases,
    corrected_would_accept: cases.filter((item: any) => item.corrected_validator.would_accept).length,
    corrected_would_reject: cases.filter((item: any) => !item.corrected_validator.would_accept).length,
    changed_disposition_cases: cases.filter((item: any) =>
      item.original_run2_result !== (item.corrected_validator.would_accept ? "PASS" : "FAIL")
    ).map((item: any) => item.stable_reasoning_record_id),
  },
  providerCalls: 0,
  writerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  rolloutChanges: [],
  deploymentChanges: [],
};

await writeFrozen(outputPath, revalidation);
console.log(JSON.stringify(revalidation, null, 2));
