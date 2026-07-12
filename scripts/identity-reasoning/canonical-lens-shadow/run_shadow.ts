/** Manual-only admin client for the v3.2 shadow cohort. It never calls production generation. */
const args: Record<string, string | undefined> = {};
for (let index = 0; index < Deno.args.length; index++) {
  const argument = Deno.args[index];
  if (!argument.startsWith("--") || argument === "--dry-run") continue;
  const value = Deno.args[index + 1];
  if (!value || value.startsWith("--")) {
    throw new Error(`Missing value for ${argument}`);
  }
  args[argument.slice(2)] = value;
  index++;
}
const required = ["date", "western", "eastern", "scenario"];
const missing = required.filter((key) => !args[key]);
if (missing.length) {
  throw new Error(`Missing required flags: ${missing.join(", ")}`);
}
const baseUrl = Deno.env.get("SUPABASE_URL");
const adminSecret = Deno.env.get("CANONICAL_LENS_V3_2_SHADOW_ADMIN_SECRET");
if (!baseUrl || !adminSecret) {
  throw new Error(
    "SUPABASE_URL and CANONICAL_LENS_V3_2_SHADOW_ADMIN_SECRET are required",
  );
}
const response = await fetch(
  `${baseUrl}/functions/v1/generate-canonical-lens-shadow`,
  {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-canonical-shadow-admin-secret": adminSecret,
    },
    body: JSON.stringify({
      generation_date: args.date,
      western_sign: args.western,
      eastern_sign: args.eastern,
      scenario_id: args.scenario,
      production_daily_ritual_id: args["production-id"],
      dry_run: Deno.args.includes("--dry-run"),
    }),
  },
);
console.log(JSON.stringify(await response.json(), null, 2));
Deno.exit(response.ok ? 0 : 1);
