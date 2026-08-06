import identityProfiles from "./runtime-data/identity_profiles_v1.runtime.json" with {
  type: "json",
};
import {
  CANONICAL_HOUSE_LIFE_AREAS,
} from "./structured-interpretation-v1/contracts.ts";
import {
  GENERIC_CHINESE_EVIDENCE,
  GENERIC_CHINESE_EVIDENCE_VERSION,
  GENERIC_CHINESE_SOURCE_SHA256,
} from "./structured-interpretation-v1/generic-chinese-evidence-v1.ts";
import {
  deriveFineGrainedTransitState,
} from "./structured-interpretation-v1/production-builder-v1.ts";
import { skyContextForMoment } from "./todays-lens-horoscope-writer-v2.ts";

const LUNATION_HOUR_MS = 60 * 60 * 1000;

function signedFullMoonError(date: Date) {
  const angle = skyContextForMoment(date).phaseAngleDegrees;
  return ((angle - 180 + 540) % 360) - 180;
}

export function exactFullMoonNear(reference: Date) {
  const start = reference.getTime() - 8 * 24 * LUNATION_HOUR_MS;
  const end = reference.getTime() + 8 * 24 * LUNATION_HOUR_MS;
  let previousTime = start;
  let previousError = signedFullMoonError(new Date(start));
  const crossings: number[] = [];
  for (
    let time = start + LUNATION_HOUR_MS;
    time <= end;
    time += LUNATION_HOUR_MS
  ) {
    const error = signedFullMoonError(new Date(time));
    if (previousError <= 0 && error >= 0 && error - previousError < 30) {
      let low = previousTime;
      let high = time;
      for (let iteration = 0; iteration < 48; iteration++) {
        const midpoint = (low + high) / 2;
        if (signedFullMoonError(new Date(midpoint)) < 0) low = midpoint;
        else high = midpoint;
      }
      crossings.push((low + high) / 2);
    }
    previousTime = time;
    previousError = error;
  }
  if (!crossings.length) {
    throw new Error("Exact Full Moon could not be derived");
  }
  return new Date(
    crossings.reduce((best, current) =>
      Math.abs(current - reference.getTime()) <
          Math.abs(best - reference.getTime())
        ? current
        : best
    ),
  );
}

export function lunationState(contentMoment: Date) {
  const exactAt = exactFullMoonNear(contentMoment);
  const elapsedHours = (contentMoment.getTime() - exactAt.getTime()) /
    LUNATION_HOUR_MS;
  const classification = elapsedHours < -12
    ? "APPROACHING_FULL_MOON"
    : Math.abs(elapsedHours) <= 12
    ? "EXACT_FULL_MOON_WINDOW"
    : elapsedHours <= 72
    ? "SEPARATING_POST_FULL_MOON_INTEGRATION"
    : "WANING_PHASE";
  return {
    classification,
    exactLunation: "FULL_MOON",
    exactAtUtc: exactAt.toISOString(),
    exactAtLocal: localTimestamp(exactAt),
    elapsedHoursSinceExact: Number(elapsedHours.toFixed(2)),
    phaseDirection: elapsedHours < 0 ? "APPROACHING" : "SEPARATING_WANING",
    narrativeFrame: elapsedHours < -12
      ? "The Full Moon is approaching."
      : Math.abs(elapsedHours) <= 12
      ? "The Full Moon is exact within the current twelve-hour window."
      : elapsedHours <= 72
      ? "The Full Moon has passed; its effects are separating and being processed or integrated."
      : "The Moon is in the waning phase after the Full Moon.",
  };
}

export const SKY_LED_PRODUCTION_CANDIDATE_V1 =
  "todays-lens-sky-led-production-candidate-v1" as const;
export const SKY_LED_RUNTIME_CONTRACT_V1 = "todays-lens-read-only-v1" as const;
export const SKY_LED_ASTROLOGY_PROVENANCE_V1 =
  "sky_led_astrology_packet_v1" as const;
export const SKY_LED_PLAIN_LANGUAGE_VOICE_VERSION =
  "todays-lens-sky-led-plain-language-v1" as const;
export const SKY_LED_COMPRESSION_EDITOR_VERSION =
  "todays-lens-sky-led-compression-editor-v1" as const;
const TIMEZONE = "America/Los_Angeles";
const HOUR_MS = 60 * 60 * 1000;
const WESTERN_SIGNS = [
  "Aries",
  "Taurus",
  "Gemini",
  "Cancer",
  "Leo",
  "Virgo",
  "Libra",
  "Scorpio",
  "Sagittarius",
  "Capricorn",
  "Aquarius",
  "Pisces",
] as const;
const CHINESE_SIGNS = [
  "Rat",
  "Ox",
  "Tiger",
  "Rabbit",
  "Dragon",
  "Snake",
  "Horse",
  "Goat",
  "Monkey",
  "Rooster",
  "Dog",
  "Pig",
] as const;

type ProviderPayload = Record<string, unknown>;

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function timezoneOffsetMs(date: Date) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: TIMEZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);
  const values = Object.fromEntries(
    parts.map((part) => [part.type, part.value]),
  );
  return Date.UTC(
    Number(values.year),
    Number(values.month) - 1,
    Number(values.day),
    Number(values.hour),
    Number(values.minute),
    Number(values.second),
  ) - date.getTime();
}

function localDateTimeToUtc(contentDate: string, hour: number) {
  const [year, month, day] = contentDate.split("-").map(Number);
  const nominalUtc = Date.UTC(year, month - 1, day, hour);
  let result = new Date(nominalUtc);
  for (let iteration = 0; iteration < 3; iteration++) {
    result = new Date(nominalUtc - timezoneOffsetMs(result));
  }
  return result;
}

function localTimestamp(date: Date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TIMEZONE,
    dateStyle: "medium",
    timeStyle: "long",
    hourCycle: "h23",
  }).format(date);
}

function nextLocalDate(dayStart: Date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TIMEZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date(dayStart.getTime() + 30 * HOUR_MS));
}

function relativeHouse(transitSign: string, westernSign: string) {
  const transit = WESTERN_SIGNS.indexOf(transitSign as never);
  const identity = WESTERN_SIGNS.indexOf(westernSign as never);
  assert(transit >= 0 && identity >= 0, "House calculation failed");
  return ((transit - identity + 12) % 12) + 1;
}

function moonSignTransitions(dayStart: Date, dayEnd: Date) {
  const transitions: Array<Record<string, string>> = [];
  let previousTime = dayStart.getTime();
  let previousSign = skyContextForMoment(dayStart).moonSign;
  for (
    let time = previousTime + 30 * 60 * 1000;
    time <= dayEnd.getTime();
    time += 30 * 60 * 1000
  ) {
    const sign = skyContextForMoment(new Date(time)).moonSign;
    if (sign !== previousSign) {
      let low = previousTime;
      let high = time;
      for (let iteration = 0; iteration < 40; iteration++) {
        const midpoint = (low + high) / 2;
        if (skyContextForMoment(new Date(midpoint)).moonSign === previousSign) {
          low = midpoint;
        } else high = midpoint;
      }
      const at = new Date(high);
      transitions.push({
        from: previousSign,
        to: sign,
        atUtc: at.toISOString(),
        atLocal: localTimestamp(at),
      });
      previousSign = sign;
    }
    previousTime = time;
  }
  return transitions;
}

