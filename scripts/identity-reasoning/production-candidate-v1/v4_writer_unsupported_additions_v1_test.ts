import { assert, assertEquals } from "jsr:@std/assert";
import { unsupportedAdditionErrors } from "./v4_writer_unsupported_additions.ts";
import {
  unsupportedAdditionErrorsV1,
  VALIDATOR_HEURISTIC_CORRECTION_V1,
} from "./v4_writer_unsupported_additions_v1.ts";

const cancerOutput = {
  title: "Taking Charge Without Clear Limits",
  read: "You may step in when no one else has taken the next step and make sure it moves forward. It may be less clear where your part ends once you have taken it on.",
};
const cancerInput = {
  plain_insight: "You may step into the open handoff and take responsibility for moving the next step forward. You may be slower to state where your responsibility ends.",
  plain_action: null,
};

Deno.test("Validator Heuristic Correction v1 keeps the frozen Run 2 Cancer output as a positive regression fixture", () => {
  assertEquals(VALIDATOR_HEURISTIC_CORRECTION_V1, "pcv1-v4-writer-validator-heuristic-correction-v1");
  assert(
    unsupportedAdditionErrors(cancerOutput, cancerInput).includes(
      "output invents advice although no supported action was supplied",
    ),
    "frozen original validator must preserve the Run 2 terminal rejection",
  );
  assertEquals(unsupportedAdditionErrorsV1(cancerOutput, cancerInput), []);
});

Deno.test("Validator Heuristic Correction v1 rejects true imperative and modal advice", () => {
  const fixtureInput = { plain_insight: "You may take responsibility for the next step.", plain_action: null };
  for (const read of [
    "Make sure it moves forward.",
    "Before you leave, make sure it moves forward.",
    "You should make sure it moves forward.",
    "You need to make sure it moves forward.",
  ]) {
    assert(
      unsupportedAdditionErrorsV1({ title: "The Next Step", read }, fixtureInput).includes(
        "output invents advice although no supported action was supplied",
      ),
      `true advice must remain rejected: ${read}`,
    );
  }
});

Deno.test("Validator Heuristic Correction v1 permits clear descriptive subject behavior only", () => {
  const input = { plain_insight: "You make sure a handoff moves forward.", plain_action: null };
  assertEquals(
    unsupportedAdditionErrorsV1(
      { title: "The Handoff", read: "You make sure a handoff moves forward." },
      input,
    ),
    [],
  );
  assert(
    unsupportedAdditionErrorsV1(
      { title: "Make Sure It Moves", read: "You make sure a handoff moves forward." },
      input,
    ).includes("output invents advice although no supported action was supplied"),
    "titles remain model-generated and must still reject imperative advice",
  );
});
