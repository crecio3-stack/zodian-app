export type FinalRead = {
  stableCaseId: string;
  title: string;
  read: string;
  plainInsight: string;
  plainAction: string | null;
};

export type RepetitionDisposition = "ACCEPT" | "HOLD" | "REJECT";
export type RepetitionFinding = {
  kind:
    | "exact_final_duplicate"
    | "near_final_duplicate"
    | "title_collapse"
    | "template_collapse"
    | "repeated_insight_action"
    | "recent_user_repeat";
  disposition: RepetitionDisposition;
  caseIds: string[];
  detail: string;
};

export type RepetitionAudit = {
  disposition: RepetitionDisposition;
  findings: RepetitionFinding[];
};

function normalize(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ")
    .trim();
}

function tokens(value: string) {
  return new Set(
    normalize(value).split(" ").filter((token) => token.length > 2),
  );
}

function similarity(left: string, right: string) {
  const a = tokens(left);
  const b = tokens(right);
  const union = new Set([...a, ...b]);
  if (union.size === 0) return 1;
  const intersection = [...a].filter((token) => b.has(token)).length;
  return intersection / union.size;
}

function template(read: string) {
  return normalize(read)
    .replace(/\byou\b/g, "<person>")
    .replace(
      /\b(?:may|might|often|keep|notice|when|before|after)\b/g,
      "<frame>",
    )
    .split(" ")
    .slice(0, 10)
    .join(" ");
}

function group<T>(items: T[], keyFor: (item: T) => string) {
  const groups = new Map<string, T[]>();
  for (const item of items) {
    const key = keyFor(item);
    groups.set(key, [...(groups.get(key) ?? []), item]);
  }
  return groups;
}

export function auditLightweightRepetition(
  reads: FinalRead[],
  recentReadsForUser: FinalRead[] = [],
): RepetitionAudit {
  const findings: RepetitionFinding[] = [];
  const exactFinals = group(
    reads,
    (item) => `${normalize(item.title)}\u0000${normalize(item.read)}`,
  );
  for (const items of exactFinals.values()) {
    if (items.length > 1) {
      findings.push({
        kind: "exact_final_duplicate",
        disposition: "REJECT",
        caseIds: items.map((item) => item.stableCaseId),
        detail: "Exact normalized title and read are duplicated.",
      });
    }
  }

  for (let left = 0; left < reads.length; left++) {
    for (let right = left + 1; right < reads.length; right++) {
      if (
        normalize(reads[left].title) === normalize(reads[right].title) &&
        similarity(reads[left].read, reads[right].read) >= 0.92 &&
        normalize(reads[left].read) !== normalize(reads[right].read)
      ) {
        findings.push({
          kind: "near_final_duplicate",
          disposition: "HOLD",
          caseIds: [reads[left].stableCaseId, reads[right].stableCaseId],
          detail:
            "Same normalized title with materially matching final copy requires human duplicate review.",
        });
      }
    }
  }

  const collapseThreshold = Math.max(4, Math.ceil(reads.length * 0.15));
  for (const [title, items] of group(reads, (item) => normalize(item.title))) {
    if (title && items.length >= collapseThreshold) {
      findings.push({
        kind: "title_collapse",
        disposition: "HOLD",
        caseIds: items.map((item) => item.stableCaseId),
        detail:
          `Title appears ${items.length} times, meeting the corpus-review threshold of ${collapseThreshold}.`,
      });
    }
  }
  for (
    const [signature, items] of group(reads, (item) => template(item.read))
  ) {
    if (signature && items.length >= collapseThreshold) {
      findings.push({
        kind: "template_collapse",
        disposition: "HOLD",
        caseIds: items.map((item) => item.stableCaseId),
        detail:
          `A repeated opening template appears ${items.length} times, meeting the corpus-review threshold of ${collapseThreshold}.`,
      });
    }
  }
  for (
    const [pair, items] of group(
      reads,
      (item) =>
        `${normalize(item.plainInsight)}\u0000${
          normalize(item.plainAction ?? "")
        }`,
    )
  ) {
    if (pair && items.length >= collapseThreshold) {
      findings.push({
        kind: "repeated_insight_action",
        disposition: "HOLD",
        caseIds: items.map((item) => item.stableCaseId),
        detail:
          `An identical normalized insight/action pair appears ${items.length} times and requires corpus review.`,
      });
    }
  }
  for (const candidate of reads) {
    for (const recent of recentReadsForUser) {
      if (
        normalize(candidate.read) === normalize(recent.read) ||
        similarity(candidate.read, recent.read) >= 0.92
      ) {
        findings.push({
          kind: "recent_user_repeat",
          disposition: "HOLD",
          caseIds: [candidate.stableCaseId, recent.stableCaseId],
          detail:
            "Candidate is substantially similar to a recent read for the same user.",
        });
      }
    }
  }

  const disposition = findings.some((item) => item.disposition === "REJECT")
    ? "REJECT"
    : findings.some((item) => item.disposition === "HOLD")
    ? "HOLD"
    : "ACCEPT";
  return { disposition, findings };
}
