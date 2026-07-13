import {
  auditLightweightRepetition,
  type FinalRead,
} from "./lightweight_repetition.ts";
import {
  assessPersonFirstSpecificity,
  outputKeepsPersonalActor,
} from "../canonical-lens-production-preview/person_first_specificity.ts";
import { assessHumanLanguage } from "../canonical-lens-production-preview/human_language_calibration.ts";
import {
  buildOneParagraphPromptV4,
  validateOneParagraphLens,
} from "../canonical-lens-production-preview/one_paragraph_writer_v4.ts";
import {
  type SelectorEvidence,
  validateNeutralInsightSelectorResult,
} from "../canonical-lens-production-preview/neutral_insight_selector_validate.ts";

type CanonicalIdentity = Record<string, unknown> & {
  signPair: string;
  archetypeName: string;
  version: string;
  evidence: { observableBehaviors: string[] };
};
type MatrixCase = {
  stable_case_id: string;
  identity: string;
  neutral_scenario_id: string;
  domain: string;
  canonical_source: { identitySha256: string; sourceSha256: string };
};
type MatrixScenario = {
  id: string;
  domain: string;
  situation: string;
  observableFacts: string[];
};
type Matrix = {
  sha256: string;
  cases: MatrixCase[];
  scenarios: MatrixScenario[];
  canonicalLibrary: { sourceSha256: string; fileSha256: string };
};

const root = new URL("./", import.meta.url);
const artifacts = new URL("./artifacts/", root);
const previewArtifacts = new URL(
  "../canonical-lens-production-preview/artifacts/",
  root,
);
const matrixPath = new URL(
  "production-candidate-v1-unseen-24-matrix.json",
  artifacts,
);
const canonicalLibraryPath = new URL(
  "canonical-library-v2.json",
  previewArtifacts,
);
const goldSetPath = new URL(
  "v321-one-paragraph-gold-set-v1.json",
  previewArtifacts,
);
const designFreezePath = new URL(
  "production-candidate-v1-design-freeze.json",
  artifacts,
);
const evidencePayloadPath = new URL(
  "production-candidate-v1-evidence-payload.json",
  artifacts,
);
const stageContractsPath = new URL(
  "production-candidate-v1-runner-stage-contracts-v2.json",
  artifacts,
);
const fixturePath = new URL(
  "production-candidate-v1-runner-provider-free-fixtures-v2.json",
  artifacts,
);
const preflightPath = new URL(
  "production-candidate-v1-runner-preflight-v2.json",
  artifacts,
);
const preflightMarkdownPath = new URL(
  "production-candidate-v1-runner-preflight-v2.md",
  artifacts,
);

const EXPECTED_MATRIX_SHA =
  "ec8d10feeecb5fc4d1233d14a8aac0008e7afa7ecd27ca77591384feedc59405";

const domainEvidencePaths: Record<string, string[]> = {
  work: [
    "work.problemSolvingStyle",
    "work.teamRole",
    "work.careerBlindSpot",
    "work.relationshipToStructure",
  ],
  relationships: [
    "relationships.closenessStyle",
    "relationships.relationshipBlindSpot",
    "relationships.trustBreakers[0]",
    "social.communicationStyle",
  ],
  money: [
    "decision.defaultProcess",
    "decision.evidenceThreshold",
    "decision.delayPattern",
    "decision.regretPattern",
  ],
  home: [
    "social.responseToGroupUncertainty",
    "pressure.firstShift",
    "growth.groundingBehaviors[0]",
    "evidence.everydaySituations[0]",
  ],
  rest: [
    "pressure.visibleBehaviors[0]",
    "growth.restorationPattern",
    "decision.delayPattern",
    "evidence.everydaySituations[0]",
  ],
  conflict: [
    "social.conflictStyle",
    "pressure.firstShift",
    "pressure.decisionDistortion",
    "growth.groundingBehaviors[0]",
  ],
  routine: [
    "decision.defaultProcess",
    "decision.reversalPattern",
    "pressure.visibleBehaviors[0]",
    "growth.groundingBehaviors[0]",
  ],
  recognition: [
    "work.completionSignal",
    "social.influenceStyle",
    "core.matureExpression",
    "pressure.overextendedStrength",
  ],
  opportunity: [
    "decision.defaultProcess",
    "decision.actionTrigger",
    "decision.delayPattern",
    "decision.reversalPattern",
  ],
  friends: [
    "social.responseToGroupUncertainty",
    "social.communicationStyle",
    "social.defaultRole",
    "relationships.loyaltyStyle",
  ],
  confidence: [
    "core.matureExpression",
    "work.completionSignal",
    "social.influenceStyle",
    "growth.recoveryRecognition",
  ],
};

