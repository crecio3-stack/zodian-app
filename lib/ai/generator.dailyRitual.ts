import { aiFetch } from './aiClient';
import { trackEvent } from './analytics';
import { generateDailyRitualFallback } from './dailyrtFallback';
import { isValidDailyRitualResponse } from './dailyrtValidator';
import { logError, logInfo } from './logger';
import { buildDailyRitualUserPrompt, DAILY_RITUAL_SYSTEM_PROMPT } from './prompts';
import type { DailyRitualResponse } from './types';

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

export async function generateDailyRitual(params: {
  westernSign: string;
  chineseSign: string;
  dateISO: string;
  weekday: string;
}): Promise<DailyRitualResponse> {
  const userPrompt = buildDailyRitualUserPrompt(params);
  const hasOpenAiKey = Boolean(OPENAI_API_KEY);

  const requestBody = hasOpenAiKey
    ? {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: DAILY_RITUAL_SYSTEM_PROMPT },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.7,
        max_tokens: 400,
      }
    : {
        systemPrompt: DAILY_RITUAL_SYSTEM_PROMPT,
        userPrompt,
      };

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  if (hasOpenAiKey) headers.Authorization = `Bearer ${OPENAI_API_KEY}`;

  try {
    const raw = await aiFetch<any>({ endpoint: AI_ENDPOINT, body: requestBody, headers, timeoutMs: 15000, maxRetries: 3 });

    trackEvent('ai.generate.daily_ritual.attempt', { backend: hasOpenAiKey ? 'openai' : 'zodian_backend' });

    // OpenAI-style response
    if (hasOpenAiKey) {
      const content = raw?.choices?.[0]?.message?.content || raw?.choices?.[0]?.text;
      if (typeof content !== 'string') throw new Error('Invalid AI response format');

      let parsed: any;
      try {
        parsed = JSON.parse(content);
      } catch (err) {
        logError('AI JSON parse failed', { err, content });
        throw new Error('AI response could not be parsed as JSON');
      }

      if (!isValidDailyRitualResponse(parsed)) {
        logError('AI validation failed', { parsed });
        throw new Error('AI response did not match expected ritual shape');
      }

      trackEvent('ai.generate.daily_ritual.success', { source: 'ai' });
      return parsed as DailyRitualResponse;
    }

    // If using a custom backend that returns the full object
    if (!isValidDailyRitualResponse(raw)) {
      logError('AI backend returned invalid ritual response', { raw });
      throw new Error('AI backend returned invalid ritual response');
    }

    trackEvent('ai.generate.daily_ritual.success', { source: 'backend' });
    return raw as DailyRitualResponse;
  } catch (err) {
    // Log, emit analytics, and return fallback content
    logError(err, { params });
    trackEvent('ai.generate.daily_ritual.fallback', { reason: String((err as Error).message) });

    const fallback = generateDailyRitualFallback(params);
    logInfo('Returning fallback ritual', { id: fallback.id });
    return fallback;
  }
}
