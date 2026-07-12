import type {
  CanonicalIdentityModel,
  DecisionPace,
  SocialRole,
} from "../canonical/types.ts";

export interface ArchetypeSource {
  id: string;
  combinedName: string;
  title: string;
  overview: string;
  howYouMove: string;
  strengthProfile: string[];
  shadowProfile: string[];
  dominantStrengthTrait: string;
  dominantShadowTrait: string;
  strengths: string[];
  shadows: string[];
  emotionalPattern: string;
  loveStyle: string;
  friendshipStyle: string;
  workStyle: string;
  growthPath: string;
  compatibilityNotes: string;
  tagline: string;
}

const westernContribution: Record<string, string> = {
  Aries:
    "initiates directly, learns through action, and wants movement before over-analysis",
  Taurus:
    "builds stability through tangible proof, continuity, patience, and embodied comfort",
  Gemini:
    "tracks multiple possibilities through language, curiosity, exchange, and rapid reframing",
  Cancer:
    "reads belonging and safety through memory, care, protection, and emotional continuity",
  Leo:
    "organizes experience around creative expression, visibility, courage, and generous participation",
  Virgo:
    "improves what matters through discrimination, service, sequence, and practical refinement",
  Libra:
    "reads relational balance, fairness, tone, and the consequences of competing perspectives",
  Scorpio:
    "looks beneath appearances for motive, loyalty, leverage, and emotionally consequential truth",
  Sagittarius:
    "seeks range, meaning, candor, movement, and a larger frame for present constraints",
  Capricorn:
    "builds durable authority through standards, responsibility, timing, and earned competence",
  Aquarius:
    "sees systems, exceptions, future possibilities, and the social logic beneath convention",
  Pisces:
    "absorbs atmosphere, imagination, vulnerability, and the human meaning beneath literal facts",
};

const chineseContribution: Record<string, string> = {
  Rat:
    "adds tactical intelligence, adaptability, resource awareness, and an instinct for openings",
  Ox:
    "adds endurance, method, restraint, and a preference for commitments that can bear weight",
  Tiger:
    "adds nerve, personal sovereignty, appetite for challenge, and resistance to confinement",
  Rabbit:
    "adds social sensitivity, discretion, aesthetic intelligence, and protection through diplomacy",
  Dragon:
    "adds scale, charisma, ambition, conviction, and a need to make a consequential mark",
  Snake:
    "adds intuition, strategic patience, privacy, attraction, and selective investment",
  Horse:
    "adds independence, momentum, expressiveness, and a need for room to move",
  Goat:
    "adds imagination, tenderness, artistry, and sensitivity to the quality of an environment",
  Monkey:
    "adds improvisation, wit, experimentation, and pleasure in finding an unexpected route",
  Rooster:
    "adds precision, presentation, candor, vigilance, and pride in visible standards",
  Dog:
    "adds loyalty, conscience, protection, and close attention to whether trust is deserved",
  Pig:
    "adds generosity, sensuality, openness, and a preference for sincere, abundant participation",
};

const paceByWestern: Record<string, DecisionPace> = {
  Aries: "immediate",
  Taurus: "deliberate",
  Gemini: "fast",
  Cancer: "measured",
  Leo: "fast",
  Virgo: "measured",
  Libra: "measured",
  Scorpio: "deliberate",
  Sagittarius: "fast",
  Capricorn: "deliberate",
  Aquarius: "measured",
  Pisces: "slow",
};

const roleByWestern: Record<string, SocialRole> = {
  Aries: "initiator",
  Taurus: "stabilizer",
  Gemini: "explorer",
  Cancer: "protector",
  Leo: "amplifier",
  Virgo: "organizer",
  Libra: "mediator",
  Scorpio: "strategist",
  Sagittarius: "explorer",
  Capricorn: "builder",
  Aquarius: "challenger",
  Pisces: "caretaker",
};

function firstSentence(value: string): string {
  return value.trim().split(/(?<=[.!?])\s+/)[0].replace(/[.!?]+$/, "");
}

