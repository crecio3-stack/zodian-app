import { assert, assertEquals } from "jsr:@std/assert";
import {
  ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_SCENARIOS_V1,
  ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1,
  auditZodianShadowNaturalReaderWriterCanaryV1Corpus,
  buildZodianShadowNaturalReaderWriterCanaryV1ProviderRequest,
  listZodianShadowNaturalReaderWriterCanaryV1Packets,
  validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest,
  validateZodianShadowNaturalReaderWriterCanaryV1Output,
} from "./zodian-shadow-natural-reader-writer-canary-v1.ts";

const APPROVED_PATHS = [
  "docs/editorial/ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1.md",
  "docs/editorial/ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1_REVIEW.md",
  "scripts/run-zodian-shadow-natural-reader-writer-canary-v1.ts",
  "supabase/functions/_shared/zodian-shadow-natural-reader-writer-canary-v1.ts",
  "supabase/functions/_shared/zodian-shadow-natural-reader-writer-canary-v1_test.ts",
];
const packets = listZodianShadowNaturalReaderWriterCanaryV1Packets();
const validOutput = {
  version: ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1,
  scenarioId: packets[0].scenarioId,
  identity: packets[0].identity,
  title: "The Part Left Unsaid",
  read: "Something has been kept smaller than it feels. You may have been smoothing it over because the mood seemed easier to protect than the truth underneath it. But the silence has not stayed neutral. It has started to decide the shape of the connection for you, quietly shifting what can be expected and what gets left alone. The point is not to force a perfect moment or control anyone's response. It is to notice that what remains unnamed is already present between you. That changes the story before anyone says another word.",
};

Deno.test("exactly four approved scenarios retain their exact committed Story Engine briefs", () => {
  assertEquals(packets.map((packet) => packet.scenarioId), [...ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_SCENARIOS_V1]);
  assertEquals(packets.length, 4);
  assertEquals(packets.map((packet) => packet.brief.dailyThread), [
    "A softened discomfort is asking for a clear limit.",
    "A quiet response is starting to stand in for a judgment of worth.",
    "A moving goal is pushing a close bond farther into the background.",
    "A loud beginning is starting to feel complete before the routine arrives.",
  ]);
  assertEquals(packets.map((packet) => packet.brief.landingDirection), [
    "What stays unnamed is already shaping the connection.",
    "The silence still has more than one meaning.",
    "What has been waiting is no longer outside the story.",
    "What happens after the excitement fades is still unwritten.",
  ]);
});

Deno.test("provider packet contains every brief field and excludes profiles, provenance, and source material", () => {
  for (const packet of packets) {
    for (const value of [packet.brief.dailyThread, packet.brief.centralTension, packet.brief.readerQuestion, packet.brief.hookDirection, packet.brief.perspectiveShift, packet.brief.landingDirection]) assert(packet.prompt.includes(value));
    for (const forbidden of ["sourceId", "provenance", "coreMotivations", "recurringStrengths", "selectedIdentitySignal", "Suzanne White", "canonical source"]) assert(!packet.prompt.includes(forbidden));
  }
  assert(packets[0].prompt.includes("write only that story"));
  assert(packets[0].prompt.includes('"westernSign":"Libra"'));
  assert(packets[0].prompt.includes("Do not explain astrology"));
  assert(packets[0].prompt.includes("detailed external scene"));
  assert(packets[0].prompt.includes("Preserve the brief's story, not its sentences"));
  assert(packets[0].prompt.includes("reveal what is already changing"));
  assert(packets[0].prompt.includes("At most one optional action-oriented sentence"));
  assert(packets[0].prompt.includes("Do not default to a contrast sentence beginning with “But”"));
});

Deno.test("provider request preflight permits only the approved gpt-5.6-terra request shape", () => {
  const request = buildZodianShadowNaturalReaderWriterCanaryV1ProviderRequest(packets[0]);
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest(request), []);
  assert(!("temperature" in request));
  assertEquals(request.model, "gpt-5.6-terra");
  assertEquals(request.text.format.type, "json_object");
  assertEquals(request.max_output_tokens, 500);
  assert(validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest({ ...request, temperature: 0.2 }).some((finding) => finding.includes("temperature")));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest({ ...request, model: "other" }).some((finding) => finding.includes("model")));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest({ ...request, text: {} }).some((finding) => finding.includes("json_object")));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest({ ...request, max_output_tokens: 1 }).some((finding) => finding.includes("max_output_tokens")));
});

