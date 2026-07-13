export type OneParagraphLens = { title: string; read: string };

export type OneParagraphWritingInput = {
  caseId: string;
  clarityStatus: "CLEAR" | "PARTIAL";
  plainInsight: string;
  supportingEvidence: Array<{ path: string; claim: string }>;
  goldExamples: OneParagraphLens[];
  blockedPhrases: string[];
};

export type OneParagraphValidation = { errors: string[]; flags: string[] };

const abstractRiskTerms = [
  "deeper meaning",
  "inner truth",
  "framework",
  "mechanism",
  "dynamic",
  "alignment",
  "holding space",
];

function sentences(value: string) {
  return value.trim().split(/(?<=[.!?])\s+/).filter(Boolean);
}

function normalized(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim();
}

export function buildOneParagraphPrompt(input: OneParagraphWritingInput): string {
  const examples = input.goldExamples.map((example, index) =>
    `${index + 1}. Title: ${example.title}\nRead: ${example.read}`
  ).join("\n\n");
  const evidence = input.supportingEvidence.map((item) => `- ${item.claim}`).join("\n");

  return `You write a short Today’s Lens in normal conversational English.\n\nReturn JSON only with exactly two string fields: title and read.\n\nUse this supported insight and no other interpretation:\n${input.plainInsight}\n\nSupported evidence you may rephrase:\n${evidence}\n\nThe clarity status is ${input.clarityStatus}. ${input.clarityStatus === "PARTIAL" ? "Stay with the narrow supported behavior. Do not supply a missing reason, emotional motive, or deeper problem." : "Do not add any claim beyond the supported insight and evidence."}\n\nTitle: common words, immediately understandable, literal rather than clever.\nRead: one flowing paragraph, normally 3–5 sentences when useful, with one main idea. Say exactly what you mean. Use concrete behavior, explicit subjects and actions, and obvious cause and effect. Advice is optional.\n\nDo not use metaphors, literary language, abstract causal language, corporate jargon, therapy-speak, personality-model terminology, semicolons, repeated restatements, hidden motives, unsupported emotions, new scenario facts, or unsupported advice.\n\nThese approved examples show the target simplicity. Do not copy their structure or wording:\n\n${examples}`;
}

export function validateOneParagraphLens(value: unknown, input: Pick<OneParagraphWritingInput, "blockedPhrases">): OneParagraphValidation {
  const errors: string[] = [];
  const flags: string[] = [];
  if (!value || typeof value !== "object" || Array.isArray(value)) return { errors: ["Output must be an object."], flags };
  const record = value as Record<string, unknown>;
  const keys = Object.keys(record).sort();
  if (keys.join(",") !== "read,title") errors.push("Output must contain exactly title and read.");
  if (typeof record.title !== "string" || !record.title.trim()) errors.push("title must be a non-empty string.");
  if (typeof record.read !== "string" || !record.read.trim()) errors.push("read must be a non-empty string.");
  if (errors.length) return { errors, flags };

  const title = (record.title as string).trim();
  const read = (record.read as string).trim();
  if (title.length > 80) errors.push("title exceeds 80 characters.");
  if (read.includes("\n")) errors.push("read must be one paragraph.");
  const readSentences = sentences(read);
  if (readSentences.length > 5) errors.push("read exceeds five sentences.");
  if (readSentences.length === 0) errors.push("read must contain a sentence.");
  if (read.includes(";")) flags.push("semicolon");
  if (/\b(?:intro|pull quote|deeper read|watch|move):/i.test(read)) errors.push("read contains a legacy six-field label.");
  if (readSentences.some((sentence) => sentence.trim().split(/\s+/).length > 32)) flags.push("long_sentence");
  if (new Set(readSentences.map(normalized)).size !== readSentences.length) flags.push("repeated_sentence");
  if (/\bnot\b[^.]{0,80}\bbut\b/i.test(read)) flags.push("contrast_construction");
  for (const term of abstractRiskTerms) if (normalized(`${title} ${read}`).includes(term)) flags.push(`abstract_risk:${term}`);
  for (const phrase of input.blockedPhrases) if (normalized(`${title} ${read}`).includes(normalized(phrase))) errors.push(`contains excluded unsupported phrase: ${phrase}`);
  return { errors, flags };
}
