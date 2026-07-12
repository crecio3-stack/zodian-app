import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);

    const westernSign = normalizedSign(url.searchParams.get("western_sign"));
    const easternSign = normalizedSign(url.searchParams.get("eastern_sign"));
    const requestedDate = normalizedDate(url.searchParams.get("ritual_date"));

    if (!westernSign || !easternSign) {
      return json({ error: "Missing signs" }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");

    const supabaseKey =
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
      JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;

    const supabase = createClient(supabaseUrl!, supabaseKey!);

    const todayInLosAngeles = dateStringInTimeZone(new Date(), "America/Los_Angeles");
    const ritualDates = uniqueStrings([
      requestedDate,
      todayInLosAngeles,
    ]);

    const data: Record<string, unknown> | null =
      await findRitualForDates(supabase, ritualDates, westernSign, easternSign)
      ?? await findLatestRitualOnOrBefore(
        supabase,
        todayInLosAngeles,
        westernSign,
        easternSign,
      );

    if (!data) {
      return json({
        error: "Today’s Lens not found",
        ritual_date: ritualDates[0] ?? todayInLosAngeles,
        western_sign: westernSign,
        eastern_sign: easternSign,
      }, 404);
    }

    return json(structuredResponse({
      ...data,
      title: stripSignPairFromTitle(data.title, westernSign, easternSign),
    }));

  } catch (err) {
    return json({ error: "Server error" }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

async function findRitualForDates(
  supabase: any,
  ritualDates: string[],
  westernSign: string,
  easternSign: string,
): Promise<Record<string, unknown> | null> {
  for (const ritualDate of ritualDates) {
    const { data, error } = await supabase
      .from("daily_rituals")
      .select("*")
      .eq("ritual_date", ritualDate)
      .ilike("western_sign", westernSign)
      .ilike("eastern_sign", easternSign)
      .maybeSingle();

    if (error) {
      console.error("Today’s Lens lookup failed", {
        ritualDate,
        westernSign,
        easternSign,
        message: error.message,
      });
      continue;
    }

    if (data) return data;
  }

  return null;
}

async function findLatestRitualOnOrBefore(
  supabase: any,
  ritualDate: string,
  westernSign: string,
  easternSign: string,
): Promise<Record<string, unknown> | null> {
  const { data, error } = await supabase
    .from("daily_rituals")
    .select("*")
    .lte("ritual_date", ritualDate)
    .ilike("western_sign", westernSign)
    .ilike("eastern_sign", easternSign)
    .order("ritual_date", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    console.error("Today’s Lens fallback lookup failed", {
      ritualDate,
      westernSign,
      easternSign,
      message: error.message,
    });
  }

  return data ?? null;
}

function uniqueStrings(values: Array<string | null>) {
  return [...new Set(values.filter((value): value is string => Boolean(value)))];
}

function structuredResponse(row: Record<string, unknown>) {
  const legacyText = normalizedString(row.ritual_text);
  const legacyAction = normalizedString(row.action_text);
  const sentences = splitSentences(legacyText);
  const intro = normalizedString(row.intro) || sentences[0] || legacyText;
  const pullQuote = normalizedString(row.pull_quote) || meaningfulString(sentences[1], [row.title, intro]);
  const deeperRead = normalizedString(row.deeper_read) || meaningfulString(sentences.slice(2).join(" "), [row.title, intro, pullQuote]);
  const watchFor = normalizedString(row.watch_for);
  const move = normalizedString(row.move) || legacyAction;

  return {
    ...row,
    intro,
    pull_quote: pullQuote,
    deeper_read: deeperRead,
    watch_for: watchFor,
    move,
    ritual_text: legacyText || [intro, pullQuote, deeperRead].filter(Boolean).join(" "),
    action_text: legacyAction || move,
  };
}

function meaningfulString(value: unknown, nearbyValues: unknown[]) {
  const normalized = normalizedString(value);
  if (!normalized) return "";

  const fingerprint = dailyReadFingerprint(normalized);
  if (!fingerprint) return "";

  const duplicatesNearby = nearbyValues.some((nearbyValue) =>
    dailyReadFingerprint(normalizedString(nearbyValue)) === fingerprint
  );

  return duplicatesNearby ? "" : normalized;
}

function normalizedString(value: unknown) {
  return typeof value === "string"
    ? value.trim().replace(/\s+/g, " ")
    : "";
}

function dailyReadFingerprint(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, "")
    .replace(/\s+/g, " ");
}

function splitSentences(text: string) {
  const matches = text.match(/[^.!?]+[.!?]+/g);
  if (!matches) return text.trim() ? [text.trim()] : [];
  return matches.map((sentence) => sentence.trim()).filter(Boolean);
}

function normalizedDate(value: string | null) {
  if (!value) return null;

  const cleaned = value.trim();
  return /^\d{4}-\d{2}-\d{2}$/.test(cleaned) ? cleaned : null;
}

function normalizedSign(value: string | null) {
  const cleaned = normalizedString(value);
  return cleaned ? cleaned.toLowerCase() : "";
}

function dateStringInTimeZone(date: Date, timeZone: string) {
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

function stripSignPairFromTitle(title: unknown, westernSign: string, easternSign: string) {
  if (typeof title !== "string") return title;

  const western = toTitleCase(westernSign);
  const eastern = toTitleCase(easternSign);
  const pairPattern = new RegExp(
    `^${escapeRegExp(western)}\\s*[x×]\\s*${escapeRegExp(eastern)}\\s*:?(\\s*)`,
    "i",
  );

  return title
    .trim()
    .replace(/\s+/g, " ")
    .replace(pairPattern, "")
    .replace(/^[:\-\s]+/, "")
    .trim();
}

function toTitleCase(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

function escapeRegExp(value: string) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
