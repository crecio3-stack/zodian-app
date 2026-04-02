// filepath: /Users/christianrecio/zodian/lib/ai/generateDailyRitual.ts
import type { DailyRitualResponse } from '../../types/dailyRitual';
import {
  buildDailyRitualUserPrompt,
  DAILY_RITUAL_SYSTEM_PROMPT,
} from './prompts';
import { isValidDailyRitualResponse } from './validateDailyRitual';
import { generateWithOrchestration } from './orchestrator';
import { generateFallbackContent } from '../storage/dailyStateService';

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
    const fallback = generateFallbackContent({ westernSign: params.westernSign, chineseSign: params.chineseSign, dateISO: params.dateISO });
    // @ts-ignore
    return { ...fallback.ritual, _meta: { fallback: true } } as DailyRitualResponse;
  }

  try {
    const ai = await generateWithOrchestration({ endpoint, body, headers }, { timeoutMs: 7000, retries: 2, allowFallback: true });

    // data might already be the parsed shape or contain raw content
    let parsed = ai as any;

    if (ai && typeof ai === 'object' && ai.raw && typeof ai.raw === 'string') {
      try {
        parsed = JSON.parse(ai.raw);
      } catch {}
    }

    if (!isValidDailyRitualResponse(parsed)) {
      throw new Error('AI responded with invalid shape');
    }

    return parsed as DailyRitualResponse;
  } catch (err) {
    // Telemetry hook
    try {
      // @ts-ignore
      if (globalThis?.analytics?.track) globalThis.analytics.track('ai.generate.fallback', { error: String(err?.message ?? err) });
    } catch {}

    // fallback content
    const fallback = generateFallbackContent({ westernSign: params.westernSign, chineseSign: params.chineseSign, dateISO: params.dateISO });
    // attach meta to indicate fallback
    // @ts-ignore
    return { ...fallback.ritual, _meta: { fallback: true, error: String(err?.message ?? err) } } as DailyRitualResponse;
  }
}