export function buildSkyLedProductionPacket(args: {
  contentDate: string;
  westernSign: string;
  chineseSign: string;
}) {
  assert(/^\d{4}-\d{2}-\d{2}$/.test(args.contentDate), "Invalid content date");
  assert(
    WESTERN_SIGNS.includes(args.westernSign as never),
    "Invalid Western sign",
  );
  assert(
    CHINESE_SIGNS.includes(args.chineseSign as never),
    "Invalid Chinese sign",
  );
  const identityKey = `${args.westernSign}-${args.chineseSign}`.toLowerCase();
  const profile = (identityProfiles as Array<Record<string, unknown>>).find(
    (item) => item.id === identityKey,
  );
  const identitySignature = profile?.signature;
  assert(
    typeof identitySignature === "string" && identitySignature.trim(),
    "Signature unavailable",
  );

  const dayStart = localDateTimeToUtc(args.contentDate, 0);
  const dayEnd = localDateTimeToUtc(nextLocalDate(dayStart), 0);
  const contentMoment = localDateTimeToUtc(args.contentDate, 12);
  const skyContext = skyContextForMoment(contentMoment);
  const fineGrainedTransitState = deriveFineGrainedTransitState({
    contentDate: args.contentDate,
    westernSign: args.westernSign,
  });
  const activatedHouse = relativeHouse(skyContext.moonSign, args.westernSign);
  const opposingHouse = relativeHouse(skyContext.sunSign, args.westernSign);
  const chineseEvidence = GENERIC_CHINESE_EVIDENCE[args.chineseSign];
  assert(chineseEvidence, "Chinese evidence unavailable");
  const transitions = moonSignTransitions(dayStart, dayEnd);

  return {
    contentDate: args.contentDate,
    identityPair: {
      westernSign: args.westernSign,
      chineseSign: args.chineseSign,
    },
    identitySignature,
    skyContext,
    lunationState: lunationState(contentMoment),
    moonSignMovement: {
      timezone: TIMEZONE,
      localDayStartUtc: dayStart.toISOString(),
      localDayEndUtc: dayEnd.toISOString(),
      startSign: skyContextForMoment(dayStart).moonSign,
      endSign: skyContextForMoment(new Date(dayEnd.getTime() - 1)).moonSign,
      changedSigns: transitions.length > 0,
      transitions,
    },
    fineGrainedTransitState,
    westernHouseAndAspectReasoning: {
      basis: "solar_house",
      sunSign: args.westernSign,
      activatedHouse,
      activatedLifeArea: CANONICAL_HOUSE_LIFE_AREAS[activatedHouse],
      opposingHouse,
      opposingLifeArea: CANONICAL_HOUSE_LIFE_AREAS[opposingHouse],
      lunarAspectToIdentity: {
        name: fineGrainedTransitState.aspectName,
        targetDegrees: fineGrainedTransitState.aspectTargetDegrees,
        orbDegrees: fineGrainedTransitState.orbDegrees,
        orbBand: fineGrainedTransitState.orbBand,
        motion: fineGrainedTransitState.aspectMotion,
        strengthMotion: fineGrainedTransitState.strengthMotion,
        transitStage: fineGrainedTransitState.transitStage,
      },
    },
    chineseYearContext: {
      identitySign: args.chineseSign,
      evidenceVersion: GENERIC_CHINESE_EVIDENCE_VERSION,
      sourceSha256: GENERIC_CHINESE_SOURCE_SHA256,
      traits: chineseEvidence.traits,
      sources: chineseEvidence.sources,
    },
    astrologyProvenance: {
      timezone: TIMEZONE,
      skySource: "todays-lens-horoscope-writer-v2.skyContextForMoment",
      transitSource:
        "structured-production-builder-v1.deriveFineGrainedTransitState",
      identitySource: "Resources/Identity/identity_profiles_v1.json#signature",
      chineseEvidenceVersion: GENERIC_CHINESE_EVIDENCE_VERSION,
    },
  };
}

export type SkyLedEndingCategory =
  | "Rest / Recovery"
  | "Communicate"
  | "Act"
  | "Wait"
  | "Observe"
  | "Connect"
  | "Create"
  | "Organize"
  | "Decide"
  | "Release"
  | "Explore"
  | "Other";

export type SkyLedRecentRead = {
  ritualDate: string;
  read: string;
};
export const SKY_LED_OPENING_FAMILIES = [
  "concrete_situation",
  "direct_observation",
  "tension",
  "choice",
  "social_cue",
  "action_underway",
  "contrast",
  "concrete_consequence",
] as const;
export type SkyLedOpeningFamily = typeof SKY_LED_OPENING_FAMILIES[number];
export const SKY_LED_OPENING_ASSIGNMENT_VERSION =
  "sky-led-opening-family-assignment-v1" as const;

function openingAssignmentHash(value: string) {
  let hash = 2166136261;
  for (const character of value) {
    hash = Math.imul(hash ^ character.charCodeAt(0), 16777619);
  }
  return hash >>> 0;
}

/** Deterministic full-144 assignment; independent of batch worker order. */
export function assignSkyLedOpeningFamily(
  contentDate: string,
  westernSign: string,
  chineseSign: string,
): SkyLedOpeningFamily {
  const seed = openingAssignmentHash(contentDate);
  const ranked = WESTERN_SIGNS.flatMap((western) =>
    CHINESE_SIGNS.map((chinese) => ({ western, chinese }))
  ).sort((left, right) => {
    const leftValue =
      (openingAssignmentHash(`${left.western} × ${left.chinese}`) ^ seed) >>> 0;
    const rightValue =
      (openingAssignmentHash(`${right.western} × ${right.chinese}`) ^ seed) >>>
      0;
    return leftValue - rightValue ||
      `${left.western} × ${left.chinese}`.localeCompare(
        `${right.western} × ${right.chinese}`,
      );
  });
  const index = ranked.findIndex((pair) =>
    pair.western === westernSign && pair.chinese === chineseSign
  );
  assert(index >= 0, "Opening-family identity unavailable");
  return SKY_LED_OPENING_FAMILIES[
    Math.floor(index / (ranked.length / SKY_LED_OPENING_FAMILIES.length))
  ];
}

