import { blockedStyle } from "./v321_plain_english.ts";
export type Lens = Record<
  "title" | "intro" | "pull_quote" | "deeper_read" | "watch_for" | "move",
  string
>;
const norm = (v: string) =>
  v.toLowerCase().replace(/[^a-z0-9\s]/g, " ").replace(/\s+/g, " ").trim();
export function styleFlags(lens: Lens) {
  const all = Object.values(lens).join(" ").toLowerCase();
  return [
    ...blockedStyle.filter((p) => all.includes(p)).map((p) =>
      `literary stem: ${p}`
    ),
    ...Object.entries(lens).filter(([, v]) => v.split(/\s+/).length > 65).map((
      [k],
    ) => `${k} is overly long`),
    ...Object.entries(lens).filter(([, v]) =>
      /\b(attribution|bounded evidence|observable impact|agenda|column)\b/i
        .test(v)
    ).map(([k]) => `${k} has strategy language`),
  ];
}
export function meaningFlags(source: Lens, rewrite: Lens) {
  const flags: string[] = [];
  for (const key of Object.keys(source) as Array<keyof Lens>) {
    const shared = norm(source[key]).split(" ").filter((w) =>
      w.length > 4 && norm(rewrite[key]).includes(w)
    ).length;
    if (key !== "title" && shared === 0) {
      flags.push(`${key} requires human meaning review`);
    }
  }
  return flags;
}
