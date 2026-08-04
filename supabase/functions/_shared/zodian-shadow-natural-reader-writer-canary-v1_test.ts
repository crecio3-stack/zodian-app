import { assert, assertEquals } from "jsr:@std/assert";
import {
  ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_SCENARIOS_V1,
  ZODIAN_SHADOW_NATURAL_READER_WRITER_CANARY_V1,
  listZodianShadowNaturalReaderWriterCanaryV1Packets,
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
});

Deno.test("valid output passes and exact attribution is retained for contract failures", () => {
  assertEquals(validateZodianShadowNaturalReaderWriterCanaryV1Output(validOutput, packets[0]), []);
  const findings = validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, scenarioId: "wrong", identity: { westernSign: "Wrong", chineseSign: "Wrong" } }, packets[0]);
  assert(findings.some((finding) => finding.field === "scenarioId" && finding.code === "incorrect_scenario" && finding.severity === "error"));
  assert(findings.some((finding) => finding.field === "identity" && finding.code === "incorrect_identity" && finding.severity === "error"));
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({}, packets[0]).some((finding) => finding.field === "version"));
});

Deno.test("narrow canary validator rejects prohibited reader-facing material", () => {
  const cases: Array<[string, Partial<typeof validOutput>, string]> = [
    ["astrology", { read: validOutput.read + " Mercury is in retrograde." }, "astrology_mechanics"],
    ["sign", { title: "Libra Knows" }, "sign_name"],
    ["scene", { read: validOutput.read + " Your manager waits in the office." }, "invented_scene"],
    ["therapy", { read: validOutput.read + " This is emotional regulation." }, "therapy_or_corporate_language"],
    ["metadata", { read: validOutput.read + " The editorial brief is clear." }, "metadata_reference"],
    ["repetition", { read: `${validOutput.read} Something has been kept smaller than it feels. Something has been kept smaller than it feels.` }, "excessive_repetition"],
  ];
  for (const [, override, code] of cases) assert(validateZodianShadowNaturalReaderWriterCanaryV1Output({ ...validOutput, ...override }, packets[0]).some((finding) => finding.code === code));
});

Deno.test("mechanical copying and repetitive framing return warnings without semantic classification", () => {
  const copied = { ...validOutput, title: packets[0].brief.hookDirection, read: `${packets[0].brief.dailyThread} ${packets[0].brief.centralTension} ${packets[0].brief.readerQuestion} ${validOutput.read}` };
  const findings = validateZodianShadowNaturalReaderWriterCanaryV1Output(copied, packets[0]);
  assert(findings.some((finding) => finding.code === "mechanical_brief_copy" && finding.severity === "warning"));
  assert(findings.some((finding) => finding.code === "mechanical_hook_title" && finding.severity === "warning"));
  const repeated = { ...validOutput, read: `${validOutput.read} Something has been kept smaller than it feels.` };
  assert(validateZodianShadowNaturalReaderWriterCanaryV1Output(repeated, packets[0]).some((finding) => finding.code === "repeated_opening_ending" && finding.severity === "warning"));
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
  const paths = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean).sort();
  assertEquals(paths, [...APPROVED_PATHS].sort());
});
