/**
 * Types for daily state management
 * These match the actual data shapes used in lib/storage/dailyStateService.ts
 */

export interface UserProfile {
  id: string;
  name?: string;
  westernSign?: string;
  chineseSign?: string;
  birthdate?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface DailyRitualRecord {
  date: string; // YYYY-MM-DD
  westernSign: string;
  chineseSign: string;
  revealed: boolean;
  completed: boolean;
  content?: Record<string, any> | string;
  source?: 'ai' | 'fallback' | 'import';
  generatedAt?: string;
  version?: number;
  revealedAt?: string;
  completedAt?: string;
  headline?: string;
}

export interface StreakState {
  currentStreak: number; // Days streaked
  longestStreak: number;
  lastCompletedDate?: string; // YYYY-MM-DD
  updatedAt?: string;
}

export interface DailyStateSummary {
  todayDate: string;
  todayRitual?: DailyRitualRecord | null;
  revealed: boolean;
  completed: boolean;
  canReveal: boolean;
  canComplete: boolean;
  streak: {
    current: number;
    longest: number;
    lastCompletedDate?: string;
  };
  message?: string;
}
