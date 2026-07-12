import type { CanonicalLens } from "../canonical-lens/types.ts";
import { validateCanonicalLens } from "../canonical-lens/validate.ts";
import type {
  LensModelProvider,
  ModelWritingRequest,
} from "../canonical-lens-model/types.ts";
import type { V3EditorialBrief } from "./v3_sample_plan.ts";
import {
  buildV3RepairPrompt,
  buildV3WritingPrompt,
  type V3CorpusGuard,
  type V3PromptVersion,
} from "./v3_prompt.ts";

export const V3_LENS_FIELDS = [
  "title",
  "intro",
  "pull_quote",
  "deeper_read",
  "watch_for",
  "move",
] as const;
type LensField = typeof V3_LENS_FIELDS[number];

export interface V3WritingAttempt {
  attempt: number;
  mode: "full" | "patch";
  requestedFields: LensField[];
  prompt: string;
  rawResponse: string;
  parsedResponse: unknown;
  mergedCandidate: Partial<CanonicalLens> | null;
  validation: { accepted: boolean; reasons: string[] };
  validFieldsPreserved: boolean;
  usage?: Record<string, unknown>;
}

export interface V3WritingResult {
  provider: string;
  signPair: string;
  scenarioId: string;
  accepted: boolean;
  retryCount: number;
  finalLens: CanonicalLens | null;
  attempts: V3WritingAttempt[];
  modelConfig: Record<string, unknown>;
}

function parseObject(raw: string): Record<string, unknown> | null {
  try {
    const value = JSON.parse(raw);
    return value && typeof value === "object" && !Array.isArray(value)
      ? value as Record<string, unknown>
      : null;
  } catch {
    return null;
  }
}

function knownFields(
  value: Record<string, unknown> | null,
): Partial<CanonicalLens> {
  if (!value) return {};
  return Object.fromEntries(
    V3_LENS_FIELDS.filter((field) => typeof value[field] === "string").map(
      (field) => [field, value[field]],
    ),
  ) as Partial<CanonicalLens>;
}

function validateFull(candidate: Record<string, unknown> | null): {
  lens: CanonicalLens | null;
  reasons: string[];
} {
  if (!candidate) {
    return { lens: null, reasons: ["response was not valid JSON"] };
  }
  const keys = Object.keys(candidate).sort();
  const expected = [...V3_LENS_FIELDS].sort();
  if (JSON.stringify(keys) !== JSON.stringify(expected)) {
    return {
      lens: null,
      reasons: ["response must contain exactly the six Lens fields"],
    };
  }
  if (V3_LENS_FIELDS.some((field) => typeof candidate[field] !== "string")) {
    return { lens: null, reasons: ["all Lens fields must be strings"] };
  }
  const lens = candidate as CanonicalLens;
  const validation = validateCanonicalLens(lens);
  return { lens, reasons: validation.reasons };
}

function fieldsForErrors(reasons: string[]): LensField[] {
  const fields = new Set<LensField>();
  for (const reason of reasons) {
    const direct = V3_LENS_FIELDS.find((field) =>
      reason.startsWith(`${field} `)
    );
    if (direct) fields.add(direct);
    if (reason === "watch_for and move must differ") {
      fields.add("watch_for");
      fields.add("move");
    }
  }
  return fields.size ? [...fields] : [...V3_LENS_FIELDS];
}

function parsePatch(
  raw: string,
  requested: LensField[],
): { patch: Partial<CanonicalLens> | null; reasons: string[] } {
  const value = parseObject(raw);
  if (!value) return { patch: null, reasons: ["repair was not valid JSON"] };
  const keys = Object.keys(value).sort();
  const expected = [...requested].sort();
  if (JSON.stringify(keys) !== JSON.stringify(expected)) {
    return {
      patch: null,
      reasons: ["repair must contain exactly the requested invalid fields"],
    };
  }
  if (requested.some((field) => typeof value[field] !== "string")) {
    return {
      patch: null,
      reasons: ["every requested repair field must be a string"],
    };
  }
  return { patch: value as Partial<CanonicalLens>, reasons: [] };
}

export async function writeModelLensV3(options: {
  request: ModelWritingRequest;
  provider: LensModelProvider;
  brief: V3EditorialBrief;
  guard?: V3CorpusGuard;
  maxRetries?: number;
  additionalValidation?: (lens: CanonicalLens) => string[];
  promptVersion?: V3PromptVersion;
}): Promise<V3WritingResult> {
  const maxRetries = options.maxRetries ?? 2;
  const attempts: V3WritingAttempt[] = [];
  let current: Partial<CanonicalLens> = {};
  let reasons: string[] = [];
  let failedFields: LensField[] = [...V3_LENS_FIELDS];

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const mode = attempt === 0 ? "full" : "patch";
    const prompt = mode === "full"
      ? buildV3WritingPrompt(
        options.request,
        options.brief,
        options.guard,
        options.promptVersion,
      )
      : buildV3RepairPrompt(
        options.request,
        current,
        reasons,
        failedFields,
        options.brief,
        options.guard,
        options.promptVersion,
      );
    const response = await options.provider.complete(prompt, attempt);
    const parsed = parseObject(response.raw);
    let merged: Partial<CanonicalLens> | null;
    let validationReasons: string[];

    if (mode === "full") {
      const validation = validateFull(parsed);
      current = validation.lens ?? knownFields(parsed);
      merged = current;
      validationReasons = validation.reasons.concat(
        validation.lens
          ? options.additionalValidation?.(validation.lens) ?? []
          : [],
      );
    } else {
      const repair = parsePatch(response.raw, failedFields);
      if (!repair.patch) {
        merged = current;
        validationReasons = repair.reasons;
      } else {
        current = { ...current, ...repair.patch };
        merged = current;
        const validation = validateFull(
          current as Record<string, unknown>,
        );
        validationReasons = validation.reasons.concat(
          validation.lens
            ? options.additionalValidation?.(validation.lens) ?? []
            : [],
        );
      }
    }

    const accepted = validationReasons.length === 0;
    attempts.push({
      attempt,
      mode,
      requestedFields: mode === "full" ? [...V3_LENS_FIELDS] : failedFields,
      prompt,
      rawResponse: response.raw,
      parsedResponse: parsed,
      mergedCandidate: merged,
      validation: { accepted, reasons: validationReasons },
      validFieldsPreserved: true,
      usage: response.usage,
    });
    if (accepted) {
      return {
        provider: options.provider.name,
        signPair: options.request.context.signPair,
        scenarioId: options.request.scenario.seed,
        accepted: true,
        retryCount: attempt,
        finalLens: current as CanonicalLens,
        attempts,
        modelConfig: {
          model: options.provider.name.replace(/^openai:/, ""),
          responseFormat: attempt === 0 ? "six-field JSON" : "field patch JSON",
          maxEditorialRetries: maxRetries,
          patchMergeRecorded: true,
        },
      };
    }
    reasons = validationReasons;
    failedFields = fieldsForErrors(validationReasons);
  }

  return {
    provider: options.provider.name,
    signPair: options.request.context.signPair,
    scenarioId: options.request.scenario.seed,
    accepted: false,
    retryCount: maxRetries,
    finalLens: null,
    attempts,
    modelConfig: {
      model: options.provider.name.replace(/^openai:/, ""),
      responseFormat: "six-field JSON with recorded field-patch retries",
      maxEditorialRetries: maxRetries,
      patchMergeRecorded: true,
    },
  };
}
