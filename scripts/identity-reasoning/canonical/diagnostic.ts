import { libraSnakeCanonical } from "./fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "./fixtures/taurus-horse.ts";
import type { CanonicalIdentityModel } from "./types.ts";

export function diagnosticSummary(model: CanonicalIdentityModel): string {
  return [
    `Sign pair: ${model.signPair}`,
    `Central paradox: ${model.core.centralParadox}`,
    `Decision pattern: ${model.decision.defaultProcess}`,
    `Trust pattern: ${model.relationships.healthyRelationshipCondition}`,
    `Pressure loop: ${model.pressure.escalationPattern}`,
    `Restoration pattern: ${model.growth.restorationPattern}`,
    `Love logic: ${model.relationships.closenessStyle}`,
    `Work logic: ${model.work.valueCreated}`,
  ].join("\n");
}

if (import.meta.main) {
  const requested = Deno.args[0]?.toLowerCase();
  const fixtures = requested === "libra-snake"
    ? [libraSnakeCanonical]
    : requested === "taurus-horse"
    ? [taurusHorseCanonical]
    : [libraSnakeCanonical, taurusHorseCanonical];
  console.log(fixtures.map(diagnosticSummary).join("\n\n---\n\n"));
}
