import {
  assert,
  assertEquals,
  assertThrows,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { resolveRealModelConfig, runPreflight } from "./config.ts";

Deno.test("configuration resolves the safe model default without a key", () => {
  const config = resolveRealModelConfig({});
  assertEquals(config.apiKey, undefined);
  assertEquals(config.model, "gpt-5.2");
  assertEquals(config.modelSource, "default");
});

Deno.test("specific model variable wins without exposing secrets", () => {
  const config = resolveRealModelConfig({
    OPENAI_API_KEY: "secret-test-value",
    OPENAI_MODEL: "shared",
    OPENAI_IDENTITY_LENS_MODEL: "specific",
  });
  assertEquals(config.model, "specific");
  assertEquals(config.apiKey, "secret-test-value");
});

Deno.test("real preflight fails before network when API key is missing", () => {
  assertThrows(
    () =>
      runPreflight({
        real: true,
        env: {},
        scenarioCount: 10,
        mockArtifactPath: "mock",
        realArtifactPath: "real",
        productionPaths: [],
      }),
    Error,
    "OPENAI_API_KEY",
  );
});

Deno.test("placeholder preflight succeeds without calling a provider or writing artifacts", () => {
  const checks = runPreflight({
    real: true,
    env: {
      OPENAI_API_KEY: "placeholder-only",
      OPENAI_IDENTITY_LENS_MODEL: "approved-test-model",
    },
    scenarioCount: 10,
    mockArtifactPath: "mock",
    realArtifactPath: "real",
    productionPaths: [],
  });
  assert(checks.includes("network_call=none"));
  assert(checks.includes("artifact_paths=distinct"));
  assert(checks.includes("production_write_scope=empty"));
  assert(!checks.some((check) => check.includes("placeholder-only")));
});

Deno.test("mock preflight is credential-free and uses the mock path", () => {
  const checks = runPreflight({
    real: false,
    env: {},
    scenarioCount: 10,
    mockArtifactPath: "mock",
    realArtifactPath: "real",
    productionPaths: [],
  });
  assert(checks.includes("provider=mock"));
});
