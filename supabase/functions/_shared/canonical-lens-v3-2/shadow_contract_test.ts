import { assertEquals, assert } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { cohortEligible, deterministicSample, identityKey, parseAllowlist, validateRequest } from "./shadow_contract.ts";

Deno.test("shadow contract rejects missing or unknown scenario IDs before provider access", () => {
  assert(validateRequest({ generation_date: "2026-07-12", western_sign: "Libra", eastern_sign: "Snake" }).errors.length > 0);
  assert(validateRequest({ generation_date: "2026-07-12", western_sign: "Libra", eastern_sign: "Snake", scenario_id: "invented" }).errors.length > 0);
  assertEquals(validateRequest({ generation_date: "2026-07-12", western_sign: "Libra", eastern_sign: "Snake", scenario_id: "work-speaking-up", dry_run: true }).errors, []);
});

Deno.test("allowlist and sample cohort selection are deterministic", () => {
  const allowlist = parseAllowlist("Libra|Snake, Taurus|Horse");
  assert(allowlist.has(identityKey("Libra", "Snake")));
  assert(!allowlist.has(identityKey("Sagittarius", "Monkey")));
  const key = "2026-07-12|libra|snake|work-speaking-up";
  assertEquals(deterministicSample(key, 50), deterministicSample(key, 50));
  assert(cohortEligible({ enabled: true, mode: "allowlist", allowlist, samplePercent: 0, key: identityKey("Libra", "Snake") }));
  assert(!cohortEligible({ enabled: false, mode: "full", allowlist, samplePercent: 100, key }));
});
