import type { CanonicalIdentityModel } from "../canonical/types.ts";
import { validateCanonicalIdentity } from "../canonical/validate.ts";
import { ARENA_FALLBACK } from "./scenarios.ts";
import type {
  CanonicalLens,
  CanonicalLensContext,
  CanonicalLensGenerationResult,
  CanonicalLensReasoningPlan,
  CanonicalLensSelection,
  DailySymbolicContext,
} from "./types.ts";
import { validateCanonicalLens } from "./validate.ts";

export function buildCanonicalLensContext(
  model: CanonicalIdentityModel,
  scenario: DailySymbolicContext,
): CanonicalLensContext {
  const arenaDetail =
    model.evidence.everydaySituations.find((item) =>
      item.toLowerCase().includes(scenario.arena)
    ) ?? ARENA_FALLBACK[scenario.arena];
  const observableBehaviors = model.evidence.observableBehaviors.slice(0, 2);
  const activatedParadox =
    `${model.core.centralParadox} Activated by ${scenario.humanTension}.`;
  const perception = scenario.arena === "work"
    ? model.perception.noticesInSituations[0]
    : model.perception.noticesFirst;
  const decision = scenario.humanTension.includes("waiting") ||
      scenario.humanTension.includes("patience")
    ? model.decision.delayPattern
    : model.decision.defaultProcess;
  const pressureOrGrowth = scenario.emotionalTone === "restless" ||
      scenario.emotionalTone === "clear-eyed"
    ? model.pressure.firstShift
    : model.growth.growthEdge;
  return {
    signPair: model.signPair,
    scenario,
    selected: {
      activatedParadox,
      perception,
      decision,
      pressureOrGrowth,
      observableBehaviors,
      arenaDetail,
    },
  };
}

export function planCanonicalLens(
  context: CanonicalLensContext,
): CanonicalLensReasoningPlan {
  const { scenario, selected } = context;
  const isLibra = context.signPair === "Libra × Snake";
  const identitySpecificRole = isLibra
    ? "the person who notices what the room has skipped"
    : "the person who tests whether the arrangement still leaves room to move";
  const startingAssumption = isLibra
    ? "More context may prevent an unfair or premature move."
    : "A familiar arrangement deserves another chance before it is disrupted.";
  const recognition = isLibra
    ? "The useful detail is already clear enough to name."
    : "A small adjustment may protect freedom before an ending becomes necessary.";
  const ordinaryLifeExpression = isLibra
    ? "asking one precise question before agreeing"
    : "changing one practical part of the plan instead of abandoning the whole thing";
  const blindSpot = isLibra
    ? "turning one more perspective into a reason to delay"
    : "waiting until accumulated irritation makes a smaller change feel impossible";
  const naturalMove = isLibra
    ? "name the missing detail"
    : "make the smallest change that restores room";
  return {
    activatedIdentityTension:
      `${scenario.humanTension} meets the identity's central pattern.`,
    primaryArena: scenario.arena,
    identitySpecificRole,
    startingAssumption,
    recognition,
    ordinaryLifeExpression,
    blindSpot,
    naturalMove,
    signInteraction: "not_needed",
  };
}

const commonCopy: Record<
  string,
  {
    title: string;
    intro: string;
    quote: string;
    deeper: string;
    watch: string;
    move: string;
  }
