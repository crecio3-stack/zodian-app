import type { CanonicalIdentityModel } from "../canonical/types.ts";
import { buildCanonicalLensContext } from "../canonical-lens/adapter.ts";
import type {
  CanonicalLensContext,
  CanonicalLensReasoningPlan,
  DailySymbolicContext,
} from "../canonical-lens/types.ts";
import { manifestationFor, validateManifestation } from "./manifestations.ts";

const libraMoves: Record<string, [string, string, string, string]> = {
  work: [
    "the person who notices the missing condition",
    "The polished answer may still be missing the detail that changes its cost.",
    "state the condition",
    "name the condition before endorsing the plan",
  ],
  love: [
    "the person who watches what follows warmth",
    "A kind interpretation deserves room, but repeated conduct still has to answer for itself.",
    "let the next action provide evidence",
    "watch what happens next instead of explaining it early",
  ],
  home: [
    "the person who tests whether an arrangement still serves everyone",
    "Fairness can include admitting that a familiar arrangement no longer works for you.",
    "make one shared adjustment",
    "change one practical detail before judging the whole arrangement",
  ],
  friends: [
    "the person who hears the honest sentence beneath the mood",
    "Keeping the exchange pleasant is useful only while people are still being honest.",
    "say the true part gently",
    "name the honest part before agreement becomes distance",
  ],
  money: [
    "the person who checks the condition behind the offer",
    "A polished option becomes useful only when the practical term survives scrutiny.",
    "ask for the missing term",
    "check the condition that determines daily usefulness",
  ],
  rest: [
    "the person who separates active responsibility from open questions",
    "Not every unresolved matter still belongs to the part of the day you are protecting.",
    "return an owned decision",
    "set down the question that no longer needs your attention",
  ],
  confidence: [
    "the person who remembers the whole collaboration",
    "Giving context to a success does not require removing your own judgment from it.",
    "receive the recognition plainly",
    "say thank you before supplying the footnotes",
  ],
  routine: [
    "the person who notices when care became ceremony",
    "A thoughtful process can outlive the reason it was built, even when it still looks considerate.",
    "test one removed layer",
    "skip the step whose original purpose has disappeared",
  ],
  conflict: [
    "the person who can tell when an answer is being avoided",
    "Patience helps while the exchange is learning; after that, another explanation may only hide the point.",
    "ask the original question",
    "return to the question instead of refining the explanation",
  ],
  opportunity: [
    "the person who tests a promising opening without surrendering judgment",
    "One unanswered detail can be tested without erasing the evidence already pointing toward a useful beginning.",
    "choose a reversible test",
    "take the first test that lets the opportunity prove itself",
  ],
};

const taurusMoves: Record<string, [string, string, string, string]> = {
  work: [
    "the person who notices responsibility becoming assumed",
    "A dependable setup stops being dependable when every missing piece quietly becomes yours.",
    "move one responsibility early",
    "name the handoff before resentment makes the role impossible",
  ],
  love: [
    "the person who protects chosen closeness",
    "A relationship can feel safe without turning separate time into a test of devotion.",
    "keep one part of the day separate",
    "say what you can offer without surrendering the whole plan",
  ],
  home: [
    "the person who gives restlessness a physical outlet",
    "The life you built may need one changed object or boundary, not a dramatic departure.",
    "alter the room",
    "change the smallest physical detail that restores ownership",
  ],
  friends: [
    "the person who notices availability becoming an obligation",
    "A friendship can remain solid when the familiar plan changes before your yes becomes reluctant.",
    "offer another arrangement",
    "suggest a different plan before showing up resentfully",
  ],
  money: [
    "the person who weighs comfort against future room",
    "A purchase earns its place when it improves the life you are keeping, not only the mood you are escaping.",
    "compare use with freedom",
    "check what the same money lets you choose next week",
  ],
  rest: [
    "the person who protects an unassigned hour",
    "Rest does not have to prove its usefulness before it becomes part of the life you want.",
    "leave one task undone",
    "protect an ordinary hour without turning it into a reward",
  ],
  confidence: [
    "the person whose maintenance made the result last",
    "The work that kept functioning after excitement faded is expertise, even when nobody saw the upkeep.",
    "claim the durable contribution",
    "name what you maintained before minimizing the result",
  ],
  routine: [
    "the person who preserves purpose while changing the route",
    "A useful routine can stay while its shape changes enough to feel chosen again.",
    "vary one part of the pattern",
    "change the route while keeping the result you value",
  ],
  conflict: [
    "the person who catches an old compromise inside a new request",
    "A small irritation may be carrying the weight of several adjustments you never named.",
    "name the earliest compromise",
    "talk about the first change instead of only today's request",
  ],
  opportunity: [
    "the person who looks for expansion with a durable shape",
    "A worthwhile opening should add room to the life you built, not simply replace one constraint with another.",
    "extend what already works",
    "take the step that enlarges options without discarding the foundation",
  ],
};

