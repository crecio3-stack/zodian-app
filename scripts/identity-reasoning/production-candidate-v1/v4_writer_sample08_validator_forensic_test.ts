import { unsupportedAdditionErrors } from "./v4_writer_unsupported_additions.ts";

const sample08 = {
  title: "When Attention Stays on You",
  plainInsight:
    "After getting public credit, you may keep the attention on yourself longer than you need to.",
  read:
    "After getting public credit, you may keep the attention on yourself longer than you need to.",
  plainAction: null,
};

function currentHeuristicErrors(
  title: string,
  read: string,
  plainAction: string | null,
) {
  const text = `${title} ${read}`.toLowerCase();
  const errors: string[] = [];
  if (/\byou\s+(?:want|fear|need|feel|believe|are afraid)\b/.test(text)) {
    errors.push("output adds an unsupported motive, emotion, or inner state");
  }
  if (
    plainAction === null &&
    /\b(?:try to|remember to|make sure|you should|you need to)\b/.test(text)
  ) {
    errors.push(
      "output invents advice although no supported action was supplied",
    );
  }
  return errors;
}

Deno.test("Sample 08 reproduces the stored false positive from verbatim approved input", () => {
  if (sample08.read !== sample08.plainInsight) {
    throw new Error(
      "Fixture must preserve the exact input/output equivalence.",
    );
  }
  const errors = currentHeuristicErrors(
    sample08.title,
    sample08.read,
    sample08.plainAction,
  );
  if (
    JSON.stringify(errors) !==
      JSON.stringify([
        "output adds an unsupported motive, emotion, or inner state",
        "output invents advice although no supported action was supplied",
      ])
  ) {
    throw new Error(
      "Current heuristic no longer reproduces the stored failure.",
    );
  }
});

Deno.test("narrow fix permits verbatim input while retaining title checks", () => {
  const errors = unsupportedAdditionErrors(
    { title: sample08.title, read: sample08.read },
    {
      plain_insight: sample08.plainInsight,
      plain_action: sample08.plainAction,
    },
  );
  if (errors.length !== 0) {
    throw new Error(
      "Verbatim plain insight should not be classified as an addition.",
    );
  }
  const titleErrors = unsupportedAdditionErrors(
    { title: "You Need to Act", read: sample08.read },
    {
      plain_insight: sample08.plainInsight,
      plain_action: sample08.plainAction,
    },
  );
  if (titleErrors.length !== 2) {
    throw new Error(
      "The narrow proposal must continue to scan model-generated titles.",
    );
  }
});

Deno.test("narrow fix continues to scan a read when the writer adds wording", () => {
  const errors = unsupportedAdditionErrors(
    {
      title: sample08.title,
      read: `${sample08.read} You need to stop.`,
    },
    {
      plain_insight: sample08.plainInsight,
      plain_action: sample08.plainAction,
    },
  );
  if (
    !errors.includes(
      "output invents advice although no supported action was supplied",
    )
  ) {
    throw new Error(
      "A non-verbatim read must remain subject to the unsupported-advice scan.",
    );
  }
});
