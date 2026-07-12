import {
  assert,
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import {
  buildCanonicalLensContext,
  generateCanonicalLens,
  planCanonicalLens,
} from "../canonical-lens/adapter.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { buildModelWritingPrompt } from "./prompt.ts";
import { buildMockProvider, writeModelLens } from "./model_writer.ts";
import type { LensModelProvider } from "./types.ts";

const request = () => {
  const scenario = MATCHED_SCENARIOS[0];
  const context = buildCanonicalLensContext(libraSnakeCanonical, scenario);
  return { context, reasoning: planCanonicalLens(context), scenario };
};

Deno.test("writing prompt receives focused context, never the full canonical model", () => {
  const prompt = buildModelWritingPrompt(request());
  assertStringIncludes(prompt, "Selected canonical context");
  assertStringIncludes(prompt, "observableBehaviors");
  assert(!prompt.includes("coreDrive"));
  assert(!prompt.includes("trustBreakers"));
  assert(!prompt.includes("westernContribution"));
  assert(!prompt.includes("Libra × Snake"));
  assertStringIncludes(prompt, "observable\nbehavior");
  assertStringIncludes(prompt, "arena detail");
  assertStringIncludes(prompt, "unsupported");
  assertStringIncludes(prompt, "swapped");
});

Deno.test("mock provider works without network and preserves exact six-field shape", async () => {
  const result = await writeModelLens(request(), buildMockProvider());
  assert(result.accepted);
  assertEquals(Object.keys(result.finalLens!).sort(), [
    "deeper_read",
    "intro",
    "move",
    "pull_quote",
    "title",
    "watch_for",
  ]);
  assertEquals(result.retryCount, 0);
});

for (
  const [name, raw] of [
    ["non-json", "not json"],
    ["missing-field", JSON.stringify({ title: "Only Title" })],
    [
      "extra-field",
      JSON.stringify({
        title: "A Title",
        intro:
          "A useful question may matter more today than a confident answer delivered too soon.",
        pull_quote: "You can name the missing detail before the room moves on.",
        deeper_read:
          "A meeting can stay polite while a useful question remains unspoken. Name it while the decision can still improve.",
        watch_for: "Watch for a useful question being softened into agreement.",
        move: "Ask the direct question and let the room respond.",
        extra: "not allowed",
      }),
    ],
    ["invalid-type", JSON.stringify({ title: 42 })],
  ] as const
) {
  Deno.test(`${name} model response is rejected`, async () => {
    const provider: LensModelProvider = {
      name,
      async complete() {
        return { raw };
      },
    };
    const result = await writeModelLens(request(), provider);
    assert(!result.accepted);
    assertEquals(result.attempts.length, 3);
  });
}

Deno.test("validation errors are supplied on retries without broadening context", async () => {
  const prompts: string[] = [];
  const provider: LensModelProvider = {
    name: "retry-test",
    async complete(prompt, attempt) {
      prompts.push(prompt);
      if (attempt === 0) return { raw: "not json" };
      return {
        raw: JSON.stringify({
          title: "A Title",
          intro:
            "A useful question may matter more today than a confident answer delivered too soon.",
          pull_quote:
            "You can name the missing detail before the whole discussion moves on without you.",
          deeper_read:
            "A meeting can stay polite while a useful question remains unspoken. Name it while the decision can still improve, before another round of agreement makes the omission harder to see.",
          watch_for:
            "Watch for a useful question being softened into agreement today.",
          move:
            "Ask the direct question and let the room respond before the discussion moves on.",
        }),
      };
    },
  };
  const result = await writeModelLens(request(), provider);
  assert(result.accepted);
  assertEquals(result.retryCount, 1);
  assertStringIncludes(prompts[1], "response was not valid JSON");
  assert(!prompts[1].includes("coreDrive"));
  assert(!prompts[1].includes("trustBreakers"));
});

Deno.test("deterministic baseline remains stable and separate", async () => {
  const baseline = generateCanonicalLens(
    libraSnakeCanonical,
    MATCHED_SCENARIOS[0],
  );
  const baselineAgain = generateCanonicalLens(
    libraSnakeCanonical,
    MATCHED_SCENARIOS[0],
  );
  assertEquals(baseline.lens, baselineAgain.lens);
  assertEquals(baseline.retryCount, 0);
});
