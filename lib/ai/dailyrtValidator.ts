import type { DailyRitualResponse } from './types';

export function isValidDailyRitualResponse(obj: any): obj is DailyRitualResponse {
  if (!obj || typeof obj !== 'object') return false;
  if (typeof obj.title !== 'string' || obj.title.length === 0) return false;
  if (!Array.isArray(obj.steps)) return false;
  if (!obj.metadata || typeof obj.metadata !== 'object') return false;
  const m = obj.metadata;
  if (typeof m.westernSign !== 'string' || typeof m.chineseSign !== 'string' || typeof m.dateISO !== 'string' || typeof m.weekday !== 'string') return false;

  // Validate steps
  if (obj.steps.length === 0) return false;
  for (const s of obj.steps) {
    if (!s || typeof s !== 'object') return false;
    if (typeof s.title !== 'string' || typeof s.description !== 'string') return false;
    if (s.durationMinutes !== undefined && typeof s.durationMinutes !== 'number') return false;
  }

  return true;
}