export function validateSkyLedOpeningFamily(
  read: string,
  family: SkyLedOpeningFamily,
) {
  const first = read.split(/(?<=[.!?])\s+/)[0] ?? "";
  const concreteSituation = (() => {
    const startsWithDeterminer = /^(?:a|an|the)\s+/i.test(first);
    const hasInternalOrAbstractHead =
      /^(?:a|an|the)\s+(?:\w+\s+){0,4}(?:feeling|energy|mood|situation)\b/i
        .test(first);
    const hasExternalHead =
      /\b(?:project|task|responsibility|message|plan|arrangement|promise|reply|conversation|group|meeting|request|deadline|schedule|assignment|order|bill|account|detail|delay|invitation|workload|job|commitment|decision|rule|agreement|event|object)\b/i
        .test(first);
    const templateFree = validateSkyLedTemplateLanguage(read).accepted;
    const noYouMayBe = !/^you may be\b/i.test(first);
    return {
      accepted: startsWithDeterminer && hasExternalHead &&
        !hasInternalOrAbstractHead && templateFree && noYouMayBe,
      conditions: {
        startsWithDeterminer,
        hasExternalHead,
        noInternalOrAbstractHead: !hasInternalOrAbstractHead,
        templateFree,
        noYouMayBe,
      },
    };
  })();
  const socialCue = (() => {
    const startsWithDeterminer = /^(?:a|an|the|that)\s+/i.test(first);
    const hasCueNoun =
      /\b(?:reply|message|tone|pause|invite|invitation|silence|look|delay|response|comment|text|call|expression|gesture)\b/i
        .test(first);
    const hasInternalOrAbstractHead =
      /^(?:a|an|the|that)\s+(?:\w+\s+){0,4}(?:feeling|energy|mood|situation)\b/i
        .test(first);
    const templateFree = validateSkyLedTemplateLanguage(read).accepted;
    const noTemporalLead =
      !/^(?:today|this morning|this afternoon|this evening|tonight)\b/i.test(
        first,
      );
    const noYouMayBe = !/^you may be\b/i.test(first);
    return {
      accepted: startsWithDeterminer && hasCueNoun &&
        !hasInternalOrAbstractHead && templateFree && noTemporalLead &&
        noYouMayBe,
      conditions: {
        startsWithDeterminer,
        hasCueNoun,
        noInternalOrAbstractHead: !hasInternalOrAbstractHead,
        templateFree,
        noTemporalLead,
        noYouMayBe,
      },
    };
  })();
  const tension = (() => {
    const hasConflictRelationship =
      /\b(?:but|while|yet|although)\b/i.test(first) ||
      /\bbecause\b.*\b(?:while|another|someone|they|each side|people|one person|the other)\b/i
        .test(first) ||
      /\b(?:real|problem)\b.*\bnot\b/i.test(first) ||
      /\bis not really about\b/i.test(first) ||
      /\bpulling\b.*\bdifferent directions\b/i.test(first) ||
      /\bclashing with\b|\bcausing friction\b|\beach side\b|\btreating\b.*\blike\b/i
        .test(first);
    const concreteTerms = first.match(
      /\b(?:plan|work|answer|room|standard|detail|expectation|priority|goal|responsibility|task|message|agreement|favor|commitment|time|money|role|decision|effort)\w*\b/gi,
    ) ?? [];
    const hasTwoConcreteSides = concreteTerms.length >= 2 ||
      /\b(?:one person|someone|you)\b.*\b(?:while|but)\b.*\b(?:another|someone|they)\b/i
        .test(first) ||
      /\b(?:you|someone|one person)\b.*\bwants?\b.*\band\b.*\b(?:someone else|another|they)\b.*\bwants?\b/i
        .test(first) ||
      /\btwo\s+reasonable\s+priorities\b/i.test(first) ||
      /\bproblem\b.*\bnot\b.*\bbut\b/i.test(first) ||
      /\bargument\b.*\bis not really about\b/i.test(first) ||
      /\b(?:you|one person|someone)\b.*\bclashing with\b.*\b(?:someone|another|their)\b/i
        .test(first) ||
      /\b(?:plan|idea|decision|commitment)\b.*\bclashing with\b.*\b(?:expect|need|demand|rule|home|people)\b/i
        .test(first) ||
      /\b(?:one|each)\b.*\b(?:thinks|expects)\b.*\b(?:other|another)\b.*\b(?:thinks|expects)\b/i
        .test(first) ||
      /\b(?:friend|partner|someone|people)\b.*\b(?:expects|treating)\b.*\b(?:you|your)\b/i
        .test(first);
    const genericOrAbstract =
      /^(?:a shared plan feels difficult|there is tension around|a problem needs attention|you may feel conflicted)\b/i
        .test(first);
    const templateFree = validateSkyLedTemplateLanguage(read).accepted;
    const noTemporalLead =
      !/^(?:today|this morning|this afternoon|this evening|tonight)\b/i.test(
        first,
      );
    const noYouMayBe = !/^you may be\b/i.test(first);
    return {
      accepted: hasConflictRelationship && hasTwoConcreteSides &&
        !genericOrAbstract && templateFree && noTemporalLead && noYouMayBe,
      conditions: {
        hasConflictRelationship,
        hasTwoConcreteSides,
        noGenericOrAbstractTension: !genericOrAbstract,
        templateFree,
        noTemporalLead,
        noYouMayBe,
      },
    };
  })();
  const actionUnderway = (() => {
    const hasMovementMarker =
      /\b(?:has|have)\s+already\s+(?:\w+ed|begun|started|turned|grown)\b|\byou(?:'|’)ve\s+already\s+(?:\w+ed|begun|started|turned|grown)\b|\byou\s+already\s+(?:\w+ed|begun|started|turned|grown)\b|\balready\s+(?:has|have|is|are)\b|\b(?:has|have)\s+(?:begun|started)\b|\b(?:is|are)\s+already\b|\bkeeps\b|\bcontinues to\b|\b(?:is|are)\s+beginning to\b|\bset in motion\b/i
        .test(first);
    const hasConcreteSubject =
      /^you\b|^(?:a|an|the)\s+(?:\w+\s+){0,4}(?:reply|message|plan|task|responsibility|pattern|habit|decision|conversation|relationship|commitment|favor|expectation|workload|feeling|worry|arrangement|agreement|purchase|expense)\b/i
        .test(first);
    const hasAbstractSubject =
      /^(?:a|an|the)\s+(?:\w+\s+){0,4}(?:energy|mood|situation)\b/i.test(first);
    const templateFree = validateSkyLedTemplateLanguage(read).accepted;
    const noTemporalLead =
      !/^(?:today|this morning|this afternoon|this evening|tonight)\b/i.test(
        first,
      );
    const noYouMayBe = !/^you may be\b/i.test(first);
    return {
      accepted: hasMovementMarker && hasConcreteSubject &&
        !hasAbstractSubject && templateFree && noTemporalLead && noYouMayBe,
      conditions: {
        hasMovementMarker,
        hasConcreteSubject,
        noAbstractSubject: !hasAbstractSubject,
        templateFree,
        noTemporalLead,
        noYouMayBe,
      },
    };
  })();
  const checks: Record<SkyLedOpeningFamily, boolean> = {
    concrete_situation: concreteSituation.accepted,
    direct_observation: /^you\s+(notice|already know|keep|see|catch|spot)\b/i
      .test(first),
    tension: tension.accepted,
    choice: /^(either|choose|ask|decide)\b/i.test(first) &&
      /\b(or|instead)\b/i.test(first),
    social_cue: socialCue.accepted,
    action_underway: actionUnderway.accepted,
    contrast: /\b(?:but|while|although)\b/i.test(first),
    concrete_consequence:
      /^(?:one|a|an|that|the)\s+(?!\s*(?:feeling|energy|mood|situation)\b).+\b(?:is|creates|costs|leaves|has left|has turned into|is now|is taking|are taking)\b/i
        .test(first),
  };
  return {
    accepted: checks[family],
    findings: checks[family] ? [] : [`opening_family_mismatch:${family}`],
    conditions: family === "concrete_situation"
      ? concreteSituation.conditions
      : family === "social_cue"
      ? socialCue.conditions
      : family === "tension"
      ? tension.conditions
      : family === "action_underway"
      ? actionUnderway.conditions
      : { openingMatchesAssignedFamily: checks[family] },
  };
}
export function openingFamilyRecipe(family: SkyLedOpeningFamily) {
  const recipes: Record<SkyLedOpeningFamily, string> = {
    concrete_situation:
      "Begin with a specific external task/situation. Good: A shared project has quietly become your responsibility. Reject internal-state hedges. Checklist: external noun first; no energy language.",
    direct_observation:
      "Begin with observable noticing/doing. Good: You notice the missing detail before anyone else does. Reject: A missing detail may catch your attention. Checklist: observable cue; never You may be.",
    tension:
      "Editorial intent: expose the hidden source of a concrete conflict. Use a false assumption, competing priorities, uneven expectations, an overlooked cause, or the visible problem versus the real problem. Do not prefer one sentence construction. Checklist: explicit conflict; both sides concrete; no vague mood framing.",
    choice:
      "Open with two real alternatives/decision. Good: Either ask for a clear answer or stop carrying the uncertainty. Reject generic choice language. Checklist: actionable alternatives.",
    social_cue:
      "Editorial intent: begin with a specific observable signal from another person or group that creates a clear question, tension, or decision. Cue categories include a short or changed message, unusual tone, pause or silence, delayed response, last-minute invitation, changed plan, look, reaction, omission, or interruption. Do not prescribe a preferred determiner, noun, or sentence pattern. Reject vague social situation. Checklist: cue in first sentence.",
    action_underway:
      "Editorial intent: show that movement has already begun. The movement may be emotional, behavioral, relational, practical, or a decision taking shape. Do not prefer one sentence construction. Checklist: action already happening; present-perfect or active present; no hypothetical readiness.",
    contrast:
      "Open with an explicit outward/reality contrast. Good: You look calm, but one unfair detail is getting under your skin. Reject generic conflict. Checklist: but/while/although/yet and two specifics.",
    concrete_consequence:
      "Editorial intent: show a concrete cause already producing a practical effect. The cause may be a promise, assumption, delay, unfinished task, missing answer, expectation, favor, or agreement. Do not prefer one sentence construction. Checklist: named cause; named consequence; direct causal relationship.",
  };
  return recipes[family];
}

export type SkyLedBatchRead = { id: string; read: string };
export type SkyLedBatchDiversityFinding = {
  ids: string[];
  reasons: string[];
  distinctivePhrase?: string;
};

const TIME_OF_DAY_SCAFFOLDING =
  /\b(?:morning|afternoon|evening|tonight|later in the day|as the day goes on|by the end of the day)\b/i;
const OBSERVED_DAY_PROGRESSION_TEMPLATE =
  /\b(?:foggy|emotional fog|starts? soft|starts? a little softer|mood gets more direct|energy gets clearer)\b/i;
const WEEKDAY_SCAFFOLDING =
  /\b(?:sunday|monday|tuesday|wednesday|thursday|friday|saturday)\b/i;

export function validateSkyLedTemplateLanguage(read: string) {
  const findings: string[] = [];
  if (
    TIME_OF_DAY_SCAFFOLDING.test(read) ||
    /\b(?:by afternoon|by evening|later today|all day)\b/i.test(read)
  ) findings.push("time_of_day_scaffolding");
  if (WEEKDAY_SCAFFOLDING.test(read)) findings.push("weekday_led_scaffolding");
  if (OBSERVED_DAY_PROGRESSION_TEMPLATE.test(read)) {
    findings.push("observed_template_language");
  }
  return { accepted: findings.length === 0, findings };
}
const COMMON_LONG_PHRASES = new Set([
  "you may feel more than",
  "may feel more than",
  "before you make a decision",
  "say what you need to",
  "give yourself time to think",
]);

/**
 * Deterministic post-generation audit for one full batch. It never changes a
 * draft and therefore cannot bias the writer by generation order. The caller
 * may selectively regenerate only the later member of each finding, using the
 * same packet/proposition and requesting new language and structure.
 */
export function auditSkyLedBatchDiversity(reads: SkyLedBatchRead[]) {
  const findings: SkyLedBatchDiversityFinding[] = [];
  for (const item of reads) {
    const reasons: string[] = [];
    if (TIME_OF_DAY_SCAFFOLDING.test(item.read)) {
      reasons.push("time_of_day_scaffolding");
    }
    if (OBSERVED_DAY_PROGRESSION_TEMPLATE.test(item.read)) {
      reasons.push("observed_soft_foggy_direct_action_template");
    }
    if (reasons.length) findings.push({ ids: [item.id], reasons });
  }

  for (let left = 0; left < reads.length; left++) {
    for (let right = left + 1; right < reads.length; right++) {
      const comparison = compareSkyLedBatchReads(
        reads[left].read,
        reads[right].read,
      );
      if (comparison.reasons.length) {
        findings.push({
          ids: [reads[left].id, reads[right].id],
          reasons: comparison.reasons,
          ...(comparison.distinctivePhrase
            ? { distinctivePhrase: comparison.distinctivePhrase }
            : {}),
        });
      }
    }
  }
  return { accepted: findings.length === 0, findings };
}

/** Select only the later member of each pair; never alter the earlier draft. */
export function selectSkyLedBatchRewriteCandidates(reads: SkyLedBatchRead[]) {
  const audit = auditSkyLedBatchDiversity(reads);
  const candidates = new Set<string>();
  for (const finding of audit.findings) {
    candidates.add(finding.ids.at(-1)!);
  }
  return { audit, candidateIds: [...candidates] };
}

function compareSkyLedBatchReads(left: string, right: string) {
  const leftSentences = skyLedSentences(left);
  const rightSentences = skyLedSentences(right);
  const reasons: string[] = [];
  const openingSimilar =
    sentenceSimilarity(leftSentences[0], rightSentences[0]) >= 0.72 &&
    sentenceShape(leftSentences[0]) === sentenceShape(rightSentences[0]);
  const transitionSimilar = hasDayProgressionTransition(left) &&
    hasDayProgressionTransition(right);
  const closingSimilar =
    sentenceSimilarity(leftSentences.at(-1), rightSentences.at(-1)) >= 0.68 &&
    closingAction(leftSentences.at(-1)) ===
      closingAction(rightSentences.at(-1));
  const distinctivePhrase = sharedDistinctivePhrase(left, right);

  if (distinctivePhrase) reasons.push("distinctive_repeated_phrase");
  if (openingSimilar) reasons.push("similar_opening_structure");
  if (transitionSimilar) reasons.push("shared_day_progression_transition");
  if (closingSimilar) reasons.push("similar_closing_action");

  // A copied distinctive phrase is sufficient. Otherwise require at least two
  // independent structural signals before flagging a pair for review.
  return {
    reasons: distinctivePhrase || reasons.length >= 2 ? reasons : [],
    distinctivePhrase: distinctivePhrase ?? undefined,
  };
}

function normalizeBatchRead(value: string) {
  return value.toLowerCase().replace(/[’']/g, "").replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ").trim();
}

function skyLedSentences(value: string) {
  return value.split(/(?<=[.!?])\s+/).map((item) => item.trim()).filter(
    Boolean,
  );
}

function contentWords(value?: string) {
  return new Set(
    normalizeBatchRead(value ?? "").split(" ").filter((word) =>
      word.length > 3 &&
      ![
        "that",
        "this",
        "with",
        "from",
        "your",
        "have",
        "will",
        "more",
        "than",
        "they",
        "them",
      ].includes(word)
    ),
  );
}

function sentenceSimilarity(left?: string, right?: string) {
  const leftWords = contentWords(left);
  const rightWords = contentWords(right);
  const union = new Set([...leftWords, ...rightWords]);
  return union.size === 0
    ? 0
    : [...leftWords].filter((word) => rightWords.has(word)).length / union.size;
}

function sentenceShape(value?: string) {
  const normalized = normalizeBatchRead(value ?? "");
  if (
    /^(?:sunday|monday|tuesday|wednesday|thursday|friday|saturday) starts?\b/
      .test(normalized)
  ) return "day_starts";
  if (/^(?:a |an |someone |you )/.test(normalized)) {
    return normalized.split(" ").slice(0, 2).join(" ");
  }
  return normalized.split(" ").slice(0, 3).join(" ");
}

function hasDayProgressionTransition(value: string) {
  return /\b(?:by the afternoon|by afternoon|later in the day|as the day goes on)\b/i
    .test(value);
}

function closingAction(value?: string) {
  return normalizeBatchRead(value ?? "").split(" ").find((word) =>
    ["ask", "say", "send", "name", "make", "choose", "tell", "decide"].includes(
      word,
    )
  ) ?? "";
}

function sharedDistinctivePhrase(left: string, right: string) {
  const phrases = new Set<string>();
  const leftWords = normalizeBatchRead(left).split(" ").filter(Boolean);
  for (let index = 0; index <= leftWords.length - 6; index++) {
    const phrase = leftWords.slice(index, index + 6).join(" ");
    if (!isCommonLongPhrase(phrase)) phrases.add(phrase);
  }
  const rightWords = normalizeBatchRead(right).split(" ").filter(Boolean);
  for (let index = 0; index <= rightWords.length - 6; index++) {
    const phrase = rightWords.slice(index, index + 6).join(" ");
    if (phrases.has(phrase) && !isCommonLongPhrase(phrase)) return phrase;
  }
  return null;
}

function isCommonLongPhrase(phrase: string) {
  return [...COMMON_LONG_PHRASES].some((common) =>
    phrase === common || phrase.includes(common) ||
    common.startsWith(`${phrase} `)
  );
}

const REST_CLOSING =
  /\b(rest|recover|recovery|restoration|restore|self-care|wellbeing|well-being|solitude|ritual|hydrate|hydration|music|water|sleep|slow(?:ing)? down|let that be enough|act of care)\b/i;
const ENDING_CATEGORY_PATTERNS: Array<[SkyLedEndingCategory, RegExp]> = [
  ["Rest / Recovery", REST_CLOSING],
  [
    "Communicate",
    /\b(say|tell|ask|answer|conversation|talk|speak|name what)\b/i,
  ],
  ["Decide", /\b(decide|choose|commit|make the call|settle on)\b/i],
  ["Act", /\b(act|start|send|do it|move forward|take the step)\b/i],
  ["Wait", /\b(wait|give it time|pause|hold off|not yet)\b/i],
  ["Observe", /\b(notice|watch|observe|pay attention|look for)\b/i],
  ["Connect", /\b(friend|partner|together|reach out|connection|company)\b/i],
  ["Create", /\b(make|create|write|design|imagine|build)\b/i],
  ["Organize", /\b(plan|organize|sort|schedule|finish|practical)\b/i],
  ["Release", /\b(release|let go|stop carrying|leave behind)\b/i],
  ["Explore", /\b(explore|try|experiment|curious|new)\b/i],
];

function closingParagraph(read: string) {
  return read.trim().split(/\n\s*\n/).at(-1)?.trim() ?? "";
}

function normalizedClosing(read: string) {
  return closingParagraph(read).toLowerCase().replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ").trim();
}

export function classifySkyLedEnding(read: string): SkyLedEndingCategory {
  const closing = closingParagraph(read);
  return ENDING_CATEGORY_PATTERNS.find(([, pattern]) => pattern.test(closing))
    ?.[0] ?? "Other";
}

export function restIsMateriallyPrimary(
  packet: ReturnType<typeof buildSkyLedProductionPacket>,
) {
  return packet.westernHouseAndAspectReasoning.activatedLifeArea ===
    "restoration";
}

/**
 * Editorial-only diagnostics. These flags never alter a provider result or
 * publication state; they make a repeated closing visible for review.
 */
export function validateSkyLedEndingDiversity(args: {
  packet: ReturnType<typeof buildSkyLedProductionPacket>;
  read: string;
  recentReads?: SkyLedRecentRead[];
  openingFamily?: SkyLedOpeningFamily;
}) {
  const category = classifySkyLedEnding(args.read);
  const closing = normalizedClosing(args.read);
  const recent = (args.recentReads ?? []).slice(-5);
  const recentCategories = recent.map((item) =>
    classifySkyLedEnding(item.read)
  );
  const matchingCategoryCount =
    recentCategories.filter((item) => item === category).length;
  const repeatedPhrases = [
    /\btonight\b/i,
    /\bchoose rest\b/i,
    /\brestoration over performance\b/i,
    /\bmake room for rest\b/i,
    /\bone small act of care\b/i,
    /\bmusic,? water,? solitude\b/i,
    /\blet that be enough\b/i,
  ].filter((pattern) => pattern.test(closing)).map((pattern) => pattern.source);
  const nearDuplicate = recent.some((item) => {
    const prior = normalizedClosing(item.read);
    if (!prior || !closing) return false;
    return prior === closing ||
      (prior.length > 36 && closing.length > 36 &&
        (prior.includes(closing) || closing.includes(prior)));
  });
  const findings: string[] = [];
  if (matchingCategoryCount >= 2) findings.push("repeated_ending_category");
  if (nearDuplicate) findings.push("near_duplicate_closing");
  if (repeatedPhrases.length) findings.push("reused_closing_phrase");
  if (category === "Rest / Recovery" && !restIsMateriallyPrimary(args.packet)) {
    findings.push("rest_closing_not_primary_sky_theme");
  }
  return {
    accepted: true,
    flagged: findings.length > 0,
    findings,
    category,
    recentCategories,
    repeatedPhrases,
    restMateriallyPrimary: restIsMateriallyPrimary(args.packet),
  };
}

export function skyLedWriterPrompt(
  packet: ReturnType<typeof buildSkyLedProductionPacket>,
  recentReads: SkyLedRecentRead[] = [],
  retryReasons: string[] = [],
  openingFamily?: SkyLedOpeningFamily,
) {
  return [
    `Write today’s horoscope for someone who is a ${packet.identityPair.westernSign} born in the Year of the ${packet.identityPair.chineseSign}. Use the supplied identity signature and astrological sky. Return only {"read":"..."}.`,
    "Write one natural, conversational observation. Start with the strongest recognizable behavior today, not a personality report. The canonical proposition is source material: preserve its meaning without copying its objects or wording. Translate astrology into ordinary human terms; do not explain houses, aspects, or sign mechanics.",
    "The first sentence must reach the point at once. Never begin with Today, You may, Maybe, When, Something, or Part of you. Keep the outside situation open; do not invent messages, meetings, jobs, purchases, family roles, or scenes. Do not give advice or end with a task.",
    "Do not organize the horoscope around the progression of the day. Never mention a weekday, date, morning, afternoon, evening, tonight, later today, later in the day, as the day goes on, by afternoon, by evening, or an equivalent time transition.",
    "PROHIBITED TEMPLATE EXAMPLES — never copy or paraphrase: Sunday starts…, August 2 starts…, The day begins…, Things feel foggy…, The energy starts soft…, Later in the day…, As the day goes on…, Your mood gets more direct…, The energy gets clearer….",
    "Open with a concrete present-tense tension, observation, choice, or behavior specific to the identity and supplied sky proposition. Develop one central idea naturally; never use a morning-to-afternoon transformation arc.",
    "OPENING DIVERSITY v2: Never begin with You may be tempted to, You may be carrying, You may be trying to, You may be ready to, A feeling you have been carrying, Say what you need plainly, Say what you can do, You do not have to, or an equivalent generic internal-state setup. You may begin with You only for a concrete observation or behavior, never as a vague feeling/intention scaffold.",
    "Prefer a concrete situation, direct observation, tension, choice, or social cue. Shape examples only, never copy: A group task has quietly become your responsibility. Someone is relying on your silence more than your agreement. The problem is not the extra work; it is that nobody asked. A vague reply is making too much room for guessing.",
    "Prefer specific everyday language over generic dramatic shorthand. When the supplied situation supports it, name the conversation, disagreement, invitation, offer, purchase, plan, commitment, work issue, family decision, change, or opportunity instead of reaching for a vague metaphor such as the room, a real decision, a new door, or the biggest answer. Do not invent specificity, and keep the astrology and Western/Eastern identity interaction visible.",
    "Required structural example: You may be reading too much into a small change in someone’s tone. Ask the direct question instead of building a whole story around it. The answer will give you more to work with than another hour of guessing.",
    "The preceding prohibited template examples are rejection examples only, never output material.",
    openingFamily
      ? `Assigned opening family: ${openingFamily}. Use this exact recipe only: ${
        openingFamilyRecipe(openingFamily)
      }`
      : "",
    "The strongest day-specific astrological proposition must drive the ending. The last paragraph should feel earned by the day’s astrology, not like a reusable horoscope ending.",
    "Do not default to rest, recovery, self-care, restoration, solitude, a soothing nighttime ritual, hydration, music, sleep, or slowing down as the closing. Use those only when they are one of the strongest specific themes in the supplied astrology packet.",
    "Time-of-day framing such as ‘Tonight’ is optional, never expected. The read may end with a direct action, decision, conversation, boundary, risk, pause, observation, social move, practical task, creative move, or no explicit instruction. Do not force a lesson or a tidy conclusion.",
    "Avoid corporate, coaching, therapy, mystical, or textbook language. Avoid phrases such as ‘Your gift is graceful adjustment,’ ‘choose restoration over performance,’ ‘one deliberate act of care,’ or ‘your deeper power lies in.’ Prefer direct, current language a person could actually say to a friend.",
    "WRITING LEVEL: Write so a smart 13–14 year old can understand every sentence on the first read. Use short, clear sentences and everyday words. Write like a trusted older sibling or friend: natural, warm, direct, and modern.",
    "If an idea can be said more simply, always choose the simpler version. Keep each paragraph to one clear idea. Do not use abstract or poetic wording when a direct explanation works. The reader should never need to reread a sentence.",
    "Prefer language such as: tell someone, say what you need, feel worn out, take a break, slow down, pay attention, be honest, stay calm, think before you answer, and do something that helps you recharge.",
    "Avoid formal, corporate, therapy, or astrology-report language. Never use: inform your choices, graceful adjustment, infer your needs, restoration, performance, obligation, direct exchange, emotionally meaningful, wellbeing, culminating, embody, navigate, facilitate, lean into, honor your feelings, allow yourself, hold space, or energetic shift.",
    "Before returning the horoscope, silently rewrite any sentence that sounds formal, literary, like therapy language, like corporate advice, uses a word a typical 8th grader may not understand, contains more than one complicated idea, or would feel unnatural in a text message or Instagram caption.",
    "",
    "Supplied identity signature and astrological sky:",
    JSON.stringify(packet),
    retryReasons.length
      ? `Rewrite the previous draft with different language and structure only. Preserve the supplied identity and sky meaning. The prior draft failed: ${
        retryReasons.join(", ")
      }. ${
        retryReasons.includes("plain_language_overlong_sentence")
          ? "Use shorter sentences and split long ideas naturally."
          : ""
      } ${
        openingFamily
          ? `Keep the assigned ${openingFamily} family and satisfy its exact checklist: ${
            openingFamilyRecipe(openingFamily)
          }`
          : ""
      }`
      : "",
    recentReads.length
      ? [
        "",
        "Recent endings for this same identity (avoid their category, phrase, and cadence unless today’s packet materially requires it):",
        ...recentReads.slice(-5).map((item) =>
          `- ${item.ritualDate}: [${classifySkyLedEnding(item.read)}] ${
            closingParagraph(item.read)
          }`
        ),
      ].join("\n")
      : "",
  ].join("\n");
}

function outputText(payload: ProviderPayload) {
  const nested = (Array.isArray(payload.output) ? payload.output : []).flatMap(
    (item) =>
      item && typeof item === "object" &&
        Array.isArray((item as ProviderPayload).content)
        ? (item as ProviderPayload).content as unknown[]
        : [],
  ).filter((part) =>
    part && typeof part === "object" &&
    (part as ProviderPayload).type === "output_text" &&
    typeof (part as ProviderPayload).text === "string"
  )
    .map((part) => String((part as ProviderPayload).text)).join("");
  return nested ||
    (typeof payload.output_text === "string" ? payload.output_text : "");
}

export async function generateSkyLedHoroscope(args: {
  apiKey: string;
  model: string;
  packet: ReturnType<typeof buildSkyLedProductionPacket>;
  recentReads?: SkyLedRecentRead[];
  openingFamily?: SkyLedOpeningFamily;
  fetchImpl?: typeof fetch;
  timeoutMs?: number;
  onTiming?: (event: Record<string, unknown>) => void;
}) {
  const fetchImpl = args.fetchImpl ?? fetch;
  const diagnostics: Array<Record<string, unknown>> = [];
  const maxAttempts = 3;
  const timeoutMs = args.timeoutMs ?? 90_000;
  let retryReasons: string[] = [];
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    let response: Response;
    const startedAt = performance.now();
    args.onTiming?.({ event: "request_start", attempt, timeoutMs });
    try {
      args.onTiming?.({ event: "request_sent", attempt });
      response = await fetchImpl("https://api.openai.com/v1/responses", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${args.apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: args.model,
          input: skyLedWriterPrompt(
            args.packet,
            args.recentReads,
            retryReasons,
            args.openingFamily,
          ),
          text: {
            format: {
              type: "json_schema",
              name: SKY_LED_PRODUCTION_CANDIDATE_V1,
              strict: true,
              schema: {
                type: "object",
                additionalProperties: false,
                properties: { read: { type: "string" } },
                required: ["read"],
              },
            },
          },
          max_output_tokens: 2000,
        }),
        signal: AbortSignal.timeout(timeoutMs),
      });
      args.onTiming?.({
        event: "first_byte_received",
        attempt,
        elapsedMs: Math.round(performance.now() - startedAt),
        httpStatus: response.status,
      });
    } catch (error) {
      args.onTiming?.({
        event: "request_error",
        attempt,
        elapsedMs: Math.round(performance.now() - startedAt),
        error: sanitizedError(error),
      });
      diagnostics.push({
        attempt,
        classification: "temporary_transport_failure",
        message: sanitizedError(error),
      });
      if (attempt < maxAttempts) {
        await backoff(attempt);
        continue;
      }
      return failedProviderResult(
        diagnostics,
        attempt,
        "temporary_transport_exhausted",
      );
    }

    const payload = await response.json().catch(() => ({})) as ProviderPayload;
    args.onTiming?.({
      event: "response_completed",
      attempt,
      elapsedMs: Math.round(performance.now() - startedAt),
      httpStatus: response.status,
    });
    const errorCode = providerErrorCode(payload);
    const retryable = retryableProviderResponse(response.status, errorCode);
    const diagnostic = {
      attempt,
      httpStatus: response.status,
      requestId: response.headers.get("x-request-id"),
      responseId: typeof payload.id === "string" ? payload.id : null,
      responseStatus: typeof payload.status === "string"
        ? payload.status
        : null,
      errorCode,
      incompleteDetails: payload.incomplete_details ?? null,
      usage: payload.usage ?? null,
    };
    diagnostics.push(diagnostic);

    if (!response.ok) {
      if (retryable && attempt < maxAttempts) {
        args.onTiming?.({
          event: "retry",
          attempt,
          reason: `http_${response.status}`,
        });
        await backoff(attempt);
        continue;
      }
      return failedProviderResult(
        diagnostics,
        attempt,
        retryable
          ? `provider_http_${response.status}_exhausted`
          : `provider_http_${response.status}_${errorCode ?? "terminal"}`,
        diagnostic,
      );
    }
    if (payload.status !== "completed") {
      return failedProviderResult(
        diagnostics,
        attempt,
        `provider_${String(payload.status ?? "unknown")}`,
        diagnostic,
      );
    }

    const raw = outputText(payload);
    if (!raw.trim()) {
      return failedProviderResult(
        diagnostics,
        attempt,
        "empty_provider_output",
        diagnostic,
      );
    }
    try {
      const parsed = JSON.parse(raw);
      if (
        !parsed || Object.keys(parsed).length !== 1 ||
        typeof parsed.read !== "string" || !parsed.read.trim()
      ) {
        return failedProviderResult(
          diagnostics,
          attempt,
          "invalid_read_schema",
          diagnostic,
        );
      }
      const voiceValidation = validateSkyLedPlainLanguage(parsed.read);
      if (!voiceValidation.accepted) {
        retryReasons = [
          ...new Set([...retryReasons, ...voiceValidation.findings]),
        ];
        diagnostics.push({
          ...diagnostic,
          classification: "plain_language_validation",
          findings: voiceValidation.findings,
        });
        if (attempt < maxAttempts) {
          await backoff(attempt);
          continue;
        }
        return failedProviderResult(
          diagnostics,
          attempt,
          "plain_language_validation_exhausted",
          diagnostic,
        );
      }
      const templateValidation = validateSkyLedTemplateLanguage(parsed.read);
      if (!templateValidation.accepted) {
        retryReasons = templateValidation.findings;
        diagnostics.push({
          ...diagnostic,
          classification: "template_language_validation",
          findings: templateValidation.findings,
          rejectedRead: parsed.read,
        });
        args.onTiming?.({
          event: "retry",
          attempt,
          reason: "template_language_validation",
        });
        if (attempt < maxAttempts) {
          await backoff(attempt);
          continue;
        }
        return failedProviderResult(
          diagnostics,
          attempt,
          "template_language_validation_exhausted",
          diagnostic,
        );
      }
      if (args.openingFamily) {
        const familyValidation = validateSkyLedOpeningFamily(
          parsed.read,
          args.openingFamily,
        );
        if (!familyValidation.accepted) {
          retryReasons = familyValidation.findings;
          diagnostics.push({
            ...diagnostic,
            classification: "opening_family_validation",
            findings: familyValidation.findings,
            familyValidation,
            assignedOpeningFamily: args.openingFamily,
            openingSentence: parsed.read.split(/(?<=[.!?])\s+/)[0] ?? "",
            rejectedRead: parsed.read,
          });
          if (attempt < maxAttempts) {
            await backoff(attempt);
            continue;
          }
          return failedProviderResult(
            diagnostics,
            attempt,
            "opening_family_validation_exhausted",
            diagnostic,
          );
        }
      }
      return {
        output: { read: parsed.read },
        rawOutput: { read: parsed.read },
        provider: {
          ...diagnostic,
          attempts: attempt,
          diagnostics,
          terminalReason: null,
        },
      };
    } catch {
      return failedProviderResult(
        diagnostics,
        attempt,
        "malformed_provider_output",
        diagnostic,
      );
    }
  }
  return failedProviderResult(diagnostics, maxAttempts, "unreachable");
}

