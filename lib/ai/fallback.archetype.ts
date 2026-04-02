import type { ArchetypeResponse } from './types';

export function generateArchetypeFallback(params: { westernSign?: string; chineseSign?: string }): ArchetypeResponse {
  const name = params.westernSign ? `${params.westernSign} Archetype` : 'Balanced Archetype';
  return {
    id: `fallback-archetype-${params.westernSign ?? 'none'}`,
    archetypeName: name,
    description: `A grounded archetype focused on balance and presence.`,
    rituals: [{ title: 'Morning breath', description: 'Three mindful breaths to begin your day', durationMinutes: 2 }],
    practicalTips: ['Prioritize sleep', 'Short daily rituals'],
    metadata: { westernSign: params.westernSign, chineseSign: params.chineseSign },
  };
}
