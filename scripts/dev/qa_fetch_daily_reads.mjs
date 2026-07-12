#!/usr/bin/env node

import { readFileSync } from "node:fs";

const projectRef = process.env.SUPABASE_PROJECT_REF || "xyyahrqfmdblvonnaifi";
const startDate = process.env.QA_START_DATE || "2026-07-01";
const count = Number.parseInt(process.env.QA_DAY_COUNT || "15", 10);
const westernSign = process.env.QA_WESTERN_SIGN || "Libra";
const easternSign = process.env.QA_EASTERN_SIGN || "Snake";
const anonKey = process.env.SUPABASE_ANON_KEY || readAnonKeyFromBetaConfig();
const neighborhoodPatterns = {
  "guardedness/protection/boundaries": [
    "guard", "guarded", "protect", "protection", "boundary", "boundaries", "space", "limit",
    "line", "defensive", "position", "private",
  ],
  "control/strategy/careful timing": [
    "control", "strategy", "strategic", "timing", "careful", "carefully", "manage", "steer",
    "shape", "calculate", "precise", "precision", "read the room", "right moment",
  ],
  "harmony/smoothing/softening": [
    "harmony", "pleasant", "agreeable", "agree", "keep the peace", "smooth", "soften",
    "diplomacy", "diplomatic", "comfortable", "polite", "civil", "clash",
  ],
  "confidence/leadership/credit": [
    "confidence", "confident", "lead", "leading", "leadership", "credit", "recognition",
    "claim", "authority", "direct", "bold", "accomplished", "success", "earned", "spotlight",
  ],
  "joy/playfulness/humor": [
    "joy", "delight", "pleasure", "play", "playful", "fun", "funny", "humor", "laugh",
    "smile", "wit", "joke", "lightness", "savor", "enjoy",
  ],
  "creativity/curiosity/experimentation": [
    "creative", "creativity", "curious", "curiosity", "experiment", "test", "try", "idea",
    "spark", "invent", "imagine", "question", "explore", "offbeat", "different way",
  ],
  "rest/patience/enoughness": [
    "rest", "pause", "patient", "patience", "enough", "settle", "settled", "slow", "slower",
    "capacity", "recover", "ease", "sufficient", "finished",
  ],
  "work/ambition/momentum": [
    "work", "task", "project", "ambition", "ambitious", "momentum", "progress", "goal",
    "forward", "finish", "deliver", "step", "plan", "effort", "standard",
  ],
  "relationships/warmth/connection": [
    "relationship", "relationships", "connection", "connect", "warmth", "warm", "care",
    "closeness", "conversation", "people", "someone", "share", "invite", "belong",
  ],
  "intuition/perception/noticing": [
    "intuition", "intuitive", "perception", "sense", "signal", "hunch", "read", "discern",
    "discernment", "subtle", "detect",
  ],
};

if (!anonKey) {
  console.error("Missing SUPABASE_ANON_KEY and could not read Configurations/Beta.xcconfig.");
  process.exit(1);
}

const rows = [];

for (const ritualDate of dateRange(startDate, count)) {
  rows.push(await fetchDailyRead(ritualDate));
}

printReads(rows);
printSummary(rows);

async function fetchDailyRead(ritualDate) {
  const url = new URL(`https://${projectRef}.supabase.co/functions/v1/get-daily-ritual`);
  url.searchParams.set("ritual_date", ritualDate);
  url.searchParams.set("western_sign", westernSign);
  url.searchParams.set("eastern_sign", easternSign);

  const response = await fetch(url, {
    headers: {
      apikey: anonKey,
      Authorization: `Bearer ${anonKey}`,
    },
  });

  if (!response.ok) {
    throw new Error(`Fetch failed for ${ritualDate}: ${response.status} ${await response.text()}`);
  }

  const read = await response.json();

  return {
    date: ritualDate,
    title: normalized(read.title),
    intro: normalized(read.intro),
    pull_quote: normalized(read.pull_quote),
    deeper_read: normalized(read.deeper_read),
    watch_for: normalized(read.watch_for),
    move: normalized(read.move),
  };
}

function printReads(reads) {
  console.log(`Today’s Lens QA: ${westernSign} x ${easternSign}`);
  console.log(`${reads[0]?.date ?? ""} through ${reads.at(-1)?.date ?? ""}`);
  console.log("=".repeat(80));

  for (const read of reads) {
    console.log(`\nDate: ${read.date}`);
    console.log(`Title: ${read.title}`);
    console.log(`Intro: ${read.intro}`);
    console.log(`Pull Quote: ${read.pull_quote}`);
    console.log(`Deeper Read: ${read.deeper_read}`);
    console.log(`Watch: ${read.watch_for}`);
    console.log(`Move: ${read.move}`);
    console.log("-".repeat(80));
  }
}

