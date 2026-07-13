import type {
  OneParagraphLens,
  RuntimeSnapshotCase,
  SelectorResult,
} from "./producer_contract.ts";

const engineered = [
  "observable impact",
  "separate the assumption",
  "repeated step",
  "reversible test",
  "future option",
  "finished work stand",
  "next handoff",
  "follow-through detail",
  "group role",
];

// These are canonical fields whose contract meaning is an observable or
// behavior-bearing pattern. This is deliberately an allowlist: summaries,
// trait labels, motives, fears, and advice remain ineligible evidence sources.
const behaviorBearingCanonicalPaths = [
  /^evidence\.observableBehaviors\[\d+\]$/,
  /^pressure\.visibleBehaviors\[\d+\]$/,
  /^growth\.groundingBehaviors\[\d+\]$/,
  /^work\.careerBlindSpot$/,
  /^relationships\.relationshipBlindSpot$/,
  /^pressure\.decisionDistortion$/,
  /^social\.conflictStyle$/,
  /^core\.matureExpression$/,
];

export function isBehaviorBearingCanonicalPath(path: string): boolean {
  return behaviorBearingCanonicalPaths.some((pattern) => pattern.test(path));
}

function normalize(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ")
    .trim();
}

function contentWords(value: string): Set<string> {
  const ignored = new Set([
    "when", "that", "with", "from", "your", "have", "what", "this",
    "they", "them", "about", "before", "after", "into", "again",
  ]);
  return new Set(normalize(value).split(" ").filter((word) =>
    word.length > 3 && !ignored.has(word)
  ));
}

function sentences(value: string): string[] {
  return value.trim().split(/(?<=[.!?])\s+/).filter(Boolean);
}

export function validateSelector(
  result: unknown,
  item: RuntimeSnapshotCase,
): { errors: string[]; value: SelectorResult | null } {
  const errors: string[] = [];
  if (!result || typeof result !== "object" || Array.isArray(result)) {
    return { errors: ["selector result must be an object"], value: null };
  }
  const row = result as Record<string, unknown>;
  const keys = Object.keys(row).sort().join(",");
  if (keys !== "applicability,behavior,status,supporting_evidence,unsupported_claims_added") {
    errors.push("selector result must contain exactly the frozen fields");
  }
  if (row.status !== "SELECTED" && row.status !== "BLOCKED") {
    errors.push("selector status must be SELECTED or BLOCKED");
  }
  if (!Array.isArray(row.supporting_evidence)) {
    errors.push("selector supporting_evidence must be an array");
  }
  if (!Array.isArray(row.unsupported_claims_added) || row.unsupported_claims_added.length !== 0) {
    errors.push("selector unsupported_claims_added must be an empty array");
  }
  const value = row as unknown as SelectorResult;
  const allowed = new Set(item.candidate_evidence.map((evidence) =>
    `${evidence.path}\u0000${evidence.claim}`
  ));
  const cited = Array.isArray(value.supporting_evidence)
    ? value.supporting_evidence
    : [];
  for (const citation of cited) {
    if (!citation || typeof citation.path !== "string" || typeof citation.claim !== "string") {
      errors.push("selector citation is malformed");
      continue;
    }
    if (!allowed.has(`${citation.path}\u0000${citation.claim}`)) {
      errors.push(`selector citation is outside supplied evidence: ${citation.path}`);
    }
  }
  if (value.status === "SELECTED") {
    if (typeof value.behavior !== "string" || !value.behavior.trim()) {
      errors.push("SELECTED requires a behavior");
    }
    if (!/\byou\b/i.test(value.behavior ?? "")) {
      errors.push("SELECTED behavior must retain a user actor");
    }
    if (/\b(?:should|need to|try|make sure|remember to|because|want|fear|desire)\b/i.test(value.behavior ?? "")) {
      errors.push("SELECTED behavior adds advice, motive, or causal explanation");
    }
    if (typeof value.applicability !== "string" || !value.applicability.trim()) {
      errors.push("SELECTED requires an applicability explanation");
    }
    if (cited.length === 0) errors.push("SELECTED requires cited evidence");
  }
  if (value.status === "BLOCKED") {
    if (value.behavior !== null || value.applicability !== null || cited.length !== 0) {
      errors.push("BLOCKED must not include behavior, applicability, or citations");
    }
  }
  return { errors, value: errors.length ? null : value };
}

export function gateResults(
  selector: SelectorResult,
  item: RuntimeSnapshotCase,
): {
  direct_applicability: { passed: boolean; errors: string[] };
  reasoning_clarity: { status: "CLEAR" | "PARTIAL" | "BLOCKED"; errors: string[] };
  person_first: { passed: boolean; errors: string[] };
  human_language: { passed: boolean; flags: string[] };
} {
  if (selector.status === "BLOCKED") {
    return {
      direct_applicability: { passed: true, errors: [] },
      reasoning_clarity: { status: "BLOCKED", errors: [] },
      person_first: { passed: true, errors: [] },
      human_language: { passed: true, flags: [] },
    };
  }
  const applicabilityErrors: string[] = [];
  if (!item.neutral_situation.situation.trim() || item.neutral_situation.observableFacts.length === 0) {
    applicabilityErrors.push("neutral situation is incomplete");
  }
  if (/\b(?:should|must|try|make sure|remember|because)\b/i.test(selector.applicability ?? "")) {
    applicabilityErrors.push("applicability adds advice, motive, or lesson");
  }
  const behaviorBearingCitations = selector.supporting_evidence.filter((citation) =>
    isBehaviorBearingCanonicalPath(citation.path)
  ).length;
  const personErrors: string[] = [];
  if (behaviorBearingCitations === 0) {
    personErrors.push("no cited approved behavior-bearing canonical field supports the personal pattern");
  }
  if (!/\byou\s+(?:may|notice|often|tend to|keep|compare|wait|move|finish|leave|look|avoid|check|repeat|react|hesitate)\b/i.test(selector.behavior ?? "")) {
    personErrors.push("selected behavior is not a concrete user-owned pattern");
  }
  const flags = engineered.filter((phrase) =>
    new RegExp(`\\b${phrase.replace(/ /g, "\\s+")}\\b`, "i").test(selector.behavior ?? "")
  );
  return {
    direct_applicability: { passed: applicabilityErrors.length === 0, errors: applicabilityErrors },
    reasoning_clarity: {
      status: selector.supporting_evidence.some((citation) => citation.claim === selector.behavior)
        ? "CLEAR"
        : "PARTIAL",
      errors: [],
    },
    person_first: { passed: personErrors.length === 0, errors: personErrors },
    human_language: { passed: flags.length === 0, flags },
  };
}

