import {
  buildOneParagraphPromptV4,
  type OneParagraphLens,
  validateOneParagraphLens,
} from "../canonical-lens-production-preview/one_paragraph_writer_v4.ts";
import { outputKeepsPersonalActor } from "../canonical-lens-production-preview/person_first_specificity.ts";
import {
  auditLightweightRepetition,
  type FinalRead,
} from "./lightweight_repetition.ts";
import { unsupportedAdditionErrors } from "./v4_writer_unsupported_additions.ts";

type WriterInput = {
  stable_case_id: string;
  identity: string;
  neutral_situation: string;
  plain_insight: string;
  plain_action: string | null;
  source_calibration_status: "APPROVE" | "NARROW";
};

type WriterInputArtifact = {
  developmentOnly: true;
  status: string;
  cases: WriterInput[];
};

type WriterRow = {
  stable_case_id: string;
  status: "ACCEPTED" | "TERMINAL_REJECTED" | "INCOMPLETE_TRANSPORT_FAILURE";
  input_sha256: string;
  prompt_sha256: string;
  writer_input: { plain_insight: string; plain_action: string | null };
  started_at: string;
  completed_at: string | null;
  latency_ms: number | null;
  raw_provider_response: unknown | null;
  raw_response: string | null;
  parsed: OneParagraphLens | null;
  validation: Record<string, unknown>;
  usage: unknown | null;
  provider: string;
  model: string;
  configuration_sha256: string;
  prompt_fingerprint: string;
  retries: 0;
  transport_error?: string;
  http_status?: number;
};

const root = new URL("./", import.meta.url);
const artifacts = new URL("./artifacts/", root);
const previewArtifacts = new URL(
  "../canonical-lens-production-preview/artifacts/",
  root,
);
const previewRoot = new URL("../canonical-lens-production-preview/", root);
const inputsPath = new URL(
  "production-candidate-v1-writer-inputs-v2.json",
  artifacts,
);
const blocksPath = new URL(
  "production-candidate-v1-terminal-blocks-v1.json",
  artifacts,
);
const freezePath = new URL(
  "production-candidate-v1-writer-inputs-freeze-v2.json",
  artifacts,
);
const goldPath = new URL(
  "v321-one-paragraph-gold-set-v1.json",
  previewArtifacts,
);
const v4ContractPath = new URL(
  "v321-one-paragraph-writer-contract-v4.md",
  previewArtifacts,
);
const v4WriterSourcePath = new URL("one_paragraph_writer_v4.ts", previewRoot);
const historicalV4ConfigPath = new URL(
  "v321-one-paragraph-unseen-10-v4-run-config.json",
  previewArtifacts,
);
const preflightPath = new URL(
  "production-candidate-v1-v4-writer-preflight-v1.json",
  artifacts,
);
const preflightMarkdownPath = new URL(
  "production-candidate-v1-v4-writer-preflight-v1.md",
  artifacts,
);
const configPath = new URL(
  "production-candidate-v1-v4-writer-run-config-v1.json",
  artifacts,
);
const checkpointDirectory = new URL(
  "production-candidate-v1-v4-writer-checkpoints/",
  artifacts,
);
const generationPath = new URL(
  "production-candidate-v1-v4-writer-generation-v1.json",
  artifacts,
);
const blindReviewJsonPath = new URL(
  "production-candidate-v1-v4-writer-blind-review-v1.json",
  artifacts,
);
const blindReviewMarkdownPath = new URL(
  "production-candidate-v1-v4-writer-blind-review-v1.md",
  artifacts,
);

const EXPECTED_INPUTS_SHA =
  "37cc447f7b161708d086ee86635d9c9e5e435879af4a46aef801db8e94502243";
const EXPECTED_GOLD_SHA =
  "b78ce5067559cbe72f94db777697279e12b08657ad582cc102ee043e1190a646";

function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return Array.from(new Uint8Array(digest)).map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

async function readJson<T>(path: URL): Promise<T> {
  return JSON.parse(await Deno.readTextFile(path)) as T;
}

