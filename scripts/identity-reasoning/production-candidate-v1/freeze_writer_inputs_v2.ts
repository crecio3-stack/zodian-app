type WriterInput = {
  stable_case_id: string;
  identity: string;
  neutral_situation: string;
  plain_insight: string;
  plain_action: string | null;
  source_calibration_status: "APPROVE" | "NARROW";
};

type WriterInputs = {
  developmentOnly: true;
  status: string;
  source: string;
  writerCalls: number;
  providerCalls: number;
  productionWritePaths: string[];
  shadowWritePaths: string[];
  cases: WriterInput[];
};

const artifacts = new URL("./artifacts/", import.meta.url);
const sourcePath = new URL(
  "production-candidate-v1-writer-inputs-v1.json",
  artifacts,
);
const outputPath = new URL(
  "production-candidate-v1-writer-inputs-v2.json",
  artifacts,
);
const reviewPath = new URL(
  "production-candidate-v1-writer-inputs-review-v2.md",
  artifacts,
);
const manifestPath = new URL(
  "production-candidate-v1-writer-inputs-v2-edit-manifest.json",
  artifacts,
);
const freezePath = new URL(
  "production-candidate-v1-writer-inputs-freeze-v2.json",
  artifacts,
);

const approvedEdits = {
  "pcv1-unseen-24-aries-x-ox-confidence-explain-result-neutral": {
    before:
      "When people ask about your part in a result, you may explain what happened before you jump to what you did.",
    after:
      "When people ask about your part in a result, you may explain the whole situation before getting to what you actually did.",
  },
  "pcv1-unseen-24-scorpio-x-dragon-recognition-public-credit-neutral": {
    before:
      "After getting public credit, you may take up more of the moment than you need to.",
    after:
      "After getting public credit, you may keep the attention on yourself longer than you need to.",
  },
} as const;

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

if (Deno.args.length !== 0) {
  throw new Error("freeze_writer_inputs_v2.ts does not accept arguments.");
}

const source = JSON.parse(await Deno.readTextFile(sourcePath)) as WriterInputs;
if (
  source.status !== "FROZEN_PRODUCTION_CANDIDATE_V1_WRITER_INPUTS" ||
  source.cases.length !== 19 ||
  new Set(source.cases.map((item) => item.stable_case_id)).size !== 19
) throw new Error("Frozen v1 writer inputs are invalid.");

const edits = Object.entries(approvedEdits);
const cases = source.cases.map((item) => {
  const edit = approvedEdits[item.stable_case_id as keyof typeof approvedEdits];
  if (!edit) return item;
  if (item.plain_insight !== edit.before) {
    throw new Error(`Unexpected v1 wording: ${item.stable_case_id}`);
  }
  return { ...item, plain_insight: edit.after };
});
const changed = cases.filter((item, index) =>
  item.plain_insight !== source.cases[index].plain_insight
);
if (
  changed.length !== 2 ||
  changed.some((item) =>
    !approvedEdits[item.stable_case_id as keyof typeof approvedEdits]
  )
) {
  throw new Error(
    "Writer-input v2 must change exactly the two approved insights.",
  );
}
if (
  cases.some((item, index) =>
    item.stable_case_id !== source.cases[index].stable_case_id ||
    item.identity !== source.cases[index].identity ||
    item.neutral_situation !== source.cases[index].neutral_situation ||
    item.plain_action !== source.cases[index].plain_action ||
    item.source_calibration_status !==
      source.cases[index].source_calibration_status
  )
) throw new Error("Writer-input v2 changed a non-insight field.");

const output: WriterInputs = {
  ...source,
  source:
    "production-candidate-v1-writer-inputs-v1.json plus two human-approved wording fixes",
  cases,
};
const manifest = {
  developmentOnly: true,
  source: sourcePath.pathname,
  output: outputPath.pathname,
  exact_changes: edits.map(([stable_case_id, edit]) => ({
    stable_case_id,
    field: "plain_insight",
    before: edit.before,
    after: edit.after,
  })),
  changed_fields: 2,
  unchanged_cases: 17,
  unchanged_non_insight_fields: true,
  providerCalls: 0,
  writerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
};
const review = [
  "# Production Candidate v1 — Writer Input Review",
  "",
  ...cases.flatMap((item) => [
    `## ${item.identity} · ${item.neutral_situation}`,
    "",
    `**Insight:** ${item.plain_insight}`,
    "",
    `**Action:** ${item.plain_action ?? "None"}`,
    "",
    `**Status:** ${item.source_calibration_status}`,
    "",
  ]),
].join("\n");
const outputSha = await sha256(stable(output));
const manifestSha = await sha256(stable(manifest));
const freeze = {
  developmentOnly: true,
  status: "FROZEN_PRODUCTION_CANDIDATE_V1_WRITER_INPUT_REVIEW_V2",
  writer_inputs: { path: outputPath.pathname, sha256: outputSha, cases: 19 },
  edit_manifest: {
    path: manifestPath.pathname,
    sha256: manifestSha,
    changed_fields: 2,
  },
  providerCalls: 0,
  selectorCalls: 0,
  writerCalls: 0,
  productionWritePaths: [],
  shadowWritePaths: [],
  scheduleChanges: [],
  allowlistChanges: [],
  deploymentChanges: [],
};

await Promise.all([
  writeFrozen(outputPath, output),
  writeFrozen(manifestPath, manifest),
  writeFrozen(freezePath, freeze),
  Deno.writeTextFile(reviewPath, review),
]);
console.log(JSON.stringify(
  {
    developmentOnly: true,
    cases: cases.length,
    changedFields: changed.length,
    writerInputArtifact: outputPath.pathname,
    review: reviewPath.pathname,
    editManifest: manifestPath.pathname,
    freeze: freezePath.pathname,
    providerCalls: 0,
    writerCalls: 0,
    productionWritePaths: [],
    shadowWritePaths: [],
  },
  null,
  2,
));
