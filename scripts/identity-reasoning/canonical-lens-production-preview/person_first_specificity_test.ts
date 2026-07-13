import {
  assessPersonFirstSpecificity,
  outputKeepsPersonalActor,
} from "./person_first_specificity.ts";

Deno.test("passes a concrete user-owned observation", () => {
  const result = assessPersonFirstSpecificity(
    "You may finish one task and then look for another instead of using the time to rest.",
    1,
  );
  if (result.status !== "PASS") throw new Error(JSON.stringify(result));
});

Deno.test("narrows a situation-first insight with supporting evidence", () => {
  const result = assessPersonFirstSpecificity(
    "A repeated step in your routine may keep making things harder after it stops helping.",
    1,
  );
  if (result.status !== "NARROW" || !result.requiresHumanRewrite) {
    throw new Error(JSON.stringify(result));
  }
});

Deno.test("narrows advice-first and capability-first wording without inventing a replacement", () => {
  const advice = assessPersonFirstSpecificity(
    "When you disagree with someone, name what happened first.",
    1,
  );
  const capability = assessPersonFirstSpecificity(
    "You can learn more before deciding.",
    1,
  );
  if (advice.status !== "NARROW" || capability.status !== "NARROW") {
    throw new Error(JSON.stringify({ advice, capability }));
  }
});

Deno.test("blocks an insight without observable evidence", () => {
  const result = assessPersonFirstSpecificity(
    "You may wait before deciding.",
    0,
  );
  if (result.status !== "BLOCKED") throw new Error(JSON.stringify(result));
});

Deno.test("output actor check requires an explicit user subject", () => {
  if (
    outputKeepsPersonalActor(
      "A meeting can end without anyone saying who will take the next step.",
    )
  ) {
    throw new Error("Unexpected actor detected.");
  }
  if (
    !outputKeepsPersonalActor(
      "You may move something before everyone has talked.",
    )
  ) {
    throw new Error("Expected actor was not detected.");
  }
});
