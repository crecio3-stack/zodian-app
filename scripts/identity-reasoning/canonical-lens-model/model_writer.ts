import type { CanonicalLens } from "../canonical-lens/types.ts";
import { validateCanonicalLens } from "../canonical-lens/validate.ts";
import { LENS_LIBRARY } from "../canonical-lens/lens_library.ts";
import { buildModelWritingPrompt, MODEL_WRITING_SYSTEM } from "./prompt.ts";
import type {
  LensModelProvider,
  ModelWritingRequest,
  ModelWritingResult,
} from "./types.ts";

const OUTPUT_KEYS = [
  "title",
  "intro",
  "pull_quote",
  "deeper_read",
  "watch_for",
  "move",
] as const;
const scenarioLibraryKey: Record<string, string> = {
  "lens-01": "work-voice",
  "lens-02": "love-trust",
  "lens-03": "home-change",
  "lens-04": "friends-honesty",
  "lens-05": "money-comfort",
  "lens-06": "rest-duty",
  "lens-07": "confidence-credit",
  "lens-08": "routine-freedom",
  "lens-09": "conflict-pace",
  "lens-10": "opportunity-growth",
  "work-speaking-up": "work-voice",
  "friends-harmony": "friends-honesty",
  "rest-responsibility": "rest-duty",
  "confidence-recognition": "confidence-credit",
  "conflict-directness": "conflict-pace",
  "opportunity-expansion": "opportunity-growth",
  "home-change": "home-change",
  "love-trust": "love-trust",
  "money-comfort": "money-comfort",
  "routine-freedom": "routine-freedom",
};

function parseStrict(
  raw: string,
): { value: CanonicalLens | null; reasons: string[] } {
  try {
    const value = JSON.parse(raw) as Record<string, unknown>;
    const keys = Object.keys(value).sort().join(",");
    const expected = [...OUTPUT_KEYS].sort().join(",");
    if (keys !== expected) {
      return {
        value: null,
        reasons: ["response must contain exactly the six Lens fields"],
      };
    }
    if (OUTPUT_KEYS.some((key) => typeof value[key] !== "string")) {
      return { value: null, reasons: ["all Lens fields must be strings"] };
    }
    const lens = value as CanonicalLens;
    const validation = validateCanonicalLens(lens);
    return {
      value: validation.accepted ? lens : null,
      reasons: validation.reasons,
    };
  } catch {
    return { value: null, reasons: ["response was not valid JSON"] };
  }
}

function retryInstructions(
  reasons: string[],
  parsedResponse: unknown,
): string[] {
  const parsed = parsedResponse && typeof parsedResponse === "object"
    ? parsedResponse as Record<string, unknown>
    : {};
  return reasons.map((reason) => {
    const field = ([
      "title",
      "intro",
      "pull_quote",
      "deeper_read",
      "watch_for",
      "move",
    ] as const).find((key) => reason.startsWith(`${key} `)) ?? "field";
    const rejectedValue = typeof parsed[field] === "string"
      ? ` Rejected value: ${JSON.stringify(parsed[field])}.`
      : "";
    const shortField = ["intro", "pull_quote", "watch_for", "move"].includes(
      field,
    );
    return `The field \`${field}\` is invalid. Validator error: ${reason}.${rejectedValue}${
      shortField
        ? ` Rewrite only the meaning of \`${field}\` while returning the complete JSON object. It must use the stated word range, be one plain declarative or imperative sentence, contain no quotation marks, no dialogue punctuation, and no semicolon, and end with one period. Silently count words. Keep every other valid field unchanged.`
        : " Return the complete JSON object and preserve every other valid field unchanged."
    }`;
  });
}

export function buildMockProvider(): LensModelProvider {
  return {
    name: "deterministic-development-mock",
    async complete(prompt: string): Promise<{ raw: string }> {
      const signPair = prompt.includes("room to move")
        ? "Taurus × Horse"
        : "Libra × Snake";
      const scenario =
        Object.entries(scenarioLibraryKey).find(([id]) => prompt.includes(id))
          ?.[1] ?? "money-comfort";
      const payload = LENS_LIBRARY[`${scenario}|${signPair}`];
      if (!payload) throw new Error(`No mock Lens for ${scenario}|${signPair}`);
      return { raw: JSON.stringify(payload) };
    },
  };
}

export function buildOpenAIProvider(
  apiKey: string,
  model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL") ??
    Deno.env.get("OPENAI_MODEL") ?? "gpt-5.2",
): LensModelProvider {
  return {
    name: `openai:${model}`,
    async complete(
      prompt: string,
    ): Promise<{ raw: string; usage?: Record<string, unknown> }> {
      const response = await fetch("https://api.openai.com/v1/responses", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model,
          instructions: MODEL_WRITING_SYSTEM,
          input: prompt,
          text: { format: { type: "json_object" } },
        }),
      });
      if (!response.ok) {
        throw new Error(`OpenAI ${response.status}: ${await response.text()}`);
      }
      const payload = await response.json();
      const text = payload.output?.flatMap((item: { content?: unknown[] }) =>
        item.content ?? []
      ).find((part: { type?: string }) => part.type === "output_text")?.text;
      return { raw: text ?? "", usage: payload.usage };
    },
  };
}

export async function writeModelLens(
  request: ModelWritingRequest,
  provider: LensModelProvider,
  maxRetries = 2,
): Promise<ModelWritingResult> {
  const prompt = buildModelWritingPrompt(request);
  const attempts = [];
  let errors: string[] = [];
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const response = await provider.complete(
      attempt === 0 ? prompt : buildModelWritingPrompt(request, errors),
      attempt,
    );
    const parsed = parseStrict(response.raw);
    const validation = {
      accepted: parsed.value !== null,
      reasons: parsed.reasons,
    };
    const parsedForRetry = parsed.value ?? (() => {
      try {
        return JSON.parse(response.raw);
      } catch {
        return null;
      }
    })();
    attempts.push({
      attempt,
      rawResponse: response.raw,
      parsedResponse: parsedForRetry,
      validation,
      usage: response.usage,
    });
    if (parsed.value) {
      return {
        provider: provider.name,
        signPair: request.context.signPair,
        scenarioId: request.scenario.seed,
        prompt,
        attempts,
        finalLens: parsed.value,
        accepted: true,
        retryCount: attempt,
        sourceTraceability: [
          "context.selected.activatedParadox",
          "context.selected.perception",
          "context.selected.decision",
          "context.selected.pressureOrGrowth",
          "context.selected.observableBehaviors",
          "context.selected.arenaDetail",
          "reasoning",
        ],
        modelConfig: provider.name.startsWith("openai:")
          ? {
            model: provider.name.slice("openai:".length),
            temperature: "provider default",
            maxOutputTokens: "provider default",
            responseFormat: "json_object",
          }
          : { provider: "deterministic mock" },
      };
    }
    errors = retryInstructions(parsed.reasons, parsedForRetry);
  }
  return {
    provider: provider.name,
    signPair: request.context.signPair,
    scenarioId: request.scenario.seed,
    prompt,
    attempts,
    finalLens: null,
    accepted: false,
    retryCount: maxRetries,
    sourceTraceability: [],
    modelConfig: provider.name.startsWith("openai:")
      ? {
        model: provider.name.slice("openai:".length),
        temperature: "provider default",
        maxOutputTokens: "provider default",
        responseFormat: "json_object",
      }
      : { provider: "deterministic mock" },
  };
}
