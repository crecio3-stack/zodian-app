import type { OneParagraphLens } from "../canonical-lens-production-preview/one_paragraph_writer_v5_candidate.ts";

export const V5_1_REPETITION_AUDIT_VERSION = "pcv1-frozen-v5-1-repetition-audit-v1" as const;
export type V5_1CohortRead = { stableCaseId: string; completenessOutcome: "ONE_BEAT_COMPLETE" | "SECOND_BEAT_SUPPORTED"; output: OneParagraphLens };
const ignored = new Set(["the", "and", "with", "from", "your", "when", "what", "before", "after", "into", "have", "where", "while", "that", "this", "you", "may", "can", "for", "are", "was", "has", "had", "its", "it"]);
function normalized(value: string) { return value.toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim(); }
function tokens(value: string) { return normalized(value).split(" ").filter((word) => word.length > 2 && !ignored.has(word)); }
function stem(word: string) { if (/^(change|changes|changed|changing)$/.test(word)) return "change"; if (/^(answer|answers|answered|answering)$/.test(word)) return "answer"; if (/^(settle|settles|settled|settling)$/.test(word)) return "settle"; return word.replace(/(?:ing|ed|s)$/i, ""); }
function openingFrame(read: string) {
  const value = read.trim().toLowerCase();
  if (/^your first move\b/.test(value)) return "first_move_framing";
  if (/^the pattern\b/.test(value)) return "pattern_framing";
  if (/^(?:rather than|instead of)\b/.test(value)) return "contrast_framing";
  if (/^you\s+(?:may|can|might)\b/.test(value)) return "possibility_hedged";
  if (/^(?:when|while|once|after|before|as|in)\b/.test(value)) return "temporal_context_opening";
  if (/^(?:a|an|the)\b/.test(value)) return "descriptive_noun_phrase";
  if (/^you\b/.test(value)) return "direct_subject_behavior";
  return "direct_declarative";
}
function group(items: Array<{ key: string; id: string }>) { const map = new Map<string, string[]>(); for (const item of items) map.set(item.key, [...(map.get(item.key) ?? []), item.id]); return Object.fromEntries(map); }
function sentences(read: string) { return read.trim().split(/(?<=[.!?])\s+/).filter(Boolean); }
export function auditV5_1CohortRepetition(reads: V5_1CohortRead[]) {
  const openingFrames = group(reads.map((item) => ({ key: openingFrame(item.output.read), id: item.stableCaseId })));
  const connectorNames = ["before", "when", "while", "once", "after"] as const;
  const connectors = Object.fromEntries(connectorNames.map((connector) => [connector, reads.filter((item) => new RegExp(`\\b${connector}\\b`, "i").test(item.output.read)).map((item) => item.stableCaseId)]));
  const connectorThreshold = Math.ceil(reads.length * 0.35);
  const excessiveConnectors = Object.entries(connectors).filter(([, ids]) => (ids as string[]).length > connectorThreshold).map(([connector, case_ids]) => ({ connector, case_ids }));
  const localStemRepetition = reads.flatMap((item) => {
    const counts = new Map<string, number>(); for (const token of tokens(item.output.read)) { const value = stem(token); counts.set(value, (counts.get(value) ?? 0) + 1); }
    const repeated = [...counts.entries()].filter(([, count]) => count > 1).map(([value, count]) => ({ stem: value, count }));
    return repeated.length ? [{ stable_case_id: item.stableCaseId, repeated_stems: repeated }] : [];
  });
  const sentenceCounts = Object.fromEntries(["ONE_BEAT_COMPLETE", "SECOND_BEAT_SUPPORTED"].map((outcome) => [outcome, reads.filter((item) => item.completenessOutcome === outcome).map((item) => sentences(item.output.read).length)]));
  const one = sentenceCounts.ONE_BEAT_COMPLETE as number[]; const two = sentenceCounts.SECOND_BEAT_SUPPORTED as number[];
  const mechanicalSentenceMapping = one.length > 0 && two.length > 0 && new Set(one).size === 1 && new Set(two).size === 1 && one[0] !== two[0];
  return { version: V5_1_REPETITION_AUDIT_VERSION, opening_frames: openingFrames, max_opening_frame_count: Math.max(...Object.values(openingFrames).map((ids) => (ids as string[]).length), 0), connector_counts: Object.fromEntries(Object.entries(connectors).map(([connector, ids]) => [connector, (ids as string[]).length])), connector_threshold: connectorThreshold, excessive_temporal_connectors: excessiveConnectors, local_stem_repetition: localStemRepetition, sentence_counts_by_completeness: sentenceCounts, mechanical_sentence_mapping: mechanicalSentenceMapping, mechanical_sentence_mapping_is_audit_signal_only: true };
}
