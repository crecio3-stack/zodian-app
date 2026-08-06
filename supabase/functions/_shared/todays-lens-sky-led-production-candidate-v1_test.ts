import { assert, assertEquals, assertStringIncludes } from "jsr:@std/assert";
import {
  buildSkyLedProductionPacket,
  generateSkyLedHoroscope,
  compressSkyLedHoroscope,
  skyLedCompressionEditorPrompt,
  skyLedWriterPrompt,
  auditSkyLedBatchDiversity,
  selectSkyLedBatchRewriteCandidates,
  validateSkyLedPlainLanguage,
  validateSkyLedTemplateLanguage,
  validateSkyLedCompression,
} from "./todays-lens-sky-led-production-candidate-v1.ts";

const packet = buildSkyLedProductionPacket({
  contentDate: "2026-08-02",
  westernSign: "Libra",
  chineseSign: "Snake",
});

Deno.test("sky-led writer carries the plain-language production requirements", () => {
  const prompt = skyLedWriterPrompt(packet);
  for (const phrase of [
    "smart 13–14 year old",
    "trusted older sibling or friend",
    "inform your choices",
    "energetic shift",
    "silently rewrite any sentence",
    "Prefer specific everyday language over generic dramatic shorthand",
    "keep the astrology and Western/Eastern identity interaction visible",
  ]) assertStringIncludes(prompt, phrase);
});

Deno.test("sky-led editor retains concrete situation, astrology, and identity guidance", () => {
  const prompt = skyLedCompressionEditorPrompt({ rawRead: "A conversation needs a clear answer.", packet, recentReads: [] });
  const writerPrompt = skyLedWriterPrompt(packet);
  assertStringIncludes(prompt, "concrete situation supported by the packet");
  assertStringIncludes(prompt, "Do not invent specificity or remove useful astrology");
  assertStringIncludes(writerPrompt, "conversation, disagreement, invitation, offer");
});

Deno.test("sky-led plain-language gate accepts everyday copy and rejects banned formal phrasing", () => {
  assertEquals(
    validateSkyLedPlainLanguage(
      "A plan may need one more look today. Pay attention to the detail that feels off, then say what you need before anyone assumes the answer.",
    ),
    { accepted: true, findings: [] },
  );
  const rejected = validateSkyLedPlainLanguage(
    "Let this energetic shift inform your choices and allow yourself to navigate the obligation.",
  );
  assert(!rejected.accepted);
  assert(rejected.findings.some((item) =>
    item.includes("inform your choices") || item.includes("energetic shift")
  ));
});

Deno.test("sky-led writer retries a banned phrase and returns valid JSON output", async () => {
  let requests = 0;
  const result = await generateSkyLedHoroscope({
    apiKey: "test",
    model: "gpt-5.6-terra",
    packet,
    fetchImpl: async () => {
      requests++;
      const read = requests === 1
        ? "Let this energetic shift inform your choices today."
        : "A plan may need one more look today. Pay attention to the detail that feels off, then say what you need before anyone assumes the answer.";
      return new Response(JSON.stringify({
        id: `response-${requests}`,
        status: "completed",
        output: [{ content: [{ type: "output_text", text: JSON.stringify({ read }) }] }],
      }), { status: 200 });
    },
  });
  assertEquals(requests, 2);
  assert(result.output);
  assertEquals(Object.keys(result.output!).sort(), ["read"]);
  assertEquals(validateSkyLedPlainLanguage(result.output!.read).accepted, true);
});

Deno.test("compression editor receives the saved raw read and rejects a changed opening", async () => {
  const rawRead = "A plan needs one more look today. The Moon makes the small detail harder to brush aside.";
  let prompt = "";
  const result = await compressSkyLedHoroscope({
    apiKey: "test", model: "gpt-5.6-terra", rawRead, packet,
    fetchImpl: async (_input, init) => {
      prompt = String((init as globalThis.RequestInit | undefined)?.body);
      return new Response(JSON.stringify({ status: "completed", output: [{ content: [{ type: "output_text", text: JSON.stringify({ read: "Something feels off today. The Moon makes it harder to brush aside." }) }] }] }), { status: 200 });
    },
  });
  assertStringIncludes(prompt, rawRead);
  assert(result.output);
  assert(!validateSkyLedCompression({ rawRead, editedRead: result.output!.read }).accepted);
});

