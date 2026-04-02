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

export interface AiError {
  message: string;
  code?: string | number;
}
