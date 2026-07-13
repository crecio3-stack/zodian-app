type Scenario = {
  id: string;
  domain:
    | "work"
    | "relationships"
    | "money"
    | "home"
    | "rest"
    | "conflict"
    | "routine"
    | "recognition"
    | "opportunity"
    | "friends"
    | "confidence";
  situation: string;
  observableFacts: string[];
};

type PlannedCase = { identity: string; scenarioId: string };
type HistoricalCase = {
  source: string;
  stableCaseId: string | null;
  identity: string;
  scenario: string;
};

const root = new URL("./", import.meta.url);
const previewArtifacts = new URL(
  "../canonical-lens-production-preview/artifacts/",
  root,
);
const output = new URL("./artifacts/", root);
const canonicalLibraryUrl = new URL(
  "canonical-library-v2.json",
  previewArtifacts,
);

const requiredDomains = [
  "work",
  "relationships",
  "money",
  "home",
  "rest",
  "conflict",
  "routine",
  "recognition",
  "opportunity",
] as const;

const scenarios: Scenario[] = [
  {
    id: "relationship-shared-plan-changes-neutral",
    domain: "relationships",
    situation: "A plan shared with someone close changes.",
    observableFacts: [
      "There is a close relationship.",
      "There was a shared plan.",
      "The plan has changed.",
    ],
  },
  {
    id: "home-guests-shared-room-neutral",
    domain: "home",
    situation: "Guests are coming, and a shared room will be used.",
    observableFacts: [
      "Guests are coming.",
      "A room is shared.",
      "The room will be used by guests.",
    ],
  },
  {
    id: "work-deadline-moves-earlier-neutral",
    domain: "work",
    situation:
      "A deadline moves earlier while the amount of work stays the same.",
    observableFacts: [
      "There is a deadline.",
      "The deadline moved earlier.",
      "The amount of work did not change.",
    ],
  },
  {
    id: "rest-open-evening-neutral",
    domain: "rest",
    situation: "An evening opens up after a busy day.",
    observableFacts: [
      "The day was busy.",
      "The evening has no fixed plan.",
    ],
  },
  {
    id: "home-shared-item-replacement-neutral",
    domain: "home",
    situation:
      "Something used in a shared space stops working and needs replacement.",
    observableFacts: [
      "The item is used in a shared space.",
      "The item no longer works.",
      "A replacement is required.",
    ],
  },
  {
    id: "conflict-decision-questioned-neutral",
    domain: "conflict",
    situation:
      "A person involved questions a decision that has already been made.",
    observableFacts: [
      "A decision was made.",
      "The person questioning it was involved.",
      "The decision is now being questioned.",
    ],
  },
  {
    id: "recognition-public-credit-neutral",
    domain: "recognition",
    situation: "A group gives public credit for a result.",
    observableFacts: [
      "A result was completed.",
      "A group is present.",
      "Credit is given publicly.",
    ],
  },
  {
    id: "friends-plan-detail-open-neutral",
    domain: "friends",
    situation:
      "A group is making plans, and one important detail remains open.",
    observableFacts: [
      "A group is making plans.",
      "One important detail has not been settled.",
    ],
  },
  {
    id: "money-unplanned-shared-expense-neutral",
    domain: "money",
    situation: "An unplanned shared expense arrives.",
    observableFacts: [
      "The expense was not planned.",
      "The expense is shared.",
    ],
  },
  {
    id: "routine-tool-change-neutral",
    domain: "routine",
    situation: "A tool used for a regular task changes how the task works.",
    observableFacts: [
      "The task is regular.",
      "A tool is used for the task.",
      "The tool has changed how the task works.",
    ],
  },
  {
    id: "opportunity-new-invitation-neutral",
    domain: "opportunity",
    situation:
      "A new invitation becomes available while an existing commitment remains in place.",
    observableFacts: [
      "A new invitation is available.",
      "There is an existing commitment.",
      "The existing commitment remains in place.",
    ],
  },
  {
    id: "confidence-explain-result-neutral",
    domain: "confidence",
    situation: "A group asks someone to explain their part in a result.",
    observableFacts: [
      "A result exists.",
      "A group is asking for an explanation.",
      "The explanation concerns one person's part in the result.",
    ],
  },
];

