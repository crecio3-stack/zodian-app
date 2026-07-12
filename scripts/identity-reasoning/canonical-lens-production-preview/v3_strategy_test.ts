import {
  assert,
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import type { ModelWritingRequest } from "../canonical-lens-model/types.ts";
import type { LensModelProvider } from "../canonical-lens-model/types.ts";
import { MATCHED_SCENARIOS } from "../canonical-lens/scenarios.ts";
import { writeModelLensV3 } from "./v3_model_writer.ts";
import { buildV3WritingPrompt } from "./v3_prompt.ts";
import {
  buildV32EditorialBrief,
  buildV3EditorialBrief,
  V2_CORPUS_EXCLUSIONS,
  V3_ENTRY_MODES,
  V3_SAMPLE_IDENTITIES,
  v3SampleKeys,
} from "./v3_sample_plan.ts";

const request = (): ModelWritingRequest => ({
  context: {
    signPair: "Taurus × Horse",
    scenario: MATCHED_SCENARIOS[0],
    selected: {
      activatedParadox: "You protect what works while needing room to move.",
      perception: "You notice the unfinished handoff before the room does.",
      decision: "You wait for evidence, then act directly.",
      pressureOrGrowth: "Pressure can turn patience into silent resistance.",
      observableBehaviors: [
        "marks the missing owner in a shared document",
        "waits through one pause before speaking",
      ],
      arenaDetail: "a meeting, shared document, owner, deadline, or handoff",
    },
  },
  reasoning: {
    activatedIdentityTension: "speaking up vs waiting meets steady autonomy",
    primaryArena: "work",
    identitySpecificRole: "the person who makes the practical gap visible",
    startingAssumption: "the work can speak for itself",
    recognition: "the handoff needs an owner before it needs more discussion",
    ordinaryLifeExpression:
      "a shared document still has no owner beside the deadline",
    blindSpot: "patience can look like agreement",
    naturalMove: "mark the missing owner, then ask one direct question",
    signInteraction: "useful",
  },
  scenario: MATCHED_SCENARIOS[0],
});

const validLens = {
  title: "Owner Beside Deadline",
  intro:
    "The blank owner field stays visible while the meeting moves toward its next topic.",
  pull_quote:
    "Your useful contribution is the practical gap everyone can see once you point to it.",
  deeper_read:
    "You can wait for enough evidence without letting the missing handoff become silent agreement. The shared document gives you a concrete place to speak, so directness serves the work instead of turning into a performance.",
  watch_for:
    "Notice when another topic begins while the owner field beside the deadline remains blank.",
  move:
    "Mark the missing owner, wait through one pause, then ask who will take the handoff.",
};

Deno.test("v3 sample covers 180 contexts and every sign family", () => {
  assertEquals(V3_SAMPLE_IDENTITIES.length, 18);
  assertEquals(
    v3SampleKeys(MATCHED_SCENARIOS.map((row) => row.arena)).length,
    180,
  );
  assertEquals(
    new Set(V3_SAMPLE_IDENTITIES.map((identity) => identity.split(" × ")[0]))
      .size,
    12,
  );
  assertEquals(
    new Set(V3_SAMPLE_IDENTITIES.map((identity) => identity.split(" × ")[1]))
      .size,
    12,
  );
  for (
    const key of [
      "Aquarius × Rat|rest",
      "Aquarius × Dog|love",
      "Pisces × Rooster|conflict",
      "Cancer × Snake|money",
      "Leo × Horse|opportunity",
    ]
  ) {
    assert(
      v3SampleKeys(MATCHED_SCENARIOS.map((row) => row.arena)).includes(key),
    );
  }
});

Deno.test("v3 editorial briefs are deterministic and distribute entry modes", () => {
  const briefs = v3SampleKeys(MATCHED_SCENARIOS.map((row) => row.arena)).map(
    (key) => {
      const [identity, arena] = key.split("|");
      return buildV3EditorialBrief(
        identity,
        arena as typeof MATCHED_SCENARIOS[number]["arena"],
      );
    },
  );
  assertEquals(
    buildV3EditorialBrief("Taurus × Horse", "work"),
    buildV3EditorialBrief("Taurus × Horse", "work"),
  );
  assertEquals(
    new Set(briefs.map((brief) => brief.entryMode)).size,
    V3_ENTRY_MODES.length,
  );
});

Deno.test("v3 prompt carries corpus exclusions without broad canonical context", () => {
  const prompt = buildV3WritingPrompt(
    request(),
    buildV3EditorialBrief("Taurus × Horse", "work"),
  );
  assertStringIncludes(prompt, "Corpus exclusions");
  assertStringIncludes(prompt, V2_CORPUS_EXCLUSIONS.exactTitles[0]);
  assertStringIncludes(prompt, "marks the missing owner");
  assert(!prompt.includes("Resources/archetypes.json"));
  assert(!prompt.includes("full canonical"));
});

Deno.test("v3.2 prompt restores ordinary voice without weakening corpus guards", () => {
  const prompt = buildV3WritingPrompt(
    request(),
    buildV32EditorialBrief("Taurus × Horse", "work"),
    {
      forbiddenTitles: ["The Specific Invitation"],
      forbiddenTitleRoots: ["specific"],
    },
    "v3.2",
  );
  assertStringIncludes(prompt, "Show the behavior before explaining what");
  assertStringIncludes(
    prompt,
    "Could this sentence appear in a strategy document?",
  );
  assertStringIncludes(prompt, "no terminal punctuation");
  assertStringIncludes(prompt, "The Specific Invitation");
  assert(!prompt.includes('"titleRoots": [\n    "name"'));
});

Deno.test("v3 retry requests only failed fields and preserves valid fields", async () => {
  const first = { ...validLens, move: "Act now." };
  const responses = [
    JSON.stringify(first),
    JSON.stringify({
      move:
        "Mark the missing owner, wait through one pause, then ask who will take the handoff.",
    }),
  ];
  const provider: LensModelProvider = {
    name: "v3-test",
    async complete() {
      return { raw: responses.shift()! };
    },
  };
  const result = await writeModelLensV3({
    request: request(),
    provider,
    brief: buildV3EditorialBrief("Taurus × Horse", "work"),
  });
  assert(result.accepted);
  assertEquals(result.retryCount, 1);
  assertEquals(result.attempts[1].requestedFields, ["move"]);
  assertEquals(result.finalLens?.title, validLens.title);
  assertEquals(result.finalLens?.intro, validLens.intro);
  assertEquals(result.attempts[1].validFieldsPreserved, true);
});

Deno.test("v3 corpus validation can repair a title without rewriting other fields", async () => {
  const responses = [
    JSON.stringify(validLens),
    JSON.stringify({ title: "Deadline Needs Ownership" }),
  ];
  const provider: LensModelProvider = {
    name: "v3-test",
    async complete() {
      return { raw: responses.shift()! };
    },
  };
  const result = await writeModelLensV3({
    request: request(),
    provider,
    brief: buildV3EditorialBrief("Taurus × Horse", "work"),
    additionalValidation: (lens) =>
      lens.title === validLens.title
        ? ["title duplicates an existing sample title"]
        : [],
  });
  assert(result.accepted);
  assertEquals(result.attempts[1].requestedFields, ["title"]);
  assertEquals(result.finalLens?.intro, validLens.intro);
  assertEquals(result.finalLens?.title, "Deadline Needs Ownership");
});
