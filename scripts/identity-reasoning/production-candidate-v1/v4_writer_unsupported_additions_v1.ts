/**
 * Validator Heuristic Correction v1.
 *
 * This is a versioned validation overlay. It intentionally does not alter the
 * frozen v4 unsupported-additions validator used by historical runs.
 */
import type { OneParagraphLens } from "../canonical-lens-production-preview/one_paragraph_writer_v4.ts";

export const VALIDATOR_HEURISTIC_CORRECTION_V1 =
  "pcv1-v4-writer-validator-heuristic-correction-v1" as const;

type WriterInput = {
  plain_insight: string;
  plain_action: string | null;
};

function sentenceFragments(value: string): string[] {
  return value.trim().split(/(?<=[.!?])\s+/).filter(Boolean);
}

/**
 * "You make sure …" and "You may … and make sure …" can describe the
 * approved subject's observed behavior. Imperative "Make sure …", conditional
 * "Before …, make sure …", and modal "You should make sure …" remain advice.
 */
function isDescriptiveMakeSure(sentence: string): boolean {
  const normalized = sentence.trim();
  if (!/^you\b/i.test(normalized)) return false;
  if (/^you\s+(?:should|need to|must|can)\b/i.test(normalized)) return false;
  return /\bmake sure\b/i.test(normalized);
}

function hasUnsupportedAdvice(read: string): boolean {
  for (const sentence of sentenceFragments(read)) {
    if (/^(?:make sure|try to|remember to)\b/i.test(sentence.trim())) return true;
    if (/^(?:before|after|when)\b[^.]{0,100},\s*(?:make sure|try to|remember to)\b/i.test(sentence.trim())) {
      return true;
    }
    if (/^you\s+(?:should|need to|must)\b/i.test(sentence.trim())) return true;
    if (/\bmake sure\b/i.test(sentence) && !isDescriptiveMakeSure(sentence)) return true;
    if (/\b(?:try to|remember to)\b/i.test(sentence) && !/^you\s+(?:may|often|tend to|usually|will)\b/i.test(sentence.trim())) {
      return true;
    }
  }
  return false;
}

function motiveErrors(text: string): string[] {
  return /\byou\s+(?:want|fear|need|feel|believe|are afraid)\b/i.test(text)
    ? ["output adds an unsupported motive, emotion, or inner state"]
    : [];
}

function adviceErrors(text: string, plainAction: string | null): string[] {
  if (plainAction !== null || !hasUnsupportedAdvice(text)) return [];
  return ["output invents advice although no supported action was supplied"];
}

function errorsForText(text: string, plainAction: string | null): string[] {
  return [...motiveErrors(text), ...adviceErrors(text, plainAction)];
}

/**
 * Titles are always generated language and remain fully checked. Reads are
 * checked with grammatical evidence: descriptive subject behavior is permitted
 * while imperative or modal advice remains rejected.
 */
export function unsupportedAdditionErrorsV1(
  result: OneParagraphLens,
  input: WriterInput,
): string[] {
  return [...new Set([
    ...errorsForText(result.title, input.plain_action),
    ...errorsForText(result.read, input.plain_action),
  ])];
}
