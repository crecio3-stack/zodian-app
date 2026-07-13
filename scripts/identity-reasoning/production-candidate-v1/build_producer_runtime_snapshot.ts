/**
 * Materializes the server-only Development producer snapshot from frozen PCv1
 * evidence, selector, and human-approved writer-input artifacts. It never
 * calls a provider and deliberately contains no user data.
 */

type Evidence = { path: string; claim: string; source: string };
type SelectorCitation = { path: string; claim: string };

type EvidenceCase = {
  stable_case_id: string;
  identity: string;
  domain: string;
  neutral_situation: { id: string; situation: string; observableFacts: string[] };
  canonical_identity: {
    sign_pair: string;
    archetype_name: string;
    version: string;
    identity_sha256: string;
  };
  candidate_evidence: Evidence[];
};

type SelectorRow = {
  stable_case_id: string;
  parsed: {
    status: "SELECTED" | "BLOCKED";
    behavior: string | null;
    supporting_evidence: SelectorCitation[];
    applicability: string | null;
  } | null;
};

type WriterInput = {
  stable_case_id: string;
  plain_insight: string;
  plain_action: string | null;
  source_calibration_status: "APPROVE" | "NARROW";
};

function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

const root = new URL("./", import.meta.url);
const artifacts = new URL("./artifacts/", root);
const target = new URL(
  "../../../supabase/functions/_shared/production-candidate-v1/producer_runtime_snapshot.json",
  root,
);
const evidencePath = new URL("production-candidate-v1-evidence-payload.json", artifacts);
const selectorPath = new URL("production-candidate-v1-selector-only-generation-v1.json", artifacts);
const writerInputsPath = new URL("production-candidate-v1-writer-inputs-v2.json", artifacts);
const goldPath = new URL(
  "../canonical-lens-production-preview/artifacts/v321-one-paragraph-gold-set-v1.json",
  root,
);

const [evidencePayload, selectorGeneration, writerInputs, gold] = await Promise.all([
  Deno.readTextFile(evidencePath).then((text) => JSON.parse(text) as { cases: EvidenceCase[]; sha256: string }),
  Deno.readTextFile(selectorPath).then((text) => JSON.parse(text) as { rows: SelectorRow[]; configuration_sha256: string }),
  Deno.readTextFile(writerInputsPath).then((text) => JSON.parse(text) as { cases: WriterInput[] }),
  Deno.readTextFile(goldPath).then((text) => JSON.parse(text) as {
    status: string;
    cases: Array<{ title: string; read: string }>;
  }),
]);

const writerByCase = new Map(writerInputs.cases.map((item) => [item.stable_case_id, item]));
const selectorByCase = new Map(selectorGeneration.rows.map((item) => [item.stable_case_id, item]));
const cases = evidencePayload.cases.map((item) => {
  const selector = selectorByCase.get(item.stable_case_id);
  if (!selector?.parsed) throw new Error(`Missing frozen selector result: ${item.stable_case_id}`);
  const writer = writerByCase.get(item.stable_case_id);
  const [western_sign, eastern_sign] = item.identity.split(" × ");
  if (!western_sign || !eastern_sign) throw new Error(`Invalid frozen identity: ${item.identity}`);
  return {
    stable_case_id: item.stable_case_id,
    western_sign,
    eastern_sign,
    domain: item.domain,
    source_context: item.neutral_situation.id,
    neutral_situation: item.neutral_situation,
    canonical_identity: item.canonical_identity,
    candidate_evidence: item.candidate_evidence,
    approved_calibration: writer
      ? {
        plain_insight: writer.plain_insight,
        plain_action: writer.plain_action,
        source_calibration_status: writer.source_calibration_status,
        selected_evidence: selector.parsed.supporting_evidence,
      }
      : null,
  };
});

const core = {
  version: "pcv1-development-producer-v1",
  development_only: true,
  source_artifacts: {
    evidence_payload_sha256: evidencePayload.sha256,
    selector_configuration_sha256: selectorGeneration.configuration_sha256,
    writer_inputs_cases: writerInputs.cases.length,
    gold_set_cases: gold.cases.length,
  },
  gold_examples: gold.cases,
  cases,
};
const snapshot = { ...core, sha256: await sha256(stable(core)) };
await Deno.mkdir(new URL("./", target), { recursive: true });
const serialized = stable(snapshot);
try {
  const existing = await Deno.readTextFile(target);
  if (existing !== serialized) {
    throw new Error(
      `Existing frozen producer snapshot differs: ${target.pathname}`,
    );
  }
} catch (error) {
  if (error instanceof Deno.errors.NotFound) {
    await Deno.writeTextFile(target, serialized);
  } else {
    throw error;
  }
}
console.log(JSON.stringify({
  developmentOnly: true,
  cases: cases.length,
  calibrated_cases: cases.filter((item) => item.approved_calibration !== null).length,
  sha256: snapshot.sha256,
  output: target.pathname,
  providerCalls: 0,
}, null, 2));