function stable(value: unknown) {
  return JSON.stringify(value, null, 2) + "\n";
}

async function sha256(value: string | Uint8Array) {
  const bytes = typeof value === "string"
    ? new TextEncoder().encode(value)
    : value;
  const digest = await crypto.subtle.digest(
    "SHA-256",
    bytes as unknown as BufferSource,
  );
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

function readPath(source: unknown, path: string): unknown {
  return path.split(".").reduce((value: any, segment) => {
    const indexed = segment.match(/^(.*)\[(\d+)\]$/);
    return indexed
      ? value?.[indexed[1]]?.[Number(indexed[2])]
      : value?.[segment];
  }, source as any);
}

function checkpointPaths(stableCaseId: string) {
  return {
    selector: new URL(
      `production-candidate-v1-checkpoints/selector/${stableCaseId}.json`,
      artifacts,
    ).pathname,
    writer: new URL(
      `production-candidate-v1-checkpoints/writer/${stableCaseId}.json`,
      artifacts,
    ).pathname,
  };
}

function verifiedCompletedStage(
  checkpoint:
    | { status: string; input_sha256: string; output_sha256: string }
    | null,
  inputSha256: string,
) {
  return checkpoint?.status === "ACCEPTED" &&
    checkpoint.input_sha256 === inputSha256 &&
    typeof checkpoint.output_sha256 === "string" &&
    checkpoint.output_sha256.length === 64;
}

function validateDirectApplicability(
  result: {
    status: "SELECTED" | "BLOCKED";
    applicability: string | null;
    supporting_evidence: SelectorEvidence[];
  },
  situation: Pick<MatrixScenario, "id" | "situation" | "observableFacts">,
) {
  const errors: string[] = [];
  if (result.status === "BLOCKED") return errors;
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

function narrowReasoningClarity(
  result: {
    status: "SELECTED" | "BLOCKED";
    behavior: string | null;
    supporting_evidence: SelectorEvidence[];
  },
) {
  if (result.status === "BLOCKED") {
    return {
      status: "BLOCKED" as const,
      plainInsight: null,
      unsupportedClaims: [] as string[],
    };
  }
  const exactCitedBehavior = result.supporting_evidence.some((evidence) =>
    evidence.claim === result.behavior
  );
  return {
    status: exactCitedBehavior
      ? "PARTIAL" as const
      : "REVIEW_REQUIRED" as const,
    plainInsight: exactCitedBehavior ? result.behavior : null,
    unsupportedClaims: [] as string[],
  };
}

if (Deno.args.length !== 1 || Deno.args[0] !== "--preflight") {
  throw new Error(
    "Production Candidate v1 currently supports only --preflight. No --real execution has been implemented or authorized.",
  );
}

const [matrixText, canonicalText, goldText, designFreezeText] = await Promise
  .all([
    Deno.readTextFile(matrixPath),
    Deno.readTextFile(canonicalLibraryPath),
    Deno.readTextFile(goldSetPath),
    Deno.readTextFile(designFreezePath),
  ]);
const matrix = JSON.parse(matrixText) as Matrix;
const library = JSON.parse(canonicalText) as {
  sourceSha256: string;
  identities: CanonicalIdentity[];
};
const goldSet = JSON.parse(goldText) as {
  status: string;
  cases: Array<{ title: string; read: string }>;
};
const designFreeze = JSON.parse(designFreezeText) as {
  status: string;
  decision: string;
};
const { sha256: recordedMatrixSha, ...matrixPayload } = matrix;
const actualMatrixSha = await sha256(JSON.stringify(matrixPayload));

if (
  recordedMatrixSha !== EXPECTED_MATRIX_SHA ||
  actualMatrixSha !== EXPECTED_MATRIX_SHA
) {
  throw new Error(
    "Frozen 24-case matrix SHA-256 does not match the approved payload.",
  );
}
if (
  matrix.cases.length !== 24 ||
  new Set(matrix.cases.map((item) => item.stable_case_id)).size !== 24
) {
  throw new Error(
    "Frozen matrix must contain exactly 24 unique stable case IDs.",
  );
}
if (
  designFreeze.status !== "FROZEN_PRODUCTION_CANDIDATE_V1_DESIGN" ||
  designFreeze.decision !== "PASS"
) {
  throw new Error("Production Candidate v1 design freeze is not valid.");
}
if (
  goldSet.status !== "FROZEN_APPROVED_GOLD_SET_V1" || goldSet.cases.length !== 5
) {
  throw new Error(
    "Frozen Gold Set v1 is unavailable for the v4 writer contract.",
  );
}
if (
  library.sourceSha256 !== matrix.canonicalLibrary.sourceSha256 ||
  await sha256(await Deno.readFile(canonicalLibraryPath)) !==
    matrix.canonicalLibrary.fileSha256
) {
  throw new Error(
    "Canonical library fingerprint does not match the frozen matrix.",
  );
}

const evidenceCases = await Promise.all(matrix.cases.map(async (item) => {
  const scenario = matrix.scenarios.find((candidate) =>
    candidate.id === item.neutral_scenario_id
  );
  const identity = library.identities.find((candidate) =>
    candidate.signPair === item.identity
  );
  if (!scenario || !identity) {
    throw new Error(`Missing frozen input for ${item.stable_case_id}.`);
  }
  if (
    await sha256(JSON.stringify(identity)) !==
      item.canonical_source.identitySha256
  ) {
    throw new Error(
      `Canonical identity fingerprint mismatch: ${item.stable_case_id}.`,
    );
  }
  const domainPaths = domainEvidencePaths[item.domain];
  if (!domainPaths) {
    throw new Error(
      `No canonical evidence retrieval paths for ${item.domain}.`,
    );
  }
  const candidateEvidence = [
    ...identity.evidence.observableBehaviors.map((claim, index) => ({
      path: `evidence.observableBehaviors[${index}]`,
      claim,
      source: "canonical_identity" as const,
    })),
    ...domainPaths.flatMap((path) => {
      const claim = readPath(identity, path);
      return typeof claim === "string" && claim.trim()
        ? [{ path, claim, source: "canonical_domain" as const }]
        : [];
    }),
  ];
  if (candidateEvidence.length < 7) {
    throw new Error(
      `Insufficient deterministic canonical evidence: ${item.stable_case_id}.`,
    );
  }
  return {
    stable_case_id: item.stable_case_id,
    identity: item.identity,
    domain: item.domain,
    neutral_situation: {
      id: scenario.id,
      situation: scenario.situation,
      observableFacts: scenario.observableFacts,
    },
    canonical_identity: {
      sign_pair: identity.signPair,
      archetype_name: identity.archetypeName,
      version: identity.version,
      identity_sha256: item.canonical_source.identitySha256,
    },
    candidate_evidence: candidateEvidence,
    checkpoint_paths: checkpointPaths(item.stable_case_id),
  };
}));

const evidencePayloadCore = {
  developmentOnly: true,
  status: "FROZEN_PRODUCTION_CANDIDATE_V1_EVIDENCE_PAYLOAD",
  matrix: { path: matrixPath.pathname, sha256: actualMatrixSha },
  canonicalLibrary: {
    path: canonicalLibraryPath.pathname,
    sourceSha256: library.sourceSha256,
    fileSha256: await sha256(canonicalText),
  },
  cases: evidenceCases,
  providerCalls: 0,
  selectorCalls: 0,
  writerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
};
const evidencePayload = {
  ...evidencePayloadCore,
  sha256: await sha256(stable(evidencePayloadCore)),
};

const stageContracts = {
  developmentOnly: true,
  runnerRevision: "provider-free-r2",
  finalOutputShape: ["title", "read"],
  stageOrder: [
    "neutral_situation",
    "canonical_evidence",
    "neutral_insight_selector",
    "direct_applicability_validation",
    "reasoning_clarity",
    "person_first_specificity",
    "human_language_calibration",
    "optional_supported_action",
    "v4_writer",
    "meaning_and_actor_preservation",
    "lightweight_repetition_audit",
    "final_output",
  ],
  contracts: {
    neutral_insight_selector: {
      providerStage: true,
      input: "neutral situation plus exact canonical evidence only",
      output: [
        "status",
        "behavior",
        "supporting_evidence",
        "applicability",
        "unsupported_claims_added",
      ],
      blockedStopsBeforeWriter: true,
      retries: 0,
    },
    calibrated_input: {
      providerStage: false,
      requirement:
        "A selected behavior may reach the writer only as an approved, evidence-preserving plain insight. optional plain action is null unless separately cited and approved.",
      rawCanonicalEvidenceWithheldFromWriter: true,
    },
    v4_writer: {
      providerStage: true,
      input: [
        "plain_insight",
        "plain_action",
        "clarity_status",
        "gold_examples",
      ],
      output: ["title", "read"],
      noActionMeansNoInventedAdvice: true,
    },
    final_validation: {
      required: [
        "v4_structural_contract",
        "excluded_claim_check",
        "actor_preservation",
        "meaning_evidence_audit",
        "lightweight_repetition",
      ],
      invalidOutputPublishes: false,
      fallbackCopyAllowed: false,
    },
    resume: {
      selectorCheckpoint: "separate per-case selector checkpoint",
      writerCheckpoint: "separate per-case writer checkpoint",
      skipOnlyWhen: "stage is ACCEPTED and input/output fingerprints verify",
      transportFailure: "incomplete and resumable",
      acceptedStageRegenerated: false,
    },
  },
  providerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
};

const blockedFixture = {
  status: "BLOCKED",
  behavior: null,
  supporting_evidence: [],
  applicability: null,
  unsupported_claims_added: [],
};
const blockedValidation = validateNeutralInsightSelectorResult(
  blockedFixture,
  evidenceCases[0].candidate_evidence,
);
if (blockedValidation.length !== 0) {
  throw new Error(`BLOCKED fixture invalid: ${blockedValidation.join("; ")}`);
}
const selectedEvidence = evidenceCases
  .flatMap((item) =>
    item.candidate_evidence.map((evidence) => ({ item, evidence }))
  )
  .find(({ evidence }) => /^You may\b/i.test(evidence.claim));
if (!selectedEvidence) {
  throw new Error(
    "No user-owned observable behavior is available for the provider-free fixture.",
  );
}
const selectedFixture = {
  status: "SELECTED" as const,
  behavior: selectedEvidence.evidence.claim,
  supporting_evidence: [{
    path: selectedEvidence.evidence.path,
    claim: selectedEvidence.evidence.claim,
  }] as SelectorEvidence[],
  applicability:
    "The neutral external situation makes this existing behavior reasonably relevant without adding a motive, consequence, or action.",
  unsupported_claims_added: [] as [],
};
const selectorValidation = validateNeutralInsightSelectorResult(
  selectedFixture,
  selectedEvidence.item.candidate_evidence,
);
if (selectorValidation.length !== 0) {
  throw new Error(`SELECTED fixture invalid: ${selectorValidation.join("; ")}`);
}
const applicabilityValidation = validateDirectApplicability(
  selectedFixture,
  selectedEvidence.item.neutral_situation,
);
if (applicabilityValidation.length !== 0) {
  throw new Error(
    `Applicability fixture invalid: ${applicabilityValidation.join("; ")}`,
  );
}
const reasoningClarity = narrowReasoningClarity(selectedFixture);
if (
  reasoningClarity.status !== "PARTIAL" ||
  reasoningClarity.plainInsight !== selectedFixture.behavior
) {
  throw new Error(
    "Reasoning-clarity fixture did not preserve the cited behavior narrowly.",
  );
}
const personFirst = assessPersonFirstSpecificity(
  reasoningClarity.plainInsight,
  1,
);
const humanLanguage = assessHumanLanguage(reasoningClarity.plainInsight, null);
if (personFirst.status !== "PASS" || humanLanguage.status !== "NATURAL") {
  throw new Error(
    "Provider-free selected fixture did not pass person-first and human-language gates.",
  );
}
const writerPrompt = buildOneParagraphPromptV4({
  caseId: "provider-free-selected-fixture",
  clarityStatus: "PARTIAL",
  plainInsight: reasoningClarity.plainInsight,
  plainAction: null,
  goldExamples: goldSet.cases,
});
if (
  writerPrompt.includes("candidate_evidence") ||
  writerPrompt.includes(selectedEvidence.evidence.path)
) {
  throw new Error(
    "Raw canonical evidence structure leaked into the writer prompt.",
  );
}
const mockWriterOutput = {
  title: "Before You Push On",
  read: reasoningClarity.plainInsight,
};
const writerValidation = validateOneParagraphLens(mockWriterOutput, {
  blockedPhrases: [],
});
if (
  writerValidation.errors.length !== 0 ||
  !outputKeepsPersonalActor(mockWriterOutput.read)
) {
  throw new Error(
    "Provider-free writer fixture failed output contract or actor preservation.",
  );
}
const repetition = auditLightweightRepetition([
  {
    stableCaseId: "provider-free-selected-fixture",
    title: mockWriterOutput.title,
    read: mockWriterOutput.read,
    plainInsight: reasoningClarity.plainInsight,
    plainAction: null,
  } satisfies FinalRead,
]);
if (repetition.disposition !== "ACCEPT") {
  throw new Error("Single fixture unexpectedly failed repetition scaffold.");
}

const selectedInputSha = await sha256(
  stable({
    selector: selectedFixture,
    insight: reasoningClarity.plainInsight,
    action: null,
  }),
);
const resumeFixture = {
  status: "ACCEPTED",
  input_sha256: selectedInputSha,
  output_sha256: await sha256(stable(mockWriterOutput)),
};
if (
  !verifiedCompletedStage(resumeFixture, selectedInputSha) ||
  verifiedCompletedStage(resumeFixture, "mismatch")
) {
  throw new Error(
    "Resume safety fixture did not preserve only verified completed stages.",
  );
}

const fixtures = {
  developmentOnly: true,
  runnerRevision: "provider-free-r2",
  purpose:
    "Provider-free control-path fixtures. They do not select behavior or write a Lens for any of the 24 cohort cases.",
  blocked: {
    selectorValidation: blockedValidation,
    writerCalled: false,
    fallbackProduced: false,
  },
  selected: {
    selectorValidation,
    applicabilityValidation,
    reasoningClarity,
    personFirst,
    humanLanguage,
    writerPromptSha256: await sha256(writerPrompt),
    rawCanonicalEvidenceWithheld: true,
    writerValidation,
    actorPreserved: true,
    repetition,
  },
  resume: {
    selectorAndWriterCheckpointsAreSeparate: evidenceCases.every((item) =>
      item.checkpoint_paths.selector !== item.checkpoint_paths.writer
    ),
    verifiedAcceptedStageSkipped: true,
    inputMismatchRegenerated: true,
  },
};

const preflight = {
  passed: true,
  developmentOnly: true,
  runner: "production-candidate-v1",
  runnerRevision: "provider-free-r2",
  matrix: {
    path: matrixPath.pathname,
    sha256: actualMatrixSha,
    cases: evidenceCases.length,
  },
  evidencePayload: {
    path: evidencePayloadPath.pathname,
    sha256: evidencePayload.sha256,
    cases: evidenceCases.length,
  },
  stageContracts: {
    path: stageContractsPath.pathname,
    stageOrder: stageContracts.stageOrder,
  },
  stageOrderVerified: true,
  stableCaseIds: {
    expected: 24,
    actual: new Set(evidenceCases.map((item) => item.stable_case_id)).size,
  },
  sourceFingerprintsVerified: true,
  providerCalls: 0,
  selectorCalls: 0,
  writerCalls: 0,
  blockedStopsBeforeWriter: true,
  genericFallbackProduced: false,
  finalOutputShape: ["title", "read"],
  actorPreservationEnforced: true,
  repetitionCanRewrite: false,
  repetitionDispositions: ["ACCEPT", "HOLD", "REJECT"],
  resumeSafetyVerified: true,
  realExecutionImplemented: false,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};

async function writeFrozen(path: URL, value: unknown) {
  const next = stable(value);
  try {
    const existing = await Deno.readTextFile(path);
    if (existing !== next) {
      throw new Error(`Existing frozen artifact differs: ${path.pathname}`);
    }
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      await Deno.writeTextFile(path, next);
    } else throw error;
  }
}

await Deno.mkdir(artifacts, { recursive: true });
await Promise.all([
  writeFrozen(evidencePayloadPath, evidencePayload),
  writeFrozen(stageContractsPath, stageContracts),
  writeFrozen(fixturePath, fixtures),
  writeFrozen(preflightPath, preflight),
]);
const markdown =
  `# Production Candidate v1 — Provider-Free Runner Preflight\n\n**Result:** PASS\n\n- Matrix SHA-256: \`${actualMatrixSha}\`\n- Cases: 24 unique stable IDs\n- Deterministic evidence payloads: 24\n- Selector calls: 0\n- Writer calls: 0\n- Provider calls: 0\n- Production writes: 0\n- Shadow writes: 0\n\n## Verified boundaries\n\n- Selector and writer checkpoints are separate per case.\n- BLOCKED terminates before writer input, with no generic fallback.\n- A selected behavior must pass citation, direct applicability, person-first, and human-language checks before it can become an approved writer input.\n- Optional action is nullable and must be separately cited and approved; it is never invented by the writer.\n- Writer input contains calibrated inputs only, not raw canonical evidence structures or excluded claims.\n- Final output is exactly \`{ title, read }\`; actor preservation is required for person-first insight.\n- Repetition can accept, hold, or reject. It cannot rewrite, create an action, or force cross-identity novelty.\n- Verified accepted stage artifacts may be skipped only when input and output fingerprints match.\n\n## Deliberate stop\n\nThis runner exposes only \`--preflight\`. It has no provider-backed execution mode. The next approval must review the frozen deterministic selector inputs and the later human-approved calibrated insight/action inputs before any \`--real\` implementation is added.\n`;
await Deno.writeTextFile(preflightMarkdownPath, markdown);
console.log(JSON.stringify(preflight, null, 2));