Deno.test("compression editor can retain a valid saved raw read when no subtraction is safe", () => {
  const rawRead = "A plan needs one more look today. The Moon makes the small detail harder to brush aside.";
  assertEquals(validateSkyLedCompression({ rawRead, editedRead: rawRead }), { accepted: true, findings: [] });
});

Deno.test("batch audit rejects the observed soft-foggy-to-afternoon structural family", () => {
  const reads = [
    "Sunday starts soft and a little foggy. By afternoon, say what you need without making a scene.",
    "Sunday starts a little foggy. By afternoon, your patience runs thinner and you may want to say exactly what you think.",
    "Sunday starts soft, but do not mistake that for weakness. By afternoon, your mood gets bolder and more direct.",
  ].map((read, index) => ({ id: `read-${index}`, read }));
  const audit = auditSkyLedBatchDiversity(reads);
  assert(!audit.accepted);
  assert(audit.findings.filter((finding) =>
    finding.reasons.includes("time_of_day_scaffolding") &&
      finding.reasons.includes("observed_soft_foggy_direct_action_template")
  ).length === 3);
});

Deno.test("writer-level template gate rejects the exact Libra Snake failure", () => {
  const rejected = validateSkyLedTemplateLanguage("Sunday starts a little foggy. By afternoon, your mood gets more direct.");
  assert(!rejected.accepted);
  assertEquals(rejected.findings.sort(), ["observed_template_language", "time_of_day_scaffolding", "weekday_led_scaffolding"]);
});

Deno.test("writer-level template gate rejects the three checkpoint misses", () => {
  for (const read of ["Sunday puts you in charge of more than you asked for.", "An emotional fog can make a small detail feel bigger.", "A loose question may follow you around all day."]) {
    assert(!validateSkyLedTemplateLanguage(read).accepted);
  }
});

Deno.test("batch audit permits harmless shared generic language", () => {
  const audit = auditSkyLedBatchDiversity([
    { id: "one", read: "A delayed answer may matter more than it first seems. You may feel more than ready to reply, but wait for the missing detail." },
    { id: "two", read: "A change at home may need a practical answer. You may feel more than ready to fix it, but start with what actually changed." },
  ]);
  assertEquals(audit, { accepted: true, findings: [] });
});

Deno.test("batch audit permits one proposition expressed through distinct structures", () => {
  const audit = auditSkyLedBatchDiversity([
    { id: "one", read: "A plan changes after you already pictured the day. Before you make a decision, check which part is actually inconvenient." },
    { id: "two", read: "The useful answer is not a faster yes. Someone has changed the terms, so name the practical cost before agreeing." },
  ]);
  assertEquals(audit, { accepted: true, findings: [] });
});

Deno.test("writer prompt size is independent of accepted batch reads", () => {
  const baseline = skyLedWriterPrompt(packet);
  assertEquals(skyLedWriterPrompt(packet, []), baseline);
});

Deno.test("retry prompt retains family guidance while requesting shorter sentences", () => {
  const prompt = skyLedWriterPrompt(packet, [], ["opening_family_mismatch:tension", "plain_language_overlong_sentence"], "tension");
  assertStringIncludes(prompt, "Use shorter sentences and split long ideas naturally.");
  assertStringIncludes(prompt, "assigned tension family");
});

Deno.test("batch rewrite selection chooses only the later member of a flagged pair", () => {
  const selection = selectSkyLedBatchRewriteCandidates([
    { id: "earlier", read: "A small delay changes the plan before you decide what still works today." },
    { id: "later", read: "A small delay changes the plan before you decide what still works today." },
  ]);
  assertEquals(selection.candidateIds, ["later"]);
});
