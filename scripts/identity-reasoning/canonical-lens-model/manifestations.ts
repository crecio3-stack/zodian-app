import type { LensArena } from "../canonical-lens/types.ts";

export interface ArenaManifestation {
  identity: "Libra × Snake" | "Taurus × Horse";
  arena: LensArena;
  perception: string;
  observableBehaviors: [string, string];
  arenaDetail: string;
  identitySpecificRole: string;
  recognition: string;
  ordinaryLifeExpression: string;
  blindSpot: string;
  naturalMove: string;
}

const bundle = (
  identity: ArenaManifestation["identity"],
  arena: LensArena,
  perception: string,
  behaviors: [string, string],
  detail: string,
  role: string,
  recognition: string,
  ordinary: string,
  blindSpot: string,
  move: string,
): ArenaManifestation => ({
  identity,
  arena,
  perception,
  observableBehaviors: behaviors,
  arenaDetail: detail,
  identitySpecificRole: role,
  recognition,
  ordinaryLifeExpression: ordinary,
  blindSpot,
  naturalMove: move,
});

export const ARENA_MANIFESTATIONS: Record<string, ArenaManifestation> = {
  "Libra × Snake|work": bundle(
    "Libra × Snake",
    "work",
    "missing context in a decision",
    ["notices a pause before an answer", "asks who has not spoken"],
    "a meeting, handoff, or unfinished decision",
    "the person who notices the missing condition",
    "The polished answer may still be missing the detail that changes its cost.",
    "states the condition before endorsing the plan",
    "turning one more perspective into a reason to delay",
    "names the condition before endorsing the plan",
  ),
  "Libra × Snake|love": bundle(
    "Libra × Snake",
    "love",
    "whether warmth continues into ordinary follow-through",
    ["remembers when a story changes", "notices who keeps a small promise"],
    "a message, promise, or ordinary plan",
    "the person who watches what follows warmth",
    "A kind interpretation deserves room, but repeated conduct still has to answer for itself.",
    "lets the next action provide evidence",
    "explaining away the same inconsistency again",
    "watches what happens next instead of explaining it early",
  ),
  "Libra × Snake|home": bundle(
    "Libra × Snake",
    "home",
    "which arrangement serves the people living with it",
    [
      "compares two household preferences",
      "notices a room no longer feels shared",
    ],
    "a room, errand, or household arrangement",
    "the person who tests whether an arrangement still serves everyone",
    "Fairness can include admitting that a familiar arrangement no longer works for you.",
    "makes one shared adjustment",
    "waiting for every preference before making a needed change",
    "changes one practical detail before judging the whole arrangement",
  ),
  "Libra × Snake|friends": bundle(
    "Libra × Snake",
    "friends",
    "the honest sentence beneath a pleasant mood",
    [
      "hears laughter where disagreement should appear",
      "waits to see who answers directly",
    ],
    "a plan, invitation, or group conversation",
    "the person who hears the honest sentence beneath the mood",
    "Keeping the exchange pleasant is useful only while people are still being honest.",
    "says the true part gently",
    "smoothing the exchange after honesty has stopped",
    "names the honest part before agreement becomes distance",
  ),
  "Libra × Snake|money": bundle(
    "Libra × Snake",
    "money",
    "the condition behind a polished offer",
    [
      "checks a cost after the presentation",
      "asks what a purchase actually includes",
    ],
    "a purchase, bill, budget, or subscription",
    "the person who checks the condition behind the offer",
    "A polished option becomes useful only when the practical term survives scrutiny.",
    "asks for the missing term",
    "letting agreeable language settle a practical question",
    "checks the condition that determines daily usefulness",
  ),
  "Libra × Snake|rest": bundle(
    "Libra × Snake",
    "rest",
    "which open question still requires attention",
    [
      "revisits an unfinished issue during a break",
      "separates an active task from a lingering thought",
    ],
    "a break, unfinished task, phone, or unassigned time",
    "the person who separates active responsibility from open questions",
    "Not every unresolved matter still belongs to the part of the day you are protecting.",
    "returns an owned decision",
    "treating every open question as active work",
    "sets down the question that no longer needs attention",
  ),
  "Libra × Snake|confidence": bundle(
    "Libra × Snake",
    "confidence",
    "how collaboration and judgment shaped a result",
    [
      "lists everyone who helped after receiving praise",
      "explains the missing context behind a success",
    ],
    "praise, recognition, contribution, visibility, or a result",
    "the person who remembers the whole collaboration",
    "Giving context to a success does not require removing your own judgment from it.",
    "receives recognition plainly",
    "editing personal contribution out of the story",
    "says thank you before supplying the footnotes",
  ),
  "Libra × Snake|routine": bundle(
    "Libra × Snake",
    "routine",
    "when care has become ceremony",
    [
      "completes a repeated step automatically",
      "checks whether an old process still helps",
    ],
    "a repeated step, schedule, habit, route, or review loop",
    "the person who notices when care became ceremony",
    "A thoughtful process can outlive the reason it was built.",
    "tests one removed layer",
    "preserving a process after its purpose disappears",
    "skips the step whose original purpose has disappeared",
  ),
  "Libra × Snake|conflict": bundle(
    "Libra × Snake",
    "conflict",
    "whether an answer is being avoided",
    [
      "refines an explanation while waiting for a reply",
      "returns to the original question",
    ],
    "a disagreement, request, boundary, or unresolved issue",
    "the person who can tell when an answer is being avoided",
    "Patience helps while the exchange is learning; after that, another explanation may hide the point.",
    "asks the original question",
    "refining language after the issue is already clear",
    "returns to the question instead of refining the explanation",
  ),
  "Libra × Snake|opportunity": bundle(
    "Libra × Snake",
    "opportunity",
    "whether an opening has enough evidence to test",
    [
      "checks one missing term in an offer",
      "compares a new option with repeated evidence",
    ],
    "an offer, opening, test, transition, risk, or proof",
    "the person who tests a promising opening without surrendering judgment",
    "One unanswered detail can be tested without erasing the evidence toward a useful beginning.",
    "chooses a reversible test",
    "letting one unknown erase several practical signals",
    "takes the first test that lets the opportunity prove itself",
  ),
  "Taurus × Horse|work": bundle(
    "Taurus × Horse",
    "work",
    "responsibility becoming assumed",
    [
      "accepts another handoff without discussion",
      "notices a reliable task has no owner",
    ],
    "a meeting, handoff, responsibility, role, or deadline",
    "the person who notices responsibility becoming assumed",
    "A dependable setup stops being dependable when every missing piece becomes yours.",
    "moves one responsibility early",
    "absorbing a temporary gap until it feels permanent",
    "names the handoff before resentment makes the role impossible",
  ),
  "Taurus × Horse|love": bundle(
    "Taurus × Horse",
    "love",
    "whether closeness leaves room for choice",
    ["defends a separate plan", "notices a loving request assumes access"],
    "a message, promise, plan, affection, time together, or space",
    "the person who protects chosen closeness",
    "A relationship can feel safe without turning separate time into a devotion test.",
    "keeps one part of the day separate",
    "treating needed space as a rejection",
    "says what can be offered without surrendering the whole plan",
  ),
  "Taurus × Horse|home": bundle(
    "Taurus × Horse",
    "home",
    "restlessness asking for a physical outlet",
    [
      "moves an object that keeps irritating them",
      "changes a household route or boundary",
    ],
    "a room, chore, household schedule, errand, or object",
    "the person who gives restlessness a physical outlet",
    "The life you built may need one changed object or boundary, not a dramatic departure.",
    "alters the room",
    "imagining a larger escape before trying a practical change",
    "changes the smallest physical detail that restores ownership",
  ),
  "Taurus × Horse|friends": bundle(
    "Taurus × Horse",
    "friends",
    "availability becoming an obligation",
    [
      "agrees automatically to a plan",
      "wishes someone would cancel after saying yes",
    ],
    "a plan, invitation, group conversation, favor, or shared activity",
    "the person who notices availability becoming an obligation",
    "A friendship can remain solid when the familiar plan changes before your yes becomes reluctant.",
    "offers another arrangement",
    "showing up resentfully to preserve a pattern",
    "suggests a different plan before becoming reluctant company",
  ),
  "Taurus × Horse|money": bundle(
    "Taurus × Horse",
    "money",
    "comfort competing with future room",
    [
      "imagines owning an expensive item for years",
      "checks what a purchase removes from next week",
    ],
    "a purchase, bill, budget, savings, tradeoff, or cost",
    "the person who weighs comfort against future room",
    "A purchase earns its place when it improves the life you are keeping.",
    "compares use with freedom",
    "buying over restlessness instead of changing the pressure",
    "checks what the same money lets you choose next week",
  ),
  "Taurus × Horse|rest": bundle(
    "Taurus × Horse",
    "rest",
    "an empty hour becoming another assignment",
    ["adds chores during a break", "keeps working because time is available"],
    "a break, quiet time, unfinished task, phone, errand, or sleep",
    "the person who protects an unassigned hour",
    "Rest does not have to prove its usefulness before becoming part of your life.",
    "leaves one task undone",
    "turning every break into maintenance",
    "protects an ordinary hour without turning it into a reward",
  ),
  "Taurus × Horse|confidence": bundle(
    "Taurus × Horse",
    "confidence",
    "maintenance becoming invisible expertise",
    [
      "keeps a result working after excitement fades",
      "minimizes repeated upkeep after praise",
    ],
    "praise, recognition, contribution, visibility, skill, or result",
    "the person whose maintenance made the result last",
    "The work that kept functioning after excitement faded is expertise.",
    "claims the durable contribution",
    "assuming useful work should speak without attribution",
    "names what was maintained before minimizing the result",
  ),
  "Taurus × Horse|routine": bundle(
    "Taurus × Horse",
    "routine",
    "a useful pattern becoming confinement",
    [
      "takes the same route despite irritation",
      "changes pace while keeping the destination",
    ],
    "a repeated step, schedule, habit, route, or recurring process",
    "the person who preserves purpose while changing the route",
    "A useful routine can stay while its shape changes enough to feel chosen.",
    "varies one part of the pattern",
    "breaking the whole habit because one part feels stale",
    "changes the route while keeping the result that matters",
  ),
  "Taurus × Horse|conflict": bundle(
    "Taurus × Horse",
    "conflict",
    "an old compromise inside a new request",
    [
      "feels a small request land unusually hard",
      "remembers several earlier accommodations",
    ],
    "a disagreement, request, boundary, unresolved issue, or changed expectation",
    "the person who catches an old compromise inside a new request",
    "A small irritation may carry the weight of several adjustments never named.",
    "names the earliest compromise",
    "arguing only about today's request",
    "talks about the first change instead of only today's request",
  ),
  "Taurus × Horse|opportunity": bundle(
    "Taurus × Horse",
    "opportunity",
    "expansion needing a durable shape",
    [
      "compares an offer with the life already built",
      "tests whether a new role adds room",
    ],
    "an offer, role, opening, test, transition, expansion, risk, or proof",
    "the person who looks for expansion with a durable shape",
    "A worthwhile opening should add room to the life you built.",
    "extends what already works",
    "rejecting movement because the foundation is still workable",
    "takes the step that enlarges options without discarding the foundation",
  ),
};

