import {
  assessPersonFirstSpecificity,
} from "../canonical-lens-production-preview/person_first_specificity.ts";
import {
  assessHumanLanguage,
} from "../canonical-lens-production-preview/human_language_calibration.ts";
import {
  type NeutralInsightSelectorResult,
  type SelectorEvidence,
  validateNeutralInsightSelectorResult,
} from "../canonical-lens-production-preview/neutral_insight_selector_validate.ts";

type EvidenceCase = {
  stable_case_id: string;
  identity: string;
  domain: string;
  neutral_situation: {
    id: string;
    situation: string;
    observableFacts: string[];
  };
  canonical_identity: {
    sign_pair: string;
    archetype_name: string;
    version: string;
    identity_sha256: string;
  };
  candidate_evidence: Array<SelectorEvidence & { source: string }>;
  checkpoint_paths: { selector: string; writer: string };
};

type EvidencePayload = {
  status: string;
  matrix: { sha256: string };
  canonicalLibrary: { sourceSha256: string; fileSha256: string };
  cases: EvidenceCase[];
  sha256: string;
};

type CanonicalIdentity = Record<string, unknown> & { signPair: string };

type SelectorRow = {
  stable_case_id: string;
  status:
    | "SELECTED"
    | "BLOCKED"
    | "TERMINAL_REJECTED"
    | "INCOMPLETE_TRANSPORT_FAILURE";
  input_sha256: string;
  prompt_sha256: string;
  selector_input: string;
  identity: string;
  domain: string;
  neutral_situation: EvidenceCase["neutral_situation"];
  canonical_identity: EvidenceCase["canonical_identity"];
  candidate_evidence: EvidenceCase["candidate_evidence"];
  started_at: string;
  completed_at: string | null;
  latency_ms: number | null;
  raw_provider_response: unknown | null;
  raw_response: string | null;
  parsed: NeutralInsightSelectorResult | null;
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
const canonicalLibraryPath = new URL(
  "canonical-library-v2.json",
  previewArtifacts,
);
const evidencePayloadPath = new URL(
  "production-candidate-v1-evidence-payload.json",
  artifacts,
);
const matrixPath = new URL(
  "production-candidate-v1-unseen-24-matrix.json",
  artifacts,
);
const stageContractsPath = new URL(
  "production-candidate-v1-runner-stage-contracts-v2.json",
  artifacts,
);
const historicalConfigPath = new URL(
  "v321-neutral-insight-selector-json-input-fix-run-config-v1.json",
  previewArtifacts,
);
const preflightPath = new URL(
  "production-candidate-v1-selector-only-preflight-v1.json",
  artifacts,
);
const preflightMarkdownPath = new URL(
  "production-candidate-v1-selector-only-preflight-v1.md",
  artifacts,
);
const configPath = new URL(
  "production-candidate-v1-selector-only-run-config-v1.json",
  artifacts,
);
const runCheckpointPath = new URL(
  "production-candidate-v1-selector-only-checkpoint-v1.json",
  artifacts,
);
const generationPath = new URL(
  "production-candidate-v1-selector-only-generation-v1.json",
  artifacts,
);
const reviewJsonPath = new URL(
  "production-candidate-v1-selector-only-human-review-v1.json",
  artifacts,
);
const reviewMarkdownPath = new URL(
  "production-candidate-v1-selector-only-human-review-v1.md",
  artifacts,
);
const worksheetJsonPath = new URL(
  "production-candidate-v1-selector-only-calibrated-input-worksheet-v1.json",
  artifacts,
);
const worksheetMarkdownPath = new URL(
  "production-candidate-v1-selector-only-calibrated-input-worksheet-v1.md",
  artifacts,
);

const EXPECTED_MATRIX_SHA =
  "ec8d10feeecb5fc4d1233d14a8aac0008e7afa7ecd27ca77591384feedc59405";
const EXPECTED_EVIDENCE_PAYLOAD_SHA =
  "0dfd7164956ab35851542934decd85583310a42a290bb054be081fe8ae987fde";
const JSON_INPUT_PREFIX =
  "Return JSON only. Use this frozen selector input exactly as supplied:\n\n";
const SELECTOR_INSTRUCTIONS =
  `You are Neutral Insight Selector v1 for a development-only Zodian experiment.

Select at most one concrete, user-owned behavior from the supplied canonical evidence that can plausibly be relevant to the supplied neutral external situation.

Return JSON only with exactly these five fields:
status, behavior, supporting_evidence, applicability, unsupported_claims_added.

SELECTED means the supplied evidence directly supports one behavior. Cite only exact path and claim pairs from candidate_evidence. Write behavior as one ordinary observation about what the user may do, notice, avoid, check, repeat, or hesitate to do. The applicability explains only how the neutral external situation makes that cited behavior relevant.

BLOCKED means no supplied evidence supports a concrete personal behavior in this situation. For BLOCKED return behavior null, applicability null, and an empty supporting_evidence array.

Never create a title, action, corrective move, Today’s Lens copy, trait, motive, fear, desire, causal explanation, or unsupported scenario fact. Do not use words such as because, want, fear, desire, trust, bored, should, need to, try, make sure, or remember to in behavior. unsupported_claims_added must always be an empty array. The neutral situation supplies no behavior; select only from canonical evidence.`;

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

async function readJson<T>(path: URL | string): Promise<T> {
  return JSON.parse(await Deno.readTextFile(path)) as T;
}

async function readJsonIfPresent<T>(path: URL | string): Promise<T | null> {
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

function buildSelectorInput(item: EvidenceCase): string {
  return JSON_INPUT_PREFIX + JSON.stringify(
    {
      neutral_situation: item.neutral_situation,
      canonical_identity: item.canonical_identity,
      candidate_evidence: item.candidate_evidence.map(({ path, claim }) => ({
        path,
        claim,
      })),
    },
    null,
    2,
  );
}

function semanticBoundaryErrors(value: unknown): string[] {
  if (!value || typeof value !== "object" || Array.isArray(value)) return [];
  const behavior = (value as Record<string, unknown>).behavior;
  if (typeof behavior !== "string") return [];
  const errors: string[] = [];
  if (
    /\b(?:because|so that|in order to|want|fear|desire|trust|bored|always|exactly)\b/i
      .test(behavior)
  ) {
    errors.push(
      "behavior contains motive, causal explanation, or unsupported certainty language",
    );
  }
  if (/\n|:/.test(behavior)) {
    errors.push("behavior must be one observation, not title-formatted text");
  }
  return errors;
}

function directApplicabilityErrors(
  result: NeutralInsightSelectorResult,
  situation: EvidenceCase["neutral_situation"],
): string[] {
  if (result.status === "BLOCKED") return [];
  const errors: string[] = [];
  if (!situation.situation.trim() || situation.observableFacts.length === 0) {
    errors.push("neutral situation is incomplete");
  }
  if (!result.applicability?.trim()) {
    errors.push("selected behavior requires applicability");
  }
  if (
    /\b(?:because|should|must|try|make sure|remember)\b/i.test(
      result.applicability ?? "",
    )
  ) {
    errors.push("applicability adds a motive, advice, or lesson");
  }
  if (result.supporting_evidence.length === 0) {
    errors.push("selected behavior has no cited evidence");
  }
  return errors;
}

function reasoningClarity(result: NeutralInsightSelectorResult) {
  if (result.status === "BLOCKED") {
    return {
      status: "BLOCKED" as const,
      evidence_entailment: "NOT_APPLICABLE" as const,
      notes: ["BLOCKED is an explicit terminal selection outcome."],
    };
  }
  const exactCitedBehavior = result.supporting_evidence.some((evidence) =>
    evidence.claim === result.behavior
  );
  return {
    status: exactCitedBehavior
      ? "PARTIAL" as const
      : "REVIEW_REQUIRED" as const,
    evidence_entailment: exactCitedBehavior
      ? "DIRECT" as const
      : "PARAPHRASE_REVIEW" as const,
    notes: exactCitedBehavior
      ? ["Behavior exactly matches a cited canonical observation."]
      : [
        "Behavior is cited but paraphrased; human review must confirm it preserves the exact supported meaning before any calibration.",
      ],
  };
}

function validationFor(
  parsed: unknown,
  item: EvidenceCase,
): Record<string, unknown> {
  const structural_errors = validateNeutralInsightSelectorResult(
    parsed,
    item.candidate_evidence,
  );
  const boundary_errors = semanticBoundaryErrors(parsed);
  if (structural_errors.length > 0 || boundary_errors.length > 0) {
    return {
      accepted: false,
      structural_errors,
      boundary_errors,
      direct_applicability_errors: [],
      reasoning_clarity: null,
      person_first: null,
      human_language: null,
      errors: [...structural_errors, ...boundary_errors],
    };
  }
  const result = parsed as NeutralInsightSelectorResult;
  const direct_applicability_errors = directApplicabilityErrors(
    result,
    item.neutral_situation,
  );
  const clarity = reasoningClarity(result);
  const observableEvidenceCount = result.status === "SELECTED"
    ? result.supporting_evidence.filter((citation) =>
      citation.path.startsWith("evidence.observableBehaviors[")
    ).length
    : 0;
  const person_first = result.status === "SELECTED"
    ? assessPersonFirstSpecificity(
      result.behavior ?? "",
      observableEvidenceCount,
    )
    : null;
  const human_language = result.status === "SELECTED"
    ? assessHumanLanguage(result.behavior ?? "", null)
    : null;
  return {
    accepted: direct_applicability_errors.length === 0,
    structural_errors,
    boundary_errors,
    direct_applicability_errors,
    reasoning_clarity: clarity,
    person_first,
    human_language,
    errors: direct_applicability_errors,
  };
}

function completedRowIsVerified(
  row: SelectorRow,
  item: EvidenceCase,
  configurationSha: string,
  inputSha: string,
  promptSha: string,
): boolean {
  if (
    !["SELECTED", "BLOCKED", "TERMINAL_REJECTED"].includes(row.status) ||
    row.configuration_sha256 !== configurationSha ||
    row.input_sha256 !== inputSha ||
    row.prompt_sha256 !== promptSha ||
    row.retries !== 0 ||
    row.stable_case_id !== item.stable_case_id ||
    !row.completed_at
  ) return false;
  if (row.status === "TERMINAL_REJECTED") {
    return row.raw_provider_response !== null && row.validation !== null;
  }
  if (!row.parsed || row.raw_provider_response === null) return false;
  const recalculated = validationFor(row.parsed, item);
  return JSON.stringify(recalculated) === JSON.stringify(row.validation);
}

function reviewGroup(rows: SelectorRow[], item: EvidenceCase) {
  const row = rows.find((candidate) =>
    candidate.stable_case_id === item.stable_case_id
  );
  return {
    stable_case_id: item.stable_case_id,
    identity: item.identity,
    selector_status: row?.status ?? "INCOMPLETE",
    selected_behavior: row?.parsed?.behavior ?? null,
    applicability: row?.parsed?.applicability ?? null,
    cited_evidence: row?.parsed?.supporting_evidence ?? [],
    automated: row?.validation ?? null,
    review: {
      evidence_entailment: "",
      direct_applicability: "",
      person_first_specificity: "",
      human_language_naturalness: "",
      unsupported_inference: "",
      generation_eligibility: "",
      reviewer_notes: "",
    },
  };
}

function createReviewArtifacts(
  rows: SelectorRow[],
  cases: EvidenceCase[],
  configurationSha: string,
) {
  const grouped = Object.values(
    Object.groupBy(
      cases,
      (item) => `${item.domain}\u0000${item.neutral_situation.id}`,
    ),
  ).map((group) => {
    const items = group ?? [];
    return {
      domain: items[0].domain,
      neutral_scenario_id: items[0].neutral_situation.id,
      neutral_situation: items[0].neutral_situation.situation,
      observable_facts: items[0].neutral_situation.observableFacts,
      cases: items.map((item) => reviewGroup(rows, item)),
      group_review: {
        similarity_is_evidence_supported: "",
        lazy_duplication: "",
        scenario_leakage: "",
        notes: "",
      },
    };
  });
  const review = {
    developmentOnly: true,
    purpose:
      "Human review of selector results only. No selection is approved for action selection or v4 writing by this artifact.",
    configuration_sha256: configurationSha,
    writer_calls: 0,
    action_generation: "disabled",
    groups: grouped,
  };
  const worksheet = {
    developmentOnly: true,
    purpose:
      "Blank human calibration worksheet. Proposed writer inputs must be separately approved and may not be inferred automatically from selector output.",
    configuration_sha256: configurationSha,
    cases: cases.map((item) => {
      const row = rows.find((candidate) =>
        candidate.stable_case_id === item.stable_case_id
      );
      return {
        stable_case_id: item.stable_case_id,
        identity: item.identity,
        domain: item.domain,
        selector_status: row?.status ?? "INCOMPLETE",
        selected_behavior: row?.parsed?.behavior ?? null,
        cited_evidence: row?.parsed?.supporting_evidence ?? [],
        evidence_boundary: {
          allowed_claims: row?.parsed?.supporting_evidence ?? [],
          excluded_unsupported_claims: row?.parsed?.unsupported_claims_added ??
            [],
          raw_canonical_evidence_withheld_from_future_writer: true,
        },
        human_review: {
          evidence_entailment: "",
          direct_applicability: "",
          person_first_specificity: "",
          human_language_naturalness: "",
          unsupported_inference: "",
          generation_eligibility: row?.status === "BLOCKED"
            ? "NOT_ELIGIBLE_BLOCKED"
            : "HUMAN_REVIEW_REQUIRED",
          proposed_plain_insight: "",
          proposed_plain_action: null,
          approved: "",
          reviewer_notes: "",
        },
      };
    }),
  };
  const reviewMarkdown = [
    "# Production Candidate v1 — Selector-Only Human Review",
    "",
    "Review selector evidence before any action or writer stage. A selected behavior is not a writer input until the separate worksheet is human-approved.",
    "",
    ...grouped.flatMap((group) => [
      `## ${group.domain} · ${group.neutral_scenario_id}`,
      "",
      `**Situation:** ${group.neutral_situation}`,
      "",
      ...group.cases.flatMap((item) => [
        `### ${item.identity}`,
        "",
        `- Status: **${item.selector_status}**`,
        `- Selected behavior: ${item.selected_behavior ?? "None"}`,
        `- Applicability: ${item.applicability ?? "None"}`,
        "- Exact cited evidence:",
        ...(item.cited_evidence.length
          ? item.cited_evidence.map((citation: SelectorEvidence) =>
            `  - \`${citation.path}\`: ${citation.claim}`
          )
          : ["  - None"]),
        "- Review: evidence entailment [ ], direct applicability [ ], person-first specificity [ ], human-language naturalness [ ], unsupported inference [ ], generation eligibility [ ]",
        "- Notes: ",
        "",
      ]),
    ]),
  ].join("\n");
  const worksheetMarkdown = [
    "# Production Candidate v1 — Proposed Calibrated Inputs Worksheet",
    "",
    "This is intentionally blank. Do not treat selector behavior as approved plain insight or invent a plain action.",
    "",
    ...worksheet.cases.flatMap((item) => [
      `## ${item.identity} · ${item.domain}`,
      "",
      `- Case: \`${item.stable_case_id}\``,
      `- Selector status: **${item.selector_status}**`,
      `- Selected behavior: ${item.selected_behavior ?? "None"}`,
      "- Proposed plain insight: ",
      "- Proposed plain action: ",
      "- Evidence entailment: ",
      "- Direct applicability: ",
      "- Person-first specificity: ",
      "- Human-language naturalness: ",
      "- Unsupported inference: ",
      "- Generation eligibility: ",
      "- Approved: ",
      "- Notes: ",
      "",
    ]),
  ].join("\n");
  return { review, worksheet, reviewMarkdown, worksheetMarkdown };
}

const mode = Deno.args[0];
if (
  Deno.args.length !== 1 || !["--preflight", "--real-selector"].includes(mode)
) {
  throw new Error(
    "Production Candidate v1 selector runner supports only --preflight and --real-selector. It never invokes action selection or the v4 writer.",
  );
}

const [payloadText, matrixText, contractsText, historicalConfig, libraryText] =
  await Promise.all([
    Deno.readTextFile(evidencePayloadPath),
    Deno.readTextFile(matrixPath),
    Deno.readTextFile(stageContractsPath),
    readJson<{ instructions_sha256: string; inputPrefixSha256: string }>(
      historicalConfigPath,
    ),
    Deno.readTextFile(canonicalLibraryPath),
  ]);
const payload = JSON.parse(payloadText) as EvidencePayload;
const matrix = JSON.parse(matrixText) as { sha256: string; cases: unknown[] };
const library = JSON.parse(libraryText) as {
  sourceSha256: string;
  identities: CanonicalIdentity[];
};
const stageContracts = JSON.parse(contractsText) as {
  contracts: {
    neutral_insight_selector: { retries: number; providerStage: boolean };
  };
};
const { sha256: recordedPayloadSha, ...payloadCore } = payload;
const { sha256: recordedMatrixSha, ...matrixCore } = matrix;
const actualPayloadSha = await sha256(stable(payloadCore));
const actualMatrixSha = await sha256(JSON.stringify(matrixCore));

if (
  payload.status !== "FROZEN_PRODUCTION_CANDIDATE_V1_EVIDENCE_PAYLOAD" ||
  recordedPayloadSha !== EXPECTED_EVIDENCE_PAYLOAD_SHA ||
  actualPayloadSha !== EXPECTED_EVIDENCE_PAYLOAD_SHA
) throw new Error("Frozen evidence payload SHA-256 does not match.");
if (
  recordedMatrixSha !== EXPECTED_MATRIX_SHA ||
  actualMatrixSha !== EXPECTED_MATRIX_SHA ||
  payload.matrix.sha256 !== EXPECTED_MATRIX_SHA
) throw new Error("Frozen 24-case matrix SHA-256 does not match.");
if (
  payload.cases.length !== 24 ||
  new Set(payload.cases.map((item) => item.stable_case_id)).size !== 24 ||
  matrix.cases.length !== 24
) {
  throw new Error(
    "Frozen matrix must contain exactly 24 unique stable case IDs.",
  );
}
if (
  !stageContracts.contracts.neutral_insight_selector.providerStage ||
  stageContracts.contracts.neutral_insight_selector.retries !== 0
) {
  throw new Error("Frozen selector stage contract is invalid.");
}
if (
  await sha256(SELECTOR_INSTRUCTIONS) !==
    historicalConfig.instructions_sha256 ||
  await sha256(JSON_INPUT_PREFIX) !== historicalConfig.inputPrefixSha256
) {
  throw new Error(
    "Selector prompt fingerprint differs from the frozen selector contract.",
  );
}
for (const item of payload.cases) {
  const identity = library.identities.find((candidate) =>
    candidate.signPair === item.identity
  );
  if (
    !identity ||
    item.canonical_identity.identity_sha256.length !== 64 ||
    item.checkpoint_paths.selector === item.checkpoint_paths.writer ||
    item.candidate_evidence.length === 0
  ) throw new Error(`Invalid frozen source reference: ${item.stable_case_id}`);
  if (
    await sha256(JSON.stringify(identity)) !==
      item.canonical_identity.identity_sha256
  ) {
    throw new Error(
      `Canonical identity fingerprint mismatch: ${item.stable_case_id}`,
    );
  }
}
if (
  library.sourceSha256 !== payload.canonicalLibrary.sourceSha256 ||
  await sha256(libraryText) !== payload.canonicalLibrary.fileSha256
) {
  throw new Error(
    "Canonical library fingerprint does not match frozen evidence.",
  );
}

const caseInputs = await Promise.all(payload.cases.map(async (item) => {
  const selector_input = buildSelectorInput(item);
  return {
    item,
    selector_input,
    input_sha256: await sha256(selector_input),
    prompt_sha256: await sha256(
      stable({ instructions: SELECTOR_INSTRUCTIONS, selector_input }),
    ),
  };
}));
const promptFingerprint = await sha256(SELECTOR_INSTRUCTIONS);
const preflight = {
  passed: true,
  developmentOnly: true,
  mode: "selector-only",
  matrix: { sha256: actualMatrixSha, stable_case_ids: caseInputs.length },
  evidence_payload: { sha256: actualPayloadSha, cases: caseInputs.length },
  canonical_source_fingerprints_verified: true,
  selector_contract_fingerprint: promptFingerprint,
  selector_input_prefix_fingerprint: await sha256(JSON_INPUT_PREFIX),
  selector_prompt_matches_frozen_contract: true,
  selector_calls: 0,
  writer_calls: 0,
  action_generation: "disabled",
  retries_for_quality: 0,
  resume: {
    selector_checkpoints_separate_from_writer: true,
    completed_selected_or_blocked_not_regenerated: true,
    incomplete_transport_only_resumable: true,
  },
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
  `# Production Candidate v1 — Selector-Only Preflight\n\n**Result:** PASS\n\n- Matrix SHA-256: \`${actualMatrixSha}\`\n- Evidence payload SHA-256: \`${actualPayloadSha}\`\n- Cases: 24 unique stable IDs\n- Selector calls: 0\n- Writer calls: 0\n- Action generation: disabled\n- Production and shadow writes: 0\n\n## Deliberate boundary\n\nThis runner can execute only the frozen Neutral Insight Selector through \`--real-selector\`. It does not select actions, invoke v4, create titles, or emit Today’s Lens copy.\n`,
);

if (mode === "--preflight") {
  console.log(JSON.stringify(preflight, null, 2));
  Deno.exit(0);
}

const apiKey = Deno.env.get("OPENAI_API_KEY");
const model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL");
if (!apiKey || !model) {
  throw new Error(
    "Selector-only execution requires a rotated OPENAI_API_KEY and explicit OPENAI_IDENTITY_LENS_MODEL.",
  );
}
const configCore = {
  developmentOnly: true,
  mode: "selector-only",
  provider: "openai",
  model,
  endpoint: "https://api.openai.com/v1/responses",
  response_format: "json_object",
  matrix_sha256: actualMatrixSha,
  evidence_payload_sha256: actualPayloadSha,
  selector_contract_sha256: promptFingerprint,
  input_prefix_sha256: await sha256(JSON_INPUT_PREFIX),
  case_input_fingerprints: Object.fromEntries(
    caseInputs.map((entry) => [entry.item.stable_case_id, entry.prompt_sha256]),
  ),
  retry_policy: { retries: 0, subjective_quality_retries: 0 },
  writer_calls: 0,
  action_generation: "disabled",
  productionWritePaths: [],
  shadowWritePaths: [],
};
const configuration_sha256 = await sha256(stable(configCore));
const configuration = { ...configCore, configuration_sha256 };
await writeFrozen(configPath, configuration);
let checkpoint = await readJsonIfPresent<{
  configuration_sha256: string;
  rows: SelectorRow[];
}>(runCheckpointPath) ?? { configuration_sha256, rows: [] };
if (
  checkpoint.configuration_sha256 !== configuration_sha256 ||
  !Array.isArray(checkpoint.rows)
) {
  throw new Error(
    "Selector-only checkpoint does not match frozen configuration.",
  );
}

for (const entry of caseInputs) {
  const existing = checkpoint.rows.find((row) =>
    row.stable_case_id === entry.item.stable_case_id
  );
  if (
    existing && completedRowIsVerified(
      existing,
      entry.item,
      configuration_sha256,
      entry.input_sha256,
      entry.prompt_sha256,
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
        instructions: SELECTOR_INSTRUCTIONS,
        input: entry.selector_input,
        text: { format: { type: "json_object" } },
      }),
    });
  } catch (error) {
    const transportRow: SelectorRow = {
      stable_case_id: entry.item.stable_case_id,
      status: "INCOMPLETE_TRANSPORT_FAILURE",
      input_sha256: entry.input_sha256,
      prompt_sha256: entry.prompt_sha256,
      selector_input: entry.selector_input,
      identity: entry.item.identity,
      domain: entry.item.domain,
      neutral_situation: entry.item.neutral_situation,
      canonical_identity: entry.item.canonical_identity,
      candidate_evidence: entry.item.candidate_evidence,
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
      prompt_fingerprint: promptFingerprint,
      retries: 0,
      transport_error: error instanceof Error
        ? error.message
        : "network failure",
    };
    checkpoint.rows = checkpoint.rows.filter((row) =>
      row.stable_case_id !== entry.item.stable_case_id
    );
    checkpoint.rows.push(transportRow);
    await Deno.writeTextFile(runCheckpointPath, stable(checkpoint));
    throw error;
  }
  const body = await response.text();
  if (!response.ok) {
    const transportRow: SelectorRow = {
      stable_case_id: entry.item.stable_case_id,
      status: "INCOMPLETE_TRANSPORT_FAILURE",
      input_sha256: entry.input_sha256,
      prompt_sha256: entry.prompt_sha256,
      selector_input: entry.selector_input,
      identity: entry.item.identity,
      domain: entry.item.domain,
      neutral_situation: entry.item.neutral_situation,
      canonical_identity: entry.item.canonical_identity,
      candidate_evidence: entry.item.candidate_evidence,
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
      prompt_fingerprint: promptFingerprint,
      retries: 0,
      http_status: response.status,
    };
    checkpoint.rows = checkpoint.rows.filter((row) =>
      row.stable_case_id !== entry.item.stable_case_id
    );
    checkpoint.rows.push(transportRow);
    await Deno.writeTextFile(runCheckpointPath, stable(checkpoint));
    throw new Error(
      `OpenAI ${response.status}: selector-only request stopped; rerun resumes verified completed cases.`,
    );
  }
  const raw_provider_response = JSON.parse(body);
  const raw_response = outputText(raw_provider_response);
  const parsed = parseJson(raw_response) as NeutralInsightSelectorResult | null;
  const validation = validationFor(parsed, entry.item);
  const status = validation.accepted && parsed?.status === "SELECTED"
    ? "SELECTED"
    : validation.accepted && parsed?.status === "BLOCKED"
    ? "BLOCKED"
    : "TERMINAL_REJECTED";
  const row: SelectorRow = {
    stable_case_id: entry.item.stable_case_id,
    status,
    input_sha256: entry.input_sha256,
    prompt_sha256: entry.prompt_sha256,
    selector_input: entry.selector_input,
    identity: entry.item.identity,
    domain: entry.item.domain,
    neutral_situation: entry.item.neutral_situation,
    canonical_identity: entry.item.canonical_identity,
    candidate_evidence: entry.item.candidate_evidence,
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
    prompt_fingerprint: promptFingerprint,
    retries: 0,
  };
  checkpoint.rows = checkpoint.rows.filter((candidate) =>
    candidate.stable_case_id !== entry.item.stable_case_id
  );
  checkpoint.rows.push(row);
  await Deno.writeTextFile(runCheckpointPath, stable(checkpoint));
}

