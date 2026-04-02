import { aiFetch } from './aiClient';
import { trackEvent } from './analytics';
import { generateDailyFateFallback } from './fallback.dailyFate';
import { logError, logInfo } from './logger';
import { buildDailyFatePrompt, DAILY_FATE_SYSTEM_PROMPT } from './prompts';
import type { DailyFateResponse } from './types';
import { isValidDailyFateResponse } from './validateDailyFate';

const OPENAI_API_KEY =
  typeof globalThis !== 'undefined' &&
  typeof (globalThis as any).process !== 'undefined'
    ? (globalThis as any).process.env.OPENAI_API_KEY
    : undefined;

const AI_ENDPOINT =
  (typeof globalThis !== 'undefined' &&
    typeof (globalThis as any).process !== 'undefined' &&
    (globalThis as any).process.env.ZODIAN_AI_ENDPOINT) ||
  (OPENAI_API_KEY ? 'https://api.openai.com/v1/chat/completions' : 'https://your-zodian-ai-backend.example.com/generate');

export async function generateDailyFate(params: { westernSign: string; chineseSign: string; dateISO: string }): Promise<DailyFateResponse> {
  const userPrompt = buildDailyFatePrompt(params as any);
  const hasOpenAiKey = Boolean(OPENAI_API_KEY);

  const requestBody = hasOpenAiKey
    ? {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: DAILY_FATE_SYSTEM_PROMPT },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.7,
        max_tokens: 350,
      }
    : { systemPrompt: DAILY_FATE_SYSTEM_PROMPT, userPrompt };

  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (hasOpenAiKey) headers.Authorization = `Bearer ${OPENAI_API_KEY}`;

  try {
    trackEvent('ai.generate.daily_fate.attempt');
    const raw = await aiFetch<any>({ endpoint: AI_ENDPOINT, body: requestBody, headers, timeoutMs: 14000, maxRetries: 2 });

    if (hasOpenAiKey) {
      const content = raw?.choices?.[0]?.message?.content || raw?.choices?.[0]?.text;
      if (typeof content !== 'string') throw new Error('Invalid AI response format');
      let parsed: any;
      try {
        parsed = JSON.parse(content);
      } catch (err) {
        logError('DailyFate JSON parse failed', { err, content });
        throw err;
      }
      if (!isValidDailyFateResponse(parsed)) throw new Error('Invalid DailyFate shape');
      trackEvent('ai.generate.daily_fate.success');
      return parsed as DailyFateResponse;
    }

    if (!isValidDailyFateResponse(raw)) throw new Error('AI backend returned invalid daily fate');
    trackEvent('ai.generate.daily_fate.success');
    return raw as DailyFateResponse;
  } catch (err) {
    logError(err, { params });
    trackEvent('ai.generate.daily_fate.fallback', { reason: String((err as Error).message) });
    const fallback = generateDailyFateFallback(params);
    logInfo('Returning fallback daily fate', { id: fallback.id });
    return fallback;
  }
}
