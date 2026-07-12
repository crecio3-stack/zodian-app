const dir = new URL("artifacts/", import.meta.url);
const cohort = JSON.parse(
  await Deno.readTextFile(new URL("v321-plain-english-cohort.json", dir)),
);
const manifest = JSON.parse(
  await Deno.readTextFile(
    new URL("v321-plain-english-repair-manifest.json", dir),
  ),
);
const out = new URL("v321-plain-english-repairs.json", dir);
if (!Deno.args.includes("--real")) {
  console.log(
    JSON.stringify(
      {
        preflight: true,
        targets: manifest.targets.length,
        providerCalls: 0,
        untouchedFields: 177,
      },
      null,
      2,
    ),
  );
  Deno.exit(0);
}
const key = Deno.env.get("OPENAI_API_KEY"),
  model = Deno.env.get("OPENAI_IDENTITY_LENS_MODEL");
if (!key || !model) {
  throw new Error("rotated OPENAI_API_KEY and model required");
}
const repairs = [];
for (const t of manifest.targets) {
  const row = cohort.rows.find((r: any) => r.id === t.id);
  const prompt =
    `Rewrite only ${t.field} in this Lens. Preserve meaning and return JSON with only that field. Original: ${
      JSON.stringify(row.rewrite)
    }. Problem: ${t.reason}.`;
  const res = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: prompt,
      text: { format: { type: "json_object" } },
    }),
  });
  const body = await res.json();
  let patch: any = null;
  try {
    patch = JSON.parse(
      body.output?.flatMap((x: any) => x.content ?? []).find((x: any) =>
        x.type === "output_text"
      )?.text ?? "",
    );
  } catch {}
  if (
    patch && typeof patch[t.field] === "string" &&
    Object.keys(patch).length === 1
  ) {
    row.rewrite = { ...row.rewrite, ...patch };
    repairs.push({
      ...t,
      accepted: true,
      before: t.value,
      after: patch[t.field],
      usage: body.usage,
    });
  } else repairs.push({ ...t, accepted: false, usage: body.usage });
}
await Deno.writeTextFile(
  out,
  JSON.stringify({ developmentOnly: true, repairs }, null, 2) + "\n",
);
await Deno.writeTextFile(
  new URL("v321-plain-english-cohort.json", dir),
  JSON.stringify(cohort, null, 2) + "\n",
);
console.log(
  JSON.stringify(
    {
      repairs: repairs.length,
      accepted: repairs.filter((r: any) => r.accepted).length,
    },
    null,
    2,
  ),
);
