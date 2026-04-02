import { aiFetch } from './aiClient';
import { trackEvent } from './analytics';
import { generateCompatibilityFallback } from './fallback.compatibility';
import { logError, logInfo } from './logger';
import { buildCompatibilityPrompt, COMPATIBILITY_SYSTEM_PROMPT } from './prompts';
import type { CompatibilityResponse } from './types';
import { isValidCompatibilityResponse } from './validateCompatibility';

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

export async function generateCompatibility(params: { left: { westernSign: string; chineseSign: string }; right: { westernSign: string; chineseSign: string } }): Promise<CompatibilityResponse> {
  const userPrompt = buildCompatibilityPrompt(params.left, params.right);
  const hasOpenAiKey = Boolean(OPENAI_API_KEY);

  const requestBody = hasOpenAiKey
    ? {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: COMPATIBILITY_SYSTEM_PROMPT },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.6,
        max_tokens: 400,
      }
    : { systemPrompt: COMPATIBILITY_SYSTEM_PROMPT, userPrompt };

  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (hasOpenAiKey) headers.Authorization = `Bearer ${OPENAI_API_KEY}`;

  try {
    trackEvent('ai.generate.compatibility.attempt');
    const raw = await aiFetch<any>({ endpoint: AI_ENDPOINT, body: requestBody, headers, timeoutMs: 16000, maxRetries: 3 });

    if (hasOpenAiKey) {
      const content = raw?.choices?.[0]?.message?.content || raw?.choices?.[0]?.text;
      if (typeof content !== 'string') throw new Error('Invalid AI response format');
      let parsed: any;
      try {
        parsed = JSON.parse(content);
      } catch (err) {
        logError('Compatibility JSON parse failed', { err, content });
        throw err;
      }
      if (!isValidCompatibilityResponse(parsed)) throw new Error('Invalid Compatibility shape');
      trackEvent('ai.generate.compatibility.success');
      return parsed as CompatibilityResponse;
    }

    if (!isValidCompatibilityResponse(raw)) throw new Error('AI backend returned invalid compatibility');
    trackEvent('ai.generate.compatibility.success');
    return raw as CompatibilityResponse;
  } catch (err) {
    logError(err, { params });
    trackEvent('ai.generate.compatibility.fallback', { reason: String((err as Error).message) });
    const fallback = generateCompatibilityFallback(params.left, params.right);
    logInfo('Returning fallback compatibility', { id: fallback.id });
    return fallback;
  }
}
