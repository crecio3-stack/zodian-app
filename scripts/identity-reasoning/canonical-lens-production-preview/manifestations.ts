import type {
  CanonicalLensContext,
  CanonicalLensReasoningPlan,
  DailySymbolicContext,
  LensArena,
} from "../canonical-lens/types.ts";
import type { CanonicalIdentityModel } from "../canonical/types.ts";
import { normalizeTraitPhrase } from "./source.ts";

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
  sourcePaths: string[];
}

export const ARENAS: LensArena[] = [
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

const arenaDetail: Record<LensArena, string> = {
  work: "a meeting, handoff, role, deadline, standard, or collaboration",
  love: "a message, promise, reassurance, plan, affection, or shared time",
  home: "a room, chore, object, privacy boundary, or shared household routine",
  friends:
    "an invitation, favor, group role, availability question, or social tone",
  money: "a purchase, bill, budget, risk, comfort expense, or future option",
  rest:
    "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  confidence:
    "praise, attribution, visibility, competence, performance, or result",
  routine: "a repeated step, schedule, ritual, optimization, or friction point",
  conflict:
    "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  opportunity:
    "an offer, proof point, timing choice, ambition, risk, or reversible test",
};

const moveOpening: Record<LensArena, string> = {
  work: "Clarify",
  love: "Answer",
  home: "Rearrange",
  friends: "Invite",
  money: "Price",
  rest: "Close",
  confidence: "Credit",
  routine: "Alter",
  conflict: "Separate",
  opportunity: "Test",
};

function clean(value: string): string {
  return value.trim().replace(/[.!?]+$/, "");
}

function lower(value: string): string {
  const cleaned = clean(value);
  if (/^[A-Za-z-]+$/.test(cleaned)) return normalizeTraitPhrase(cleaned);
  return cleaned ? cleaned[0].toLowerCase() + cleaned.slice(1) : cleaned;
}

function bundleFor(
  model: CanonicalIdentityModel,
  arena: LensArena,
): ArenaManifestation {
  const base = {
    identity: model.signPair,
    arena,
    arenaDetail: arenaDetail[arena],
  };
  const strength = lower(model.evidence.observableBehaviors[0]);
  const secondStrength = lower(model.evidence.observableBehaviors[1]);
  const pressure = lower(model.pressure.visibleBehaviors[0]);
  const shadow = lower(model.pressure.visibleBehaviors[1]);
  const move = moveOpening[arena];
  switch (arena) {
    case "work":
      return {
        ...base,
        perception:
          `${model.work.problemSolvingStyle} becomes visible around ownership and execution.`,
        observableBehaviors: [
          `names who owns the next handoff before ${pressure}`,
          `uses ${strength} to make one standard visible before ${shadow}`,
        ],
        identitySpecificRole: `the ${model.social.defaultRole} who turns ${
          lower(model.work.valueCreated)
        } into clear ownership`,
        recognition: `The work improves when the ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } result has an owner other people can identify.`,
        ordinaryLifeExpression: `The handoff makes ${
          lower(model.core.recurringThemes[0])
        } observable before ownership is finalized.`,
        blindSpot: model.work.careerBlindSpot,
        naturalMove: `${move} one owner and use ${
          lower(model.core.recurringThemes[0])
        } as the visible standard.`,
        sourcePaths: [
          "work.valueCreated",
          "work.problemSolvingStyle",
          "work.careerBlindSpot",
          "social.defaultRole",
        ],
      };
    case "love":
      return {
        ...base,
        perception: `The identity brings ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } to closeness, where promises and pacing are tested.`,
        observableBehaviors: [
          `asks what a warm promise will look like in follow-through`,
          `paces reassurance before ${shadow}`,
        ],
        identitySpecificRole: `the partner who turns ${
          lower(model.core.recurringThemes[0])
        } into reliable follow-through without forcing certainty`,
        recognition:
          `Closeness becomes trustworthy when a clear promise survives an ordinary week without asking ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } to disappear.`,
        ordinaryLifeExpression: `Evidence of ${
          lower(model.core.recurringThemes[0])
        } becomes the test beneath a reassuring message.`,
        blindSpot: model.relationships.relationshipBlindSpot,
        naturalMove:
          `${move} the practical promise and make one follow-through detail observable without abandoning ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          }.`,
        sourcePaths: [
          "relationships.attractionPattern",
          "relationships.closenessStyle",
          "relationships.healthyRelationshipCondition",
          "relationships.relationshipBlindSpot",
        ],
      };
    case "home":
      return {
        ...base,
        perception: `The need for ${
          lower(model.core.recurringThemes[0])
        } shows up through space, objects, privacy, and shared maintenance.`,
        observableBehaviors: [
          `changes the placement of one object before debating the whole household`,
          `protects a private corner when ${pressure}`,
        ],
        identitySpecificRole: `the person who translates ${
          lower(model.core.recurringThemes[0])
        } into a livable household condition`,
        recognition:
          `The room feels different when recovery has a physical place to happen after ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } has filled the day.`,
        ordinaryLifeExpression: `A physical change gives ${
          lower(model.core.recurringThemes[0])
        } somewhere to be practiced at home.`,
        blindSpot: model.perception.attentionBlindSpot,
        naturalMove:
          `${move} one shared-space condition so recovery can happen there without ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } running the room.`,
        sourcePaths: [
          "core.coreNeed",
          "growth.restorationPattern",
          "perception.attentionBlindSpot",
        ],
      };
    case "friends":
      return {
        ...base,
        perception:
          `Group belonging becomes visible through invitations, favors, and a social role shaped by ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          }.`,
        observableBehaviors: [
          `notices who keeps receiving the group role nobody named`,
          `offers one specific invitation instead of ${shadow}`,
        ],
        identitySpecificRole: `the friend who uses ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } to change participation rather than manage the whole group`,
        recognition:
          `Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          }.`,
        ordinaryLifeExpression:
          `The social tone changes when availability is made explicit instead of assumed, especially around ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          }.`,
        blindSpot: model.social.commonMisreads[0],
        naturalMove:
          `${move} one person clearly and make the invitation specific to the ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } dynamic.`,
        sourcePaths: [
          "social.communicationStyle",
          "social.influenceStyle",
          "social.commonMisreads",
          "relationships.loyaltyStyle",
        ],
      };
    case "money":
      return {
        ...base,
        perception: `A decision style shaped by ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } meets comfort, scarcity, status, and future options.`,
        observableBehaviors: [
          `compares the relief of a purchase with the option it removes`,
          `waits for evidence before ${pressure}`,
        ],
        identitySpecificRole:
          `the chooser who makes the tradeoff between immediate comfort and future options visible`,
        recognition: `The cost is honest when the future option tied to ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } comfort is named alongside the purchase.`,
        ordinaryLifeExpression:
          `The decision prices comfort and lost flexibility in the same moment, including what ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } makes tempting.`,
        blindSpot: model.decision.regretPattern,
        naturalMove:
          `${move} immediate comfort against the future option the purchase would remove from a ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } choice.`,
        sourcePaths: [
          "decision.certaintyStyle",
          "decision.evidenceThreshold",
          "decision.regretPattern",
          "core.coreNeed",
        ],
      };
    case "rest":
      return {
        ...base,
        perception: `Pressure keeps usefulness shaped by ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } active after the useful work is done.`,
        observableBehaviors: [
          `ends one maintenance loop before checking for another`,
          `puts the phone away when ${pressure}`,
        ],
        identitySpecificRole:
          `the person learning that rest is a condition for returning well, not a reward for exhaustion`,
        recognition: `Rest starts when recovery from ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } can happen without another proof of usefulness.`,
        ordinaryLifeExpression:
          `A quiet hour interrupts the habit of adding another small task when ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } keeps usefulness moving.`,
        blindSpot: model.pressure.internalStory,
        naturalMove:
          `${move} one open loop, then protect the remaining hour from the ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } maintenance loop.`,
        sourcePaths: [
          "pressure.internalStory",
          "growth.restorationPattern",
          "growth.recoveryRecognition",
        ],
      };
    case "confidence":
      return {
        ...base,
        perception: `The ability to accept credit for ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } is tested by praise, attribution, and visible competence.`,
        observableBehaviors: [
          `states the contribution without reducing it to luck`,
          `lets the finished result stand before ${shadow}`,
        ],
        identitySpecificRole: `the contributor who can accept ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } without performing a larger identity`,
        recognition: `Confidence settles when praise names the ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } contribution without demanding another performance.`,
        ordinaryLifeExpression:
          `Precise praise names the work without requiring a larger ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } performance.`,
        blindSpot: model.social.commonMisreads[1],
        naturalMove:
          `${move} the contribution accurately, then stop before ${shadow}.`,
        sourcePaths: [
          "core.matureExpression",
          "evidence.observableBehaviors",
          "social.commonMisreads",
        ],
      };
    case "routine":
      return {
        ...base,
        perception:
          `The current structure reveals whether repetition shaped by ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } is reducing friction or preserving confinement.`,
        observableBehaviors: [
          `marks the repeated step that creates the most rework`,
          `changes the sequence before ${pressure}`,
        ],
        identitySpecificRole:
          `the operator who tests whether the current structure still serves the actual result`,
        recognition:
          `The routine earns its place when the strength expressed as ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } reduces friction without demanding loyalty.`,
        ordinaryLifeExpression:
          `The repeated sequence reveals which small change reduces friction for a ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } working style.`,
        blindSpot: model.work.releasePattern,
        naturalMove:
          `${move} one repeated step and watch what becomes easier for this ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          } rhythm.`,
        sourcePaths: [
          "work.relationshipToStructure",
          "work.completionSignal",
          "work.releasePattern",
        ],
      };
    case "conflict":
      return {
        ...base,
        perception: `The ${
          normalizeTraitPhrase(model.core.recurringThemes[1])
        } response to conflict shapes the reading of evidence, tone, control, and repair.`,
        observableBehaviors: [
          `separates the observable impact from the motive being assumed`,
          `sets one repair condition before ${shadow}`,
        ],
        identitySpecificRole:
          `the ${model.social.defaultRole} who makes the conflict precise enough to repair`,
        recognition:
          `The disagreement becomes workable when the boundary against ${
            normalizeTraitPhrase(model.core.recurringThemes[1])
          } is stated as evidence and a repair condition.`,
        ordinaryLifeExpression:
          `A clear boundary names what happened, what changed, and what repair requires before ${
            normalizeTraitPhrase(model.core.recurringThemes[1])
          } takes over.`,
        blindSpot: model.pressure.decisionDistortion,
        naturalMove:
          `${move} impact from motive, then state one repair condition that addresses ${
            normalizeTraitPhrase(model.core.recurringThemes[1])
          }.`,
        sourcePaths: [
          "social.conflictStyle",
          "social.boundaryStyle",
          "pressure.decisionDistortion",
        ],
      };
    case "opportunity":
      return {
        ...base,
        perception: `The capacity to act on possibility shaped by ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } competes with proof, timing, ambition, and reversibility.`,
        observableBehaviors: [
          `asks what evidence would make the opening worth leaving a proven position`,
          `builds a reversible test before ${pressure}`,
        ],
        identitySpecificRole:
          `the decision-maker who turns an attractive possibility into bounded proof`,
        recognition: `The opening is real when the next action reflects ${
          normalizeTraitPhrase(model.core.recurringThemes[0])
        } and can be tested without pretending the risk has disappeared.`,
        ordinaryLifeExpression:
          `A bounded action turns an attractive offer into a timed, observable test for ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          }.`,
        blindSpot: model.decision.delayPattern,
        naturalMove:
          `${move} the opening with the smallest step that produces useful proof about ${
            normalizeTraitPhrase(model.core.recurringThemes[0])
          }.`,
        sourcePaths: [
          "perception.readsAsOpportunity",
          "decision.actionTrigger",
          "decision.delayPattern",
        ],
      };
  }
}

export function buildManifestationLibrary(
  models: CanonicalIdentityModel[],
): Record<string, ArenaManifestation> {
  const library: Record<string, ArenaManifestation> = {};
  for (const model of models) {
    for (const arena of ARENAS) {
      const key = `${model.signPair}|${arena}`;
      library[key] = bundleFor(model, arena);
    }
  }
  return library;
}

export function buildFocusedContext(
  model: CanonicalIdentityModel,
  scenario: DailySymbolicContext,
  library: Record<string, ArenaManifestation>,
): CanonicalLensContext {
  const key = `${model.signPair}|${scenario.arena}`;
  const manifestation = library[key];
  if (!manifestation) throw new Error(`Missing explicit manifestation ${key}`);
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

export function buildReasoningPlan(
  context: CanonicalLensContext,
  library: Record<string, ArenaManifestation>,
): CanonicalLensReasoningPlan {
  const manifestation = library[context.selected.manifestationKey ?? ""];
  if (!manifestation) {
    throw new Error(
      `Missing explicit manifestation ${context.selected.manifestationKey}`,
    );
  }
  return {
    activatedIdentityTension:
      `${context.scenario.humanTension} meets the identity's ${context.scenario.arena} mechanism.`,
    primaryArena: context.scenario.arena,
    identitySpecificRole: manifestation.identitySpecificRole,
    startingAssumption:
      `The visible ${context.scenario.arena} detail can be handled through the identity's default process.`,
    recognition: manifestation.recognition,
    ordinaryLifeExpression: manifestation.ordinaryLifeExpression,
    blindSpot: manifestation.blindSpot,
    naturalMove: manifestation.naturalMove,
    signInteraction: "not_needed",
  };
}

export function validateManifestation(
  key: string,
  manifestation: ArenaManifestation,
): string[] {
  const errors: string[] = [];
  if (key !== `${manifestation.identity}|${manifestation.arena}`) {
    errors.push("manifestation key mismatch");
  }
  for (
    const field of [
      "perception",
      "arenaDetail",
      "identitySpecificRole",
      "recognition",
      "ordinaryLifeExpression",
      "blindSpot",
      "naturalMove",
    ] as const
  ) if (!manifestation[field].trim()) errors.push(`${field} is empty`);
  if (
    manifestation.observableBehaviors.length !== 2 ||
    manifestation.observableBehaviors.some((v) => !v.trim())
  ) errors.push("observableBehaviors must contain two non-empty behaviors");
  if (!manifestation.sourcePaths.length) errors.push("sourcePaths is empty");
  return errors;
}

export function validateFocusedContext(
  context: CanonicalLensContext,
  plan: CanonicalLensReasoningPlan,
  library: Record<string, ArenaManifestation>,
): string[] {
  const errors: string[] = [];
  const manifestation = library[context.selected.manifestationKey ?? ""];
  if (!manifestation) return ["manifestation missing"];
  if (
    context.selected.manifestationKey !==
      `${context.signPair}|${context.scenario.arena}`
  ) errors.push("identity or arena contamination");
  if (manifestation.identity !== context.signPair) {
    errors.push("identity mismatch");
  }
  if (
    manifestation.arena !== context.scenario.arena ||
    context.selected.manifestationArena !== context.scenario.arena ||
    plan.primaryArena !== context.scenario.arena
  ) errors.push("arena mismatch");
  if (
    context.selected.perception !== manifestation.perception ||
    context.selected.arenaDetail !== manifestation.arenaDetail
  ) errors.push("context not sourced from selected manifestation");
  if (
    context.selected.observableBehaviors.join("|") !==
      manifestation.observableBehaviors.join("|")
  ) errors.push("behavior contamination");
  if (
    plan.identitySpecificRole !== manifestation.identitySpecificRole ||
    plan.recognition !== manifestation.recognition ||
    plan.naturalMove !== manifestation.naturalMove
  ) errors.push("reasoning plan contamination");
  return errors;
}