Deno.test("valid output passes and exact attribution is retained for contract failures", () => {
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1Output(validOutput, packets[0]), []);
  const findings = validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, scenarioId: "wrong", identity: { westernSign: "Wrong", chineseSign: "Wrong" } }, packets[0]);
  assert(findings.some((finding) => finding.field === "scenarioId" && finding.code === "incorrect_scenario" && finding.severity === "error"));
  assert(findings.some((finding) => finding.field === "identity" && finding.code === "incorrect_identity" && finding.severity === "error"));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({}, packets[0]).some((finding) => finding.field === "version"));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, identity: "Libra × Snake" }, packets[0]).some((finding) => finding.field === "identity"));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, identity: { westernSign: "Libra" } }, packets[0]).some((finding) => finding.field === "identity"));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, extra: true }, packets[0]).some((finding) => finding.code === "unexpected_field"));
});

Deno.test("narrow canary validator rejects prohibited reader-facing material", () => {
  const cases: Array<[string, Partial<typeof validOutput>, string]> = [
    ["astrology", { read: validOutput.read + " Mercury is in retrograde." }, "astrology_mechanics"],
    ["sign", { title: "Libra Knows" }, "sign_name"],
    ["scene", { read: validOutput.read + " Your manager waits in the office." }, "invented_scene"],
    ["therapy", { read: validOutput.read + " This is emotional regulation." }, "therapy_or_corporate_language"],
    ["metadata", { read: validOutput.read + " The editorial brief is clear." }, "metadata_reference"],
    ["multiple themes", { read: validOutput.read + " In a different area, everything is changing too." }, "multiple_themes"],
    ["repetition", { read: `${validOutput.read} Something has been kept smaller than it feels. Something has been kept smaller than it feels.` }, "excessive_repetition"],
  ];
  for (const [, override, code] of cases) assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, ...override }, packets[0]).some((finding) => finding.code === code));
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, read: validOutput.read.replace("But the silence", "Meanwhile, the silence") }, packets[0]).filter((finding) => finding.code === "multiple_themes"), []);
});

Deno.test("mechanical brief copying is attributed while newly phrased transformation passes", () => {
  const copied = { ...validOutput, title: packets[0].brief.hookDirection, read: `${packets[0].brief.dailyThread} ${packets[0].brief.centralTension} ${packets[0].brief.readerQuestion} ${validOutput.read}` };
  const findings = validateZodianShadowNaturalReaderWriterCanaryV1Output(copied, packets[0]);
  assert(findings.some((finding) => finding.code === "mechanical_brief_copy" && finding.severity === "warning"));
  assert(findings.some((finding) => finding.code === "mechanical_hook_title" && finding.severity === "warning"));
  const hookCopied = { ...validOutput, read: `${packets[0].brief.hookDirection} ${validOutput.read}` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(hookCopied, packets[0]).some((finding) => finding.code === "hook_copied_at_opening" && finding.severity === "error" && finding.matchedBriefField === "hookDirection"));
  const landingCopied = { ...validOutput, read: `${validOutput.read} ${packets[0].brief.landingDirection}` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(landingCopied, packets[0]).some((finding) => finding.code === "landing_copied_at_ending" && finding.severity === "error" && finding.matchedBriefField === "landingDirection"));
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1Output(validOutput, packets[0]), []);
  const repeated = { ...validOutput, read: `${validOutput.read} Something has been kept smaller than it feels.` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(repeated, packets[0]).some((finding) => finding.code === "repeated_opening_ending" && finding.severity === "warning"));
});

Deno.test("dominant advice fails while observational second person remains allowed", () => {
  const advice = { ...validOutput, read: `${validOutput.read} You need to act now. You should make the limit clear. It is time to stop waiting.` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(advice, packets[0]).some((finding) => finding.code === "commands_dominate" && finding.severity === "error"));
  const genericEnding = { ...validOutput, read: `${validOutput.read} Keep going.` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(genericEnding, packets[0]).some((finding) => finding.code === "generic_advice_ending" && finding.severity === "error"));
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1Output(validOutput, packets[0]).filter((finding) => finding.code === "commands_dominate"), []);
});

