export type LensLike = {
  title: string;
  intro: string;
  pull_quote: string;
  deeper_read: string;
  watch_for: string;
  move: string;
};
export type CohortRow = {
  identity: string;
  scenarioId: string;
  arena: string;
  lens: LensLike;
};
const normalize = (value: string) =>
  value.toLowerCase().replace(/[^a-z0-9\s]/g, " ").replace(/\s+/g, " ").trim();
const stem = (value: string, size = 4) =>
  normalize(value).split(" ").slice(0, size).join(" ");
const phrases = [
  "somewhere to land",
  "the room",
  "the moment",
  "one small",
  "one clear",
  "before moves on",
  "watch for the moment",
];

export function auditV321Cohort(rows: CohortRow[]) {
  const counts = (values: string[]) =>
    Object.entries(
      values.reduce<Record<string, number>>(
        (map, value) => ({ ...map, [value]: (map[value] ?? 0) + 1 }),
        {},
      ),
    ).filter(([, count]) => count > 1);
  const scenarioGroups = Object.values(
    Object.groupBy(rows, (row) => row.scenarioId),
  );
  const swapRisk = scenarioGroups.flatMap((group) => {
    const valid = group ?? [];
    const moveStems = counts(valid.map((row) => stem(row.lens.move, 7)));
    const introStems = counts(valid.map((row) => stem(row.lens.intro, 6)));
    return moveStems.length || introStems.length
      ? [{ scenarioId: valid[0]?.scenarioId, moveStems, introStems }]
      : [];
  });
  const haystack = rows.map((row) =>
    Object.values(row.lens).join(" ").toLowerCase()
  ).join("\n");
  return {
    rows: rows.length,
    exactTitles: counts(rows.map((row) => normalize(row.lens.title))),
    openingStems: counts(rows.map((row) => stem(row.lens.intro))),
    exactMoves: counts(rows.map((row) => normalize(row.lens.move))),
    swapRisk,
    phraseCounts: Object.fromEntries(
      phrases.map((phrase) => [phrase, haystack.split(phrase).length - 1]),
    ),
    predeterminedOpenings: rows.filter((row) =>
      /^(someone|a tender message|the meeting|an offer)\b/i.test(row.lens.intro)
    ).map((row) => ({
      identity: row.identity,
      scenarioId: row.scenarioId,
      intro: row.lens.intro,
    })),
  };
}