export function skyLedCompressionEditorPrompt(args: {
  rawRead: string;
  packet: ReturnType<typeof buildSkyLedProductionPacket> & Record<string, unknown>;
  recentReads: SkyLedRecentRead[];
}) {
  return [
    "Edit the supplied Today’s Lens by removing sentences or clauses that explain what the writing has already made clear.",
    "Keep the strongest opening, natural human voice, supported astrology, and the current date’s distinct canonical-proposition meaning. Prefer deletion over rewriting. Do not add ideas, settings, motives, fears, advice, metaphors, astrology, sign explanations, or identity claims.",
    "When editing, prefer the concrete situation supported by the packet over generic dramatic shorthand such as the room, a real decision, a new door, or the biggest answer. Do not invent specificity or remove useful astrology or Western/Eastern identity explanation.",
    "Do not change the canonical proposition, remove the only day-specific astrology connection, flatten this into a generic identity story, or make the language polished, poetic, mystical, therapeutic, corporate, or robotic. Every sentence must be clear to a typical 13-year-old. Return only {\"read\":\"...\"}.",
    "LOCKED PROVENANCE (not visible prose):",
    JSON.stringify(args.packet.canonicalPropositionControl ?? {}),
    "RAW WRITER OUTPUT (the only text you may edit):",
    JSON.stringify({ read: args.rawRead }),
    args.recentReads.length ? `RECENT READS (preserve today's distinct story):\n${args.recentReads.slice(-7).map((item) => `- ${item.ritualDate}: ${item.read}`).join("\n")}` : "",
  ].join("\n");
}