Deno.test("observation-first action budget protects limit and choice reads", () => {
  const observational = { ...validOutput, read: "Something has been kept smaller than it feels. You have been smoothing it over because the mood seemed easier to protect. The silence has started changing the shape of the connection before anyone names it. What stays unspoken is already setting part of the balance between you." };
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1Output(observational, packets[0]).filter((finding) => finding.severity === "error"), []);
  const mildAfterTension = { ...validOutput, read: `${validOutput.read} Naming it may make the pattern easier to see. The balance has already changed.` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(mildAfterTension, packets[0]).some((finding) => finding.code === "mild_action_orientation" && finding.severity === "warning"));
  const earlyAdvice = { ...validOutput, read: `Once you say it, everything becomes clearer. ${validOutput.read}` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(earlyAdvice, packets[0]).some((finding) => finding.code === "advice_before_tension"));
  const actionShift = { ...validOutput, read: `Something has been kept smaller than it feels. The silence has started changing the balance. Set the boundary. What remains unspoken is already shaping the connection.` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(actionShift, packets[0]).some((finding) => finding.code === "action_recommendation_shift"));
});

Deno.test("action-based landings fail while recognition landings remain allowed", () => {
  for (const [ending, code] of [["Set the boundary.", "direct_command_ending"], ["You are allowed to step back.", "permission_ending"], ["The next step is to speak up.", "next_step_ending"]] as const) {
    assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, read: `${validOutput.read} ${ending}` }, packets[0]).some((finding) => finding.code === code));
  }
  const unresolved = { ...validOutput, read: `${validOutput.read} The meaning of the silence is clearer, even if the answer is not.` };
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1Output(unresolved, packets[0]).filter((finding) => finding.severity === "error"), []);
});

Deno.test("cross-read audit reports repeated But turns and ending structures", () => {
  const reads = ["Opening one. But the meaning changes here. Same ending.", "Opening two. But the meaning changes there. Same ending.", "Opening three. But the meaning changes again. Same ending.", "Opening four. A different turn appears. Same ending."]
    .map((read, index) => ({ ...validOutput, scenarioId: `test-${index}`, read }));
  const findings = auditZodianShadowNaturalReaderWriterCanaryV1Corpus(reads);
  assert(findings.some((finding) => finding.code === "repeated_but_turn"));
  assert(findings.some((finding) => finding.code === "repeated_ending_structure"));
});

Deno.test("first-canary review evidence preserves the original four generated reads", async () => {
  const review = await Deno.readTextFile(new URL("../../../docs/editorial/ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1_REVIEW.md", import.meta.url));
  for (const phrase of ["Bigger Than It Looks", "What the Silence Holds", "What Fell Behind", "After the Entrance", "The Small Thing", "The Unfilled Space", "The Hidden Cost", "After the Applause", "This may be more important than you have let yourself admit.", "Something can feel finished just because it arrived with force.", "That “small” irritation has been taking up far more room than anyone admits.", "Why does this already feel done when it has barely begun?"]) assert(review.includes(phrase));
});

Deno.test("shadow module is provider-free and cannot reach production or infrastructure", async () => {
  const source = await Deno.readTextFile(new URL("./zodian-shadow-natural-reader-writer-canary-v1.ts", import.meta.url));
  const executable = source.replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, "");
  assertEquals([...executable.matchAll(/^\s*import\s.+$/gm)].length, 2);
  for (const forbidden of [/\bfetch\s*\(/i, /api\.openai\.com/i, /OPENAI_API_KEY/i, /\bcreateClient\s*\(/i, /\.(?:from|rpc)\s*\(/i, /natural-reader-writer-v1-production/i, /production.*prompt/i, /production.*validat/i, /generate-daily-rituals/i, /\b(?:publish|publication|resolver|scheduler|cron)\b/i]) assert(!forbidden.test(executable));
});

Deno.test("an opted-in canary revision changes only approved implementation files", async () => {
  const permission = await Deno.permissions.query({ name: "env", variable: "ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1_REVISION" });
  if (permission.state !== "granted") return;
  const revision = Deno.env.get("ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1_REVISION");
  if (!revision) return;
  const result = await new Deno.Command("git", { args: ["diff-tree", "--no-commit-id", "--name-only", "-r", revision] }).output();
  assertEquals(result.code, 0);
  const paths = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean);
  assert(paths.length > 0);
  assert(paths.every((path) => APPROVED_PATHS.includes(path)));
});