function lowerLead(value: string): string {
  return value ? value[0].toLowerCase() + value.slice(1) : value;
}

const irregularBases: Record<string, string> = {
  asks: "ask",
  avoids: "avoid",
  changes: "change",
  connects: "connect",
  finds: "find",
  keeps: "keep",
  looks: "look",
  makes: "make",
  needs: "need",
  notices: "notice",
  offers: "offer",
  pushes: "push",
  reads: "read",
  seeks: "seek",
  stays: "stay",
  takes: "take",
  talks: "talk",
  uses: "use",
  wants: "want",
  works: "work",
};

export function normalizeImperative(value: string): string {
  const cleaned = firstSentence(value).trim().replace(/^you\s+/i, "");
  if (!cleaned) return "name what matters";
  const [head, ...rest] = cleaned.split(/\s+/);
  const lowerHead = head.toLowerCase();
  const base = irregularBases[lowerHead] ?? (
    lowerHead.endsWith("ies")
      ? `${lowerHead.slice(0, -3)}y`
      : lowerHead.endsWith("s") && lowerHead.length > 3
      ? lowerHead.slice(0, -1)
      : lowerHead
  );
  if (
    base === "quick" || base === "steady" || base === "warm" || base === "clear"
  ) {
    return `move with ${normalizeTraitPhrase(cleaned)}`;
  }
  return [base, ...rest].join(" ").replace(/\s+when\s+/gi, " as ");
}

export function normalizeGerund(value: string): string {
  const base = normalizeImperative(value);
  return base.split(/\s+/).map((word, index) => {
    if (index !== 0) return word;
    if (word.endsWith("ie")) return `${word.slice(0, -2)}ying`;
    if (word.endsWith("e") && !word.endsWith("ee")) {
      return `${word.slice(0, -1)}ing`;
    }
    return `${word}ing`;
  }).join(" ");
}

export function normalizeBehaviorClause(value: string): string {
  const cleaned = firstSentence(value);
  if (/^you\s+/i.test(cleaned)) {
    return `${cleaned[0].toLowerCase()}${cleaned.slice(1)}`;
  }
  if (/^[A-Z][^,]+,\s/.test(cleaned) && !/^[A-Z][a-z]+s\b/.test(cleaned)) {
    return `move with ${normalizeTraitPhrase(cleaned)}`;
  }
  return normalizeImperative(cleaned);
}

function normalizeConditionClause(value: string): string {
  return normalizeBehaviorClause(value).replace(/\.$/, "");
}

export function normalizeTraitPhrase(value: string): string {
  const first = firstSentence(value).trim().toLowerCase();
  const traitNouns: Record<string, string> = {
    adaptive: "adaptability",
    charming: "charm",
    clear: "clarity",
    creative: "creativity",
    critical: "critical judgment",
    defensive: "defensiveness",
    independent: "independence",
    loyal: "loyalty",
    perceptive: "perceptiveness",
    quick: "quickness",
    restless: "restlessness",
    steady: "steadiness",
    warm: "warmth",
  };
  return traitNouns[first] ?? first
    .replace(/mentally agile/g, "mental agility")
    .replace(/\bquick\b/g, "quickness")
    .replace(/\bpolished\b/g, "polish")
    .replace(/\bagile\b/g, "agility")
    .replace(/\bsteady\b/g, "steadiness")
    .replace(/\bwarm\b/g, "warmth");
}

function normalizeNounPhrase(value: string): string {
  return normalizeGerund(value);
}

function secondPersonSentence(value: string): string {
  const cleaned = firstSentence(value);
  if (/^you\s+/i.test(cleaned)) return `${cleaned}.`;
  return `You ${lowerLead(cleaned)}.`;
}

function behaviorSentence(value: string): string {
  return `You ${normalizeBehaviorClause(value)}.`;
}

function unique(values: string[]): string[] {
  return [...new Set(values.map((v) => v.trim()).filter(Boolean))];
}

