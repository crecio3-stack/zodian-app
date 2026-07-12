import { V32_MODEL_WRITING_SYSTEM } from "./v3_prompt.ts";

/** Separate v3.2.1 overlay; v3.2 source and fingerprints remain untouched. */
export const V321_VERSION = "v3.2.1-editorial-hardening";
export const V321_EDITORIAL_HARDENING = `
v3.2.1 editorial hardening:
- Preserve behavior-first recognition. Show a concrete action before interpretation.
- For a shared scenario, make intro, deeper_read, watch_for, and move arise from this identity's supplied mechanism. Do not let the scenario dictate a generic action.
- Especially in work, rest, money, and opportunity, make the Move express the identity-specific way of acting, not a generic scenario remedy.
- Tighten the prose: prefer one concrete noun and one observable action over layered abstractions or multiple metaphors.
- Treat recurring phrases such as somewhere to land, the room, the moment, one small, one clear, and before X moves on as cohort-level variation signals, not mandatory bans.
- Do not frame every Lens as a guaranteed external event. Vary confident openings with When, If, In a conversation that, The next time, A small purchase can, or a recurring observation. Do not blanket-hedge with may, might, perhaps, or possibly.
- Keep warmth, psychological recognition, and ordinary language. Never name this instruction or the divergence test.`;

export function buildV321SystemPrompt(): string {
  return `${V32_MODEL_WRITING_SYSTEM}\n\n${V321_EDITORIAL_HARDENING}`;
}

export const V321_COHORT_IDENTITIES = [
  "Libra × Snake",
  "Taurus × Horse",
  "Sagittarius × Monkey",
] as const;
