import { assert, assertEquals } from "jsr:@std/assert";
import {
  auditLightweightRepetition,
  type FinalRead,
} from "./lightweight_repetition.ts";

const base: FinalRead = {
  stableCaseId: "one",
  title: "Pause First",
  read: "You may push through before you reassess.",
  plainInsight: "You may push through before you reassess.",
  plainAction: null,
};

Deno.test("exact duplicates reject without proposing a rewrite", () => {
  const audit = auditLightweightRepetition([base, {
    ...base,
    stableCaseId: "two",
  }]);
  assertEquals(audit.disposition, "REJECT");
  assertEquals(audit.findings[0].kind, "exact_final_duplicate");
});

Deno.test("supported similarity is accepted when copy is not duplicate", () => {
  const audit = auditLightweightRepetition([
    base,
    {
      stableCaseId: "two",
      title: "Wait a Moment",
      read: "You may hold back while the next step stays unclear.",
      plainInsight: "You may hold back while the next step stays unclear.",
      plainAction: null,
    },
  ]);
  assertEquals(audit.disposition, "ACCEPT");
  assertEquals(audit.findings.length, 0);
});

Deno.test("recent same-user similarity holds rather than rewriting", () => {
  const audit = auditLightweightRepetition([base], [{
    ...base,
    stableCaseId: "recent",
  }]);
  assertEquals(audit.disposition, "HOLD");
  assert(
    audit.findings.some((finding) => finding.kind === "recent_user_repeat"),
  );
});
