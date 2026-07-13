export const PCV1_DEVELOPMENT_PROJECT_REF = "wlsewblvpyeanfganbkc" as const;
// This Development-only key intentionally advances after the frozen-input
// boundary fix. Earlier selector-driven terminal rows remain immutable and
// auditable under their original candidate versions.
export const PCV1_PRODUCER_VERSION = "pcv1-frozen-approved-input-v1" as const;

export type ProducerRequest = {
  candidate_date?: unknown;
  stable_case_id?: unknown;
};

export type RuntimeSnapshotCase = {
  stable_case_id: string;
  western_sign: string;
  eastern_sign: string;
  domain: string;
  source_context: string;
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
  candidate_evidence: Array<{ path: string; claim: string; source: string }>;
  approved_calibration: null | {
    plain_insight: string;
    plain_action: string | null;
    source_calibration_status: "APPROVE" | "NARROW";
    selected_evidence: Array<{ path: string; claim: string }>;
  };
};

export type RuntimeSnapshot = {
  version: string;
  development_only: true;
  source_artifacts: Record<string, unknown>;
  gold_examples: Array<{ title: string; read: string }>;
  cases: RuntimeSnapshotCase[];
  sha256: string;
};

export type SelectorResult = {
  status: "SELECTED" | "BLOCKED";
  behavior: string | null;
  supporting_evidence: Array<{ path: string; claim: string }>;
  applicability: string | null;
  unsupported_claims_added: [];
};

export type OneParagraphLens = { title: string; read: string };

export function frozenApprovedWriterInput(item: RuntimeSnapshotCase): {
  plain_insight: string;
  plain_action: string | null;
  source_calibration_status: "APPROVE" | "NARROW";
  selected_evidence: Array<{ path: string; claim: string }>;
} | null {
  return item.approved_calibration
    ? {
      plain_insight: item.approved_calibration.plain_insight,
      plain_action: item.approved_calibration.plain_action,
      source_calibration_status: item.approved_calibration.source_calibration_status,
      selected_evidence: item.approved_calibration.selected_evidence,
    }
    : null;
}

function text(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

export function parseProducerRequest(input: ProducerRequest): {
  value?: { candidateDate: string; stableCaseId: string };
  errors: string[];
} {
  const candidateDate = text(input.candidate_date);
  const stableCaseId = text(input.stable_case_id);
  const errors: string[] = [];
  if (!/^\d{4}-\d{2}-\d{2}$/.test(candidateDate)) {
    errors.push("candidate_date must be YYYY-MM-DD");
  }
  if (!stableCaseId) errors.push("stable_case_id is required");
  return errors.length ? { errors } : {
    errors,
    value: { candidateDate, stableCaseId },
  };
}

export function isDevelopmentProjectUrl(url: string | undefined): boolean {
  try {
    return new URL(url ?? "").hostname ===
      `${PCV1_DEVELOPMENT_PROJECT_REF}.supabase.co`;
  } catch {
    return false;
  }
}

export function stable(value: unknown): string {
  return JSON.stringify(value, null, 2) + "\n";
}

export async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

export const selectorInstructions =
  `You are Neutral Insight Selector v1 for a development-only Zodian experiment.

Select at most one concrete, user-owned behavior from the supplied canonical evidence that can plausibly be relevant to the supplied neutral external situation.

Return JSON only with exactly these five fields:
status, behavior, supporting_evidence, applicability, unsupported_claims_added.

SELECTED means the supplied evidence directly supports one behavior. Cite only exact path and claim pairs from candidate_evidence. Write behavior as one ordinary observation about what the user may do, notice, avoid, check, repeat, or hesitate to do. The applicability explains only how the neutral external situation makes that cited behavior relevant.

BLOCKED means no supplied evidence supports a concrete personal behavior in this situation. For BLOCKED return behavior null, applicability null, and an empty supporting_evidence array.

Never create a title, action, corrective move, Today’s Lens copy, trait, motive, fear, desire, causal explanation, or unsupported scenario fact. Do not use words such as because, want, fear, desire, trust, bored, should, need to, try, make sure, or remember to in behavior. unsupported_claims_added must always be an empty array. The neutral situation supplies no behavior; select only from canonical evidence.`;

export function buildSelectorInput(item: RuntimeSnapshotCase): string {
  return "Return JSON only. Use this frozen selector input exactly as supplied:\n\n" +
    JSON.stringify({
      neutral_situation: item.neutral_situation,
      canonical_identity: item.canonical_identity,
      candidate_evidence: item.candidate_evidence.map(({ path, claim }) => ({
        path,
        claim,
      })),
    }, null, 2);
}

export function buildV4WriterPrompt(
  plainInsight: string,
  plainAction: string | null,
  goldExamples: OneParagraphLens[],
): string {
  const examples = goldExamples.map((example, index) =>
    `${index + 1}. Title: ${example.title}\nRead: ${example.read}`
  ).join("\n\n");
  const action = plainAction
    ? `\n\nOptional supported action:\n${plainAction}`
    : "\n\nThere is no supported action. Do not invent one.";
  return `You write a short Today’s Lens in normal conversational English.

Return JSON only with exactly two string fields: title and read.

Plain insight — this is the only source of meaning and wording for the pattern:
${plainInsight}${action}

The clarity status is PARTIAL. Stay with the narrow observed pattern. Do not explain why it happens. Use the action only if supplied.

Title: use common words. Describe the pattern or useful direction. It must never sound like an instruction to continue the unwanted behavior.
Read: write one flowing paragraph. Two sentences are acceptable. Do not add sentences just to make it longer.

Do not restate the insight in different words. If the insight and optional action already make a complete read, stop. Use explicit subjects and actions, common everyday words, and obvious cause and effect.

Do not use metaphors, literary language, abstract causal language, workplace jargon, therapy-speak, personality-model terminology, semicolons, hidden psychological explanations, or unsupported advice.

Before returning, silently read every sentence aloud as if speaking to a friend. Replace anything that sounds like internal model language, workplace jargon, literary prose, or translated reasoning with ordinary spoken English.

These approved examples show the target simplicity. Do not copy their structure or wording:

${examples}`;
}

export function outputText(payload: Record<string, unknown>): string {
  const output = Array.isArray(payload.output) ? payload.output : [];
  for (const item of output) {
    const content = item && typeof item === "object" &&
        Array.isArray((item as Record<string, unknown>).content)
      ? (item as { content: unknown[] }).content
      : [];
    for (const part of content) {
      if (part && typeof part === "object") {
        const record = part as Record<string, unknown>;
        if (record.type === "output_text" && typeof record.text === "string") {
          return record.text;
        }
      }
    }
  }
  return "";
}

export function parseJson(raw: string): unknown | null {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}
