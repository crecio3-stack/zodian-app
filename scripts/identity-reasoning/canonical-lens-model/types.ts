import type {
  CanonicalLens,
  CanonicalLensContext,
  CanonicalLensReasoningPlan,
  DailySymbolicContext,
} from "../canonical-lens/types.ts";

export interface LensModelProvider {
  name: string;
  complete(
    prompt: string,
    attempt: number,
  ): Promise<{ raw: string; usage?: Record<string, unknown> }>;
}

export interface ModelWritingRequest {
  context: CanonicalLensContext;
  reasoning: CanonicalLensReasoningPlan;
  scenario: DailySymbolicContext;
}

export interface ModelWritingAttempt {
  attempt: number;
  rawResponse: string;
  parsedResponse: unknown | null;
  validation: { accepted: boolean; reasons: string[] };
  usage?: Record<string, unknown>;
}

export interface ModelWritingResult {
  provider: string;
  signPair: string;
  scenarioId: string;
  prompt: string;
  attempts: ModelWritingAttempt[];
  finalLens: CanonicalLens | null;
  accepted: boolean;
  retryCount: number;
  sourceTraceability: string[];
  modelConfig?: Record<string, unknown>;
}

export interface RubricScores {
  identitySpecificity: number;
  behavioralConcreteness: number;
  scenarioRelevance: number;
  canonicalGrounding: number;
  internalCoherence: number;
  fieldDifferentiation: number;
  contemporaryVoice: number;
  usefulness: number;
  nonPredictiveDiscipline: number;
  repetitionControl: number;
}
