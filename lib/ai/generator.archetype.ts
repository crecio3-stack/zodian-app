import { aiFetch } from './aiClient';
import { trackEvent } from './analytics';
import { generateArchetypeFallback } from './fallback.archetype';
import { logError, logInfo } from './logger';
import { ARCHETYPE_SYSTEM_PROMPT, buildArchetypePrompt } from './prompts';
import type { ArchetypeResponse } from './types';
import { isValidArchetypeResponse } from './validateArchetype';

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

export async function generateArchetype(params: { westernSign?: string; chineseSign?: string }): Promise<ArchetypeResponse> {
  const userPrompt = buildArchetypePrompt(params);
  const hasOpenAiKey = Boolean(OPENAI_API_KEY);

  const requestBody = hasOpenAiKey
    ? {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: ARCHETYPE_SYSTEM_PROMPT },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.7,
        max_tokens: 450,
      }
    : { systemPrompt: ARCHETYPE_SYSTEM_PROMPT, userPrompt };

  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (hasOpenAiKey) headers.Authorization = `Bearer ${OPENAI_API_KEY}`;

  try {
    trackEvent('ai.generate.archetype.attempt');
    const raw = await aiFetch<any>({ endpoint: AI_ENDPOINT, body: requestBody, headers, timeoutMs: 18000, maxRetries: 2 });

    if (hasOpenAiKey) {
      const content = raw?.choices?.[0]?.message?.content || raw?.choices?.[0]?.text;
      if (typeof content !== 'string') throw new Error('Invalid AI response format');
      let parsed: any;
      try {
        parsed = JSON.parse(content);
      } catch (err) {
        logError('Archetype JSON parse failed', { err, content });
        throw err;
      }
      if (!isValidArchetypeResponse(parsed)) throw new Error('Invalid Archetype shape');
      trackEvent('ai.generate.archetype.success');
      return parsed as ArchetypeResponse;
    }

    if (!isValidArchetypeResponse(raw)) throw new Error('AI backend returned invalid archetype');
    trackEvent('ai.generate.archetype.success');
    return raw as ArchetypeResponse;
  } catch (err) {
    logError(err, { params });
    trackEvent('ai.generate.archetype.fallback', { reason: String((err as Error).message) });
    const fallback = generateArchetypeFallback(params);
    logInfo('Returning fallback archetype', { id: fallback.id });
    return fallback;
  }
}
