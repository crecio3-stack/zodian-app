import {
  assert,
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { auditV321Cohort } from "./v321_cohort_qa.ts";
import {
  buildV321SystemPrompt,
  V321_COHORT_IDENTITIES,
  V321_VERSION,
} from "./v321_editorial.ts";

Deno.test("v3.2.1 is a separate overlay that preserves the frozen v3.2 system", () => {
  assertEquals(V321_COHORT_IDENTITIES.length, 3);
  assertStringIncludes(
    buildV321SystemPrompt(),
    "Write identity recognition in natural, contemporary language",
  );
  assertStringIncludes(
    buildV321SystemPrompt(),
    "make the Move express the identity-specific way",
  );
  assertEquals(V321_VERSION, "v3.2.1-editorial-hardening");
});

Deno.test("cohort QA flags interchangeable shared-scenario moves and predetermined openings", () => {
  const lens = {
    title: "Before It Drifts",
    intro:
      "Someone points out the handoff while the meeting moves toward its next topic.",
    pull_quote:
      "You notice the practical gap before anyone says what the missing piece will cost.",
    deeper_read:
      "The shared task stays vague until someone makes the next handoff visible. Your attention becomes useful when it gives the work a clear direction.",
    watch_for:
      "Watch for the moment another topic begins while the handoff still has no owner.",
    move: "Name one owner before the meeting ends and the next task begins.",
  };
  const audit = auditV321Cohort(
    ["Libra × Snake", "Taurus × Horse", "Sagittarius × Monkey"].map((
      identity,
    ) => ({ identity, scenarioId: "work-speaking-up", arena: "work", lens })),
  );
  assert(audit.swapRisk.length > 0);
  assert(audit.predeterminedOpenings.length === 3);
});
