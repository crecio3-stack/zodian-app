import { assert, assertEquals } from "jsr:@std/assert";
import { validateV5CandidateOutput } from "./v5_writer_candidate_validation.ts";
import { validateV5CandidateOutputCorrectionV1 } from "./v5_writer_candidate_validator_correction_v1.ts";
import { auditV5_1CohortRepetition } from "./v5_1_cohort_repetition_audit.ts";

const piscesInput = { plainInsight: "You may stay composed while the disagreement continues without naming what you need from it.", approvedSecondBeat: null, approvedInterpersonalEffects: [], completenessOutcome: "ONE_BEAT_COMPLETE" as const };
const piscesOutput = { title: "Calm in an Unnamed Disagreement", read: "You can stay composed as a disagreement continues without naming what you need from it." };

Deno.test("v5.1 allows the approved Pisces × Ox descriptive need phrase but retains advice rejection", () => {
  assert(!validateV5CandidateOutput(piscesOutput, piscesInput).accepted);
  assert(validateV5CandidateOutputCorrectionV1(piscesOutput, piscesInput).accepted);
  const advisory = validateV5CandidateOutputCorrectionV1({ title: "A Quiet Disagreement", read: "You need to name what you need from it." }, piscesInput);
  assert(advisory.errors.includes("output adds an unsupported motive, emotion, or inner state"));
});

Deno.test("v5.1 rejects unsupported claims about another person's needs", () => {
  const result = validateV5CandidateOutputCorrectionV1({ title: "A Quiet Disagreement", read: "You may stay composed while another person's needs go unnamed." }, piscesInput);
  assert(result.errors.includes("unsupported claim about another person's needs"));
  const theyNeed = validateV5CandidateOutputCorrectionV1({ title: "A Quiet Disagreement", read: "You may stay composed while they need an answer." }, piscesInput);
  assert(theyNeed.errors.includes("unsupported claim about another person's needs"));
});

Deno.test("v5.1 refines openings, flags excessive temporal connectors, and catches Aries local wording repetition", () => {
  const reads = Array.from({ length: 16 }, (_, index) => ({ stableCaseId: String(index), completenessOutcome: index < 3 ? "ONE_BEAT_COMPLETE" as const : "SECOND_BEAT_SUPPORTED" as const, output: { title: `Pattern ${index}`, read: index < 8 ? "Before a choice settles, you may hold the same position. It can remain open." : "A practical pattern can stay visible. The details remain clear." } }));
  reads[0].output.read = "After a shared cost changes, you may stay with your first position. You may keep pushing the original approach instead of reassessing the change.";
  const audit = auditV5_1CohortRepetition(reads);
  assert(audit.excessive_temporal_connectors.some((item) => item.connector === "before"));
  assert(audit.local_stem_repetition.some((item) => item.stable_case_id === "0" && item.repeated_stems.some((stem) => stem.stem === "change")));
  assertEquals(audit.mechanical_sentence_mapping_is_audit_signal_only, true);
  assert(!Object.hasOwn(audit.opening_frames, "other_declarative"));
});

Deno.test("v5.1 assigns each supported opening frame without requiring all frames in a cohort", () => {
  const reads = [
    ["direct", "You tend to hold a position when the terms change."],
    ["temporal", "When terms change, you tend to hold a position."],
    ["first", "Your first move is often to hold the position."],
    ["pattern", "The pattern here is holding the position."],
    ["contrast", "Rather than reassessing, you keep the position."],
    ["hedged", "You may hold the position as the terms change."],
    ["noun", "A familiar position can stay in place."],
  ].map(([stableCaseId, read]) => ({ stableCaseId, completenessOutcome: "ONE_BEAT_COMPLETE" as const, output: { title: stableCaseId, read } }));
  const audit = auditV5_1CohortRepetition(reads);
  assert(Object.hasOwn(audit.opening_frames, "direct_subject_behavior"));
  assert(Object.hasOwn(audit.opening_frames, "temporal_context_opening"));
  assert(Object.hasOwn(audit.opening_frames, "first_move_framing"));
  assert(Object.hasOwn(audit.opening_frames, "pattern_framing"));
  assert(Object.hasOwn(audit.opening_frames, "contrast_framing"));
  assert(Object.hasOwn(audit.opening_frames, "possibility_hedged"));
  assert(Object.hasOwn(audit.opening_frames, "descriptive_noun_phrase"));
});