export function buildDiversifiedCanonicalLensContext(
  model: CanonicalIdentityModel,
  scenario: DailySymbolicContext,
): CanonicalLensContext {
  const base = buildCanonicalLensContext(model, scenario);
  const manifestation = manifestationFor(
    model.signPair as "Libra × Snake" | "Taurus × Horse",
    scenario.arena,
  );
  const compatibilityErrors = validateManifestation(manifestation);
  if (compatibilityErrors.length) {
    throw new Error(
      `Incompatible manifestation: ${compatibilityErrors.join("; ")}`,
    );
  }
  return {
    ...base,
    selected: {
      ...base.selected,
      manifestationKey: `${manifestation.identity}|${manifestation.arena}`,
      manifestationArena: manifestation.arena,
      perception: manifestation.perception,
      observableBehaviors: manifestation.observableBehaviors,
      arenaDetail: manifestation.arenaDetail,
    },
  };
}

export function planDiversifiedCanonicalLens(
  context: CanonicalLensContext,
): CanonicalLensReasoningPlan {
  const isLibra = context.signPair === "Libra × Snake";
  const table = isLibra ? libraMoves : taurusMoves;
  const [role, recognition, blindSpot, naturalMove] =
    table[context.scenario.arena];
  const manifestation = manifestationFor(
    context.signPair as "Libra × Snake" | "Taurus × Horse",
    context.scenario.arena,
  );
  return {
    activatedIdentityTension:
      `${context.scenario.humanTension} activates a distinct ${context.scenario.arena} expression of the central paradox.`,
    primaryArena: context.scenario.arena,
    identitySpecificRole: manifestation.identitySpecificRole || role,
    startingAssumption: isLibra
      ? "The situation deserves one more honest distinction before a conclusion."
      : "The established arrangement deserves protection, but not at the cost of available room.",
    recognition: manifestation.recognition || recognition,
    ordinaryLifeExpression: manifestation.ordinaryLifeExpression || naturalMove,
    blindSpot: manifestation.blindSpot || blindSpot,
    naturalMove: manifestation.naturalMove || naturalMove,
    signInteraction: "not_needed",
  };
}

export function validateDiversifiedContext(
  context: CanonicalLensContext,
  reasoning: CanonicalLensReasoningPlan,
): string[] {
  const errors: string[] = [];
  const manifestation = manifestationFor(
    context.signPair as "Libra × Snake" | "Taurus × Horse",
    context.scenario.arena,
  );
  if (context.scenario.arena !== manifestation.arena) {
    errors.push("scenario arena does not match manifestation arena");
  }
  if (
    context.selected.manifestationKey !==
      `${manifestation.identity}|${manifestation.arena}`
  ) errors.push("manifestation key mismatch");
  if (context.selected.manifestationArena !== context.scenario.arena) {
    errors.push("selected manifestation arena mismatch");
  }
  if (context.selected.perception !== manifestation.perception) {
    errors.push("perception not from selected manifestation");
  }
  if (
    JSON.stringify(context.selected.observableBehaviors) !==
      JSON.stringify(manifestation.observableBehaviors)
  ) errors.push("observable behaviors not from selected manifestation");
  if (context.selected.arenaDetail !== manifestation.arenaDetail) {
    errors.push("arena detail not from selected manifestation");
  }
  if (reasoning.primaryArena !== context.scenario.arena) {
    errors.push("reasoning arena mismatch");
  }
  if (reasoning.identitySpecificRole !== manifestation.identitySpecificRole) {
    errors.push("reasoning role not from selected manifestation");
  }
  if (reasoning.recognition !== manifestation.recognition) {
    errors.push("reasoning recognition not from selected manifestation");
  }
  if (reasoning.naturalMove !== manifestation.naturalMove) {
    errors.push("reasoning move not from selected manifestation");
  }
  return errors;
}