if (
  checkpoint.rows.length !== 24 ||
  checkpoint.rows.some((row) => row.status === "INCOMPLETE_TRANSPORT_FAILURE")
) {
  throw new Error(
    "Selector-only run is incomplete; rerun with the same frozen configuration to resume.",
  );
}
const rows = caseInputs.map((entry) => {
  const row = checkpoint.rows.find((candidate) =>
    candidate.stable_case_id === entry.item.stable_case_id
  );
  if (!row) {
    throw new Error(`Missing selector result: ${entry.item.stable_case_id}`);
  }
  return row;
});
const generation = {
  developmentOnly: true,
  status: "FROZEN_PRODUCTION_CANDIDATE_V1_SELECTOR_ONLY_GENERATION",
  configuration_sha256,
  provider: `openai:${model}`,
  matrix_sha256: actualMatrixSha,
  evidence_payload_sha256: actualPayloadSha,
  provider_calls: rows.length,
  selected: rows.filter((row) => row.status === "SELECTED").length,
  blocked: rows.filter((row) => row.status === "BLOCKED").length,
  terminal_rejected:
    rows.filter((row) => row.status === "TERMINAL_REJECTED").length,
  retries: 0,
  action_generation: "disabled",
  writer_calls: 0,
  rows,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};
const { review, worksheet, reviewMarkdown, worksheetMarkdown } =
  createReviewArtifacts(rows, payload.cases, configuration_sha256);
await Promise.all([
  writeFrozen(generationPath, generation),
  writeFrozen(reviewJsonPath, review),
  writeFrozen(worksheetJsonPath, worksheet),
  Deno.writeTextFile(reviewMarkdownPath, reviewMarkdown),
  Deno.writeTextFile(worksheetMarkdownPath, worksheetMarkdown),
]);
console.log(JSON.stringify(
  {
    developmentOnly: true,
    configuration_sha256,
    provider: `openai:${model}`,
    providerCalls: rows.length,
    selected: generation.selected,
    blocked: generation.blocked,
    terminalRejected: generation.terminal_rejected,
    retries: 0,
    writerCalls: 0,
    actionGeneration: "disabled",
    generation: generationPath.pathname,
    humanReview: reviewMarkdownPath.pathname,
    calibratedInputWorksheet: worksheetMarkdownPath.pathname,
    productionWritePaths: [],
    shadowWritePaths: [],
  },
  null,
  2,
));
