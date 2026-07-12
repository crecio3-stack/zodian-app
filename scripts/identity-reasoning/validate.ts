import {
  type IdentityQualityAudit,
  type IdentitySectionKey,
  SECTION_KEYS,
} from "./types.ts";

const forbiddenOpeners = [
  /^as an?\s/i,
  /^because you are\s/i,
  /^your western sign\s/i,
  /^your chinese sign\s/i,
];
const behaviorMarkers = [
  /\bwhen\b/gi,
  /\bwhile\b/gi,
  /\bnotice\b/gi,
  /\bask\b/gi,
  /\bsay\b/gi,
  /\bshow up\b/gi,
  /\banswer\b/gi,
  /\bconversation\b/gi,
  /\bdecision\b/gi,
  /\bwork\b/gi,
  /\broom\b/gi,
  /\bday\b/gi,
  /\bplan\b/gi,
  /\bleave\b/gi,
  /\breturn\w*\b/gi,
  /\bdrive\w*\b/gi,
  /\bproject\b/gi,
  /\bchange\w*\b/gi,
  /\bchoose\w*\b/gi,
  /\bmake\w*\b/gi,
  /\bremember\w*\b/gi,
  /\bfix\w*\b/gi,
  /\btake\w*\b/gi,
  /\bwait\w*\b/gi,
  /\bmove\w*\b/gi,
];
const syntheticPhrases = [
  "emotional regulation",
  "relational dynamic",
  "ordinary stewardship",
  "holding space",
];

type ProseShape = Record<IdentitySectionKey, string>;

export function auditIdentity(result: ProseShape): IdentityQualityAudit {
  const issues: string[] = [];
  const section_word_counts = {} as Record<IdentitySectionKey, number>;
  const observable_behavior_hits = {} as Record<IdentitySectionKey, number>;
  const clarity_flags = {} as Record<IdentitySectionKey, string[]>;
  const normalizedSections: string[] = [];

  for (const key of SECTION_KEYS) {
    const text = result[key]?.trim() ?? "";
    const count = text ? text.split(/\s+/).length : 0;
    section_word_counts[key] = count;
    clarity_flags[key] = [];
    observable_behavior_hits[key] = behaviorMarkers.reduce(
      (sum, marker) => sum + (text.match(marker)?.length ?? 0),
      0,
    );
    if (count < 90) issues.push(`${key}: fewer than 90 words`);
    if (count > 210) {
      issues.push(`${key}: more than 210 words; compress the section`);
    }
    if (observable_behavior_hits[key] < 2) {
      issues.push(`${key}: insufficient observable behavior`);
    }
    if (forbiddenOpeners.some((pattern) => pattern.test(text))) {
      issues.push(`${key}: forbidden astrological opener`);
    }
    for (const phrase of syntheticPhrases) {
      if (text.toLowerCase().includes(phrase)) {
        clarity_flags[key].push(phrase);
        issues.push(`${key}: synthetic or clinical phrase: ${phrase}`);
      }
    }
    const overloaded = text.split(/[.!?]+/).filter((sentence) =>
      sentence.trim().split(/\s+/).length > 34
    ).length;
    if (overloaded > 1) {
      clarity_flags[key].push(`${overloaded} sentences over 34 words`);
      issues.push(`${key}: too many overloaded sentences`);
    }
    normalizedSections.push(text.toLowerCase().replace(/[^a-z0-9 ]/g, " "));
  }

  for (let a = 0; a < normalizedSections.length; a++) {
    for (let b = a + 1; b < normalizedSections.length; b++) {
      const phrases = new Set(
        normalizedSections[a].split(/\s+/).filter(Boolean).map((
          _,
          index,
          words,
        ) => words.slice(index, index + 8).join(" ")),
      );
      const repeated = normalizedSections[b].split(/\s+/).some((
        _,
        index,
        words,
      ) => phrases.has(words.slice(index, index + 8).join(" ")));
      if (repeated) {
        issues.push(
          `${SECTION_KEYS[a]} / ${SECTION_KEYS[b]}: repeated 8-word phrase`,
        );
      }
    }
  }
  return {
    passed: issues.length === 0,
    issues,
    section_word_counts,
    observable_behavior_hits,
    clarity_flags,
  };
}
