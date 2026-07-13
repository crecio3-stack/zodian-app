import { assessHumanLanguage } from "./human_language_calibration.ts";

Deno.test("accepts concrete everyday wording", () => {
  const result = assessHumanLanguage(
    "You may keep doing something the same way out of habit, even when it starts creating more work for you.",
    "Change the part of your routine that is making things harder instead of easier.",
  );
  if (result.status !== "NATURAL" || result.flags.length !== 0) {
    throw new Error(JSON.stringify(result));
  }
});

Deno.test("flags framework phrasing without rewriting it", () => {
  const result = assessHumanLanguage(
    "After someone gives you credit, you may keep going instead of letting the finished work stand.",
    "Say what you did, then let the finished work stand.",
  );
  if (result.status !== "REVIEW" || result.flags.length !== 2) {
    throw new Error(JSON.stringify(result));
  }
});

Deno.test("identifies the field containing engineered language", () => {
  const result = assessHumanLanguage(
    "You notice when one person keeps ending up with a group role nobody clearly gave them.",
    null,
  );
  if (result.flags[0]?.source !== "plain_insight") {
    throw new Error(JSON.stringify(result));
  }
});