const plannedCases: PlannedCase[] = [
  {
    identity: "Libra × Snake",
    scenarioId: "relationship-shared-plan-changes-neutral",
  },
  { identity: "Libra × Snake", scenarioId: "friends-plan-detail-open-neutral" },
  {
    identity: "Aquarius × Snake",
    scenarioId: "relationship-shared-plan-changes-neutral",
  },
  {
    identity: "Aquarius × Snake",
    scenarioId: "home-guests-shared-room-neutral",
  },
  { identity: "Virgo × Dragon", scenarioId: "home-guests-shared-room-neutral" },
  {
    identity: "Virgo × Dragon",
    scenarioId: "work-deadline-moves-earlier-neutral",
  },
  {
    identity: "Taurus × Horse",
    scenarioId: "work-deadline-moves-earlier-neutral",
  },
  { identity: "Taurus × Horse", scenarioId: "rest-open-evening-neutral" },
  { identity: "Pisces × Dog", scenarioId: "rest-open-evening-neutral" },
  {
    identity: "Pisces × Dog",
    scenarioId: "home-shared-item-replacement-neutral",
  },
  {
    identity: "Capricorn × Rabbit",
    scenarioId: "home-shared-item-replacement-neutral",
  },
  {
    identity: "Capricorn × Rabbit",
    scenarioId: "conflict-decision-questioned-neutral",
  },
  {
    identity: "Scorpio × Dragon",
    scenarioId: "conflict-decision-questioned-neutral",
  },
  {
    identity: "Scorpio × Dragon",
    scenarioId: "recognition-public-credit-neutral",
  },
  { identity: "Leo × Horse", scenarioId: "recognition-public-credit-neutral" },
  { identity: "Leo × Horse", scenarioId: "friends-plan-detail-open-neutral" },
  {
    identity: "Aries × Ox",
    scenarioId: "money-unplanned-shared-expense-neutral",
  },
  { identity: "Aries × Ox", scenarioId: "confidence-explain-result-neutral" },
  {
    identity: "Cancer × Pig",
    scenarioId: "money-unplanned-shared-expense-neutral",
  },
  { identity: "Cancer × Pig", scenarioId: "routine-tool-change-neutral" },
  { identity: "Gemini × Tiger", scenarioId: "routine-tool-change-neutral" },
  {
    identity: "Gemini × Tiger",
    scenarioId: "opportunity-new-invitation-neutral",
  },
  {
    identity: "Sagittarius × Monkey",
    scenarioId: "opportunity-new-invitation-neutral",
  },
  {
    identity: "Sagittarius × Monkey",
    scenarioId: "confidence-explain-result-neutral",
  },
];

const historicalArtifactNames = [
  "v321-diversity-matrix.json",
  "v321-cohort.json",
  "v321-plain-english-cohort.json",
  "v321-one-paragraph-gold-set-v1.json",
  "v321-one-paragraph-unseen-10-matrix.json",
  "v321-one-paragraph-unseen-10-matrix-v2.json",
  "v321-one-paragraph-unseen-10-v3-matrix.json",
  "v321-one-paragraph-unseen-10-v4-matrix.json",
  "v321-horizontal-12-neutral-matrix-v1.json",
  "v321-neutral-36-matrix.json",
  "v321-neutral-insight-selector-evidence-payload-v1.json",
  "v321-neutral-insight-selector-json-input-fix-generation-v1.json",
];

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

