#!/usr/bin/env node

const WESTERN_SIGNS = [
  "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
  "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces",
];

const EASTERN_SIGNS = [
  "Rat", "Ox", "Tiger", "Rabbit", "Dragon", "Snake",
  "Horse", "Goat", "Monkey", "Rooster", "Dog", "Pig",
];

const ALL_PAIRS = WESTERN_SIGNS.flatMap((western) =>
  EASTERN_SIGNS.map((eastern) => ({ western, eastern }))
);

const DEFAULT_PROJECT_REF = "xyyahrqfmdblvonnaifi";
const DEFAULT_ANON_KEY = "sb_publishable_XdJh1iA7viOhIoq87A94-w_PNG5Oufj";
const TIME_ZONE = "America/Los_Angeles";
const READ_TIMEOUT_MS = 15000;
const GENERATE_TIMEOUT_MS = 120000;

const args = parseArgs(process.argv.slice(2));
const projectRef = process.env.SUPABASE_PROJECT_REF || args.projectRef || DEFAULT_PROJECT_REF;
const anonKey = process.env.SUPABASE_ANON_KEY || args.anonKey || DEFAULT_ANON_KEY;
const ritualDate = args.tomorrow
  ? dateStringInTimeZone(addDays(new Date(), 1), TIME_ZONE)
  : args.date || dateStringInTimeZone(new Date(), TIME_ZONE);
const shouldRepair = Boolean(args.repair);
const maxAttempts = Number(args.maxAttempts || 6);
const concurrency = Number(args.concurrency || 2);

if (!/^\d{4}-\d{2}-\d{2}$/.test(ritualDate)) {
  fail(`Invalid ritual_date "${ritualDate}". Use YYYY-MM-DD.`);
}

console.log(`Today’s Lens availability check`);
console.log(`Project: ${projectRef}`);
console.log(`Date: ${ritualDate}`);
console.log(`Repair: ${shouldRepair ? "yes" : "no"}`);
console.log("=".repeat(80));

let status = await checkDate(ritualDate);
printStatus(status);

if (shouldRepair && !status.ready) {
  for (let attempt = 1; attempt <= maxAttempts && !status.ready; attempt++) {
    console.log("");
    console.log(`Repair attempt ${attempt}/${maxAttempts}: ${status.missing.length} missing`);
    console.log("-".repeat(80));

    await mapWithConcurrency(status.missing, concurrency, async (pair) => {
      const result = await generatePair(ritualDate, pair);
      const label = `${pair.western} × ${pair.eastern}`;
      if (result.ok) {
        console.log(`ok      ${label}`);
      } else {
        console.log(`failed  ${label}: ${result.reason}`);
      }
      return { pair, result };
    });

    status = await checkDate(ritualDate);
    printStatus(status);
  }
}

if (!status.ready) {
  process.exitCode = 1;
}

async function checkDate(date) {
  const checked = await mapWithConcurrency(ALL_PAIRS, concurrency, async (pair) => {
    const read = await fetchRead(date, pair);
    const ready = read.ok && read.source === "row";
    return {
      ...pair,
      ready,
      title: read.title,
      createdAt: read.createdAt,
      reason: read.reason,
    };
  });

  const readyRows = checked.filter((row) => row.ready);
  const missing = checked
    .filter((row) => !row.ready)
    .map(({ western, eastern, reason }) => ({ western, eastern, reason }));
  const createdValues = readyRows
    .map((row) => row.createdAt)
    .filter(Boolean)
    .sort();

  return {
    date,
    count: readyRows.length,
    missing,
    createdAtMin: createdValues[0] || null,
    createdAtMax: createdValues[createdValues.length - 1] || null,
    ready: readyRows.length === ALL_PAIRS.length && missing.length === 0,
  };
}

function printStatus(status) {
  console.log("");
  console.log(`total row count: ${status.count}/144`);
  console.log(`created_at range: ${status.createdAtMin || "none"} -> ${status.createdAtMax || "none"}`);
  console.log(`ready: ${status.ready ? "true" : "false"}`);

  if (status.missing.length) {
    console.log(`missing combinations (${status.missing.length}):`);
    for (const pair of status.missing) {
      console.log(`- ${pair.western} × ${pair.eastern}${pair.reason ? ` (${pair.reason})` : ""}`);
    }
  } else {
    console.log("missing combinations: none");
  }
}

