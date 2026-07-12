import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { buildPlainEnglishPrompt } from "./v321_plain_english.ts";
import { meaningFlags, styleFlags } from "./v321_plain_english_validate.ts";
const lens: any = {
  title: "Make Some Space",
  intro: "You may change the room before talking about what is bothering you.",
  pull_quote:
    "You often make things comfortable before saying what needs to be said.",
  deeper_read:
    "Changing the space can help you reset. It can also delay a conversation that still needs to happen.",
  watch_for: "Notice when you start making hints instead of asking directly.",
  move: "Make room to reset, then say what needs to change.",
};
Deno.test("plain-English pass preserves six fields and flags style only", () => {
  assert(buildPlainEnglishPrompt(lens).includes("Preserve meaning"));
  assertEquals(styleFlags(lens), []);
  assertEquals(meaningFlags(lens, lens), []);
});