function slug(value: string) {
  return value.toLowerCase().replace(/×/g, "x").replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function key(identity: string, scenario: string) {
  return `${identity.toLowerCase()}|${scenario.toLowerCase()}`;
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;
}

function string(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value : null;
}

function extractHistoricalCases(
  source: string,
  document: unknown,
): HistoricalCase[] {
  const root = asRecord(document);
  if (!root) return [];
  const collections = [root.cases, root.rows, root.outputs]
    .filter(Array.isArray)
    .flat() as unknown[];
  const cases: HistoricalCase[] = [];
  for (const item of collections) {
    const row = asRecord(item);
    if (!row) continue;
    const identity = string(row.identity) ?? string(row.signPair);
    const neutralSituation = asRecord(row.neutral_situation);
    const scenario = string(row.scenario) ?? string(row.scenarioId) ??
      string(row.neutral_scenario_id) ?? string(neutralSituation?.id);
    const stableCaseId = string(row.stable_case_id) ?? string(row.caseId) ??
      string(row.stable_source_case_id) ?? string(row.key);
    if (identity && scenario) {
      cases.push({ source, stableCaseId, identity, scenario });
      continue;
    }
    const compound = string(row.key) ?? string(row.stable_source_case_id);
    if (identity && compound?.includes("|")) {
      const [, parsedScenario] = compound.split("|", 2);
      if (parsedScenario) {
        cases.push({
          source,
          stableCaseId,
          identity,
          scenario: parsedScenario,
        });
      }
    }
  }
  return cases;
}

const forbiddenScenarioLanguage = [
  /\byou\b/i,
  /\bshould\b/i,
  /\bmust\b/i,
  /\btry\b/i,
  /\bnotice\b/i,
  /\bavoid\b/i,
  /\bassume\b/i,
  /\blearn\b/i,
  /\bwatch\b/i,
  /\bmove\b/i,
  /\bremember\b/i,
  /\bmake sure\b/i,
];

const library = JSON.parse(await Deno.readTextFile(canonicalLibraryUrl)) as {
  sourceSha256: string;
  identities: Array<Record<string, unknown> & { signPair: string }>;
};
const historicalSources = await Promise.all(
  historicalArtifactNames.map(async (name) => {
    const url = new URL(name, previewArtifacts);
    const text = await Deno.readTextFile(url);
    return {
      name,
      sha256: await sha256(text),
      cases: extractHistoricalCases(name, JSON.parse(text)),
    };
  }),
);
const historicalCases = historicalSources.flatMap((source) => source.cases);
const historicalPairs = new Set(
  historicalCases.map((item) => key(item.identity, item.scenario)),
);
const historicalStableIds = new Set(
  historicalCases.flatMap((item) =>
    item.stableCaseId === null ? [] : [item.stableCaseId]
  ),
);
const scenarioById = new Map(
  scenarios.map((scenario) => [scenario.id, scenario]),
);

const plannedStableIds = plannedCases.map((item) =>
  `pcv1-unseen-24-${slug(item.identity)}-${item.scenarioId}`
);
const errors: string[] = [];
if (plannedCases.length !== 24) {
  errors.push(`expected 24 cases, received ${plannedCases.length}`);
}
if (new Set(plannedStableIds).size !== plannedStableIds.length) {
  errors.push("duplicate planned stable case ID");
}
if (plannedStableIds.some((id) => historicalStableIds.has(id))) {
  errors.push("planned stable case ID exists in historical artifacts");
}
if (
  new Set(scenarios.map((scenario) => scenario.id)).size !== scenarios.length
) errors.push("duplicate neutral scenario ID");

const scenarioLeakage = scenarios.map((scenario) => {
  const text = `${scenario.situation} ${scenario.observableFacts.join(" ")}`;
  const violations = forbiddenScenarioLanguage
    .filter((expression) => expression.test(text))
    .map((expression) => expression.source);
  return {
    id: scenario.id,
    domain: scenario.domain,
    situation: scenario.situation,
    observableFacts: scenario.observableFacts,
    violations,
    passed: violations.length === 0,
    rationale:
      "Situation and facts name only external state. They do not state what a person notices, assumes, does, avoids, learns, or should do.",
  };
});
if (scenarioLeakage.some((item) => !item.passed)) {
  errors.push("scenario-leakage audit failed");
}

const cases = plannedCases.map((item, index) => {
  const scenario = scenarioById.get(item.scenarioId);
  if (!scenario) {
    throw new Error(`missing planned scenario: ${item.scenarioId}`);
  }
  const canonical = library.identities.find((identity) =>
    identity.signPair === item.identity
  );
  if (!canonical) {
    throw new Error(`missing canonical identity: ${item.identity}`);
  }
  const stableCaseId = plannedStableIds[index];
  const overlap = historicalCases.filter((prior) =>
    key(prior.identity, prior.scenario) === key(item.identity, item.scenarioId)
  );
  if (historicalPairs.has(key(item.identity, item.scenarioId))) {
    errors.push(
      `historical identity/scenario overlap: ${item.identity}|${item.scenarioId}`,
    );
  }
  return {
    stable_case_id: stableCaseId,
    identity: item.identity,
    neutral_scenario_id: scenario.id,
    domain: scenario.domain,
    canonical_source: {
      artifact: "canonical-library-v2.json",
      sourceSha256: library.sourceSha256,
      signPair: canonical.signPair,
      identitySha256: "",
    },
    overlap,
  };
});

for (const item of cases) {
  const canonical = library.identities.find((identity) =>
    identity.signPair === item.identity
  )!;
  item.canonical_source.identitySha256 = await sha256(
    JSON.stringify(canonical),
  );
}

const identityCounts = Object.fromEntries(
  [...new Set(plannedCases.map((item) => item.identity))].map((identity) => [
    identity,
    plannedCases.filter((item) => item.identity === identity).length,
  ]),
);
const domainCounts = Object.fromEntries(scenarios.map((scenario) => [
  scenario.domain,
  cases.filter((item) => item.domain === scenario.domain).length,
]));
if (Object.keys(identityCounts).length !== 12) {
  errors.push(
    `expected 12 identities, received ${Object.keys(identityCounts).length}`,
  );
}
if (Object.values(identityCounts).some((count) => count !== 2)) {
  errors.push("each identity must appear exactly twice");
}
for (const domain of requiredDomains) {
  if (!domainCounts[domain]) {
    errors.push(`required domain missing: ${domain}`);
  }
}

const canonicalMatrixPayload = {
  version: "production-candidate-v1-unseen-24",
  developmentOnly: true,
  status: "FROZEN_UNSEEN_24_MATRIX",
  purpose:
    "Provider-free frozen input matrix for a later isolated end-to-end candidate validation. No provider, selector, or writer calls are authorized by this artifact.",
  sourceDesign: {
    path:
      "../production-candidate-v1/artifacts/production-candidate-v1-design-freeze.json",
  },
  canonicalLibrary: {
    path:
      "../canonical-lens-production-preview/artifacts/canonical-library-v2.json",
    sourceSha256: library.sourceSha256,
    fileSha256: await sha256(await Deno.readFile(canonicalLibraryUrl)),
  },
  scenarios,
  cases: cases.map(({ overlap: _overlap, ...item }) => item),
  coverage: { identities: identityCounts, domains: domainCounts },
  priorArtifactSources: historicalSources.map(({ name, sha256 }) => ({
    name,
    sha256,
  })),
  providerCalls: 0,
  selectorCalls: 0,
  writerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};
const matrixSha256 = await sha256(JSON.stringify(canonicalMatrixPayload));
if (errors.length) {
  throw new Error(`matrix preflight failed:\n- ${errors.join("\n- ")}`);
}

const matrix = { ...canonicalMatrixPayload, sha256: matrixSha256 };
const nonOverlapAudit = {
  developmentOnly: true,
  plannedCases: cases.length,
  historicalArtifactSources: historicalSources.map((
    { name, sha256, cases },
  ) => ({ name, sha256, extractedCases: cases.length })),
  historicalIdentityScenarioPairs: historicalPairs.size,
  plannedOverlapCount: cases.reduce(
    (total, item) => total + item.overlap.length,
    0,
  ),
  stableCaseIdCollisionCount:
    plannedStableIds.filter((id) => historicalStableIds.has(id)).length,
  passed: true,
};
const fingerprintVerification = {
  developmentOnly: true,
  canonicalLibrary: canonicalMatrixPayload.canonicalLibrary,
  identities: cases.map((item) => ({
    stable_case_id: item.stable_case_id,
    identity: item.identity,
    canonical_source: item.canonical_source,
  })),
  missingFingerprints: [],
  mismatchedFingerprints: [],
  passed: true,
};
const coverage = {
  developmentOnly: true,
  totalCases: cases.length,
  uniqueIdentities: Object.keys(identityCounts).length,
  casesPerIdentity: identityCounts,
  casesPerDomain: domainCounts,
  requiredDomains,
  allRequiredDomainsCovered: true,
  passed: true,
};
const preflight = {
  passed: true,
  developmentOnly: true,
  matrixSha256,
  cases: cases.length,
  uniqueStableCaseIds: new Set(plannedStableIds).size,
  identities: Object.keys(identityCounts).length,
  scenarioLeakagePassed: scenarioLeakage.every((item) => item.passed),
  historicalOverlapCount: nonOverlapAudit.plannedOverlapCount,
  sourceFingerprintsPassed: fingerprintVerification.passed,
  coveragePassed: coverage.passed,
  providerCalls: 0,
  selectorCalls: 0,
  writerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};

function markdownList(items: string[]) {
  return items.map((item) => `- ${item}`).join("\n");
}

await Deno.mkdir(output, { recursive: true });
await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-matrix.json", output),
  `${JSON.stringify(matrix, null, 2)}\n`,
);
await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-non-overlap-audit.json", output),
  `${JSON.stringify(nonOverlapAudit, null, 2)}\n`,
);
await Deno.writeTextFile(
  new URL(
    "production-candidate-v1-unseen-24-scenario-leakage-audit.json",
    output,
  ),
  `${JSON.stringify(scenarioLeakage, null, 2)}\n`,
);
await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-coverage.json", output),
  `${JSON.stringify(coverage, null, 2)}\n`,
);
await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-source-fingerprints.json", output),
  `${JSON.stringify(fingerprintVerification, null, 2)}\n`,
);
await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-preflight.json", output),
  `${JSON.stringify(preflight, null, 2)}\n`,
);

