export type ISODate = string;

export interface RitualStep {
  title: string;
  description: string;
  durationMinutes?: number;
}

export interface DailyRitualResponse {
  id?: string; // optional unique id
  title: string;
  subtitle?: string;
  mood?: string;
  estimatedDurationMinutes?: number;
  steps: RitualStep[];
  metadata: {
    westernSign: string;
    chineseSign: string;
    dateISO: ISODate;
    weekday: string;
  };
}

export interface ArchetypeResponse {
  id?: string;
  archetypeName: string;
  description: string;
  rituals?: RitualStep[];
  practicalTips?: string[];
  metadata?: {
    westernSign?: string;
    chineseSign?: string;
  };
}

export interface CompatibilityResponse {
  id?: string;
  pair: {
    left: string;
    right: string;
  };
  compatibilityScore: number;
  strengths: string[];
  challenges: string[];
  advice: string;
  metadata?: {
    generatedAt?: string;
  };
}

export interface DailyFateResponse {
  id?: string;
  summary: string;
  tone?: string;
  guidance: string[];
  metadata: {
    dateISO: ISODate;
    westernSign: string;
    chineseSign: string;
  };
}

export interface AiError {
  message: string;
  code?: string | number;
}
