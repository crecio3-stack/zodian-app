import { logError, logInfo } from './logger';

type AiRequestOptions = {
  endpoint: string;
  body: string | Record<string, unknown>;
  headers?: Record<string, string>;
  timeoutMs?: number;
  maxRetries?: number;
};

function sleep(ms: number) {
  return new Promise((r) => setTimeout(r, ms));
}

export async function aiFetch<T = any>(opts: AiRequestOptions): Promise<T> {
  const { endpoint, body, headers = {}, timeoutMs = 15000, maxRetries = 3 } = opts;
  const payload = typeof body === 'string' ? body : JSON.stringify(body);

  let attempt = 0;
  let lastError: any = null;

  while (attempt <= maxRetries) {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeoutMs);

    try {
      logInfo('aiFetch: request', { endpoint, attempt });

      const res = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
        body: payload,
        signal: controller.signal,
      });

      clearTimeout(id);

      if (res.ok) {
        const json = await res.json();
        return json as T;
      }

      // Handle retryable statuses
      if (res.status === 429 || (res.status >= 500 && res.status < 600)) {
        lastError = new Error(`Transient API error (${res.status})`);
        const backoff = Math.min(1000 * 2 ** attempt, 60000);
        const jitter = Math.floor(Math.random() * 300);
        logInfo('aiFetch: retrying', { status: res.status, attempt, backoff });
        await sleep(backoff + jitter);
        attempt += 1;
        continue;
      }

      // Non-retryable error
      const text = await res.text();
      const err = new Error(`AI request failed: ${res.status} ${text}`);
      logError(err, { endpoint, status: res.status, body: text });
      throw err;
    } catch (err: any) {
      clearTimeout(id);
      lastError = err;

      // Abort / network errors are retryable
      if (err.name === 'AbortError' || err.name === 'TypeError') {
        const backoff = Math.min(1000 * 2 ** attempt, 60000);
        const jitter = Math.floor(Math.random() * 300);
        logInfo('aiFetch: network retry', { attempt, backoff, message: err.message });
        await sleep(backoff + jitter);
        attempt += 1;
        continue;
      }

      // Unknown fatal error
      logError(err, { endpoint, attempt });
      throw err;
    }
  }

  // All retries exhausted
  logError(lastError, { message: 'aiFetch: retries exhausted' });
  throw lastError;
}