export async function loadArchetypeSources(): Promise<ArchetypeSource[]> {
  const url = new URL("../../../Resources/archetypes.json", import.meta.url);
  return JSON.parse(await Deno.readTextFile(url)) as ArchetypeSource[];
}

export async function sourceFingerprint(): Promise<string> {
  const url = new URL("../../../Resources/archetypes.json", import.meta.url);
  const digest = await crypto.subtle.digest(
    "SHA-256",
    await Deno.readFile(url),
  );
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

export function canonicalFromSource(
  source: ArchetypeSource,
): CanonicalIdentityModel {
  const [westernSign, chineseSign] = source.combinedName.split(" × ");
  const strengths = source.strengths.map((v) => v.replace(/[.!?]+$/, ""));
  const shadows = source.shadows.map((v) => v.replace(/[.!?]+$/, ""));
  const coreDrive = firstSentence(source.howYouMove);
  const growth = firstSentence(source.growthPath);
  const emotion = firstSentence(source.emotionalPattern);
  const love = firstSentence(source.loveStyle);
  const friendship = firstSentence(source.friendshipStyle);
  const work = firstSentence(source.workStyle);
  return {
    signPair: source.combinedName,
    westernSign,
    chineseSign,
    archetypeName: source.title,
    version: "1.0.0",
    status: "draft",
    sourceType: "hybrid",
    core: {
      centralParadox: `${source.overview} Yet ${growth}.`,
      coreDrive,
      coreNeed: source.compatibilityNotes,
      coreFear: `${source.dominantShadowTrait} takes over when ${
        lowerLead(shadows[0])
      }.`,
      matureExpression: `${source.dominantStrengthTrait} becomes durable when ${
        lowerLead(growth)
      }.`,
      recurringThemes: unique([
        source.dominantStrengthTrait,
        source.dominantShadowTrait,
        ...source.strengthProfile,
        ...source.shadowProfile,
      ]).slice(0, 4),
    },
    sourceReasoning: {
      westernContribution: westernContribution[westernSign],
      chineseContribution: chineseContribution[chineseSign],
      emergentSynthesis: `${source.overview} ${source.tagline}.`,
    },
    perception: {
      noticesFirst: source.overview,
      noticesInPeople: [friendship, love, strengths[0]],
      noticesInSituations: [coreDrive, work, strengths[1]],
      readsAsThreat: [shadows[0], shadows[1], source.dominantShadowTrait],
      readsAsOpportunity: [strengths[0], strengths[1], growth],
      interpretationBias: emotion,
      attentionBlindSpot: shadows[2],
    },
    decision: {
      decisionPace: paceByWestern[westernSign],
      defaultProcess: `${coreDrive}; then ${lowerLead(strengths[0])}.`,
      evidenceThreshold: `Enough visible proof that ${
        lowerLead(strengths[1])
      }.`,
      actionTrigger: strengths[2],
      delayPattern: shadows[0],
      reversalPattern: `Changes course when ${lowerLead(growth)}.`,
      regretPattern: `Regrets the choice when ${lowerLead(shadows[1])}.`,
      certaintyStyle:
        `${source.dominantStrengthTrait} in public, with ${source.dominantShadowTrait.toLowerCase()} kept underneath.`,
    },
    social: {
      defaultRole: roleByWestern[westernSign],
      communicationStyle: friendship,
      conflictStyle: shadows[0],
      influenceStyle: strengths[0],
      boundaryStyle: growth,
      commonMisreads: [source.overview, source.tagline, shadows[2]],
      responseToGroupUncertainty: friendship,
      responseToAuthority: `${work}; pressure can make this person ${
        lowerLead(shadows[1])
      }.`,
    },
    relationships: {
      attractionPattern: love,
      trustBuilders: [strengths[0], source.compatibilityNotes, strengths[1]],
      trustBreakers: [shadows[0], shadows[1], shadows[2]],
      closenessStyle: source.loveStyle,
      loyaltyStyle: source.friendshipStyle,
      forgivenessPattern: `Forgiveness becomes possible when ${
        lowerLead(growth)
      }.`,
      relationshipBlindSpot: shadows[1],
      healthyRelationshipCondition: source.compatibilityNotes,
      withdrawalTrigger: shadows[2],
    },
    work: {
      valueCreated: work,
      problemSolvingStyle: strengths[1],
      teamRole: source.workStyle,
      leadershipStyle: `${
        strengths[0]
      } while making room for others to carry visible ownership.`,
      idealConditions: [source.compatibilityNotes, strengths[0], strengths[2]],
      drainingConditions: [shadows[0], shadows[1], shadows[2]],
      relationshipToStructure: coreDrive,
      relationshipToAutonomy: source.tagline,
      careerBlindSpot: shadows[1],
      completionSignal:
        `The result visibly carries the identity's ${source.dominantStrengthTrait.toLowerCase()} strength.`,
      releasePattern: growth,
    },
    pressure: {
      firstShift: shadows[0],
      overextendedStrength:
        `${source.dominantStrengthTrait} becomes ${source.dominantShadowTrait.toLowerCase()}.`,
      visibleBehaviors: shadows,
      internalStory: emotion,
      emotionalCost: source.emotionalPattern,
      relationalCost: shadows[2],
      decisionDistortion: shadows[1],
      shadowRole:
        `the ${source.dominantShadowTrait.toLowerCase()} version of ${source.title}`,
      escalationPattern: `${shadows[0]}, then ${lowerLead(shadows[1])}, then ${
        lowerLead(shadows[2])
      }.`,
    },
    growth: {
      restorationPattern: growth,
      helpfulConditions: [
        source.compatibilityNotes,
        strengths[0],
        strengths[1],
      ],
      helpfulPeople: [source.compatibilityNotes, friendship, love],
      groundingBehaviors: [growth, strengths[0], strengths[2]],
      recurringLesson: source.growthPath,
      growthEdge: growth,
      recoveryRecognition: `Recovery starts when ${lowerLead(growth)}.`,
      matureReturn:
        `${source.dominantStrengthTrait} returns without ${source.dominantShadowTrait.toLowerCase()} running the exchange.`,
    },
    evidence: {
      observableBehaviors: unique([...strengths, ...shadows, coreDrive]),
      everydaySituations: [
        source.workStyle,
        source.loveStyle,
        source.friendshipStyle,
        source.emotionalPattern,
      ],
      signatureContrasts: [
        `${source.dominantStrengthTrait} outside, ${source.dominantShadowTrait.toLowerCase()} underneath`,
        `${strengths[0]} until ${lowerLead(shadows[0])}`,
        `${source.tagline} while ${lowerLead(emotion)}`,
      ],
      signatureObservations: [
        source.overview,
        source.tagline,
        source.growthPath,
      ],
      prohibitedGenericClaims: [
        "observant",
        "loyal",
        "independent",
        "intuitive",
        "reliable",
      ],
    },
  };
}

function canonicalFromSourceV2(
  source: ArchetypeSource,
): CanonicalIdentityModel {
  const [westernSign, chineseSign] = source.combinedName.split(" × ");
  const strengths = source.strengths.map((v) => v.replace(/[.!?]+$/, ""));
  const shadows = source.shadows.map((v) => v.replace(/[.!?]+$/, ""));
  const coreDrive = firstSentence(source.howYouMove);
  const growth = firstSentence(source.growthPath);
  const emotion = firstSentence(source.emotionalPattern);
  const love = firstSentence(source.loveStyle);
  const friendship = firstSentence(source.friendshipStyle);
  const work = firstSentence(source.workStyle);
  const trait = normalizeTraitPhrase(source.dominantStrengthTrait);
  const shadowTrait = normalizeTraitPhrase(source.dominantShadowTrait);
  return {
    signPair: source.combinedName,
    westernSign,
    chineseSign,
    archetypeName: source.title,
    version: "1.0.0",
    status: "draft",
    sourceType: "hybrid",
    core: {
      centralParadox: `${
        secondPersonSentence(source.overview)
      } Growth begins when you ${normalizeImperative(growth)}.`,
      coreDrive: behaviorSentence(coreDrive),
      coreNeed: source.compatibilityNotes,
      coreFear: `Under pressure, you may ${normalizeImperative(shadows[0])}.`,
      matureExpression: `You express ${trait} when you ${
        normalizeImperative(growth)
      }.`,
      recurringThemes: unique([
        source.dominantStrengthTrait,
        source.dominantShadowTrait,
        ...source.strengthProfile,
        ...source.shadowProfile,
      ]).slice(0, 4),
    },
    sourceReasoning: {
      westernContribution: westernContribution[westernSign],
      chineseContribution: chineseContribution[chineseSign],
      emergentSynthesis: `${
        secondPersonSentence(source.overview)
      } The through-line is ${normalizeTraitPhrase(source.tagline)}.`,
    },
    perception: {
      noticesFirst: source.overview,
      noticesInPeople: [friendship, love, behaviorSentence(strengths[0])],
      noticesInSituations: [
        behaviorSentence(coreDrive),
        work,
        behaviorSentence(strengths[1]),
      ],
      readsAsThreat: [
        `The tendency to ${normalizeImperative(shadows[0])}`,
        `The tendency to ${normalizeImperative(shadows[1])}`,
        `The risk of ${shadowTrait}`,
      ],
      readsAsOpportunity: [
        `The capacity to ${normalizeImperative(strengths[0])}`,
        `The capacity to ${normalizeImperative(strengths[1])}`,
        `The chance to ${normalizeImperative(growth)}`,
      ],
      interpretationBias: emotion,
      attentionBlindSpot: `You may ${normalizeImperative(shadows[2])}.`,
    },
    decision: {
      decisionPace: paceByWestern[westernSign],
      defaultProcess: `${behaviorSentence(coreDrive)} Then you ${
        normalizeImperative(strengths[0])
      }.`,
      evidenceThreshold: `You have enough visible proof when you ${
        normalizeImperative(strengths[1])
      }.`,
      actionTrigger: `You act when you ${normalizeImperative(strengths[2])}.`,
      delayPattern: `You delay when you ${normalizeImperative(shadows[0])}.`,
      reversalPattern: `You change course when you ${
        normalizeImperative(growth)
      }.`,
      regretPattern: `You regret the choice when you ${
        normalizeImperative(shadows[1])
      }.`,
      certaintyStyle:
        `You project ${trait} while managing ${shadowTrait} underneath.`,
    },
    social: {
      defaultRole: roleByWestern[westernSign],
      communicationStyle: friendship,
      conflictStyle: `You tend to ${normalizeImperative(shadows[0])}.`,
      influenceStyle: `You influence through ${
        normalizeNounPhrase(strengths[0])
      }.`,
      boundaryStyle: `The mature boundary is to ${
        normalizeImperative(growth)
      }.`,
      commonMisreads: [
        secondPersonSentence(source.overview),
        source.tagline,
        `You may ${normalizeImperative(shadows[2])}.`,
      ],
      responseToGroupUncertainty: friendship,
      responseToAuthority: `${work}. Under pressure, you may ${
        normalizeImperative(shadows[1])
      }.`,
    },
    relationships: {
      attractionPattern: love,
      trustBuilders: [
        `Evidence of ${normalizeNounPhrase(strengths[0])}`,
        source.compatibilityNotes,
        `Evidence of ${normalizeNounPhrase(strengths[1])}`,
      ],
      trustBreakers: [
        `The habit of ${normalizeGerund(shadows[0])}`,
        `The habit of ${normalizeGerund(shadows[1])}`,
        `The habit of ${normalizeGerund(shadows[2])}`,
      ],
      closenessStyle: source.loveStyle,
      loyaltyStyle: source.friendshipStyle,
      forgivenessPattern: `Forgiveness becomes possible when you ${
        normalizeImperative(growth)
      }.`,
      relationshipBlindSpot: `You may ${
        normalizeImperative(shadows[1])
      } after closeness is already possible.`,
      healthyRelationshipCondition: source.compatibilityNotes,
      withdrawalTrigger: `You withdraw when you ${
        normalizeImperative(shadows[2])
      }.`,
    },
    work: {
      valueCreated: work,
      problemSolvingStyle: behaviorSentence(strengths[1]),
      teamRole: source.workStyle,
      leadershipStyle: `You lead by ${
        normalizeGerund(strengths[0])
      } while making room for others to carry visible ownership.`,
      idealConditions: [
        source.compatibilityNotes,
        behaviorSentence(strengths[0]),
        behaviorSentence(strengths[2]),
      ],
      drainingConditions: [
        `You ${normalizeImperative(shadows[0])}.`,
        `You ${normalizeImperative(shadows[1])}.`,
        `You ${normalizeImperative(shadows[2])}.`,
      ],
      relationshipToStructure: behaviorSentence(coreDrive),
      relationshipToAutonomy: source.tagline,
      careerBlindSpot: `You may ${
        normalizeImperative(shadows[1])
      } after the work is already good enough.`,
      completionSignal:
        `The result visibly carries the identity's ${trait} strength.`,
      releasePattern: `You release the work by ${normalizeGerund(growth)}.`,
    },
    pressure: {
      firstShift: `Under pressure, you first ${
        normalizeImperative(shadows[0])
      }.`,
      overextendedStrength: `${trait} becomes ${shadowTrait} when overused.`,
      visibleBehaviors: shadows.map((shadow) => behaviorSentence(shadow)),
      internalStory: emotion,
      emotionalCost: source.emotionalPattern,
      relationalCost:
        `Other people may experience you as ${shadowTrait} when the pressure continues.`,
      decisionDistortion:
        `You may decide from ${shadowTrait} instead of evidence.`,
      shadowRole: `the ${shadowTrait} version of ${source.title}`,
      escalationPattern: `Under pressure, you ${
        normalizeImperative(shadows[0])
      }. Then you ${normalizeImperative(shadows[1])}. Finally, you ${
        normalizeImperative(shadows[2])
      }.`,
    },
    growth: {
      restorationPattern: `You recover by ${normalizeGerund(growth)}.`,
      helpfulConditions: [
        source.compatibilityNotes,
        behaviorSentence(strengths[0]),
        behaviorSentence(strengths[1]),
      ],
      helpfulPeople: [source.compatibilityNotes, friendship, love],
      groundingBehaviors: [
        `You ${normalizeImperative(growth)}.`,
        behaviorSentence(strengths[0]),
        behaviorSentence(strengths[2]),
      ],
      recurringLesson: `You grow by ${normalizeGerund(source.growthPath)}.`,
      growthEdge: `You are learning to ${normalizeImperative(growth)}.`,
      recoveryRecognition: `You know you are recovering when you ${
        normalizeImperative(growth)
      }.`,
      matureReturn:
        `You return to ${trait} without letting ${shadowTrait} run the exchange.`,
    },
    evidence: {
      observableBehaviors: unique(
        [...strengths, ...shadows, coreDrive].map((value) =>
          behaviorSentence(value)
        ),
      ),
      everydaySituations: [
        source.workStyle,
        source.loveStyle,
        source.friendshipStyle,
        source.emotionalPattern,
      ],
      signatureContrasts: [
        `${trait} outside, ${shadowTrait} underneath`,
        `${normalizeTraitPhrase(strengths[0])} until you ${
          normalizeImperative(shadows[0])
        }`,
        `${normalizeTraitPhrase(source.tagline)} while ${lowerLead(emotion)}`,
      ],
      signatureObservations: [
        source.overview,
        source.tagline,
        `You grow by ${normalizeImperative(source.growthPath)}.`,
      ],
      prohibitedGenericClaims: [
        "observant",
        "loyal",
        "independent",
        "intuitive",
        "reliable",
      ],
    },
  };
}

export async function buildCanonicalLibrary(): Promise<
  CanonicalIdentityModel[]
> {
  return (await loadArchetypeSources()).map(canonicalFromSourceV2);
}
