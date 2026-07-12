import type {
  CanonicalLensContext,
  CanonicalLensReasoningPlan,
  DailySymbolicContext,
  LensArena,
} from "../canonical-lens/types.ts";
import type { CanonicalIdentityModel } from "../canonical/types.ts";
import { expansionIdentityByPair } from "./identities.ts";

export interface ArenaManifestation {
  identity: string;
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

const arenaDetail: Record<LensArena, string> = {
  work: "a meeting, handoff, role, deadline, or collaboration",
  love: "a message, promise, plan, affection, or shared time",
  home: "a room, chore, errand, object, schedule, or household boundary",
  friends: "a plan, invitation, favor, group conversation, or shared activity",
  money: "a purchase, bill, budget, subscription, saving, or cost",
  rest: "a break, phone, unfinished task, quiet hour, errand, or sleep",
  confidence: "praise, recognition, contribution, visibility, skill, or result",
  routine: "a repeated step, schedule, route, habit, or review process",
  conflict:
    "a disagreement, request, explanation, boundary, or changed expectation",
  opportunity: "an offer, role, opening, test, transition, risk, or proof",
};
const arenaNouns: Record<LensArena, string> = {
  work: "the handoff",
  love: "the promise",
  home: "the room",
  friends: "the plan",
  money: "the cost",
  rest: "the hour",
  confidence: "the contribution",
  routine: "the repeated step",
  conflict: "the unresolved point",
  opportunity: "the opening",
};
export const arenas: LensArena[] = [
  "work",
  "love",
  "home",
  "friends",
  "money",
  "rest",
  "confidence",
  "routine",
  "conflict",
  "opportunity",
];
const arenaMechanisms: Record<
  LensArena,
  { verbs: [string, string]; recognition: string; move: string }
> = {
  work: {
    verbs: ["clarifies ownership", "redesigns the handoff"],
    recognition:
      "The work gets lighter when the next owner can see the choice.",
    move: "assign one reversible next step",
  },
  love: {
    verbs: ["names the promise", "paces the reply"],
    recognition: "Closeness grows when warmth does not erase a clear promise.",
    move: "answer the promise at a pace you can keep",
  },
  home: {
    verbs: ["rearranges the shared space", "protects a quiet boundary"],
    recognition:
      "A home feels workable when care is visible in the arrangement.",
    move: "change one household condition",
  },
  friends: {
    verbs: ["reads the group temperature", "offers a specific invitation"],
    recognition:
      "Friendship stays alive when inclusion becomes an observable invitation.",
    move: "make one low-pressure invitation",
  },
  money: {
    verbs: ["prices the tradeoff", "keeps an option open"],
    recognition:
      "Comfort is more honest when the cost and the choice remain visible.",
    move: "choose the smallest purchase that preserves options",
  },
  rest: {
    verbs: ["ends the maintenance loop", "puts the phone out of reach"],
    recognition:
      "Rest begins when usefulness is allowed to stop proving itself.",
    move: "close one open loop before stepping away",
  },
  confidence: {
    verbs: ["credits the contribution", "lets the result stand"],
    recognition:
      "Confidence settles when the work can be named without performing for approval.",
    move: "state what you contributed and stop there",
  },
  routine: {
    verbs: ["spots the friction point", "changes the repeated sequence"],
    recognition:
      "A routine earns its place by reducing friction, not by demanding loyalty.",
    move: "alter one repeated step and observe the cost",
  },
  conflict: {
    verbs: ["separates impact from motive", "sets a repair condition"],
    recognition:
      "Repair becomes possible when the issue is precise enough to address.",
    move: "state the issue and one condition for repair",
  },
  opportunity: {
    verbs: ["prices the reversibility", "asks what proof would change the bet"],
    recognition:
      "An opening becomes yours when ambition and evidence can share the decision.",
    move: "take the smallest test that produces proof",
  },
};

const identityStyle: Record<
  string,
  {
    perception: string;
    role: string;
    recognition: string;
    blindSpot: string;
    verbs: [string, string];
    move: string;
  }
> = {
  "Sagittarius × Monkey": {
    perception: "the opening that makes a stale plan interesting",
    role: "the person who turns a stuck situation into an experiment",
    recognition:
      "A useful possibility becomes real when it can be tested rather than admired.",
    blindSpot: "treating novelty as proof that the old structure has no value",
    verbs: ["tries a different route", "asks what happens if the rule changes"],
    move: "test one lively alternative while keeping the useful result",
  },
  "Scorpio × Dragon": {
    perception: "the power or loyalty question beneath the visible exchange",
    role: "the person who names what the room is protecting",
    recognition:
      "The truth becomes useful when intensity serves clarity instead of control.",
    blindSpot: "turning an ambiguous signal into a verdict about motive",
    verbs: [
      "notices who changes tone near authority",
      "withholds a conclusion until the breach is clear",
    ],
    move: "name the protected issue without turning it into a loyalty test",
  },
  "Aries × Rat": {
    perception: "the first practical opening and who can move it",
    role: "the person who makes the first workable move",
    recognition:
      "Momentum is strongest when another person can carry the next step too.",
    blindSpot: "starting faster than the real ownership has been agreed",
    verbs: [
      "makes the first call",
      "finds the person who can unblock the task",
    ],
    move: "make the first reversible move and assign the next handoff",
  },
  "Pisces × Dog": {
    perception: "who is carrying the feeling nobody has named",
    role: "the person who protects the vulnerable part of the exchange",
    recognition:
      "Care becomes sustainable when it includes a boundary and a return path.",
    blindSpot:
      "mistaking understanding someone's pain for responsibility for solving it",
    verbs: [
      "checks who has gone quiet",
      "offers a practical kindness without being asked",
    ],
    move: "offer one bounded act of care and leave the rest with its owner",
  },
  "Leo × Horse": {
    perception: "where energy, recognition, and freedom are changing the room",
    role: "the person who makes participation feel alive",
    recognition:
      "Being seen is useful when it opens contribution rather than fixing you into a role.",
    blindSpot: "performing the successful version after it has stopped growing",
    verbs: [
      "names a contribution in the room",
      "changes the expression without abandoning the purpose",
    ],
    move: "accept the visibility and choose the next expression freely",
  },
  "Aquarius × Snake": {
    perception: "the system or incentive beneath the individual behavior",
    role: "the person who changes the frame",
    recognition: "A better system still has to answer a human-scale need.",
    blindSpot:
      "solving the structure while leaving the person without an answer",
    verbs: [
      "asks who benefits from the rule",
      "spots an exception that reveals the pattern",
    ],
    move: "translate the unusual insight into one useful human action",
  },
  "Cancer × Pig": {
    perception: "who needs comfort and whether care is circulating",
    role: "the person who makes belonging practical",
    recognition:
      "Generosity remains warm when receiving and limits are allowed inside it.",
    blindSpot: "calling over-giving love because asking feels less kind",
    verbs: ["remembers a small need", "makes a shared space more welcoming"],
    move: "offer care that leaves enough capacity for your own need",
  },
  "Virgo × Dragon": {
    perception: "the detail that could undermine the larger ambition",
    role: "the person who makes an ambitious plan reliable",
    recognition:
      "Precision serves the work when it helps the work leave your hands.",
    blindSpot: "using one more improvement to postpone exposure",
    verbs: [
      "finds the missing step",
      "tests whether a shortcut creates rework",
    ],
    move: "fix the critical detail and release the useful version",
  },
};

export const expansionManifestations: Record<string, ArenaManifestation> = {};
for (const identity of Object.keys(identityStyle)) {
  for (const arena of arenas) {
    const style = identityStyle[identity];
    const mechanism = arenaMechanisms[arena];
    expansionManifestations[`${identity}|${arena}`] = {
      identity,
      arena,
      perception: `${style.perception} in ${arenaDetail[arena]}.`,
      observableBehaviors: [
        `${style.verbs[0]} while you ${mechanism.verbs[0]}`,
        `${mechanism.verbs[1]} around ${arenaNouns[arena]}`,
      ],
      arenaDetail: arenaDetail[arena],
      identitySpecificRole: `${style.role} in ${arena}.`,
      recognition: `${style.recognition} ${mechanism.recognition}`,
      ordinaryLifeExpression: `${mechanism.verbs[0]} when ${
        arenaNouns[arena]
      } needs attention.`,
      blindSpot: style.blindSpot,
      naturalMove: `${mechanism.move} in ${arenaNouns[arena]}.`,
    };
  }
}

export function buildExpansionContext(
  model: CanonicalIdentityModel,
  scenario: DailySymbolicContext,
): CanonicalLensContext {
  const key = `${model.signPair}|${scenario.arena}`;
  const manifestation = expansionManifestations[key];
  if (!manifestation) {
    throw new Error(`Missing expansion manifestation: ${key}`);
  }
  return {
    signPair: model.signPair,
    scenario,
    selected: {
      manifestationKey: key,
      manifestationArena: manifestation.arena,
      activatedParadox:
        `${model.core.centralParadox} Activated by ${scenario.humanTension}.`,
      perception: manifestation.perception,
      decision: model.decision.defaultProcess,
      pressureOrGrowth: model.pressure.firstShift,
      observableBehaviors: manifestation.observableBehaviors,
      arenaDetail: manifestation.arenaDetail,
    },
  };
}

export function buildExpansionPlan(
  context: CanonicalLensContext,
): CanonicalLensReasoningPlan {
  const manifestation =
    expansionManifestations[context.selected.manifestationKey!];
  return {
    activatedIdentityTension:
      `${context.scenario.humanTension} meets the identity's ${context.scenario.arena} manifestation.`,
    primaryArena: context.scenario.arena,
    identitySpecificRole: manifestation.identitySpecificRole,
    startingAssumption:
      "The situation contains a real tension worth meeting without pretending it is simpler.",
    recognition: manifestation.recognition,
    ordinaryLifeExpression: manifestation.ordinaryLifeExpression,
    blindSpot: manifestation.blindSpot,
    naturalMove: manifestation.naturalMove,
    signInteraction: "not_needed",
  };
}

export function validateExpansionContext(
  context: CanonicalLensContext,
  plan: CanonicalLensReasoningPlan,
): string[] {
  const errors: string[] = [];
  const manifestation =
    expansionManifestations[context.selected.manifestationKey ?? ""];
  if (!manifestation) return ["manifestation missing"];
  if (manifestation.identity !== context.signPair) {
    errors.push("identity key mismatch");
  }
  if (
    manifestation.arena !== context.scenario.arena ||
    context.selected.manifestationArena !== context.scenario.arena ||
    plan.primaryArena !== context.scenario.arena
  ) errors.push("arena mismatch");
  if (context.selected.perception !== manifestation.perception) {
    errors.push("perception not sourced from manifestation");
  }
  if (context.selected.arenaDetail !== manifestation.arenaDetail) {
    errors.push("arenaDetail not sourced from manifestation");
  }
  for (
    const key of [
      "identitySpecificRole",
      "recognition",
      "ordinaryLifeExpression",
      "blindSpot",
      "naturalMove",
    ] as const
  ) {
    if (plan[key] !== manifestation[key]) {
      errors.push(`${key} not sourced from manifestation`);
    }
  }
  if (
    JSON.stringify(context.selected.observableBehaviors) !==
      JSON.stringify(manifestation.observableBehaviors)
  ) errors.push("observable behaviors mismatch");
  return errors;
}
