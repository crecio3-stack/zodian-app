import type { OneParagraphLens } from "../canonical-lens-production-preview/one_paragraph_writer_v4.ts";

type WriterInput = {
  plain_insight: string;
  plain_action: string | null;
};

function heuristicErrors(text: string, plainAction: string | null): string[] {
  const errors: string[] = [];
  if (/\byou\s+(?:want|fear|need|feel|believe|are afraid)\b/.test(text)) {
    errors.push("output adds an unsupported motive, emotion, or inner state");
  }
  if (
    plainAction === null &&
    /\b(?:try to|remember to|make sure|you should|you need to)\b/.test(text)
  ) {
    errors.push(
      "output invents advice although no supported action was supplied",
    );
  }
  return errors;
}

// A verbatim read cannot contain a writer-added motive or action. Titles remain
// model-generated and are always scanned independently.
export function unsupportedAdditionErrors(
  result: OneParagraphLens,
  input: WriterInput,
): string[] {
  const titleErrors = heuristicErrors(
    result.title.toLowerCase(),
    input.plain_action,
  );
  const readIsVerbatimApprovedInput =
    result.read.trim() === input.plain_insight.trim();
  const readErrors = readIsVerbatimApprovedInput
    ? []
    : heuristicErrors(result.read.toLowerCase(), input.plain_action);
  return [...new Set([...titleErrors, ...readErrors])];
}
