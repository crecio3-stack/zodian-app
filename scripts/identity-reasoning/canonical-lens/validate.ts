import type { CanonicalLens } from "./types.ts";

const required = [
  "title",
  "intro",
  "pull_quote",
  "deeper_read",
  "watch_for",
  "move",
] as const;
const words = (value: string): number =>
  value.trim().split(/\s+/).filter(Boolean).length;
const sentences = (value: string): number =>
  value.split(/[.!?]+/).map((part) => part.trim()).filter(Boolean).length;

export function validateCanonicalLens(
  read: CanonicalLens,
): { accepted: boolean; reasons: string[] } {
  const reasons: string[] = [];
  for (const key of required) {
    if (!read[key]?.trim()) reasons.push(`${key} is empty`);
  }
  if (words(read.title) < 2 || words(read.title) > 4) {
    reasons.push("title must be 2-4 words");
  }
  if (
    sentences(read.intro) !== 1 || words(read.intro) < 12 ||
    words(read.intro) > 22
  ) reasons.push("intro must be one sentence of 12-22 words");
  if (
    sentences(read.pull_quote) !== 1 || words(read.pull_quote) < 12 ||
    words(read.pull_quote) > 22
  ) reasons.push("pull_quote must be one sentence of 12-22 words");
  if (
    sentences(read.watch_for) !== 1 || words(read.watch_for) < 10 ||
    words(read.watch_for) > 24
  ) reasons.push("watch_for must be one sentence of 10-24 words");
  if (
    sentences(read.move) !== 1 || words(read.move) < 10 || words(read.move) > 24
  ) reasons.push("move must be one sentence of 10-24 words");
  if (
    sentences(read.deeper_read) > 2 || words(read.deeper_read) < 30 ||
    words(read.deeper_read) > 60
  ) reasons.push("deeper_read must be 1-2 sentences of 30-60 words");
  if (read.watch_for === read.move) {
    reasons.push("watch_for and move must differ");
  }
  return { accepted: reasons.length === 0, reasons };
}
