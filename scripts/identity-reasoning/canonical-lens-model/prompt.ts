import type { ModelWritingRequest } from "./types.ts";

export const MODEL_WRITING_SYSTEM =
  `You are Zodian's Today’s Lens editorial writer.
Reason only from the selected context and completed reasoning plan you receive.
Write one grounded day, not a personality profile or prediction. Use second person,
ordinary behavior, contemporary language, and a quiet recognition arc.
Never mention signs, astrology, the universe, planets, fate, guaranteed outcomes,
therapy, diagnosis, or unsupported events. Do not repeat the same insight across fields.
Every Lens must anchor its central observation in at least one supplied observable
behavior and use the supplied arena detail to make the day recognizable. Preserve the
causal logic in the reasoning plan. Do not replace concrete evidence with emotional
abstraction, and do not invent motives, fears, desires, histories, or events absent from
the supplied context. The two identities must resolve the same scenario through visibly
different reasoning. Prefer a specific action, hesitation, exchange, or decision over
generic language about energy, alignment, clarity, growth, or moving forward.
Silently check before writing: what behavior is visible, what detail makes the scenario
specific, what identity tension explains it, what claim would be unsupported, and whether
the result could be swapped with the other identity. Do not reveal this checklist or
chain-of-thought; return only the final JSON object.
Return JSON only with exactly title, intro, pull_quote, deeper_read, watch_for, and move.`;

export function buildModelWritingPrompt(
  request: ModelWritingRequest,
  validationErrors: string[] = [],
): string {
  const allowedContext = {
    activatedParadox: request.context.selected.activatedParadox,
    perception: request.context.selected.perception,
    decision: request.context.selected.decision,
    pressureOrGrowth: request.context.selected.pressureOrGrowth,
    observableBehaviors: request.context.selected.observableBehaviors,
    arenaDetail: request.context.selected.arenaDetail,
  };
  const allowedPlan = {
    activatedIdentityTension: request.reasoning.activatedIdentityTension,
    primaryArena: request.reasoning.primaryArena,
    identitySpecificRole: request.reasoning.identitySpecificRole,
    startingAssumption: request.reasoning.startingAssumption,
    recognition: request.reasoning.recognition,
    ordinaryLifeExpression: request.reasoning.ordinaryLifeExpression,
    blindSpot: request.reasoning.blindSpot,
    naturalMove: request.reasoning.naturalMove,
    signInteraction: request.reasoning.signInteraction,
  };
  return `${MODEL_WRITING_SYSTEM}

Daily input:
${
    JSON.stringify({
      scenarioId: request.scenario.seed,
      date: request.scenario.date,
      symbolicContext: request.scenario.symbolicContext,
      humanTension: request.scenario.humanTension,
      arena: request.scenario.arena,
      emotionalTone: request.scenario.emotionalTone,
    })
  }

Selected canonical context (the complete identity is intentionally unavailable):
${JSON.stringify(allowedContext, null, 2)}

Completed internal reasoning plan:
${JSON.stringify(allowedPlan, null, 2)}

Output contract:
- title: 2–4 words
- intro: exactly one sentence, 12–22 words
- pull_quote: exactly one sentence, 12–22 words
- deeper_read: 1–2 sentences, 30–60 words
- watch_for: exactly one sentence, 10–24 words, visible behavior or exchange
- move: exactly one sentence, 10–24 words, distinct from watch_for
${
    validationErrors.length
      ? `\nPrevious validation errors to correct without adding context. Preserve every valid field unchanged where possible:\n${
        validationErrors.map((error) => `- ${error}`).join("\n")
      }`
      : ""
  }`;
}
