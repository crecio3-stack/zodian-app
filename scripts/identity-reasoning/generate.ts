import { generateIdentity } from "./engine.ts";

const args = new Map<string, string>();
for (let index = 0; index < Deno.args.length; index += 2) {
  args.set(Deno.args[index], Deno.args[index + 1]);
}
const western = args.get("--western");
const chinese = args.get("--chinese");
const output = args.get("--output");
if (!western || !chinese || !output) {
  throw new Error("Required: --western SIGN --chinese SIGN --output PATH");
}
const reviewPairs = new Set([
  "Aries × Rat",
  "Pisces × Horse",
  "Taurus × Horse",
]);
if (
  !reviewPairs.has(`${western} × ${chinese}`) &&
  !Deno.args.includes("--allow-unreviewed-pair")
) {
  throw new Error(
    "v1 is limited to reviewed pairs; pass --allow-unreviewed-pair deliberately",
  );
}
const apiKey = Deno.env.get("OPENAI_API_KEY");
if (!apiKey) throw new Error("OPENAI_API_KEY is required");
const sourceNotes = args.get("--source-notes")?.split("|").filter(Boolean) ??
  [];
const result = await generateIdentity({
  western_sign: western,
  chinese_sign: chinese,
  archetype_name: args.get("--archetype-name"),
  source_notes: sourceNotes,
  debug_reasoning: Deno.args.includes("--debug-reasoning"),
}, apiKey);
await Deno.writeTextFile(output, `${JSON.stringify(result, null, 2)}\n`);
console.log(
  `Wrote development-only preview to ${output}; audit passed=${result.generation_metadata.audit.passed}`,
);
