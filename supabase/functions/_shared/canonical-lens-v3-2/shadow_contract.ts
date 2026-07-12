export const FROZEN_VERSION = "canonical-lens-v3.2" as const;
export const SCENARIO_IDS = [
  "work-speaking-up",
  "love-trust",
  "home-change",
  "friends-harmony",
  "money-comfort",
  "rest-responsibility",
  "confidence-recognition",
  "routine-freedom",
  "conflict-directness",
  "opportunity-expansion",
] as const;
export type ScenarioId = typeof SCENARIO_IDS[number];
export type ShadowMode = "disabled" | "allowlist" | "sample" | "full";

export type ShadowRequest = {
  generation_date?: unknown;
  western_sign?: unknown;
  eastern_sign?: unknown;
  scenario_id?: unknown;
  production_daily_ritual_id?: unknown;
  dry_run?: unknown;
};

export function normalizedText(value: unknown): string {
  return typeof value === "string" ? value.trim().replace(/\s+/g, " ") : "";
}

export function identityKey(western: string, eastern: string): string {
  return `${western.toLowerCase()}|${eastern.toLowerCase()}`;
}

export function parseAllowlist(value: string | undefined): Set<string> {
  return new Set(
    (value ?? "").split(",").map((pair) => {
      const [western, eastern, ...extra] = pair.split("|").map((part) =>
        normalizedText(part)
      );
      return !extra.length && western && eastern
        ? identityKey(western, eastern)
        : "";
    }).filter(Boolean),
  );
}

export function deterministicSample(key: string, percentage: number): boolean {
  let hash = 2166136261;
  for (const character of key) {
    hash ^= character.charCodeAt(0);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0) % 100 < Math.max(0, Math.min(100, percentage));
}

export function validateRequest(input: ShadowRequest): {
  value?: {
    generationDate: string;
    western: string;
    eastern: string;
    scenarioId: ScenarioId;
    productionId?: string;
    dryRun: boolean;
  };
  errors: string[];
} {
  const generationDate = normalizedText(input.generation_date);
  const western = normalizedText(input.western_sign);
  const eastern = normalizedText(input.eastern_sign);
  const scenarioId = normalizedText(input.scenario_id);
  const errors: string[] = [];
  if (!/^\d{4}-\d{2}-\d{2}$/.test(generationDate)) {
    errors.push("generation_date must be YYYY-MM-DD");
  }
  if (!western) errors.push("western_sign is required");
  if (!eastern) errors.push("eastern_sign is required");
  if (!SCENARIO_IDS.includes(scenarioId as ScenarioId)) {
    errors.push("scenario_id must be an active frozen v3.2 scenario ID");
  }
  const productionId = normalizedText(input.production_daily_ritual_id);
  return errors.length ? { errors } : {
    errors,
    value: {
      generationDate,
      western,
      eastern,
      scenarioId: scenarioId as ScenarioId,
      productionId: productionId || undefined,
      dryRun: input.dry_run === true,
    },
  };
}

export function cohortEligible(
  options: {
    enabled: boolean;
    mode: ShadowMode;
    allowlist: Set<string>;
    samplePercent: number;
    key: string;
  },
): boolean {
  if (!options.enabled || options.mode === "disabled") return false;
  if (options.mode === "full") return true;
  if (options.mode === "allowlist") return options.allowlist.has(options.key);
  return deterministicSample(options.key, options.samplePercent);
}
