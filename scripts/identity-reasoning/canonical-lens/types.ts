import type { CanonicalIdentityModel } from "../canonical/types.ts";

export type LensArena =
  | "work"
  | "love"
  | "home"
  | "friends"
  | "money"
  | "rest"
  | "confidence"
  | "routine"
  | "conflict"
  | "opportunity";
export type LensTone =
  | "steady"
  | "tender"
  | "clear-eyed"
  | "restless"
  | "encouraging"
  | "wry";

export interface DailySymbolicContext {
  date: string;
  symbolicContext: string;
  humanTension: string;
  arena: LensArena;
  emotionalTone: LensTone;
  dailyRole?: string;
  seed: string;
}

export interface CanonicalLensSelection {
  manifestationKey?: string;
  manifestationArena?: LensArena;
  activatedParadox: string;
  perception: string;
  decision: string;
  pressureOrGrowth: string;
  observableBehaviors: string[];
  arenaDetail: string;
}

export interface CanonicalLensContext {
  signPair: string;
  scenario: DailySymbolicContext;
  selected: CanonicalLensSelection;
}

export interface CanonicalLensReasoningPlan {
  activatedIdentityTension: string;
  primaryArena: LensArena;
  identitySpecificRole: string;
  startingAssumption: string;
  recognition: string;
  ordinaryLifeExpression: string;
  blindSpot: string;
  naturalMove: string;
  signInteraction: "useful" | "not_needed";
}

export interface CanonicalLens extends Record<string, string> {
  title: string;
  intro: string;
  pull_quote: string;
  deeper_read: string;
  watch_for: string;
  move: string;
}

// Backward-compatible alias for the existing development copy library.
export type TodayLensPayload = CanonicalLens;

export interface CanonicalLensGenerationResult {
  signPair: string;
  scenarioId: string;
  context: CanonicalLensContext;
  reasoning: CanonicalLensReasoningPlan;
  lens: CanonicalLens;
  validation: { accepted: boolean; reasons: string[] };
  retryCount: number;
}
