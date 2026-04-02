import type { DailyRitualResponse } from '../../types/dailyRitual';

export function isValidDailyRitualResponse(
  value: unknown
): value is DailyRitualResponse {
  if (!value || typeof value !== 'object') return false;

  const obj = value as Record<string, unknown>;

  const requiredKeys: Array<keyof DailyRitualResponse> = [
    'headline',
    'coreMessage',
    'love',
    'energy',
    'advice',
    'bluntInsight',
    'focusWord',
    'focusSupport',
  ];

  return requiredKeys.every(
    (key) => typeof obj[key] === 'string' && obj[key].trim().length > 0
  );
}