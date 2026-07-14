/** Versioned v5.1 validator overlay. It leaves the v5 validator and frozen outputs unchanged. */
import type { OneParagraphLens } from "../canonical-lens-production-preview/one_paragraph_writer_v5_candidate.ts";
import {
  type V5CandidateValidationInput,
  validateV5CandidateOutput,
} from "./v5_writer_candidate_validation.ts";

export const V5_VALIDATOR_CORRECTION_V1 = "pcv1-frozen-v5-validator-correction-v1" as const;
function normalized(value: string) { return value.toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim(); }
function approvedDescriptiveNeed(output: OneParagraphLens, input: V5CandidateValidationInput): boolean {
  const approved = normalized(input.plainInsight);
  const observed = normalized(output.read);
  if (!/\bwhat you need(?: from (?:it|the \w+))?\b/i.test(output.read)) return false;
  if (!/\bwhat you need(?: from (?:it|the \w+))?\b/i.test(input.plainInsight)) return false;
  if (/\byou need to\b|\byou should\b|^(?:need|should)\b/i.test(output.read.trim())) return false;
  return approved.includes("without naming what you need") && observed.includes("without naming what you need");
}
function otherPersonNeedErrors(text: string, approved: string[]) {
  const patterns = [
    /\b(?:their|someone else'?s|another person'?s|other people'?s) needs?\b/i,
    /\bwhat (?:they|someone else|another person) needs?\b/i,
    /\b(?:they|someone else|another person|other people) need(?:s)?\b/i,
  ];
  const normalizedApproved = approved.map(normalized);
  return patterns.flatMap((pattern) => pattern.test(text) && !normalizedApproved.some((item) => normalized(text).includes(item)) ? ["unsupported claim about another person's needs"] : []);
}
export function validateV5CandidateOutputCorrectionV1(value: unknown, input: V5CandidateValidationInput) {
  const base = validateV5CandidateOutput(value, input);
  if (!value || typeof value !== "object" || Array.isArray(value)) return { ...base, correction_applied: false, other_person_need_errors: [] };
  const output = value as OneParagraphLens;
  const descriptiveNeed = approvedDescriptiveNeed(output, input);
  const errors = base.errors.filter((error) => !(descriptiveNeed && error === "output adds an unsupported motive, emotion, or inner state"));
  const otherPersonNeeds = otherPersonNeedErrors(`${output.title} ${output.read}`, input.approvedInterpersonalEffects);
  return { ...base, accepted: errors.length + otherPersonNeeds.length === 0, errors: [...errors, ...otherPersonNeeds], correction_applied: descriptiveNeed, other_person_need_errors: otherPersonNeeds };
}
