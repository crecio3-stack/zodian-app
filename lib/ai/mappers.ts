import type { DailyRitualResponse } from './types';

// Map the AI DailyRitualResponse to the app's legacy reading model used in data/dailyRitual.getDailyRitual
export function mapDailyRitualToLegacy(ritual: DailyRitualResponse) {
  const headline = ritual.title;
  const coreMessage = ritual.subtitle ?? ritual.mood ?? (ritual.steps?.[0]?.description ?? 'A short ritual for your day.');

  const love = ritual.steps?.[0]?.description ?? 'Take a breath and notice how you show up.';
  const energy = ritual.steps?.[1]?.description ?? 'Move your body gently to align energy.';
  const advice = ritual.steps?.[2]?.description ?? 'Set a simple intention for the day.';
  const bluntInsight = ritual.steps?.[ritual.steps.length - 1]?.title ?? ritual.mood ?? 'Be present.';
  const focusWord = ritual.mood ?? ritual.title?.split(' ')[0] ?? 'Focus';
  const focusSupport = ritual.steps?.[0]?.title ? `Start with: ${ritual.steps[0].title}` : 'Practice a short grounding exercise.';

  return {
    headline,
    coreMessage,
    love,
    energy,
    advice,
    bluntInsight,
    focusWord,
    focusSupport,
  };
}
