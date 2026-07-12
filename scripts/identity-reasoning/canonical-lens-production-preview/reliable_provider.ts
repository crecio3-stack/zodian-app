import { MODEL_WRITING_SYSTEM } from "../canonical-lens-model/prompt.ts";
import type { LensModelProvider } from "../canonical-lens-model/types.ts";

export interface TransportEvent {
  editorialAttempt: number;
  transportAttempt: number;
  startedAt: string;
  latencyMs: number;
  status: "accepted" | "retry" | "failed";
  error?: string;
  prompt: string;
}

export class ProviderAuthenticationError extends Error {}

export function buildReliableOpenAIProvider(options: {
  apiKey: string;
  model: string;
  instructions?: string;
  events: TransportEvent[];
  maxTransportRetries?: number;
  timeoutMs?: number;
}): LensModelProvider {
  const maxTransportRetries = options.maxTransportRetries ?? 3;
  const timeoutMs = options.timeoutMs ?? 60_000;
  return {
    name: `openai:${options.model}`,
    async complete(prompt: string, editorialAttempt: number) {
      for (
        let transportAttempt = 0;
        transportAttempt <= maxTransportRetries;
        transportAttempt++
      ) {
        const startedAt = new Date().toISOString();
        const started = performance.now();
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), timeoutMs);
        try {
          const response = await fetch("https://api.openai.com/v1/responses", {
            method: "POST",
            signal: controller.signal,
            headers: {
              Authorization: `Bearer ${options.apiKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              model: options.model,
              instructions: options.instructions ?? MODEL_WRITING_SYSTEM,
              input: prompt,
              text: { format: { type: "json_object" } },
            }),
          });
          const latencyMs = Math.round(performance.now() - started);
          if (response.status === 401 || response.status === 403) {
            const message =
              `OpenAI authentication failed with status ${response.status}`;
            options.events.push({
              editorialAttempt,
              transportAttempt,
              startedAt,
              latencyMs,
              status: "failed",
              error: message,
              prompt,
            });
            throw new ProviderAuthenticationError(message);
          }
          if (!response.ok) {
            const retryable = response.status === 408 ||
              response.status === 409 || response.status === 429 ||
              response.status >= 500;
            const message = `OpenAI transport status ${response.status}: ${
              (await response.text()).slice(0, 500)
            }`;
            options.events.push({
              editorialAttempt,
              transportAttempt,
              startedAt,
              latencyMs,
              status: retryable && transportAttempt < maxTransportRetries
                ? "retry"
                : "failed",
              error: message,
              prompt,
            });
            if (!retryable || transportAttempt >= maxTransportRetries) {
              throw new Error(message);
            }
          } else {
            const payload = await response.json();
            const text = payload.output?.flatMap((
              item: { content?: unknown[] },
            ) => item.content ?? []).find((part: { type?: string }) =>
              part.type === "output_text"
            )?.text;
            options.events.push({
              editorialAttempt,
              transportAttempt,
              startedAt,
              latencyMs,
              status: "accepted",
              prompt,
            });
            return { raw: text ?? "", usage: payload.usage };
          }
        } catch (error) {
          if (error instanceof ProviderAuthenticationError) throw error;
          const latencyMs = Math.round(performance.now() - started);
          const message = error instanceof Error
            ? error.message
            : String(error);
          const alreadyRecorded =
            options.events.at(-1)?.startedAt === startedAt;
          if (!alreadyRecorded) {
            options.events.push({
              editorialAttempt,
              transportAttempt,
              startedAt,
              latencyMs,
              status: transportAttempt < maxTransportRetries
                ? "retry"
                : "failed",
              error: message,
              prompt,
            });
          }
          if (transportAttempt >= maxTransportRetries) throw error;
        } finally {
          clearTimeout(timeout);
        }
        await new Promise((resolve) =>
          setTimeout(resolve, Math.min(8_000, 1_000 * 2 ** transportAttempt))
        );
      }
      throw new Error("transport retry loop exhausted");
    },
  };
}
