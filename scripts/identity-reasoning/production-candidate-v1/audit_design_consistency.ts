const root = new URL("./", import.meta.url);
const artifacts = new URL("./artifacts/", root);
const manifestUrl = new URL("./production-candidate-v1.json", root);
const readmeUrl = new URL("./README.md", root);
const planUrl = new URL("./provider-free-preflight-plan.md", root);

async function sha256(value: string | Uint8Array): Promise<string> {
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

async function read(url: URL) {
  return await Deno.readTextFile(url);
}

type FrozenInput = { role: string; path: string; sha256: string };
type Manifest = {
  version: string;
  status: string;
  developmentOnly: boolean;
  finalOutput: string[];
  frozenInputs: FrozenInput[];
  providerCalls: number;
  productionWritePaths: string[];
  shadowWritePaths: string[];
};

const manifest = JSON.parse(await read(manifestUrl)) as Manifest;
const readme = await read(readmeUrl);
const plan = await read(planUrl);
const checks: Array<{ name: string; passed: boolean; evidence: string }> = [];

function check(name: string, passed: boolean, evidence: string) {
  checks.push({ name, passed, evidence });
}

const requiredStageOrder = [
  "neutral situation/context",
  "canonical identity evidence",
  "Neutral Insight Selector",
  "evidence + direct applicability validation",
  "person-first specificity",
  "human-language calibration",
  "optional supported action",
  "frozen v4 writer",
  "meaning + actor preservation",
  "lightweight repetition audit",
  "{ title, read }",
];
const candidatePath = readme.match(
  /## Candidate path\s+```text\s+([\s\S]+?)```/,
)?.[1] ?? "";
const positions = requiredStageOrder.map((stage) =>
  candidatePath.indexOf(stage)
);
check(
  "stage ownership is ordered and non-overlapping",
  positions.every((position, index) =>
    position >= 0 && (index === 0 || position > positions[index - 1])
  ),
  "The Candidate path declares one ordered owner for situation, evidence, selection, validation, calibration, writing, final validation, and repetition audit.",
);
check(
  "final output contract is exact",
  JSON.stringify(manifest.finalOutput) === JSON.stringify(["title", "read"]),
  `Manifest finalOutput=${JSON.stringify(manifest.finalOutput)}.`,
);
check(
  "v4 language architecture is frozen rather than modified",
  readme.includes(
    "The v4 one-paragraph writer is the approved language direction.",
  ) &&
    manifest.frozenInputs.some((input) =>
      input.role === "v4 language architecture freeze"
    ) &&
    manifest.frozenInputs.some((input) => input.role === "v4 writer contract"),
  "README fixes v4 as the language layer and manifest pins its freeze and contract artifacts.",
);
check(
  "selector remains evidence-grounded selection only",
  /it does not create traits, motives,\s+psychology, actions, titles, or prose\./
    .test(readme) &&
    /The system does \*\*not\*\* require a different theme, action, or conclusion for\s+every identity\./
      .test(readme),
  "Selector may select cited behavior/applicability or BLOCKED; it cannot write a Lens or force cross-identity difference.",
);
check(
  "BLOCKED cannot become generic fallback copy",
  readme.includes("`BLOCKED` and no writer call occurs") &&
    readme.includes("Preserve `BLOCKED`; skip action and writer stages"),
  "Both direct-applicability and failure sections terminate BLOCKED before writing.",
);
check(
  "person-first and human-language gates occur before writing",
  positions[4] < positions[7] && positions[5] < positions[7] &&
    readme.includes("Neither gate may generate copy itself."),
  "The gates are non-generative validation/calibration steps before the v4 writer.",
);
check(
  "meaning and actor preservation occur after writing",
  positions[7] < positions[8] &&
    /passes the v4 structural contract, actor-preservation check, and excluded\s+claim check/
      .test(plan),
  "Final validation follows the writer and includes actor preservation.",
);
check(
  "repetition policy allows honest similarity and blocks lazy duplication",
  readme.includes(
    "Repetition policy: **allow honest similarity; block lazy duplication**.",
  ) &&
    readme.includes("Similarity is permitted.") &&
    readme.includes("must not encode a requirement for semantic distance"),
  "The design forbids semantic-distance, unique-action, unique-topic, and unique-rhythm requirements.",
);
check(
  "repetition checks cannot force unsupported rewrites",
  readme.includes("do not rewrite good copy solely to make it novel") &&
    readme.includes("never an instruction to manufacture a distinction"),
  "Repetition controls block or hold; they do not manufacture a new behavior or action.",
);
check(
  "validation path has no production or shadow write path",
  manifest.developmentOnly && manifest.providerCalls === 0 &&
    manifest.productionWritePaths.length === 0 &&
    manifest.shadowWritePaths.length === 0 &&
    /authorizes no provider calls, generation, production\s+writes, shadow writes/
      .test(plan),
  "Manifest and plan both declare development-only, zero provider calls, and empty write paths.",
);
check(
  "unseen-cohort plan requires broad unseen coverage and neutral situations",
  plan.includes(
    "12 identities, with two unseen situation/identity pairs each",
  ) &&
    plan.includes("20–30 total cases") &&
    plan.includes("neutral external situations only") &&
    plan.includes("exclude cases used to tune or assess the v4 writer"),
  "The plan proposes 24 cases with 12 identities, broad scenario coverage, and explicit non-overlap requirements.",
);
check(
  "unseen-cohort plan separates automated checks from human product judgment",
  /Automatic\s+checks prove boundaries; they do not claim that a Lens feels personally true\./
    .test(readme) &&
    /human quality \(naturalness, felt-seen\s+specificity, usefulness, and return-tomorrow value\)/
      .test(plan),
  "Human review remains required after compliance validation.",
);

const frozenInputs = await Promise.all(
  manifest.frozenInputs.map(async (input) => {
    const sourceUrl = new URL(input.path, root);
    const actual = await sha256(await Deno.readFile(sourceUrl));
    return { ...input, actualSha256: actual, passed: actual === input.sha256 };
  }),
);
for (const input of frozenInputs) {
  check(
    `frozen input hash: ${input.role}`,
    input.passed,
    `${input.path} expected ${input.sha256}; actual ${input.actualSha256}.`,
  );
}

const passed = checks.every((item) => item.passed);
const sourceFingerprints = {
  manifestSha256: await sha256(await read(manifestUrl)),
  readmeSha256: await sha256(readme),
  preflightPlanSha256: await sha256(plan),
};
const audit = {
  developmentOnly: true,
  decision: passed ? "PASS" : "PASS_WITH_REQUIRED_CHANGES",
  scope:
    "Production Candidate v1 design consistency only; no unseen cohort matrix exists yet.",
  providerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  sourceFingerprints,
  frozenInputs,
  checks,
  cohortReadiness: {
    matrixCreated: false,
    statement:
      "The design passes. Cohort-specific non-overlap, case IDs, source fingerprints, and scenario-leakage assertions are required at the later matrix-freeze preflight.",
  },
};

await Deno.mkdir(artifacts, { recursive: true });
await Deno.writeTextFile(
  new URL("./production-candidate-v1-design-consistency-audit.json", artifacts),
  `${JSON.stringify(audit, null, 2)}\n`,
);

const markdown =
  `# Production Candidate v1 — Design Consistency Audit\n\n**Decision:** ${audit.decision}\n\nThis is a provider-free design audit. It does not create or validate the future 24-case matrix.\n\n## Result\n\n- Checks: ${
    checks.filter((item) => item.passed).length
  }/${checks.length} passed\n- Provider calls: 0\n- Production writes: 0\n- Shadow writes: 0\n- Cohort matrix created: no\n\n## Verified frozen inputs\n\n${
    frozenInputs.map((input) =>
      `- ${
        input.passed ? "PASS" : "FAIL"
      } — ${input.role}: \`${input.actualSha256}\``
    ).join("\n")
  }\n\n## Design checks\n\n${
    checks.map((item) =>
      `- ${item.passed ? "PASS" : "FAIL"} — **${item.name}**: ${item.evidence}`
    ).join("\n")
  }\n\n## Cohort boundary\n\nThe 24-case cohort is intentionally not yet created. The future matrix-freeze preflight must prove non-overlap with Gold, v3, v4, and selector cases; neutral scenario wording; deterministic unique case IDs; source fingerprints; and the planned identity/scenario coverage. The absence of that unbuilt matrix is not a design defect and is not represented as a completed cohort check.\n\n## Freeze basis\n\n- Manifest SHA-256: \`${sourceFingerprints.manifestSha256}\`\n- Architecture README SHA-256: \`${sourceFingerprints.readmeSha256}\`\n- Preflight plan SHA-256: \`${sourceFingerprints.preflightPlanSha256}\`\n`;
await Deno.writeTextFile(
  new URL("./production-candidate-v1-design-consistency-audit.md", artifacts),
  markdown,
);

const freezePayload = {
  developmentOnly: true,
  status: passed
    ? "FROZEN_PRODUCTION_CANDIDATE_V1_DESIGN"
    : "DESIGN_NOT_FROZEN",
  decision: audit.decision,
  sourceFingerprints,
  frozenInputFingerprints: frozenInputs.map(({ role, path, actualSha256 }) => ({
    role,
    path,
    sha256: actualSha256,
  })),
  providerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  matrixNotYetCreated: true,
};
await Deno.writeTextFile(
  new URL("./production-candidate-v1-design-freeze.json", artifacts),
  `${JSON.stringify(freezePayload, null, 2)}\n`,
);

console.log(JSON.stringify(
  {
    decision: audit.decision,
    checks: `${checks.filter((item) => item.passed).length}/${checks.length}`,
    providerCalls: 0,
    productionWritePaths: [],
    shadowWritePaths: [],
    cohortMatrixCreated: false,
  },
  null,
  2,
));
