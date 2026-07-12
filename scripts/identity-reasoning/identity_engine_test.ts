import {
  assertEquals,
  assertMatch,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { reasoningPrompt, writingPrompt } from "./prompts.ts";
import { type IdentityReasoningPlan, SECTION_KEYS } from "./types.ts";
import { auditIdentity } from "./validate.ts";

Deno.test("reasoning and writing are separate prompt stages", () => {
  const request = { western_sign: "Aries", chinese_sign: "Rat" };
  assertMatch(reasoningPrompt(request), /IdentityReasoningPlan/);
  const plan = {
    sign_pair: "Aries × Rat",
    section_plans: [],
  } as unknown as IdentityReasoningPlan;
  assertMatch(
    writingPrompt(request, plan),
    /internal plan as the source of truth/,
  );
});

Deno.test("all seven distinct section keys are contracted", () => {
  assertEquals(new Set(SECTION_KEYS).size, 7);
});

Deno.test("audit catches astrological openers and thin prose", () => {
  const thin = Object.fromEntries(
    SECTION_KEYS.map((key) => [key, "As an Aries, you act."]),
  ) as Record<typeof SECTION_KEYS[number], string>;
  const audit = auditIdentity(thin);
  assertEquals(audit.passed, false);
  assertMatch(audit.issues.join("\n"), /forbidden astrological opener/);
});

Deno.test("both editorial review previews pass the static audit", async () => {
  for (const name of ["aries-rat", "pisces-horse", "taurus-horse"]) {
    const url = new URL(
      `./previews/${name}.editorial-review.json`,
      import.meta.url,
    );
    const preview = JSON.parse(await Deno.readTextFile(url));
    assertEquals(auditIdentity(preview).issues, []);
  }
});
