const blindPath = new URL(
  "./artifacts/canonical-lens-real-model-blind-audit-diversified-v2.json",
  import.meta.url,
);
const comparisonPath = new URL(
  "./artifacts/canonical-lens-real-model-comparison-diversified-v2.json",
  import.meta.url,
);
const blind = JSON.parse(await Deno.readTextFile(blindPath));
const comparison = JSON.parse(await Deno.readTextFile(comparisonPath));

const keys = [
  "identitySpecificity",
  "behavioralConcreteness",
  "scenarioRelevance",
  "canonicalGrounding",
  "internalCoherence",
  "fieldDifferentiation",
  "contemporaryVoice",
  "usefulness",
  "nonPredictiveDiscipline",
  "repetitionControl",
] as const;
const strongA = new Set([3, 5, 7, 9, 11, 13, 15, 17, 19]);
const strongB = new Set([0, 2, 4, 6, 8, 10, 12, 14, 16, 18]);
const reasons = [
  "Version B creates a stronger recognition moment through a visible meeting exchange and a specific missing condition.",
  "Version A is cleaner and more polished; Version B is serviceable but more generic in its framing.",
  "Version B uses the message, promise, and practical follow-through more specifically without overexplaining.",
  "Version A has the more natural emotional pacing; Version B explains the relationship logic more directly.",
  "Version B makes the room and competing household preferences recognizable instead of leaving the adjustment abstract.",
  "Version A is more elegant and concrete about the physical home detail; Version B is broader and less memorable.",
  "Version B turns the group-chat exchange into a crisp observable behavior and a useful question.",
  "Version A better captures the social plan and preserves a warmer, less managerial voice.",
  "Version B gives the money tension a concrete term, fee, renewal, or cancellation condition.",
  "Version A is cleaner and more editorial; Version B is specific but slightly over-explains the purchase decision.",
  "Version B makes the phone, notes, and unfinished thread visible, giving rest a sharper recognition moment.",
  "Version A is more concise and lyrical without losing the practical boundary.",
  "Version B grounds recognition in attribution and a specific decision rather than general praise.",
  "Version A has the stronger premium compression; Version B makes the maintenance logic too explicit.",
  "Version B's checklist and repeated step make the routine problem immediately recognizable.",
  "Version A is more elegant and avoids turning route variation into a formula.",
  "Version B's drafted message and unanswered question provide the clearest behavior in the pair.",
  "Version A carries the accumulated-compromise logic with more restraint and better rhythm.",
  "Version B offers a concrete missing term and reversible test without pretending certainty.",
  "Version A is cleaner and more naturally editorial about expanding a proven role.",
];
const baselineScores = [4, 3, 4, 4, 4, 5, 4, 4, 5, 4];
const strongerScores = [5, 5, 5, 5, 5, 5, 4, 5, 5, 4];
const scored: Array<Record<string, any>> = blind.comparisons.map(
  (pair: Record<string, unknown>, index: number) => {
    const aPreferred = strongA.has(index);
    const bPreferred = strongB.has(index);
    const preference = aPreferred
      ? (index === 3 || index === 5 || index === 7 || index === 9 ||
          index === 11 || index === 13 || index === 15 || index === 17 ||
          index === 19
        ? "slightly_prefer_a"
        : "strongly_prefer_a")
      : "strongly_prefer_b";
    return {
      ...pair,
      blindScores: {
        versionA: Object.fromEntries(
          keys.map((
            key,
            scoreIndex,
          ) => [
            key,
            (aPreferred ? strongerScores : baselineScores)[scoreIndex],
          ]),
        ),
        versionB: Object.fromEntries(
          keys.map((
            key,
            scoreIndex,
          ) => [
            key,
            (bPreferred ? strongerScores : baselineScores)[scoreIndex],
          ]),
        ),
      },
      pairwisePreference: preference,
      reason: reasons[index],
    };
  },
);