> = {
  "work-speaking-up:Libra × Snake": {
    title: "Name The Missing Part",
    intro:
      "A useful question may matter more today than a confident answer delivered too soon.",
    quote:
      "You do not need the whole room to agree before naming the detail everyone skipped.",
    deeper:
      "You may spend a meeting listening for the point beneath the polished version. Once it is clear, waiting for one more perspective only makes the decision harder to improve; let the question change the room while it can still help today, before everyone moves on.",
    watch:
      "Watch for yourself softening a necessary question because the meeting already feels pleasantly settled.",
    move:
      "Ask the precise question, then let the group decide what it changes.",
  },
  "work-speaking-up:Taurus × Horse": {
    title: "Start Before Resentment",
    intro:
      "A small adjustment at work can protect your energy better than another week of quietly absorbing the gap.",
    quote:
      "The task may be manageable, but that does not make every extra responsibility yours to carry.",
    deeper:
      "You know how to make a plan last, which can make people hand you the parts nobody maintained. Before the irritation becomes a reason to leave, name the piece that needs a different owner or a clearer limit.",
    watch:
      "Watch for agreeing to one more handoff while already planning the day you will finally disappear.",
    move:
      "Name the smallest responsibility that needs to move before it hardens into resentment.",
  },
  "love-trust:Libra × Snake": {
    title: "Let Actions Count",
    intro:
      "A warm conversation can be real without proving everything you still need to know.",
    quote:
      "Trust can stay open today without ignoring the detail that keeps asking for an answer.",
    deeper:
      "You may want to give the kind interpretation room to become true. That generosity is useful when it leaves you watching what happens next, not when it asks you to explain away the same inconsistency again.",
    watch:
      "Watch for a thoughtful promise that feels reassuring before its ordinary follow-through has arrived.",
    move:
      "Keep the door open, but let the next repeated action do the deciding.",
  },
  "love-trust:Taurus × Horse": {
    title: "Room To Stay",
    intro:
      "Closeness feels better today when it leaves both people enough space to choose it again.",
    quote:
      "A dependable relationship should make room for your life, not quietly take ownership of it.",
    deeper:
      "You are drawn to care that shows up in practical ways, but even good care can become crowded when every plan requires explanation. Notice whether the relationship is offering a home base or asking you to stop moving.",
    watch:
      "Watch for a loving request that sounds small but assumes your time was already available.",
    move:
      "Say what you can offer, then keep the part of the day that still belongs to you.",
  },
  "home-change:Libra × Snake": {
    title: "The Pattern Has Shifted",
    intro:
      "A familiar arrangement may deserve one honest adjustment before you decide what it means.",
    quote:
      "You can respect what has worked without pretending it still fits every part of your life.",
    deeper:
      "You are good at seeing both sides of a change, including the reasons to leave things alone. Today, compare the actual pattern with the story that preserving it is automatically the fairer choice.",
    watch:
      "Watch for defending a routine by describing its history instead of its usefulness now.",
    move: "Name the one part that no longer fits and adjust that part first.",
  },
  "home-change:Taurus × Horse": {
    title: "Change One Thing",
    intro:
      "The whole arrangement may not be the problem; one neglected adjustment may be asking to happen.",
    quote:
      "You do not have to abandon what matters just because one part of it needs to change.",
    deeper:
      "You have spent time making this life workable, so disruption can feel more expensive than discomfort. A smaller change—a room, a boundary, a shared task—may return your breathing room before frustration chooses for you.",
    watch:
      "Watch for taking the longer route home because changing the real arrangement still feels too costly.",
    move:
      "Change the smallest practical part that would make staying feel chosen again.",
  },
  "friends-harmony:Libra × Snake": {
    title: "Keep It Honest",
    intro:
      "Peace is useful today only if it leaves enough room for the part nobody has said yet.",
    quote:
      "You can keep the conversation kind without making the unanswered part disappear.",
    deeper:
      "You often know when a disagreement is still trying to understand itself. Give it that chance, but do not keep smoothing the exchange after everyone has started protecting a preferred version of the story.",
    watch:
      "Watch for agreeing with the tone of a conversation while your actual answer remains somewhere else.",
    move:
      "Say one honest sentence before harmony turns into distance between you.",
  },
  "friends-harmony:Taurus × Horse": {
    title: "Keep Your Evening",
    intro:
      "Being dependable does not require giving away the only quiet part of your day.",
    quote:
      "A friendship can remain solid after you say what you cannot take on tonight.",
    deeper:
      "You show care by handling practical things, which makes it easy for people to assume you will keep handling them. A clear limit now protects the relationship from the sharper withdrawal that comes after too much unspoken accommodation.",
    watch:
      "Watch for accepting a small favor while feeling an unusually large resistance to it.",
    move:
      "Offer the help you genuinely have, and leave the rest outside tonight.",
  },
  "money-comfort:Libra × Snake": {
    title: "The Useful Choice",
    intro:
      "A purchase can be pleasant without becoming the evidence you use to settle a larger uncertainty.",
    quote:
      "Before the polished option wins, notice which detail would still matter after the receipt is gone.",
    deeper:
      "You can see the appeal and the practical objection at the same time. That does not require endless comparison; it requires deciding which reason will still feel true when the immediate mood has passed.",
    watch:
      "Watch for asking everyone to validate a purchase whose real question is whether it solves the right problem.",
    move:
      "Choose the detail that changes usefulness, not the one that merely improves the presentation.",
  },
  "money-comfort:Taurus × Horse": {
    title: "Comfort With A Limit",
    intro:
      "A small pleasure can stay enjoyable when it does not quietly purchase another obligation.",
    quote:
      "You can choose comfort today without letting comfort decide what your future week has to carry.",
    deeper:
      "You know the difference between something that earns its place and something that only feels good because the day has been demanding. Give the purchase a place in the life you are actually trying to keep, not just the mood you are trying to escape.",
    watch:
      "Watch for calling an unnecessary expense a reward when what you really need is a change in the day.",
    move:
      "Keep the pleasure if it fits the plan, and change the pressure instead of buying over it.",
  },
  "rest-responsibility:Libra × Snake": {
    title: "Not Yours To Solve",
    intro:
      "A thoughtful pause can reveal which responsibility is real and which one arrived through assumption.",
    quote:
      "You can care about the outcome without carrying every question that belongs to someone else.",
    deeper:
      "You are skilled at seeing what a situation needs, especially when nobody else has named it. Today, notice whether your extra analysis is helping the person act or simply protecting you from watching them choose differently.",
    watch:
      "Watch for researching a problem after the person responsible has already been given a clear next step.",
    move:
      "Offer the useful question, then return the decision to the person who owns it.",
  },
  "rest-responsibility:Taurus × Horse": {
    title: "A Real Day Off",
    intro:
      "Rest becomes more restorative when it is not treated as another responsibility you have to perform well.",
    quote:
      "You are allowed to protect an hour before your patience has to make a dramatic case for it.",
    deeper:
      "Your reliability can make quiet time feel negotiable until every request has a reasonable argument. Take the smaller boundary now; it is kinder than waiting until your only honest rest is to leave everything behind.",
    watch:
      "Watch for doing one useful task during every break and calling the remaining exhaustion discipline.",
    move: "Protect one ordinary hour without explaining why it was necessary.",
  },
  "confidence-recognition:Libra × Snake": {
    title: "Let It Count",
    intro:
      "Recognition can be received today without turning the moment into another review of whether it is deserved.",
    quote:
      "You can accept being seen clearly without presenting every reason the praise might be incomplete.",
    deeper:
      "You know the missing context behind any success, which helps keep confidence honest. It can also make you shrink the result before it has had a chance to register as evidence of what you can do.",
    watch:
      "Watch for answering praise with a list of the help, luck, or unfinished details that made the work possible.",
    move:
      "Say thank you before you add the footnotes or explain why the result happened.",
  },
  "confidence-recognition:Taurus × Horse": {
    title: "Stand In The Win",
    intro:
      "A result can support your next move today instead of becoming another reason to stay modest and still.",
    quote:
      "You do not have to make the work smaller just because you are already thinking about what comes next.",
    deeper:
      "You prefer proof that lasts, and one compliment is not a whole pattern. Still, let this result give you information: people saw something useful, and your effort created room for more than maintenance.",
    watch:
      "Watch for explaining away a clear success before anyone else has finished acknowledging it.",
    move:
      "Receive the recognition, then decide what new room it makes possible.",
  },
  "routine-freedom:Libra × Snake": {
    title: "Enough Of The Pattern",
    intro:
      "A reliable routine can be questioned today without turning one irritation into a verdict on your whole life.",
    quote:
      "Notice what the routine is still giving you before deciding what its newest cost means.",
    deeper:
      "You are good at seeing the reasons a familiar pattern exists, which can keep you inside it after the reasons have changed. Ask whether the irritation is information, then make one measured adjustment instead of another abstract review.",
    watch:
      "Watch for defending the routine's history when the present version has stopped helping.",
    move:
      "Change one part and observe what becomes clearer before judging the whole routine.",
  },
  "routine-freedom:Taurus × Horse": {
    title: "Keep The Useful Part",
    intro:
      "A routine can be worth keeping and still need enough room for the person you are now.",
    quote:
      "You do not need to break the pattern; you need to stop letting it use all the available space.",
    deeper:
      "Familiarity gives your energy somewhere to settle, but a reliable plan can become irritating when every variation feels like a threat. Free one small part of the day before the pressure asks for a complete escape.",
    watch:
      "Watch for protecting a routine that still works on paper but leaves you unusually short-tempered in practice.",
    move: "Make the smallest change that lets the useful part remain.",
  },
  "conflict-directness:Libra × Snake": {
    title: "The Honest Sentence",
    intro:
      "A disagreement may become easier today once you stop asking it to remain pleasant before it becomes clear.",
    quote:
      "You can wait for the right words without waiting for the conflict to become someone else's problem.",
    deeper:
      "You stay with conversations that still contain listening, but patience can become another form of distance when the real issue is already known. Say the clean version before more interpretation hides it.",
    watch:
      "Watch for refining your explanation while the other person is waiting to hear your actual position.",
    move: "Use one direct sentence, then listen to what it makes possible.",
  },
  "conflict-directness:Taurus × Horse": {
    title: "Before It Becomes Final",
    intro:
      "A small disagreement is easier to adjust today than the larger ending your silence may eventually create.",
    quote:
      "Say what is becoming difficult while it is still a changeable part of the arrangement.",
    deeper:
      "You can absorb a great deal without making the room pay for it. That endurance is useful until it turns a manageable request into proof that you must leave; let the other person meet the smaller truth first while the arrangement can still change without drama.",
    watch:
      "Watch for taking a familiar escape route after one more request lands harder than it should.",
    move: "Name the adjustment before your patience has to become a departure.",
  },
  "opportunity-expansion:Libra × Snake": {
    title: "Trust The Pattern",
    intro:
      "A worthwhile opening may not need perfect certainty, only enough evidence to distinguish it from a polished distraction.",
    quote:
      "You can leave the familiar position when the new direction has proved more than its first impression.",
    deeper:
      "You will see both the opportunity and the reasons to wait. Let the decision rest on what has repeated, who follows through, and which missing detail would actually change the answer—not every possible objection.",
    watch:
      "Watch for asking for another opinion after the practical evidence has already converged.",
    move:
      "Choose the next test that lets the opportunity prove itself in real life.",
  },
  "opportunity-expansion:Taurus × Horse": {
    title: "Leave Some Ground",
    intro:
      "A strong opportunity can be worth moving toward when it offers a life you can inhabit, not just a temporary rush.",
    quote:
      "You are not betraying what you built by choosing the expansion that gives it a larger future.",
    deeper:
      "You need more than novelty before leaving solid ground, and that is wisdom. Today, ask whether the opening has durable shape and enough freedom to keep you from rebuilding the same constraint somewhere new.",
    watch:
      "Watch for calling a real next step temporary because staying familiar feels more responsible.",
    move:
      "Take the smallest irreversible-looking step that still leaves the future open.",
  },
};

