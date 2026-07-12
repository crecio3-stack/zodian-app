const dir = new URL("artifacts/", import.meta.url);
const cohort = JSON.parse(
  await Deno.readTextFile(new URL("v321-plain-english-cohort.json", dir)),
);
const bad = [
  /after your momentum/i,
  /somewhere to land/i,
  /lets? the opportunity stay open/i,
  /keeps? a quick exit from taking over/i,
  /\bwatch for treating\b/i,
  /\bwatch for treating\b/i,
];
const targets = cohort.rows.filter((r: any) => r.accepted).flatMap((r: any) =>
  Object.entries(r.rewrite).filter(([, v]) =>
    bad.some((rx) => rx.test(String(v)))
  ).map(([field, value]) => ({
    id: r.id,
    identity: r.identity,
    scenario: r.scenarioId,
    field,
    value,
    reason: "plain-English naturalness or missing-subject repair",
  }))
);
await Deno.writeTextFile(
  new URL("v321-plain-english-repair-manifest.json", dir),
  JSON.stringify(
    { developmentOnly: true, providerCalls: 0, targets },
    null,
    2,
  ) + "\n",
);
console.log(JSON.stringify({ targets: targets.length, targets }, null, 2));