export async function compressSkyLedHoroscope(args: {
  apiKey: string;
  model: string;
  rawRead: string;
  packet: ReturnType<typeof buildSkyLedProductionPacket> & Record<string, unknown>;
  recentReads?: SkyLedRecentRead[];
  fetchImpl?: typeof fetch;
}) {
  const response = await (args.fetchImpl ?? fetch)("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: { Authorization: `Bearer ${args.apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: args.model,
      input: skyLedCompressionEditorPrompt({ rawRead: args.rawRead, packet: args.packet, recentReads: args.recentReads ?? [] }),
      text: { format: { type: "json_schema", name: SKY_LED_COMPRESSION_EDITOR_VERSION, strict: true, schema: { type: "object", additionalProperties: false, properties: { read: { type: "string" } }, required: ["read"] } } },
      max_output_tokens: 2000,
    }),
    signal: AbortSignal.timeout(90_000),
  });
  const payload = await response.json().catch(() => ({})) as ProviderPayload;
  const raw = outputText(payload);
  try {
    const parsed = JSON.parse(raw);
    if (!response.ok || !parsed || Object.keys(parsed).length !== 1 || typeof parsed.read !== "string" || !parsed.read.trim()) {
      return { output: null, provider: { attempts: 1, httpStatus: response.status, terminalReason: "invalid_editor_output" } };
    }
    return { output: { read: parsed.read }, provider: { attempts: 1, httpStatus: response.status, terminalReason: null } };
  } catch {
    return { output: null, provider: { attempts: 1, httpStatus: response.status, terminalReason: "malformed_editor_output" } };
  }
}

