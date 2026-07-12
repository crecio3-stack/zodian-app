export interface RealModelConfig {
  apiKey: string | undefined;
  model: string;
  modelSource: "OPENAI_IDENTITY_LENS_MODEL" | "OPENAI_MODEL" | "default";
}

export function resolveRealModelConfig(
  env: Record<string, string | undefined>,
): RealModelConfig {
  const specific = env.OPENAI_IDENTITY_LENS_MODEL?.trim();
  const shared = env.OPENAI_MODEL?.trim();
  return {
    apiKey: env.OPENAI_API_KEY?.trim() || undefined,
    model: specific || shared || "gpt-5.2",
    modelSource: specific
      ? "OPENAI_IDENTITY_LENS_MODEL"
      : shared
      ? "OPENAI_MODEL"
      : "default",
  };
}

export function runPreflight(options: {
  real: boolean;
  env: Record<string, string | undefined>;
  scenarioCount: number;
  mockArtifactPath: string;
  realArtifactPath: string;
  productionPaths: string[];
}): string[] {
  const checks: string[] = [];
  const config = resolveRealModelConfig(options.env);
  if (options.real && !config.apiKey) {
    throw new Error(
      "Preflight failed: OPENAI_API_KEY is missing; no network call was made. The mock provider remains available without credentials. Set OPENAI_API_KEY and retry with --real --preflight.",
    );
  }
  checks.push(`provider=${options.real ? "real" : "mock"}`);
  checks.push(
    `model=${options.real ? config.model : "deterministic-development-mock"}`,
  );
  checks.push(`model_source=${options.real ? config.modelSource : "n/a"}`);
  if (options.scenarioCount !== 10) {
    throw new Error(
      `Preflight failed: expected 10 matched scenarios, found ${options.scenarioCount}`,
    );
  }
  checks.push("matched_cases=20");
  if (options.mockArtifactPath === options.realArtifactPath) {
    throw new Error("Preflight failed: mock and real artifact paths overlap");
  }
  checks.push("artifact_paths=distinct");
  if (options.productionPaths.length) {
    throw new Error(
      `Preflight failed: production paths are in write scope: ${
        options.productionPaths.join(", ")
      }`,
    );
  }
  checks.push("production_write_scope=empty");
  checks.push("network_call=none");
  checks.push("secret_values=not_printed");
  return checks;
}