export function calibrationMatchesSelector(
  selector: SelectorResult,
  item: RuntimeSnapshotCase,
): string[] {
  const calibration = item.approved_calibration;
  if (!calibration) return ["no human-approved calibrated input exists for this frozen case"];
  const cited = new Set(selector.supporting_evidence.map((citation) =>
    `${citation.path}\u0000${citation.claim}`
  ));
  const approved = calibration.selected_evidence;
  if (!approved.some((citation) => cited.has(`${citation.path}\u0000${citation.claim}`))) {
    return ["current selector result does not retain the evidence cited by the approved calibrated input"];
  }
  return [];
}

export function validateWriterOutput(
  value: unknown,
  plainInsight: string,
  plainAction: string | null,
): { errors: string[]; flags: string[]; lens: OneParagraphLens | null } {
  const errors: string[] = [];
  const flags: string[] = [];
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return { errors: ["writer output must be an object"], flags, lens: null };
  }
  const row = value as Record<string, unknown>;
  if (Object.keys(row).sort().join(",") !== "read,title") {
    errors.push("writer output must contain exactly title and read");
  }
  if (typeof row.title !== "string" || !row.title.trim()) errors.push("title must be nonblank");
  if (typeof row.read !== "string" || !row.read.trim()) errors.push("read must be nonblank");
  if (errors.length) return { errors, flags, lens: null };
  const lens = {
    title: (row.title as string).trim(),
    read: (row.read as string).trim(),
  };
  if (lens.title.length > 80) errors.push("title exceeds 80 characters");
  if (lens.read.includes("\n")) errors.push("read must be one paragraph");
  if (sentences(lens.read).length === 0 || sentences(lens.read).length > 5) errors.push("read must contain 1-5 sentences");
  if (/\b(?:intro|pull quote|deeper read|watch|move):/i.test(lens.read)) errors.push("read contains legacy six-field labels");
  if (!/\byou\b/i.test(lens.read)) errors.push("read does not preserve a user actor");
  if (lens.read.includes(";")) flags.push("semicolon");
  const insightWords = contentWords(plainInsight);
  const outputWords = contentWords(`${lens.title} ${lens.read}`);
  if ([...insightWords].filter((word) => outputWords.has(word)).length < Math.min(2, insightWords.size)) {
    errors.push("output does not retain enough concrete meaning from plain insight");
  }
  if (plainAction !== null) {
    const actionWords = contentWords(plainAction);
    if ([...actionWords].filter((word) => outputWords.has(word)).length < 1) {
      errors.push("output does not retain a concrete element of supplied action");
    }
  }
  const addErrors = unsupportedAdditionErrors(lens, plainInsight, plainAction);
  errors.push(...addErrors);
  return { errors, flags, lens: errors.length ? null : lens };
}

export function unsupportedAdditionErrors(
  lens: OneParagraphLens,
  plainInsight: string,
  plainAction: string | null,
): string[] {
  const heuristic = (text: string) => {
    const errors: string[] = [];
    if (/\byou\s+(?:want|fear|need|feel|believe|are afraid)\b/i.test(text)) {
      errors.push("output adds an unsupported motive, emotion, or inner state");
    }
    if (plainAction === null && /\b(?:try to|remember to|make sure|you should|you need to)\b/i.test(text)) {
      errors.push("output invents advice although no supported action was supplied");
    }
    return errors;
  };
  // This mirrors the approved Sample 08 fix: verbatim approved insight means
  // no wording was added in the read. The title remains independently scanned.
  return [...new Set([
    ...heuristic(lens.title.toLowerCase()),
    ...(lens.read.trim() === plainInsight.trim()
      ? []
      : heuristic(lens.read.toLowerCase())),
  ])];
}

export function repetitionDisposition(
  lens: OneParagraphLens,
  existing: Array<{ candidate_title: string | null; candidate_read: string | null }>,
): { disposition: "ALLOW" | "HOLD"; findings: string[] } {
  const candidate = `${normalize(lens.title)}\u0000${normalize(lens.read)}`;
  const duplicate = existing.some((row) =>
    row.candidate_title && row.candidate_read &&
    `${normalize(row.candidate_title)}\u0000${normalize(row.candidate_read)}` === candidate
  );
  return duplicate
    ? { disposition: "HOLD", findings: ["exact normalized candidate copy already exists"] }
    : { disposition: "ALLOW", findings: [] };
}
