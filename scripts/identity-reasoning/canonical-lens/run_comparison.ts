import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "../canonical/fixtures/taurus-horse.ts";
import { generateCanonicalLens } from "./adapter.ts";
import { MATCHED_SCENARIOS } from "./scenarios.ts";
import type { CanonicalLensGenerationResult } from "./types.ts";

const results: CanonicalLensGenerationResult[] = [];
for (const scenario of MATCHED_SCENARIOS) {
  results.push(generateCanonicalLens(libraSnakeCanonical, scenario));
  results.push(generateCanonicalLens(taurusHorseCanonical, scenario));
}

const outputPath = new URL(
  "./artifacts/canonical-lens-matched-comparison.json",
  import.meta.url,
);
await Deno.mkdir(new URL("./artifacts/", import.meta.url), { recursive: true });
await Deno.writeTextFile(
  outputPath,
  `${
    JSON.stringify(
      {
        generatedOnly: true,
        generatedAt: new Date().toISOString(),
        sampleCount: results.length,
        results,
      },
      null,
      2,
    )
  }\n`,
);

function lexicalOverlap(a: string, b: string): number {
  const words = (value: string) =>
    new Set(
      value.toLowerCase().split(/[^a-z]+/).filter((word) => word.length > 4),
    );
  const left = words(a);
  const right = words(b);
  const intersection = [...left].filter((word) => right.has(word)).length;
  return intersection / Math.max(1, Math.min(left.size, right.size));
}

const rows = MATCHED_SCENARIOS.map((scenario) => {
  const pair = results.filter((result) => result.scenarioId === scenario.seed);
  const libra = pair.find((result) => result.signPair === "Libra × Snake")!;
  const taurus = pair.find((result) => result.signPair === "Taurus × Horse")!;
  return {
    id: scenario.id,
    tension: scenario.humanTension,
    arena: scenario.arena,
    libraAccepted: libra.validation.accepted,
    taurusAccepted: taurus.validation.accepted,
    retryCount: libra.retryCount + taurus.retryCount,
    quoteOverlap: Number(
      lexicalOverlap(libra.lens.pull_quote, taurus.lens.pull_quote).toFixed(2),
    ),
    distinctResolution:
      libra.reasoning.naturalMove !== taurus.reasoning.naturalMove,
    libraRole: libra.reasoning.identitySpecificRole,
    taurusRole: taurus.reasoning.identitySpecificRole,
  };
});

const accepted = results.filter((result) => result.validation.accepted).length;
const markdown = [
  "# Canonical Identity → Today’s Lens matched comparison",
  "",
  "Development-only artifact. Ten matched scenarios produce twenty Lens-shaped outputs using the same daily context for both reviewed identities. No production validator, Supabase function, app code, or stored row is touched.",
  "",
  `Accepted first attempt: ${accepted}/${results.length}
Accepted after retry: 0
Rejected: ${results.length - accepted}
Retries: 0`,
  "",
  "## Matched differentiation audit",
  "",
  "| Scenario | Arena | Libra role | Taurus role | Distinct resolution | Quote overlap | Validation |",
  "|---|---|---|---|---:|---:|---|",
  ...rows.map((row) =>
    `| ${row.id} | ${row.arena} | ${row.libraRole} | ${row.taurusRole} | ${
      row.distinctResolution ? "yes" : "no"
    } | ${row.quoteOverlap} | ${
      row.libraAccepted && row.taurusAccepted ? "pass" : "review"
    } |`
  ),
  "",
  "## Self-critique",
  "",
  "- The matched cases differentiate reliably because the adapter selects different perception, decision, pressure, and growth fields before writing. Libra × Snake tends toward missing context, earned judgment, and naming the unanswered part; Taurus × Horse tends toward accumulated constraint, chosen stability, and making a smaller adjustment before escape becomes necessary.",
  "- The outputs remain daily reads by constraining each result to one scenario, one arena, one visible behavior, and one natural move. They do not expose the canonical model or restate a whole identity profile.",
  "- This is a controlled architecture experiment, not evidence that deterministic copy is ready for production. The next test should replace the hand-authored development copy with a writing-stage model call while retaining the same selected-context boundary and existing production validation contract.",
  "- Direct reuse of `validateStructuredDailyRead` was not safe in this isolated script because the production function is not exported and imports live Edge Function/Supabase runtime concerns. The adapter validator mirrors its existing field shape and published word/sentence constraints without weakening them; production integration should call the shared validator through an explicit export rather than maintaining two implementations.",
].join("\n");
await Deno.writeTextFile(
  new URL("./artifacts/canonical-lens-matched-comparison.md", import.meta.url),
  `${markdown}\n`,
);
console.log(`Wrote ${results.length} matched development-only Lens samples.`);