export function validateSkyLedCompression(args: { rawRead: string; editedRead: string }) {
  const findings: string[] = [];
  const rawOpening = skyLedSentences(args.rawRead)[0]?.toLowerCase();
  const editedOpening = skyLedSentences(args.editedRead)[0]?.toLowerCase();
  if (!editedOpening || editedOpening !== rawOpening) findings.push("editor_changed_strongest_opening");
  if (args.editedRead.trim().length < 80) findings.push("editor_flattened_read");
  if (args.editedRead.length > args.rawRead.length + 24) findings.push("editor_added_material");
  return { accepted: findings.length === 0, findings };
}

/** Narrow safety gate only. This intentionally contains no style, voice,
 * structure, life-area, or phrase-quality rules. */
export function validateSkyLedSafety(read: string) {
  const findings: string[] = [];
  const checks: Array<[string, RegExp]> = [
    ["self_harm_instruction", /\b(kill|hurt) yourself\b/i],
    [
      "medical_instruction",
      /\b(stop|skip|double) (your )?(medication|dose|prescription)\b/i,
    ],
    ["financial_guarantee", /\bguaranteed (profit|return|investment)\b/i],
    [
      "violent_instruction",
      /\b(attack|assault|shoot|stab) (them|someone|him|her)\b/i,
    ],
  ];
  for (const [code, pattern] of checks) {
    if (pattern.test(read)) findings.push(code);
  }
  return { accepted: findings.length === 0, findings };
}

