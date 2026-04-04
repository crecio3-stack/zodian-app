// filepath: /Users/christianrecio/zodian/lib/ai/orchestrator.ts
import type { DailyRitualResponse } from '../../types/dailyRitual';
import { isValidDailyRitualResponse } from './validateDailyRitual';

const DEFAULT_TIMEOUT = typeof process !== 'undefined' && (process as any).env && (process as any).env.ZODIAN_AI_TIMEOUT ? Number((process as any).env.ZODIAN_AI_TIMEOUT) : 5000;
const DEFAULT_RETRIES = 2;

function nowMs() {
  return Date.now();
}

function sleep(ms: number) {
  return new Promise((res) => setTimeout(res, ms));
}

function trackEvent(name: string, payload?: Record<string, any>) {
  try {
    // @ts-ignore
    if (globalThis?.analytics?.track) {
      // @ts-ignore
      globalThis.analytics.track(name, payload);
    } else {
      console.debug(`[analytics] ${name}`, payload ?? {});
    }
  } catch {}
}

// Circuit breaker state persisted in-memory; for longer-lived apps consider AsyncStorage
let circuitOpenUntil = 0;
const CIRCUIT_TIMEOUT_MS = 1000 * 60 * 3; // 3 minutes

export async function generateWithOrchestration(payload: { endpoint: string; body: any; headers?: Record<string,string> }, opts?: { timeoutMs?: number; retries?: number; backoffFactor?: number; allowFallback?: boolean }): Promise<DailyRitualResponse> {
  const timeoutMs = opts?.timeoutMs ?? DEFAULT_TIMEOUT;
  const retries = opts?.retries ?? DEFAULT_RETRIES;
  const backoffFactor = opts?.backoffFactor ?? 2;
  const start = nowMs();

  if (nowMs() < circuitOpenUntil) {
    trackEvent('ai.circuit.open', { until: circuitOpenUntil });
    throw new Error('AI circuit is open');
  }

  let attempt = 0;
  let lastErr: any = null;
  while (attempt <= retries) {
    attempt += 1;
    try {
      const controller = typeof AbortController !== 'undefined' ? new AbortController() : null;
      const signal = controller ? controller.signal : undefined;

      if (controller) setTimeout(() => controller.abort(), timeoutMs);

      const resp = await fetch(payload.endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...(payload.headers ?? {}) },
        body: JSON.stringify(payload.body),
        signal,
      });

      if (!resp.ok) {
        const txt = await resp.text().catch(() => '');
        throw new Error(`AI endpoint error: ${resp.status} ${txt}`);
      }

      const data = await resp.json().catch(() => null);
      if (!data) throw new Error('Empty AI response');

      // if returned a nested model-like structure, try to extract content
      let candidate = data;
      if (typeof data === 'object' && data?.choices && Array.isArray(data.choices) && data.choices[0]?.message?.content) {
        const content = data.choices[0].message.content;
        if (typeof content === 'string') {
          try {
            candidate = JSON.parse(content);
          } catch {}
        }
      }

      if (!isValidDailyRitualResponse(candidate)) {
        throw new Error('AI returned invalid ritual shape');
      }

      trackEvent('ai.generate.success', { durationMs: nowMs() - start, attempts: attempt });
      return candidate as DailyRitualResponse;
    } catch (err) {
      lastErr = err;
      trackEvent('ai.generate.error', { attempt, error: String((err as any)?.message ?? err) });
      // simple backoff
      const backoff = Math.pow(backoffFactor, attempt) * 300;
      await sleep(backoff);
    }
  }

  // after retries, open circuit for a short period
  circuitOpenUntil = nowMs() + CIRCUIT_TIMEOUT_MS;
  trackEvent('ai.circuit.trip', { until: circuitOpenUntil, error: String((lastErr as any)?.message ?? lastErr) });
  throw lastErr ?? new Error('AI generation failed');
}
