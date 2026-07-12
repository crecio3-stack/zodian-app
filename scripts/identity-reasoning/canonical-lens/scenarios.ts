import type { DailySymbolicContext, LensArena, LensTone } from "./types.ts";

export interface MatchedScenario extends DailySymbolicContext {
  id: string;
}

export const MATCHED_SCENARIOS: MatchedScenario[] = [
  {
    id: "work-speaking-up",
    date: "2026-07-11",
    symbolicContext:
      "A quiet signal asks to be named before the group moves on.",
    humanTension: "speaking up vs waiting",
    arena: "work",
    emotionalTone: "clear-eyed",
    seed: "lens-01",
  },
  {
    id: "love-trust",
    date: "2026-07-12",
    symbolicContext: "A warm exchange leaves one practical detail unresolved.",
    humanTension: "trust vs caution",
    arena: "love",
    emotionalTone: "tender",
    seed: "lens-02",
  },
  {
    id: "home-change",
    date: "2026-07-13",
    symbolicContext:
      "A familiar arrangement has started asking for more than it used to.",
    humanTension: "stability vs change",
    arena: "home",
    emotionalTone: "steady",
    seed: "lens-03",
  },
  {
    id: "friends-harmony",
    date: "2026-07-14",
    symbolicContext:
      "A friend wants peace before the honest part has been said.",
    humanTension: "harmony vs honesty",
    arena: "friends",
    emotionalTone: "tender",
    seed: "lens-04",
  },
  {
    id: "money-comfort",
    date: "2026-07-15",
    symbolicContext:
      "A small purchase promises relief while a larger priority waits.",
    humanTension: "comfort vs restraint",
    arena: "money",
    emotionalTone: "wry",
    seed: "lens-05",
  },
  {
    id: "rest-responsibility",
    date: "2026-07-16",
    symbolicContext:
      "The useful thing to do is not the thing everyone expects from you.",
    humanTension: "responsibility vs autonomy",
    arena: "rest",
    emotionalTone: "restless",
    seed: "lens-06",
  },
  {
    id: "confidence-recognition",
    date: "2026-07-17",
    symbolicContext:
      "Someone notices work you were prepared to let speak for itself.",
    humanTension: "recognition vs humility",
    arena: "confidence",
    emotionalTone: "encouraging",
    seed: "lens-07",
  },
  {
    id: "routine-freedom",
    date: "2026-07-18",
    symbolicContext:
      "A reliable routine has become harder to inhabit without irritation.",
    humanTension: "consistency vs freedom",
    arena: "routine",
    emotionalTone: "restless",
    seed: "lens-08",
  },
  {
    id: "conflict-directness",
    date: "2026-07-19",
    symbolicContext:
      "A small disagreement is carrying more weight than its words suggest.",
    humanTension: "directness vs patience",
    arena: "conflict",
    emotionalTone: "clear-eyed",
    seed: "lens-09",
  },
  {
    id: "opportunity-expansion",
    date: "2026-07-20",
    symbolicContext:
      "A worthwhile opening would require leaving a proven position.",
    humanTension: "security vs expansion",
    arena: "opportunity",
    emotionalTone: "encouraging",
    seed: "lens-10",
  },
];

export const ARENA_FALLBACK: Record<LensArena, string> = {
  work: "a meeting, handoff, or unfinished decision",
  love: "a message, invitation, or ordinary promise",
  home: "a room, errand, or household arrangement",
  friends: "a conversation that changes the shape of the evening",
  money: "a purchase, bill, or small financial tradeoff",
  rest: "an hour that could belong to someone else",
  confidence: "a compliment, result, or moment of visibility",
  routine: "the familiar plan that no longer feels neutral",
  conflict: "a pause, reply, or sentence that lands differently than intended",
  opportunity: "an invitation whose cost is real but not necessarily final",
};
