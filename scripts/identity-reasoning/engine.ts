import { reasoningSchema, writingSchema } from "./schemas.ts";
import {
  REASONING_SYSTEM_PROMPT,
  reasoningPrompt,
  WRITING_SYSTEM_PROMPT,
  writingPrompt,
} from "./prompts.ts";
import { auditIdentity } from "./validate.ts";
import type {
  IdentityGenerationRequest,
  IdentityGenerationResult,
  IdentityReasoningPlan,
} from "./types.ts";

const DEFAULT_MODEL = "gpt-5.2";

interface StructuredResponseOptions {
  apiKey: string;
  model: string;
  schemaName: string;
  schema: Record<string, unknown>;
  system: string;
  prompt: string;
}

async function structuredResponse<T>(
  options: StructuredResponseOptions,
): Promise<T> {
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${options.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: options.model,
      instructions: options.system,
      input: options.prompt,
      text: {
        format: {
          type: "json_schema",
          name: options.schemaName,
          strict: true,
          schema: options.schema,
        },
      },
    }),
  });
  if (!response.ok) {
    throw new Error(`OpenAI ${response.status}: ${await response.text()}`);
  }
  const payload = await response.json();
  const output = payload.output?.flatMap((item: { content?: unknown[] }) =>
    item.content ?? []
  )
    .find((part: { type?: string }) => part.type === "output_text")?.text;
  if (!output) {
    throw new Error("Structured response did not contain output_text");
  }
  return JSON.parse(output) as T;
}

export async function reasonIdentity(
  request: IdentityGenerationRequest,
  apiKey: string,
  model = DEFAULT_MODEL,
): Promise<IdentityReasoningPlan> {
  return await structuredResponse({
    apiKey,
    model,
    schemaName: "identity_reasoning_plan",
    schema: reasoningSchema,
    system: REASONING_SYSTEM_PROMPT,
    prompt: reasoningPrompt(request),
  });
}

export async function writeIdentity(
  request: IdentityGenerationRequest,
  plan: IdentityReasoningPlan,
  apiKey: string,
  model = DEFAULT_MODEL,
): Promise<
  Omit<
    IdentityGenerationResult,
    "generation_metadata" | "sign_pair" | "archetype_name"
  >
> {
  return await structuredResponse({
    apiKey,
    model,
    schemaName: "identity_generation_result",
    schema: writingSchema,
    system: WRITING_SYSTEM_PROMPT,
    prompt: writingPrompt(request, plan),
  });
}

export async function generateIdentity(
  request: IdentityGenerationRequest,
  apiKey: string,
  models = { reasoning: DEFAULT_MODEL, writing: DEFAULT_MODEL },
): Promise<IdentityGenerationResult> {
  const plan = await reasonIdentity(request, apiKey, models.reasoning);
  const prose = await writeIdentity(request, plan, apiKey, models.writing);
  const audit = auditIdentity(prose);
  return {
    sign_pair: `${request.western_sign} × ${request.chinese_sign}`,
    ...(request.archetype_name
      ? { archetype_name: request.archetype_name }
      : {}),
    ...prose,
    generation_metadata: {
      engine_version: "identity-reasoning-v1",
      generated_at: new Date().toISOString(),
      reasoning_model: models.reasoning,
      writing_model: models.writing,
      development_only: true,
      audit,
      ...(request.debug_reasoning ? { reasoning_plan: plan } : {}),
    },
  };
}
