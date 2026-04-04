import type { DailyRitualResponse } from '../../types/dailyRitual';
import { generateFallbackContent } from '../storage/dailyStateService';
import { generateWithOrchestration } from './orchestrator';
import {
    buildDailyRitualUserPrompt,
    DAILY_RITUAL_SYSTEM_PROMPT,
} from './prompts';
import { isValidDailyRitualResponse } from './validateDailyRitual';

type GenerateDailyRitualParams = {
  westernSign: string;
  chineseSign: string;
  dateISO: string;
  weekday: string;
};

const OPENAI_API_KEY =
  typeof globalThis !== 'undefined' &&
  typeof (globalThis as any).process !== 'undefined'
    ? (globalThis as any).process.env.OPENAI_API_KEY
    : undefined;

const BACKEND_ENDPOINT =
  (typeof globalThis !== 'undefined' &&
    typeof (globalThis as any).process !== 'undefined' &&
    (globalThis as any).process.env.ZODIAN_AI_ENDPOINT) ||
  undefined;

function toFallbackDailyRitual(params: GenerateDailyRitualParams): DailyRitualResponse {
  const fallback = generateFallbackContent({
    westernSign: params.westernSign,
    chineseSign: params.chineseSign,
    dateISO: params.dateISO,
  });

  return {
    headline: `${params.westernSign} x ${params.chineseSign}`,
    coreMessage: fallback.plain,
    love: 'Lead with clarity and warmth in one important conversation today.',
    energy: 'Steady and grounded if you keep your attention narrow.',
    advice: 'Pick one meaningful action and complete it before adding new tasks.',
    bluntInsight: 'Scattered attention is your only real blocker today.',
    focusWord: 'Alignment',
    focusSupport: 'Reduce noise, protect your energy, and follow through.',
  };
}

export async function generateDailyRitual(
  params: GenerateDailyRitualParams
): Promise<DailyRitualResponse> {
  const userPrompt = buildDailyRitualUserPrompt(params);

  // prefer a secure backend endpoint when configured
  const useBackend = Boolean(BACKEND_ENDPOINT);
  const endpoint = useBackend
    ? BACKEND_ENDPOINT!
    : OPENAI_API_KEY
    ? 'https://api.openai.com/v1/chat/completions'
    : undefined;

  // prepare body depending on target
  const body = useBackend
    ? { systemPrompt: DAILY_RITUAL_SYSTEM_PROMPT, userPrompt }
    : {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: DAILY_RITUAL_SYSTEM_PROMPT },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.8,
        max_tokens: 320,
      };

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (!useBackend && OPENAI_API_KEY) headers.Authorization = `Bearer ${OPENAI_API_KEY}`;

  if (!endpoint) {
    // no server and no key: return fallback immediately
    return toFallbackDailyRitual(params);
  }

  try {
    const ai = await generateWithOrchestration({ endpoint, body, headers }, { timeoutMs: 7000, retries: 2, allowFallback: true });
    // orchestration already returns a parsed and validated ritual shape
    const parsed = ai as any;

    if (!isValidDailyRitualResponse(parsed)) {
      throw new Error('AI responded with invalid shape');
    }

    return parsed as DailyRitualResponse;
  } catch (err) {
    // Telemetry hook
    try {
      const analytics = (globalThis as any)?.analytics;
      if (analytics?.track) {
        analytics.track('ai.generate.fallback', { error: String((err as any)?.message ?? err) });
      }
    } catch {}

    return toFallbackDailyRitual(params);
  }
}