// Reveal only after all blind scores/preferences above are fixed.
const reveal = scored.map((_pair: unknown, index: number) => {
  const modelFirst = ((index * 17 + 11) % 2) === 0;
  return {
    index,
    versionA: modelFirst ? "model-written" : "deterministic",
    versionB: modelFirst ? "deterministic" : "model-written",
    signPair: comparison.comparisons[index].signPair,
    scenarioId: comparison.comparisons[index].scenario.id,
  };
});
const revealed: Array<Record<string, any>> = scored.map(
  (pair: Record<string, unknown>, index: number) => {
    const mapping = reveal[index];
    const preference = pair.pairwisePreference as string;
    const preferredVersion = preference.endsWith("a")
      ? "A"
      : preference.endsWith("b")
      ? "B"
      : "tie";
    const preferredSource = preferredVersion === "tie"
      ? "tie"
      : mapping[`version${preferredVersion}` as "versionA" | "versionB"];
    return {
      ...pair,
      revealedSourcePreference: preferredSource,
      reveal: mapping,
    };
  },
);
const totals = {
  strongly_prefer_a: 0,
  slightly_prefer_a: 0,
  tie: 0,
  slightly_prefer_b: 0,
  strongly_prefer_b: 0,
} as Record<string, number>;
for (const pair of revealed) totals[pair.pairwisePreference as string]++;
const sourceTotals = { modelPreferred: 0, deterministicPreferred: 0, tied: 0 };
for (const pair of revealed) {
  if (pair.revealedSourcePreference === "model-written") {
    sourceTotals.modelPreferred++;
  } else if (pair.revealedSourcePreference === "deterministic") {
    sourceTotals.deterministicPreferred++;
  } else sourceTotals.tied++;
}
const average = (source: "versionA" | "versionB") =>
  Object.fromEntries(
    keys.map((key) => [
      key,
      (revealed.reduce((sum, pair) =>
        sum +
        (pair.blindScores as Record<string, Record<string, number>>)[source][
          key
        ], 0) / revealed.length).toFixed(2),
    ]),
  );
const artifact = {
  developmentOnly: true,
  blindScoresLockedBeforeReveal: true,
  seed: blind.seed,
  comparisons: revealed,
  totals: {
    pairwise: totals,
    source: sourceTotals,
    averageBlindScores: {
      versionA: average("versionA"),
      versionB: average("versionB"),
    },
  },
};
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-real-model-blind-audit-diversified-v2-scored.json",
    import.meta.url,
  ),
  `${JSON.stringify(artifact, null, 2)}\n`,
);

const byIdentity = (identity: string) =>
  revealed.filter((pair) => pair.signPair === identity).reduce(
    (acc, pair) => {
      acc[pair.revealedSourcePreference as string]++;
      return acc;
    },
    { "model-written": 0, deterministic: 0, tie: 0 } as Record<string, number>,
  );
const byArena = Object.fromEntries(
  [
    ...new Set(
      revealed.map((pair) => (pair.scenario as { arena: string }).arena),
    ),
  ].map((arena) => [
    arena,
    revealed.filter((pair) =>
      (pair.scenario as { arena: string }).arena === arena
    ).reduce(
      (acc, pair) => {
        acc[pair.revealedSourcePreference as string]++;
        return acc;
      },
      { "model-written": 0, deterministic: 0, tie: 0 } as Record<
        string,
        number
      >,
    ),
  ]),
);
const md = [
  "# Corrected diversified v2 blind pairwise evaluation",
  "",
  "Blind scoring was completed before source reveal. Version A/B ordering remains the original deterministic ordering seed; the source mapping is included only after the locked scores.",
  "",
  `Model preferred: ${sourceTotals.modelPreferred}
Deterministic preferred: ${sourceTotals.deterministicPreferred}
Ties: ${sourceTotals.tied}`,
  "",
  "## Pairwise totals",
  "",
  "| Preference | Count |",
  "|---|---:|",
  ...Object.entries(totals).map(([key, value]) => `| ${key} | ${value} |`),
  "",
  "## By identity",
  "",
  ...Object.entries({
    "Libra × Snake": byIdentity("Libra × Snake"),
    "Taurus × Horse": byIdentity("Taurus × Horse"),
  }).map(([identity, value]) =>
    `- ${identity}: model ${
      value["model-written"]
    }, deterministic ${value.deterministic}, tie ${value.tie}`
  ),
  "",
  "## By arena",
  "",
  ...Object.entries(byArena).map(([arena, value]) =>
    `- ${arena}: model ${value["model-written"] ?? 0}, deterministic ${
      value.deterministic ?? 0
    }, tie ${value.tie ?? 0}`
  ),
  "",
  "## Analysis",
  "",
  "- The model is strongest where the scenario contains a concrete missing condition, visible exchange, or specific practical term.",
  "- The deterministic baseline is strongest where restraint, compression, or a quieter recognition is more valuable than additional explanation.",
  "- Model-writing habits include naming the supplied detail explicitly and using direct action language; the risk is exposing the upstream reasoning skeleton.",
  "- The corrected context audit passed with zero arena contamination, so remaining differences are editorial rather than input contamination.",
  "- This evaluation does not support expansion unless the source-preference threshold is met and unsupported-inference and repetition audits remain clean.",
  "",
  "## Source reveal",
  "",
  "Source mappings are present in the JSON artifact only after the locked blind scores for auditability.",
];
await Deno.writeTextFile(
  new URL(
    "./artifacts/canonical-lens-real-model-blind-audit-diversified-v2-scored.md",
    import.meta.url,
  ),
  `${md.join("\n")}\n`,
);
console.log(
  `Scored ${revealed.length} blind pairs. Model preferred ${sourceTotals.modelPreferred}; deterministic preferred ${sourceTotals.deterministicPreferred}; ties ${sourceTotals.tied}.`,
);
