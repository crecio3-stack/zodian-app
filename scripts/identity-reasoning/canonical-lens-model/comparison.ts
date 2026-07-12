import type {
  CanonicalLens,
  CanonicalLensContext,
  CanonicalLensReasoningPlan,
} from "../canonical-lens/types.ts";
import type { RubricScores } from "./types.ts";

const generic = [
  "the universe",
  "your sign",
  "fate",
  "destiny",
  "the stars",
  "everything happens",
];
const behavior = [
  "watch",
  "notice",
  "ask",
  "say",
  "reply",
  "conversation",
  "meeting",
  "plan",
  "purchase",
  "message",
  "room",
  "task",
  "route",
  "answer",
];

const wordCount = (value: string) => value.split(/\s+/).filter(Boolean).length;
export function scoreLens(
  lens: CanonicalLens,
  context: CanonicalLensContext,
  reasoning: CanonicalLensReasoningPlan,
): RubricScores {
  const all = Object.values(lens).join(" ").toLowerCase();
  const behaviorHits = behavior.filter((word) => all.includes(word)).length;
  const genericHits = generic.filter((phrase) => all.includes(phrase)).length;
  const arenaHit = all.includes(context.scenario.arena) ||
    all.includes(context.selected.arenaDetail.split(" ")[0].toLowerCase());
  const distinctFields =
    new Set(Object.values(lens).map((value) => value.slice(0, 28))).size;
  const score = (value: number) => Math.max(1, Math.min(5, Math.round(value)));
  return {
    identitySpecificity: score(
      3 +
        (all.includes(
            reasoning.identitySpecificRole.split(" ")[3]?.toLowerCase() ??
              "never",
          )
          ? 1
          : 0),
    ),
    behavioralConcreteness: score(2 + behaviorHits / 5),
    scenarioRelevance: score(3 + (arenaHit ? 1 : 0)),
    canonicalGrounding: score(
      3 +
        (reasoning.recognition &&
            all.includes(reasoning.naturalMove.split(" ")[0].toLowerCase())
          ? 1
          : 0),
    ),
    internalCoherence: score(4),
    fieldDifferentiation: score(2 + distinctFields / 2),
    contemporaryVoice: score(4 - genericHits),
    usefulness: score(3 + (wordCount(lens.move) >= 10 ? 1 : 0)),
    nonPredictiveDiscipline: score(genericHits === 0 ? 5 : 2),
    repetitionControl: score(4),
  };
}

export function automatedNotes(
  baseline: CanonicalLens,
  experimental: CanonicalLens | null,
): string[] {
  if (!experimental) {
    return ["model output rejected; no field comparison available"];
  }
  const notes: string[] = [];
  if (baseline.pull_quote !== experimental.pull_quote) {
    notes.push("model changes the recognition line");
  }
  if (baseline.move !== experimental.move) {
    notes.push("model preserves a distinct action field");
  }
  if (experimental.deeper_read.length > baseline.deeper_read.length) {
    notes.push("model adds explanatory detail");
  }
  if (experimental.deeper_read.length < baseline.deeper_read.length) {
    notes.push("model is more compressed");
  }
  return notes.length
    ? notes
    : ["model and baseline use similar editorial density"];
}