await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-non-overlap-audit.md", output),
  `# Production Candidate v1 — Unseen 24 Non-overlap Audit\n\n**Result:** PASS\n\n- Planned cases: ${cases.length}\n- Historical identity × scenario pairs scanned: ${historicalPairs.size}\n- Planned overlaps: ${nonOverlapAudit.plannedOverlapCount}\n- Stable-ID collisions: ${nonOverlapAudit.stableCaseIdCollisionCount}\n\n## Historical sources\n\n${
    historicalSources.map((source) =>
      `- ${source.name}: ${source.cases.length} extractable identity × scenario records; SHA-256 \`${source.sha256}\``
    ).join("\n")
  }\n\nEvery planned pair uses a new neutral scenario ID and has no matching historical identity × scenario pair in the audited sources.\n`,
);
await Deno.writeTextFile(
  new URL(
    "production-candidate-v1-unseen-24-scenario-leakage-audit.md",
    output,
  ),
  `# Production Candidate v1 — Unseen 24 Scenario-leakage Audit\n\n**Result:** PASS — ${scenarioLeakage.length}/${scenarioLeakage.length} neutral situations contain no user behavior, lesson, action, or advice language.\n\n${
    scenarioLeakage.map((item) =>
      `## ${item.id}\n\n- Domain: ${item.domain}\n- Situation: ${item.situation}\n- Facts:\n${
        item.observableFacts.map((fact) => `  - ${fact}`).join("\n")
      }\n- Prohibited-language matches: ${
        item.violations.length === 0 ? "none" : item.violations.join(", ")
      }\n`
    ).join("\n")
  }\n`,
);
await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-coverage.md", output),
  `# Production Candidate v1 — Unseen 24 Coverage\n\n**Result:** PASS\n\n- Cases: 24\n- Identities: 12\n- Cases per identity: exactly 2\n- Required domains: all covered\n\n## Identity coverage\n\n${
    markdownList(
      Object.entries(identityCounts).map(([identity, count]) =>
        `${identity}: ${count}`
      ),
    )
  }\n\n## Domain coverage\n\n${
    markdownList(
      Object.entries(domainCounts).map(([domain, count]) =>
        `${domain}: ${count}`
      ),
    )
  }\n`,
);
await Deno.writeTextFile(
  new URL("production-candidate-v1-unseen-24-preflight.md", output),
  `# Production Candidate v1 — Unseen 24 Provider-Free Matrix Preflight\n\n**Result:** PASS\n\n- Matrix SHA-256: \`${matrixSha256}\`\n- Cases: 24\n- Stable case IDs: 24 unique\n- Historical overlaps: 0\n- Scenario-leakage violations: 0\n- Source fingerprint failures: 0\n- Provider calls: 0\n- Selector calls: 0\n- Writer calls: 0\n- Production writes: 0\n- Shadow writes: 0\n\nThe matrix is frozen for future review only. It authorizes neither candidate-runner implementation nor provider-backed generation.\n`,
);

console.log(JSON.stringify(preflight, null, 2));
