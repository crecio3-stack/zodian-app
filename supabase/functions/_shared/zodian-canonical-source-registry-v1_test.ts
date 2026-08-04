import { assert, assertEquals } from "jsr:@std/assert";
import {
  getZodianCanonicalSourceRecordV1,
  listActiveApprovedZodianCanonicalSourceIdsV1,
  sourceMayInformDistilledEditorialProfiles,
  type ZodianCanonicalSourceRecordV1,
  validateZodianCanonicalSourceRecordV1,
  zodianCanonicalSourceExistsV1,
} from "./zodian-canonical-source-registry-v1.ts";

const SOURCE_ID = "source:suzanne-white:new-astrology-21st-century";
const APPROVED_MILESTONE_PATHS = [
  "docs/editorial/ZODIAN_CANONICAL_SOURCE_REGISTRY_V1.md",
  "supabase/functions/_shared/zodian-canonical-source-registry-v1.ts",
  "supabase/functions/_shared/zodian-canonical-source-registry-v1_test.ts",
];

function initialRecord(): ZodianCanonicalSourceRecordV1 {
  const record = getZodianCanonicalSourceRecordV1(SOURCE_ID);
  if (!record) throw new Error("Initial registry record is missing.");
  return record;
}

function codes(record: ZodianCanonicalSourceRecordV1) {
  return validateZodianCanonicalSourceRecordV1(record).map((finding) => `${finding.field}:${finding.code}`);
}

Deno.test("initial Suzanne White record is valid with exact identity coverage and policy", () => {
  const record = initialRecord();
  assertEquals(validateZodianCanonicalSourceRecordV1(record), []);
  assertEquals(record.sourceId, SOURCE_ID);
  assertEquals(record.coverage, { type: "all-combined-identities" });
  assert(record.transformationPolicy.mayInformDistilledEditorialProfiles);
  assertEquals(record.transformationPolicy.mayStoreRawPassages, false);
  assertEquals(record.transformationPolicy.mayPropagateSourceProse, false);
  assertEquals(record.transformationPolicy.requiresIndependentWording, true);
});

Deno.test("required source metadata and invalid coverage fail with attribution", () => {
  const record = initialRecord();
  record.sourceId = " ";
  record.sourceVersion = "";
  record.title = "";
  record.coverage = { type: "selected-combined-identities", identities: [] };
  assert(codes(record).includes("sourceId:required"));
  assert(codes(record).includes("sourceVersion:required"));
  assert(codes(record).includes("title:required"));
  assert(codes(record).includes("coverage.identities:required"));
});

Deno.test("blank optional metadata, unknown enums, and blank replacement IDs fail", () => {
  const record = initialRecord();
  record.author = " ";
  record.status = "unknown" as ZodianCanonicalSourceRecordV1["status"];
  record.sourceType = "unknown" as ZodianCanonicalSourceRecordV1["sourceType"];
  record.replacesSourceId = " ";
  const findings = codes(record);
  assert(findings.includes("author:required"));
  assert(findings.includes("status:unknown_status"));
  assert(findings.includes("sourceType:unknown_source_type"));
  assert(findings.includes("replacesSourceId:required"));
});

Deno.test("duplicate identities, signs, and blank coverage values fail", () => {
  const identities = initialRecord();
  identities.coverage = { type: "selected-combined-identities", identities: [
    { westernSign: "Aries", chineseSign: "Rat" },
    { westernSign: "Aries", chineseSign: "Rat" },
    { westernSign: "", chineseSign: "Ox" },
  ] };
  assert(codes(identities).includes("coverage.identities:duplicate_identity"));
  assert(codes(identities).includes("coverage.identities.westernSign:required"));

  const signs = initialRecord();
  signs.coverage = { type: "western-signs", signs: ["Aries", "Aries", " "] };
  assert(codes(signs).includes("coverage.signs:duplicate_sign"));
  assert(codes(signs).includes("coverage.signs:required"));

  const emptySigns = initialRecord();
  emptySigns.coverage = { type: "chinese-signs", signs: [] };
  assert(codes(emptySigns).includes("coverage.signs:required"));
});