async function fetchRead(date, pair) {
  const url = functionUrl("get-daily-ritual");
  url.searchParams.set("ritual_date", date);
  url.searchParams.set("western_sign", pair.western);
  url.searchParams.set("eastern_sign", pair.eastern);

  try {
    const res = await fetch(url, {
      headers: authHeaders(),
      signal: AbortSignal.timeout(READ_TIMEOUT_MS),
    });
    const json = await res.json();
    const title = typeof json.title === "string" ? json.title : "";
    const notReady = title.trim().toLowerCase() === "your read is still forming";

    return {
      ok: res.ok,
      source: res.ok && !notReady ? "row" : "not_ready",
      title,
      createdAt: typeof json.created_at === "string" ? json.created_at : null,
      reason: res.ok ? (notReady ? "not_ready" : "") : `http_${res.status}`,
    };
  } catch (error) {
    return {
      ok: false,
      source: "error",
      title: "",
      createdAt: null,
      reason: error instanceof Error ? error.message : String(error),
    };
  }
}

async function generatePair(date, pair) {
  const url = functionUrl("generate-daily-rituals");
  const body = {
    ritual_date: date,
    western_sign: pair.western,
    eastern_sign: pair.eastern,
  };

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        ...authHeaders(),
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(GENERATE_TIMEOUT_MS),
    });
    const json = await res.json().catch(() => ({}));

    if (!res.ok) {
      return { ok: false, reason: `http_${res.status}` };
    }

    if (json.count_failed && json.failed_pairs?.length) {
      return { ok: false, reason: `generation_failed: ${json.failed_pairs.join(", ")}` };
    }

    return { ok: true, reason: "" };
  } catch (error) {
    return {
      ok: false,
      reason: error instanceof Error ? error.message : String(error),
    };
  }
}

function functionUrl(slug) {
  return new URL(`https://${projectRef}.supabase.co/functions/v1/${slug}`);
}

function authHeaders() {
  return {
    Authorization: `Bearer ${anonKey}`,
    apikey: anonKey,
    Accept: "application/json",
  };
}

async function mapWithConcurrency(items, limit, mapper) {
  const results = new Array(items.length);
  let nextIndex = 0;
  const workerCount = Math.max(1, Math.min(limit, items.length));

  await Promise.all(Array.from({ length: workerCount }, async () => {
    while (nextIndex < items.length) {
      const index = nextIndex++;
      results[index] = await mapper(items[index], index);
    }
  }));

  return results;
}

function parseArgs(values) {
  const parsed = {};

  for (let index = 0; index < values.length; index++) {
    const value = values[index];

    if (value === "--repair") parsed.repair = true;
    else if (value === "--tomorrow") parsed.tomorrow = true;
    else if (value === "--date") parsed.date = values[++index];
    else if (value === "--project-ref") parsed.projectRef = values[++index];
    else if (value === "--anon-key") parsed.anonKey = values[++index];
    else if (value === "--max-attempts") parsed.maxAttempts = values[++index];
    else if (value === "--concurrency") parsed.concurrency = values[++index];
    else if (value === "--help" || value === "-h") {
      console.log([
        "Usage:",
        "  node scripts/dev/daily_read_availability.mjs --date YYYY-MM-DD",
        "  node scripts/dev/daily_read_availability.mjs --tomorrow --repair --max-attempts 6 --concurrency 2",
        "",
        "Environment:",
        "  SUPABASE_PROJECT_REF",
        "  SUPABASE_ANON_KEY",
      ].join("\n"));
      process.exit(0);
    } else {
      fail(`Unknown argument: ${value}`);
    }
  }

  return parsed;
}

function addDays(date, days) {
  const copy = new Date(date);
  copy.setUTCDate(copy.getUTCDate() + days);
  return copy;
}

function dateStringInTimeZone(date, timeZone) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(date);

  const year = parts.find((part) => part.type === "year")?.value;
  const month = parts.find((part) => part.type === "month")?.value;
  const day = parts.find((part) => part.type === "day")?.value;

  return `${year}-${month}-${day}`;
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