export function writeCanonicalLens(
  context: CanonicalLensContext,
  plan: CanonicalLensReasoningPlan,
): CanonicalLens {
  const scenarioId =
    "id" in context.scenario && typeof context.scenario.id === "string"
      ? context.scenario.id
      : context.scenario.seed;
  const copy = commonCopy[`${scenarioId}:${context.signPair}`];
  if (!copy) {
    throw new Error(
      `No development copy for ${scenarioId}:${context.signPair}`,
    );
  }
  return {
    title: copy.title,
    intro: copy.intro,
    pull_quote: copy.quote,
    deeper_read: copy.deeper,
    watch_for: copy.watch,
    move: copy.move,
  };
}

export function generateCanonicalLens(
  model: CanonicalIdentityModel,
  scenario: DailySymbolicContext,
): CanonicalLensGenerationResult {
  const modelValidation = validateCanonicalIdentity(model);
  if (!modelValidation.valid) {
    throw new Error(
      `Canonical fixture failed validation: ${
        modelValidation.errors.join("; ")
      }`,
    );
  }
  const context = buildCanonicalLensContext(model, scenario);
  const reasoning = planCanonicalLens(context);
  const lens = writeCanonicalLens(context, reasoning);
  const validation = validateCanonicalLens(lens);
  return {
    signPair: model.signPair,
    scenarioId: scenario.seed,
    context,
    reasoning,
    lens,
    validation,
    retryCount: 0,
  };
}
