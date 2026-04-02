import type { DailyFateResponse } from './types';

export function isValidDailyFateResponse(obj: any): obj is DailyFateResponse {
  if (!obj || typeof obj !== 'object') return false;
  if (typeof obj.summary !== 'string') return false;
  if (!Array.isArray(obj.guidance)) return false;
  if (!obj.metadata || typeof obj.metadata.dateISO !== 'string') return false;
  return true;
}
