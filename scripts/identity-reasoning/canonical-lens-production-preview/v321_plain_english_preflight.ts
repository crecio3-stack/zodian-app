import {
  buildPlainEnglishPrompt,
  V321_PLAIN_ENGLISH_VERSION,
} from "./v321_plain_english.ts";
const url = new URL("artifacts/v321-cohort.json", import.meta.url);
const source = JSON.parse(await Deno.readTextFile(url));
if (!Deno.args.includes("--preflight")) {
  throw new Error("Provider rewrite is not approved. Use --preflight only.");
}
if (
  source.outputCount !== 30 || source.accepted !== 30 ||
  source.outputs.length !== 30
) throw new Error("expected existing 30 accepted v3.2.1 outputs");
console.log(JSON.stringify(
  {
    developmentOnly: true,
    version: V321_PLAIN_ENGLISH_VERSION,
    sourceVersion: source.version,
    cases: 30,
    providerCalls: 0,
    originalArtifactsReadOnly: true,
    productionWritePaths: [],
    shadowWritePaths: [],
    promptPreview: buildPlainEnglishPrompt(source.outputs[0].result.finalLens)
      .slice(0, 80),
  },
  null,
  2,
));