export function manifestationFor(
  identity: ArenaManifestation["identity"],
  arena: LensArena,
): ArenaManifestation {
  const manifestation = ARENA_MANIFESTATIONS[`${identity}|${arena}`];
  if (!manifestation) {
    throw new Error(`Missing explicit manifestation for ${identity}|${arena}`);
  }
  return manifestation;
}

const ARENA_TERMS: Record<LensArena, string[]> = {
  work: [
    "meeting",
    "handoff",
    "responsibility",
    "role",
    "deadline",
    "decision",
  ],
  love: ["message", "promise", "plan", "affection", "space", "closeness"],
  home: ["room", "chore", "household", "errand", "object", "boundary"],
  friends: ["plan", "invitation", "conversation", "favor", "shared"],
  money: ["purchase", "bill", "budget", "savings", "tradeoff", "cost"],
  rest: ["break", "quiet", "task", "phone", "errand", "sleep", "hour"],
  confidence: [
    "praise",
    "recognition",
    "contribution",
    "visibility",
    "skill",
    "result",
  ],
  routine: ["step", "schedule", "habit", "route", "process", "pattern"],
  conflict: [
    "disagreement",
    "request",
    "boundary",
    "unresolved",
    "expectation",
    "change",
  ],
  opportunity: [
    "offer",
    "role",
    "opening",
    "test",
    "transition",
    "expansion",
    "risk",
    "proof",
  ],
};

export function validateManifestation(
  manifestation: ArenaManifestation,
): string[] {
  const terms = ARENA_TERMS[manifestation.arena];
  const haystack = [
    manifestation.arenaDetail,
    ...manifestation.observableBehaviors,
    manifestation.identitySpecificRole,
    manifestation.recognition,
    manifestation.ordinaryLifeExpression,
    manifestation.blindSpot,
    manifestation.naturalMove,
  ].join(" ").toLowerCase();
  return terms.some((term) => haystack.includes(term))
    ? []
    : [`manifestation has no compatible ${manifestation.arena} evidence`];
}
