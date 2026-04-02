import type { CompatibilityResponse } from './types';

export function generateCompatibilityFallback(left: { westernSign: string; chineseSign: string }, right: { westernSign: string; chineseSign: string }): CompatibilityResponse {
  return {
    id: `fallback-compat-${left.westernSign}-${right.westernSign}`,
    pair: { left: left.westernSign, right: right.westernSign },
    compatibilityScore: 70,
    strengths: ['Shared values', 'Complementary energy'],
    challenges: ['Different pacing', 'Occasional misunderstanding'],
    advice: 'Focus on communication and small rituals together.',
    metadata: { generatedAt: new Date().toISOString().slice(0, 10) },
  };
}
