import type { DailyFateResponse } from './types';

export function generateDailyFateFallback(params: { westernSign: string; chineseSign: string; dateISO: string }): DailyFateResponse {
  return {
    id: `fallback-fate-${params.dateISO}-${params.westernSign}`,
    summary: `A calm day for ${params.westernSign}. Keep attention on small wins.`,
    tone: 'calm',
    guidance: ['Take three mindful breaths', 'Prioritize one meaningful task', 'Reach out to someone you trust'],
    metadata: { dateISO: params.dateISO, westernSign: params.westernSign, chineseSign: params.chineseSign },
  };
}
