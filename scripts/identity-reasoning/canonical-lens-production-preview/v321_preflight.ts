import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import {
  buildV321SystemPrompt,
  V321_COHORT_IDENTITIES,
  V321_VERSION,
} from "./v321_editorial.ts";

if (!Deno.args.includes("--preflight")) {
  throw new Error(
    "v3.2.1 is not approved for provider generation. Use --preflight only.",
  );
}
const scenarios = MATCHED_SCENARIOS.map((scenario) => scenario.id).sort();
const manifest = V321_COHORT_IDENTITIES.flatMap((identity) =>
  scenarios.map((scenarioId) => ({ identity, scenarioId }))
);
if (
  manifest.length !== 30 ||
  new Set(manifest.map((row) => `${row.identity}|${row.scenarioId}`)).size !==
    30
) throw new Error("invalid v3.2.1 controlled cohort");
console.log(JSON.stringify(
  {
    developmentOnly: true,
    version: V321_VERSION,
    providerCalls: 0,
    identities: [...V321_COHORT_IDENTITIES],
    scenarios,
    plannedOutputs: manifest.length,
    systemPromptSha256: Array.from(
      new Uint8Array(
        await crypto.subtle.digest(
          "SHA-256",
          new TextEncoder().encode(buildV321SystemPrompt()),
        ),
      ),
    ).map((byte) => byte.toString(16).padStart(2, "0")).join(""),
    noProductionWrites: true,
    manifest,
  },
  null,
  2,
));