async function readJsonIfPresent<T>(path: URL): Promise<T | null> {
  try {
    return await readJson<T>(path);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return null;
    throw error;
  }
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

function outputText(payload: any): string {
  return payload.output?.flatMap((item: any) => item.content ?? []).find(
    (part: any) => part.type === "output_text",
  )?.text ?? "";
}

function parseJson(raw: string): unknown | null {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function contentWords(value: string): Set<string> {
  return new Set(
    value.toLowerCase().replace(/[^a-z0-9 ]/g, " ").split(/\s+/).filter(
      (word) =>
        word.length > 3 &&
        !new Set([
          "when",
          "that",
          "with",
          "from",
          "your",
          "have",
          "what",
          "this",
          "they",
          "them",
          "about",
          "before",
          "after",
          "into",
          "again",
        ]).has(word),
    ),
  );
}

function meaningPreservationErrors(
  result: OneParagraphLens,
  input: WriterInput,
): string[] {
  const errors: string[] = [];
  const outputWords = contentWords(`${result.title} ${result.read}`);
  const insightWords = contentWords(input.plain_insight);
  const insightOverlap =
    [...insightWords].filter((word) => outputWords.has(word))
      .length;
  if (insightOverlap < Math.min(2, insightWords.size)) {
    errors.push(
      "output does not retain enough concrete meaning from plain_insight",
    );
  }
  if (input.plain_action !== null) {
    const actionWords = contentWords(input.plain_action);
    const actionOverlap = [...actionWords].filter((word) =>
      outputWords.has(word)
    )
      .length;
    if (actionOverlap < 1) {
      errors.push(
        "output does not retain a concrete element of supplied plain_action",
      );
    }
  }
  return errors;
}

function validateFinalOutput(value: unknown, input: WriterInput) {
  const structural = validateOneParagraphLens(value, { blockedPhrases: [] });
  if (structural.errors.length > 0 || !value || typeof value !== "object") {
    return {
      accepted: false,
      schema_errors: structural.errors,
      schema_flags: structural.flags,
      meaning_errors: [],
      actor_errors: [],
      unsupported_addition_errors: [],
      errors: structural.errors,
    };
  }
  const result = value as OneParagraphLens;
  const actor_errors = outputKeepsPersonalActor(result.read)
    ? []
    : ["read does not preserve an explicit user actor"];
  const meaning_errors = meaningPreservationErrors(result, input);
  const unsupported_addition_errors = unsupportedAdditionErrors(result, input);
  const errors = [
    ...structural.errors,
    ...meaning_errors,
    ...actor_errors,
    ...unsupported_addition_errors,
  ];
  return {
    accepted: errors.length === 0,
    schema_errors: structural.errors,
    schema_flags: structural.flags,
    meaning_errors,
    actor_errors,
    unsupported_addition_errors,
    errors,
  };
}

function checkpointPath(stableCaseId: string): URL {
  return new URL(`${stableCaseId}.json`, checkpointDirectory);
}

function verifiedCompletedRow(
  row: WriterRow,
  input: WriterInput,
  configurationSha: string,
  inputSha: string,
  promptSha: string,
): boolean {
  if (
    !["ACCEPTED", "TERMINAL_REJECTED"].includes(row.status) ||
    row.configuration_sha256 !== configurationSha ||
    row.input_sha256 !== inputSha ||
    row.prompt_sha256 !== promptSha ||
    row.retries !== 0 ||
    row.stable_case_id !== input.stable_case_id ||
    !row.completed_at ||
    row.raw_provider_response === null
  ) return false;
  if (row.status === "TERMINAL_REJECTED" && row.parsed === null) return true;
  return JSON.stringify(validateFinalOutput(row.parsed, input)) ===
    JSON.stringify(row.validation);
}

function blindReview(rows: WriterRow[]) {
  const ordered = [...rows].sort((left, right) =>
    left.prompt_sha256.localeCompare(right.prompt_sha256)
  );
  const samples = ordered.map((row, index) => ({
    sample: `Sample ${String(index + 1).padStart(2, "0")}`,
    title: row.parsed?.title ?? "",
    read: row.parsed?.read ?? "",
    review_fields: {
      immediate_understanding: "",
      natural_conversation: "",
      insight_preserved: "",
      action_used_well: "",
      title_fits: "",
      overall: "pass / minor issue / fail",
      notes: "",
    },
  }));
  const json = {
    developmentOnly: true,
    purpose:
      "Blind product review of writer-only v4 outputs. The primary samples do not reveal identity, situation, selector content, or provider metadata.",
    samples,
    reveal_mapping: ordered.map((row, index) => ({
      sample: `Sample ${String(index + 1).padStart(2, "0")}`,
      stable_case_id: row.stable_case_id,
      status: row.status,
      had_plain_action: row.writer_input.plain_action !== null,
    })),
  };
  const markdown = [
    "# Production Candidate v1 — v4 Writer Blind Review",
    "",
    "Judge only the copy. Identity, situation, insight, action, and provider details are intentionally absent.",
    "",
    ...samples.flatMap((sample) => [
      `## ${sample.sample}`,
      "",
      sample.title ? `**${sample.title}**` : "_No valid title returned._",
      "",
      sample.read || "_No valid read returned._",
      "",
      "- Immediately understandable: yes / no",
      "- Sounds like normal conversation: yes / no",
      "- Preserves one clear idea: yes / no",
      "- Action used well: yes / no / no action",
      "- Title fits: yes / no",
      "- Overall: pass / minor issue / fail",
      "- Notes:",
      "",
    ]),
  ].join("\n");
  return { json, markdown };
}

const mode = Deno.args[0];
if (
  Deno.args.length !== 1 || !["--preflight", "--real-writer"].includes(mode)
) {
  throw new Error(
    "Production Candidate v1 v4 writer runner supports only --preflight and --real-writer. It never invokes the selector or action-generation stages.",
  );
}

const [
  inputsText,
  blocksText,
  freeze,
  goldText,
  v4ContractText,
  v4SourceText,
  historicalV4Config,
] = await Promise.all([
  Deno.readTextFile(inputsPath),
  Deno.readTextFile(blocksPath),
  readJson<{ writer_inputs: { sha256: string; cases: number } }>(freezePath),
  Deno.readTextFile(goldPath),
  Deno.readTextFile(v4ContractPath),
  Deno.readTextFile(v4WriterSourcePath),
  readJson<{ goldSet: { sha256: string } }>(historicalV4ConfigPath),
]);
const inputs = JSON.parse(inputsText) as WriterInputArtifact;
const blocks = JSON.parse(blocksText) as {
  cases: Array<{ stable_case_id: string }>;
};
const gold = JSON.parse(goldText) as {
  status: string;
  cases: Array<{ title: string; read: string }>;
};
const inputSha = await sha256(inputsText);
const goldSha = await sha256(goldText);
if (
  inputs.status !== "FROZEN_PRODUCTION_CANDIDATE_V1_WRITER_INPUTS" ||
  inputSha !== EXPECTED_INPUTS_SHA ||
  freeze.writer_inputs.sha256 !== EXPECTED_INPUTS_SHA
) throw new Error("Frozen v2 writer-input SHA-256 does not match.");
if (
  inputs.cases.length !== 19 ||
  new Set(inputs.cases.map((item) => item.stable_case_id)).size !== 19 ||
  freeze.writer_inputs.cases !== 19
) {
  throw new Error(
    "Frozen v2 writer inputs must contain exactly 19 stable cases.",
  );
}
if (
  inputs.cases.some((item) =>
    blocks.cases.some((blocked) =>
      blocked.stable_case_id === item.stable_case_id
    )
  )
) throw new Error("A terminal BLOCK case entered the writer-input freeze.");
if (
  gold.status !== "FROZEN_APPROVED_GOLD_SET_V1" ||
  gold.cases.length !== 5 ||
  goldSha !== EXPECTED_GOLD_SHA || goldSha !== historicalV4Config.goldSet.sha256
) {
  throw new Error(
    "Frozen v4 Gold Set does not match the approved language architecture.",
  );
}

// The v4 contract has a clarity-status line. Every case uses the same conservative
// PARTIAL setting so source APPROVE/NARROW status is never revealed to the writer.
const writerCases = await Promise.all(inputs.cases.map(async (item) => {
  const prompt = buildOneParagraphPromptV4({
    caseId: item.stable_case_id,
    clarityStatus: "PARTIAL",
    plainInsight: item.plain_insight,
    plainAction: item.plain_action,
    goldExamples: gold.cases,
  });
  const forbiddenValues = [
    item.identity,
    item.neutral_situation,
    "selector",
    "canonical evidence",
  ];
  if (
    forbiddenValues.some((value) =>
      prompt.toLowerCase().includes(value.toLowerCase())
    )
  ) {
    throw new Error(`Writer boundary leakage: ${item.stable_case_id}`);
  }
  return {
    input: item,
    prompt,
    input_sha256: await sha256(stable({
      plain_insight: item.plain_insight,
      plain_action: item.plain_action,
    })),
    prompt_sha256: await sha256(prompt),
  };
}));
const v4ContractSha = await sha256(v4ContractText);
const v4WriterSourceSha = await sha256(v4SourceText);
const preflight = {
  passed: true,
  developmentOnly: true,
  mode: "writer-only-v4",
  writer_inputs: { path: inputsPath.pathname, sha256: inputSha, cases: 19 },
  terminal_blocks_present: false,
  writer_boundary: {
    receives: [
      "plain_insight",
      "plain_action",
      "frozen_v4_instructions",
      "gold_examples",
    ],
    withholds: [
      "identity",
      "neutral_situation",
      "selector_output",
      "canonical_evidence",
      "source_calibration_status",
      "audit_language",
    ],
    source_status_mode: "uniform PARTIAL; no per-case status is exposed",
  },
  v4_contract: {
    path: v4ContractPath.pathname,
    sha256: v4ContractSha,
    writer_source_sha256: v4WriterSourceSha,
    gold_set_sha256: goldSha,
    matches_approved_gold_set: true,
  },
  prompt_fingerprints: writerCases.map((item) => ({
    stable_case_id: item.input.stable_case_id,
    sha256: item.prompt_sha256,
    writer_boundary_isolated: true,
  })),
  final_output_shape: ["title", "read"],
  validation_order: [
    "exact_schema",
    "meaning_preservation",
    "user_actor_preservation",
    "unsupported_addition_check",
    "lightweight_repetition_audit",
  ],
  retry_policy: { writer_attempts_per_case: 1, quality_retries: 0 },
  resume: {
    accepted_checkpoint_requires_input_and_prompt_fingerprint: true,
    only_incomplete_transport_failures_resume: true,
    accepted_writer_regenerated: false,
  },
  selector_calls: 0,
  action_generation_calls: 0,
  writer_calls: 0,
  provider_calls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};

await Deno.mkdir(artifacts, { recursive: true });
await writeFrozen(preflightPath, preflight);
await Deno.writeTextFile(
  preflightMarkdownPath,
  `# Production Candidate v1 — Isolated v4 Writer Preflight\n\n**Result:** PASS\n\n- Frozen writer inputs: 19\n- Writer-input SHA-256: \`${inputSha}\`\n- Terminal blocks in writer path: 0\n- Provider, selector, action, and writer calls: 0\n- Production and shadow writes: 0\n\n## Deliberate boundary\n\nThe writer receives only each frozen plain insight, optional plain action, and the approved v4 language contract with Gold examples. Per-case identity, situation, selector output, canonical evidence, calibration status, and audit language are withheld.\n\nEvery case uses the same conservative v4 PARTIAL instruction so the writer never sees an APPROVE/NARROW distinction.\n`,
);

if (mode === "--preflight") {
  console.log(JSON.stringify(preflight, null, 2));
  Deno.exit(0);
}

const apiKey = Deno.env.get("OPENAI_API_KEY");
const model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL");
if (!apiKey || !model) {
  throw new Error(
    "Writer-only execution requires a rotated OPENAI_API_KEY and explicit OPENAI_IDENTITY_LENS_MODEL.",
  );
}
const configurationCore = {
  developmentOnly: true,
  mode: "writer-only-v4",
  provider: "openai",
  model,
  endpoint: "https://api.openai.com/v1/responses",
  response_format: "json_object",
  writer_inputs_sha256: inputSha,
  v4_contract_sha256: v4ContractSha,
  v4_writer_source_sha256: v4WriterSourceSha,
  gold_set_sha256: goldSha,
  prompt_fingerprints: Object.fromEntries(
    writerCases.map((item) => [item.input.stable_case_id, item.prompt_sha256]),
  ),
  retry_policy: preflight.retry_policy,
  selector_calls: 0,
  action_generation_calls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
};
const configuration_sha256 = await sha256(stable(configurationCore));
const configuration = { ...configurationCore, configuration_sha256 };
await writeFrozen(configPath, configuration);
if (await readJsonIfPresent(generationPath)) {
  throw new Error(
    "A frozen writer generation already exists. Do not rerun this paid cohort; use a provider-free validation overlay for any validator correction.",
  );
}
await Deno.mkdir(checkpointDirectory, { recursive: true });

for (const item of writerCases) {
  const path = checkpointPath(item.input.stable_case_id);
  const existing = await readJsonIfPresent<WriterRow>(path);
  if (
    existing && verifiedCompletedRow(
      existing,
      item.input,
      configuration_sha256,
      item.input_sha256,
      item.prompt_sha256,
    )
  ) continue;
  const started_at = new Date().toISOString();
  const started = performance.now();
  let response: Response;
  try {
    response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        input: item.prompt,
        text: { format: { type: "json_object" } },
      }),
    });
  } catch (error) {
    await Deno.writeTextFile(
      path,
      stable(
        {
          stable_case_id: item.input.stable_case_id,
          status: "INCOMPLETE_TRANSPORT_FAILURE",
          input_sha256: item.input_sha256,
          prompt_sha256: item.prompt_sha256,
          writer_input: {
            plain_insight: item.input.plain_insight,
            plain_action: item.input.plain_action,
          },
          started_at,
          completed_at: null,
          latency_ms: Math.round(performance.now() - started),
          raw_provider_response: null,
          raw_response: null,
          parsed: null,
          validation: {},
          usage: null,
          provider: "openai",
          model,
          configuration_sha256,
          prompt_fingerprint: v4WriterSourceSha,
          retries: 0,
          transport_error: error instanceof Error
            ? error.message
            : "network failure",
        } satisfies WriterRow,
      ),
    );
    throw error;
  }
  const body = await response.text();
  if (!response.ok) {
    await Deno.writeTextFile(
      path,
      stable(
        {
          stable_case_id: item.input.stable_case_id,
          status: "INCOMPLETE_TRANSPORT_FAILURE",
          input_sha256: item.input_sha256,
          prompt_sha256: item.prompt_sha256,
          writer_input: {
            plain_insight: item.input.plain_insight,
            plain_action: item.input.plain_action,
          },
          started_at,
          completed_at: null,
          latency_ms: Math.round(performance.now() - started),
          raw_provider_response: body,
          raw_response: null,
          parsed: null,
          validation: {},
          usage: null,
          provider: "openai",
          model,
          configuration_sha256,
          prompt_fingerprint: v4WriterSourceSha,
          retries: 0,
          http_status: response.status,
        } satisfies WriterRow,
      ),
    );
    throw new Error(
      `OpenAI ${response.status}: writer-only request stopped; rerun resumes verified completed cases.`,
    );
  }
  const raw_provider_response = JSON.parse(body);
  const raw_response = outputText(raw_provider_response);
  const parsed = parseJson(raw_response) as OneParagraphLens | null;
  const validation = validateFinalOutput(parsed, item.input);
  const row: WriterRow = {
    stable_case_id: item.input.stable_case_id,
    status: validation.accepted ? "ACCEPTED" : "TERMINAL_REJECTED",
    input_sha256: item.input_sha256,
    prompt_sha256: item.prompt_sha256,
    writer_input: {
      plain_insight: item.input.plain_insight,
      plain_action: item.input.plain_action,
    },
    started_at,
    completed_at: new Date().toISOString(),
    latency_ms: Math.round(performance.now() - started),
    raw_provider_response,
    raw_response,
    parsed,
    validation,
    usage: raw_provider_response.usage ?? null,
    provider: "openai",
    model,
    configuration_sha256,
    prompt_fingerprint: v4WriterSourceSha,
    retries: 0,
  };
  await Deno.writeTextFile(path, stable(row));
}

