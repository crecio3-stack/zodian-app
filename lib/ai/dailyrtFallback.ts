import type { DailyRitualResponse } from './types';

export function generateDailyRitualFallback(params: {
  westernSign: string;
  chineseSign: string;
  dateISO: string;
  weekday: string;
}): DailyRitualResponse {
  const { westernSign, chineseSign, dateISO, weekday } = params;
  const title = `Simple ${westernSign} Ritual for ${weekday}`;
  return {
    id: `fallback-${dateISO}-${westernSign}-${chineseSign}`,
    title,
    subtitle: `A short grounding ritual for ${westernSign} (${chineseSign})`,
    mood: 'grounding',
    estimatedDurationMinutes: 12,
    steps: [
      { title: 'Breathe', description: 'Five deep, slow breaths to center your attention.', durationMinutes: 2 },
      { title: 'Set Intention', description: 'Silently set a clear, single intention for the day.', durationMinutes: 2 },
      { title: 'Move', description: 'Stand and stretch or walk for a short loop to energize your body.', durationMinutes: 4 },
      { title: 'Gratitude', description: 'Name one thing you appreciate about today.', durationMinutes: 1 },
      { title: 'Micro-ritual', description: 'Carry a talisman or repeat a short phrase that connects you to your sign.', durationMinutes: 3 },
    ],
    metadata: { westernSign, chineseSign, dateISO, weekday },
  };
}
