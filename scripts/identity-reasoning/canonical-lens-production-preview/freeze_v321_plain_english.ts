const dir = new URL("artifacts/", import.meta.url);
const files = ["v321-plain-english-cohort.json", "v321-plain-english-repairs.json", "v321-plain-english-comparison.json", "v321-plain-english-comparison.md"];
const hash = async (name: string) => Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256", await Deno.readFile(new URL(name, dir))))).map((x) => x.toString(16).padStart(2, "0")).join("");
const cohort = JSON.parse(await Deno.readTextFile(new URL(files[0], dir)));
if (cohort.rows.length !== 30 || cohort.rows.some((r: any) => !r.accepted)) throw new Error("approved cohort must contain 30 accepted rows");
await Deno.writeTextFile(new URL("v321-plain-english-approved-freeze.json", dir), JSON.stringify({ developmentOnly: true, status: "approved_for_next_validation_stage", version: "v3.2.1-plain-english-approved", sourceVersion: cohort.version, cases: 30, approvedRepairs: 3, fileSha256: Object.fromEntries(await Promise.all(files.map(async (f) => [f, await hash(f)]))) }, null, 2) + "\n");