const rows = await Promise.all(writerCases.map(async (item) => {
  const row = await readJson<WriterRow>(
    checkpointPath(item.input.stable_case_id),
  );
  if (
    !verifiedCompletedRow(
      row,
      item.input,
      configuration_sha256,
      item.input_sha256,
      item.prompt_sha256,
    )
  ) {
    throw new Error(
      `Writer-only run is incomplete: ${item.input.stable_case_id}`,
    );
  }
  return row;
}));
const acceptedReads: FinalRead[] = rows.filter((row) =>
  row.status === "ACCEPTED" && row.parsed !== null
).map((row) => ({
  stableCaseId: row.stable_case_id,
  title: row.parsed!.title,
  read: row.parsed!.read,
  plainInsight: row.writer_input.plain_insight,
  plainAction: row.writer_input.plain_action,
}));
const repetition = auditLightweightRepetition(acceptedReads);
const generation = {
  developmentOnly: true,
  status: "FROZEN_PRODUCTION_CANDIDATE_V1_V4_WRITER_GENERATION",
  configuration_sha256,
  provider: `openai:${model}`,
  provider_calls: rows.length,
  accepted: rows.filter((row) => row.status === "ACCEPTED").length,
  terminal_rejected:
    rows.filter((row) => row.status === "TERMINAL_REJECTED").length,
  retries: 0,
  selector_calls: 0,
  action_generation_calls: 0,
  lightweight_repetition: repetition,
  rows,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};
const blind = blindReview(rows);
await Promise.all([
  writeFrozen(generationPath, generation),
  writeFrozen(blindReviewJsonPath, blind.json),
  Deno.writeTextFile(blindReviewMarkdownPath, blind.markdown),
]);
console.log(JSON.stringify(
  {
    developmentOnly: true,
    configuration_sha256,
    provider: generation.provider,
    providerCalls: generation.provider_calls,
    accepted: generation.accepted,
    terminalRejected: generation.terminal_rejected,
    retries: 0,
    selectorCalls: 0,
    actionGenerationCalls: 0,
    repetitionDisposition: repetition.disposition,
    generation: generationPath.pathname,
    blindReview: blindReviewMarkdownPath.pathname,
    productionWritePaths: [],
    shadowWritePaths: [],
  },
  null,
  2,
));