function printSummary(reads) {
  const textByRead = reads.map((read) => Object.values(read).join(" ").toLowerCase());
  const titleShapes = countBy(reads.map((read) => titleShape(read.title)));
  const openingShapes = countBy(reads.map((read) => firstWords(read.intro, 3)));
  const moveStructures = countBy(reads.map((read) => moveStructure(read.move)));
  const primaryNeighborhoods = reads.map(primaryNeighborhood);
  const primaryNeighborhoodHits = countBy(primaryNeighborhoods);
  const secondaryNeighborhoodHits = Object.fromEntries(
    Object.keys(neighborhoodPatterns).map((neighborhood) => [
      neighborhood,
      reads.filter((read) => neighborhoodScore(Object.values(read).join(" "), neighborhood) >= 2).length,
    ])
  );
  const aiishTitles = reads
    .filter((read) => /\b(alignment|activation|attunement|calibration|duality|essence|expansion|integration|internal|resonance|shift|shifts|balancing|unlocking|navigating)\b/i.test(read.title))
    .map((read) => `${read.date}: ${read.title}`);
  const hiddenFlawReads = reads
    .filter((read) => /\b(secretly|hidden flaw|reveals where|exposes where|the problem starts|becomes costly|the cost of)\b/i.test(Object.values(read).join(" ")))
    .map((read) => `${read.date}: ${read.title}`);

  console.log("\nQA Summary");
  console.log("=".repeat(80));
  console.log("Primary emotional neighborhood distribution:");
  for (const [neighborhood, hits] of Object.entries(primaryNeighborhoodHits)) {
    const marker = hits > 4 ? " OVER 4/15" : "";
    console.log(`- ${neighborhood}: ${hits}/15${marker}`);
  }

  console.log("\nSecondary neighborhood mentions:");
  for (const [neighborhood, hits] of Object.entries(secondaryNeighborhoodHits)) {
    console.log(`- ${neighborhood}: ${hits}/15`);
  }

  console.log("\nRepeated title patterns:");
  printRepeated(titleShapes);

  console.log("\nRepeated opening shapes:");
  printRepeated(openingShapes);

  console.log("\nRepeated Move structures:");
  printRepeated(moveStructures);

  console.log("\nReads that feel weaker or more AI-generated:");
  if (aiishTitles.length || hiddenFlawReads.length) {
    for (const item of [...aiishTitles, ...hiddenFlawReads]) console.log(`- ${item}`);
  } else {
    console.log("- None flagged by the lightweight pattern check.");
  }

  console.log("\nReads that feel especially strong:");
  const strongReads = reads
    .filter((read) => /\b(joy|claim|clear|play|lead|choose|moment|smile|laugh|credit|forward)\b/i.test(`${read.title} ${read.pull_quote} ${read.move}`))
    .slice(0, 5)
    .map((read) => `${read.date}: ${read.title}`);

  if (strongReads.length) {
    for (const item of strongReads) console.log(`- ${item}`);
  } else {
    console.log("- No obvious standout flagged automatically; use the full text above for human review.");
  }
}

function readAnonKeyFromBetaConfig() {
  try {
    const config = readFileSync("Configurations/Beta.xcconfig", "utf8");
    return config.match(/^SUPABASE_ANON_KEY\s*=\s*(.+)$/m)?.[1]?.trim() ?? "";
  } catch {
    return "";
  }
}

function dateRange(start, length) {
  const [year, month, day] = start.split("-").map(Number);
  const date = new Date(Date.UTC(year, month - 1, day, 12, 0, 0));
  return Array.from({ length }, (_, index) => {
    const next = new Date(date);
    next.setUTCDate(date.getUTCDate() + index);
    return next.toISOString().slice(0, 10);
  });
}

function normalized(value) {
  return typeof value === "string" ? value.trim().replace(/\s+/g, " ") : "";
}

function countBy(values) {
  return values.reduce((counts, value) => {
    counts[value] = (counts[value] ?? 0) + 1;
    return counts;
  }, {});
}

function countMatching(values, pattern) {
  return values.filter((value) => pattern.test(value)).length;
}

function primaryNeighborhood(read) {
  let bestNeighborhood = "unclassified";
  let bestScore = 0;
  const source = Object.values(read).join(" ");

  for (const neighborhood of Object.keys(neighborhoodPatterns)) {
    const score = neighborhoodScore(source, neighborhood);
    if (score > bestScore) {
      bestNeighborhood = neighborhood;
      bestScore = score;
    }
  }

  return bestScore >= 2 ? bestNeighborhood : "unclassified";
}

function neighborhoodScore(source, neighborhood) {
  const lower = source.toLowerCase();
  return neighborhoodPatterns[neighborhood].reduce((score, pattern) => {
    if (pattern.includes(" ")) {
      return lower.includes(pattern) ? score + 1 : score;
    }

    const matches = lower.match(new RegExp(`\\b${escapeRegExp(pattern)}\\w*\\b`, "g"));
    return score + (matches?.length ?? 0);
  }, 0);
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function firstWords(value, length) {
  return normalized(value).split(/\s+/).slice(0, length).join(" ");
}

function titleShape(title) {
  return normalized(title)
    .split(/\s+/)
    .map((word) => {
      if (/^(the|a|an)$/i.test(word)) return word.toLowerCase();
      if (/ing$/i.test(word)) return "Gerund";
      if (/^(with|without|in|on|for|of)$/i.test(word)) return word.toLowerCase();
      return "Word";
    })
    .join(" ");
}

function moveStructure(move) {
  const words = normalized(move).split(/\s+/);
  const verb = words[0]?.toLowerCase() || "";
  const connector = /\bthen\b/i.test(move)
    ? "then"
    : /\bwithout\b/i.test(move)
      ? "without"
      : /\bbefore\b/i.test(move)
        ? "before"
        : "simple";

  return `${verb} + ${connector}`;
}

function printRepeated(counts) {
  const repeated = Object.entries(counts)
    .filter(([, count]) => count > 1)
    .sort((a, b) => b[1] - a[1]);

  if (!repeated.length) {
    console.log("- None above 1 occurrence.");
    return;
  }

  for (const [label, count] of repeated) {
    console.log(`- ${label}: ${count}`);
  }
}