Deno.test("invalid policy and self-replacement fail", () => {
  const record = initialRecord();
  record.replacesSourceId = record.sourceId;
  record.transformationPolicy = {
    mayInformDistilledEditorialProfiles: false,
    mayStoreRawPassages: true,
    mayPropagateSourceProse: true,
    requiresIndependentWording: false,
  } as unknown as ZodianCanonicalSourceRecordV1["transformationPolicy"];
  const findings = codes(record);
  assert(findings.includes("replacesSourceId:self_replacement"));
  assert(findings.includes("transformationPolicy.mayStoreRawPassages:raw_passages_permitted"));
  assert(findings.includes("transformationPolicy.mayPropagateSourceProse:source_prose_permitted"));
  assert(findings.includes("transformationPolicy.requiresIndependentWording:independent_wording_not_required"));
  assert(findings.includes("transformationPolicy.mayInformDistilledEditorialProfiles:approved_source_cannot_inform_profiles"));
});

Deno.test("lookup and approved listing are exact, safe, and deterministic", () => {
  assertEquals(getZodianCanonicalSourceRecordV1("unknown"), undefined);
  assertEquals(zodianCanonicalSourceExistsV1(SOURCE_ID), true);
  assertEquals(zodianCanonicalSourceExistsV1("unknown"), false);
  assertEquals(sourceMayInformDistilledEditorialProfiles(SOURCE_ID), true);
  assertEquals(sourceMayInformDistilledEditorialProfiles("unknown"), false);
  assertEquals(listActiveApprovedZodianCanonicalSourceIdsV1(), [SOURCE_ID]);
  assertEquals(listActiveApprovedZodianCanonicalSourceIdsV1(), [SOURCE_ID]);
});

Deno.test("returned records cannot mutate canonical registry metadata", () => {
  const copy = initialRecord();
  copy.title = "changed";
  copy.transformationPolicy.mayInformDistilledEditorialProfiles = false;
  assertEquals(initialRecord().title, "The New Astrology for the 21st Century");
  assertEquals(initialRecord().transformationPolicy.mayInformDistilledEditorialProfiles, true);
});

Deno.test("registry record contains metadata and policy but no raw source-content fields", () => {
  const record = initialRecord() as Record<string, unknown>;
  for (const forbiddenField of ["excerpt", "passage", "content", "pages", "traits", "notes"]) {
    assert(!(forbiddenField in record));
  }
});

Deno.test("the module has no imports or execution-path references", async () => {
  const source = await Deno.readTextFile(new URL("./zodian-canonical-source-registry-v1.ts", import.meta.url));
  const executableSource = source.replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, "");
  assertEquals([...executableSource.matchAll(/^\s*import\s.+$/gm)], []);
  for (const forbiddenReference of [
    /\bfetch\s*\(/i, /\b(?:openai|anthropic|gemini|model)\b/i,
    /\bcreateClient\s*\(/i, /\.(?:from|rpc)\s*\(/i,
    /\b(?:publish|publication|resolver|scheduler|cron)\b/i,
    /natural-reader-writer-v1-production/i, /generate-daily-rituals/i,
    /zodian-story-engine-v1/i, /zodian-identity-editorial-layer-v1/i,
  ]) assert(!forbiddenReference.test(executableSource));
});

Deno.test("an opted-in registry milestone revision changes only approved paths", async () => {
  const permission = await Deno.permissions.query({ name: "env", variable: "ZODIAN_CANONICAL_SOURCE_REGISTRY_V1_MILESTONE_REVISION" });
  if (permission.state !== "granted") return;
  const revision = Deno.env.get("ZODIAN_CANONICAL_SOURCE_REGISTRY_V1_MILESTONE_REVISION");
  if (!revision) return;
  const result = await new Deno.Command("git", { args: ["diff-tree", "--no-commit-id", "--name-only", "-r", revision] }).output();
  assertEquals(result.code, 0);
  const paths = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean).sort();
  assertEquals(paths, [...APPROVED_MILESTONE_PATHS].sort());
});