/** Keeps the release writer in the requested plain, first-read voice. */
export function validateSkyLedPlainLanguage(read: string) {
  const findings: string[] = [];
  const bannedPhrases = [
    "inform your choices",
    "graceful adjustment",
    "infer your needs",
    "restoration",
    "performance",
    "obligation",
    "direct exchange",
    "emotionally meaningful",
    "wellbeing",
    "culminating",
    "embody",
    "navigate",
    "facilitate",
    "lean into",
    "honor your feelings",
    "allow yourself",
    "hold space",
    "energetic shift",
  ];
  const normalized = read.toLowerCase();
  const banned = bannedPhrases.find((phrase) =>
    new RegExp(`\\b${escapeRegExp(phrase).replace(/\\ /g, "\\s+")}\\b`, "i")
      .test(normalized)
  );
  if (banned) findings.push(`plain_language_banned_phrase:${banned}`);

  const sentences = read.split(/(?<=[.!?])\s+/).map((value) => value.trim())
    .filter(Boolean);
  if (sentences.some((sentence) => wordCount(sentence) > 28)) {
    findings.push("plain_language_overlong_sentence");
  }
  return { accepted: findings.length === 0, findings };
}

function wordCount(value: string) {
  return value.trim().match(/\b[\p{L}\p{N}]+(?:[’'][\p{L}\p{N}]+)?\b/gu)
    ?.length ?? 0;
}

function escapeRegExp(value: string) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function providerErrorCode(payload: ProviderPayload) {
  const error = payload.error;
  if (!error || typeof error !== "object") return null;
  const code = (error as ProviderPayload).code ??
    (error as ProviderPayload).type;
  return typeof code === "string" ? code : null;
}

function retryableProviderResponse(status: number, code: string | null) {
  if (
    ["insufficient_quota", "billing_hard_limit_reached", "access_denied"]
      .includes(code ?? "")
  ) return false;
  return status === 408 || status === 409 || status === 429 || status >= 500;
}

function failedProviderResult(
  diagnostics: Array<Record<string, unknown>>,
  attempts: number,
  terminalReason: string,
  latest: Record<string, unknown> = {},
) {
  return {
    output: null,
    provider: {
      ...latest,
      attempts,
      diagnostics,
      terminalReason,
    },
  };
}

function sanitizedError(error: unknown) {
  return (error instanceof Error ? error.message : String(error)).slice(0, 300);
}

async function backoff(attempt: number) {
  const jitter = Math.floor(Math.random() * 150);
  await new Promise((resolve) =>
    setTimeout(resolve, 500 * 2 ** (attempt - 1) + jitter)
  );
}
