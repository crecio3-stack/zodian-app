import { createClient } from "npm:@supabase/supabase-js@2";

const WESTERN_SIGNS = [
  "Aries","Taurus","Gemini","Cancer","Leo","Virgo",
  "Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"
];

const EASTERN_SIGNS = [
  "Rat","Ox","Tiger","Rabbit","Dragon","Snake",
  "Horse","Goat","Monkey","Rooster","Dog","Pig"
];

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const body = await parseJsonBody(req);
    const requestedWestern = normalizeSign(
      body?.western_sign ?? url.searchParams.get("western_sign"),
      WESTERN_SIGNS,
    );
    const requestedEastern = normalizeSign(
      body?.eastern_sign ?? url.searchParams.get("eastern_sign"),
      EASTERN_SIGNS,
    );
    const fallbackOnly = booleanFlag(body?.fallback_only ?? url.searchParams.get("fallback_only"));
    const rewriteExisting = booleanFlag(body?.rewrite_existing ?? url.searchParams.get("rewrite_existing"));
    const rewriteAllExisting = booleanFlag(body?.rewrite_all_existing ?? url.searchParams.get("rewrite_all_existing"));
    const supabaseUrl = Deno.env.get("SUPABASE_URL");

    const supabaseKey =
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
      JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;

    const openaiKey = Deno.env.get("OPENAI_API_KEY");

    if (!supabaseUrl || !supabaseKey || !openaiKey) {
      return json({ error: "Missing environment variables" }, 500);
    }

    const supabase = createClient(supabaseUrl, supabaseKey);

    const ritualDate = normalizedDate(body?.ritual_date ?? url.searchParams.get("ritual_date"))
      ?? new Date().toISOString().slice(0, 10);

    if (rewriteAllExisting) {
      const { data: datesData, error: datesError } = await supabase
        .from("daily_rituals")
        .select("ritual_date")
        .not("ritual_date", "is", null);

      if (datesError) {
        console.error("Fetch dates error:", datesError.message);
        return json({ error: datesError.message }, 500);
      }

      const dates = Array.from(new Set((datesData || [])
        .map((row) => row.ritual_date)
        .filter((value) => typeof value === "string" && value.trim().length > 0)))
        .sort();

      let count = 0;

      for (const date of dates) {
        const { data: existing, error: fetchError } = await supabase
          .from("daily_rituals")
          .select("western_sign,eastern_sign")
          .eq("ritual_date", date);

        if (fetchError) {
          console.error("Fetch error:", fetchError.message);
          continue;
        }

        for (const pair of existing || []) {
          const ritual = fallbackOnly
            ? fallbackOne(date, pair, "rewrite")
            : await generateOne(openaiKey, date, pair, "rewrite")
              ?? fallbackOne(date, pair, "rewrite");

          const result = await supabase
            .from("daily_rituals")
            .upsert(ritual, {
              onConflict: "ritual_date,western_sign,eastern_sign",
            });

          if (result?.error) {
            console.error("Rewrite error:", result.error.message);
          } else {
            count++;
          }
        }
      }

      return json({
        count_rewritten: count,
        count_dates: dates.length,
        count_skipped: 0,
      });
    }

    const allPairs =
      requestedWestern && requestedEastern
        ? [{ western_sign: requestedWestern, eastern_sign: requestedEastern }]
        : WESTERN_SIGNS.flatMap(w =>
            EASTERN_SIGNS.map(e => ({ western_sign: w, eastern_sign: e }))
          );

    // fetch existing
    const { data: existing, error: fetchError } = await supabase
      .from("daily_rituals")
      .select("western_sign,eastern_sign")
      .eq("ritual_date", ritualDate);

    if (fetchError) {
      console.error("Fetch error:", fetchError.message);
      return json({ error: fetchError.message }, 500);
    }

    const existingSet = new Set(
      (existing || []).map((r) => `${r.western_sign}|${r.eastern_sign}`)
    );

    const missing = allPairs.filter(
      (p) => !existingSet.has(`${p.western_sign}|${p.eastern_sign}`)
    );
    const existingPairs = allPairs.filter((p) =>
      existingSet.has(`${p.western_sign}|${p.eastern_sign}`)
    );

    let created = 0;
    let rewritten = 0;

    for (const pair of missing) {
      const ritual = fallbackOnly
        ? fallbackOne(ritualDate, pair, "create")
        : await generateOne(openaiKey, ritualDate, pair, "create")
          ?? fallbackOne(ritualDate, pair, "create");

      const result = await supabase
        .from("daily_rituals")
        .upsert(ritual, {
          onConflict: "ritual_date,western_sign,eastern_sign",
        });

      if (result?.error) {
        console.error("Insert error:", result.error.message);
      } else {
        created++;
      }
    }

    if (rewriteExisting) {
      for (const pair of existingPairs) {
        const ritual = fallbackOnly
          ? fallbackOne(ritualDate, pair, "rewrite")
          : await generateOne(openaiKey, ritualDate, pair, "rewrite")
            ?? fallbackOne(ritualDate, pair, "rewrite");

        const result = await supabase
          .from("daily_rituals")
          .upsert(ritual, {
            onConflict: "ritual_date,western_sign,eastern_sign",
          });

        if (result?.error) {
          console.error("Rewrite error:", result.error.message);
        } else {
          rewritten++;
        }
      }
    }

    return json({
      count_created: created,
      count_rewritten: rewritten,
      count_skipped: allPairs.length - created - rewritten,
    });

  } catch (err) {
    console.error("Fatal error:", err);
    return json({ error: "Internal server error" }, 500);
  }
});

async function parseJsonBody(req: Request) {
  if (req.method !== "POST") return null;

  try {
    const text = await req.text();
    if (!text.trim()) return null;
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function normalizeSign(value: unknown, allowed: string[]) {
  if (typeof value !== "string") return null;

  const cleaned = value.trim().toLowerCase();
  return allowed.find((sign) => sign.toLowerCase() === cleaned) ?? null;
}

function normalizedDate(value: unknown) {
  if (typeof value !== "string") return null;

  const cleaned = value.trim();
  return /^\d{4}-\d{2}-\d{2}$/.test(cleaned) ? cleaned : null;
}

function booleanFlag(value: unknown) {
  if (typeof value === "boolean") return value;
  if (typeof value !== "string") return false;

  return ["1", "true", "yes", "on"].includes(value.trim().toLowerCase());
}

async function generateOne(
  openaiKey: string,
  date: string,
  pair: any,
  phase: "create" | "rewrite" = "create",
) {
  try {
    const res = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${openaiKey}`,
        "Content-Type": "application/json",
      },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          temperature: 0.55,
          messages: [
            {
              role: "system",
              content: [
                "You write daily horoscope-style rituals.",
                "Return only JSON. No explanation.",
                "The result should feel like a forecast for the day, not a checklist or self-help routine.",
                "Use a clear, sign-led headline every time, and keep the body more direct than poetic.",
                "Focus on what this day may bring, what tension or opportunity is in the air, and how the ritual helps the person notice it.",
                "Avoid time-of-day instructions, generic wellness steps, and sequences like begin, step, breathe, spend, conclude, or visualize.",
                "Keep the tone introspective, grounded, slightly poetic, and emotionally useful.",
                "Prefer the cleaner style of a sign-led title with a short thesis underneath, not an ornate horoscope paragraph.",
                phase === "rewrite"
                  ? "This is a rewrite pass for an already existing row. Make it feel fresher, more specific, and less generic than a first draft."
                  : "This is a first-draft pass for a missing row.",
              ].join(" "),
            },
            {
              role: "user",
              content: `
Create a horoscope-style daily ritual reading.

Western sign: ${pair.western_sign}
Eastern sign: ${pair.eastern_sign}

Return JSON:
{
  "title": "string",
  "ritual_text": "4-6 sentences",
  "action_text": "one short action"
}

Rules:
- The title must start with "${pair.western_sign} × ${pair.eastern_sign}:" and then a short headline.
- Keep the headline clean, specific, and easy to scan.
- The ritual_text must read like a day-ahead reading, not an essay.
- Use this structure:
  1. Opening mood or forecast for the day.
  2. What tension, opportunity, or pattern may show up.
  3. Where that may show up: relationships, work, self-control, or attention.
  4. How the ritual helps the person move through the day.
  5. Optional final sentence that leaves the reader feeling clear, grounded, or prepared.
- Keep each sentence short and direct where possible.
- Prefer the clearer style of "Today brings..." and "Something may ask you..." over ornate phrasing.
- Do not describe a morning routine, exact steps, or time-based instructions.
- Do not write a generic meditation or wellness checklist.
- Do not make the ritual sound like a to-do list, productivity advice, or wellness coaching.
- Do not use phrases like "begin your day," "step outside," "spend a few minutes," "practice deep breathing," or "conclude your morning ritual."
- action_text should be one practical line, but it should be framed as a way to work with the day, not just a chore.
- action_text should point toward the day ahead, not toward a specific time of day.
${phase === "rewrite" ? "- This is a rewrite pass, so prefer a new angle or sharper phrasing rather than repeating the prior draft." : ""}
            `,
            },
          ],
        }),
    });

    if (!res.ok) return null;

    const data = await res.json();
    const text = data?.choices?.[0]?.message?.content;

    if (!text) return null;

    let parsed;
    try {
      parsed = JSON.parse(extractJson(text));
    } catch {
      return null;
    }

    if (!parsed.title || !parsed.ritual_text || !parsed.action_text) {
      return null;
    }

    const ritualText = parsed.ritual_text.trim();
    if (!isHoroscopeLikeRitual(ritualText)) {
      return null;
    }

    return {
      ritual_date: date,
      western_sign: pair.western_sign,
      eastern_sign: pair.eastern_sign,
      title: normalizeTitle(parsed.title.trim(), pair),
      ritual_text: ritualText,
      action_text: parsed.action_text.trim(),
    };

  } catch (err) {
    console.error("OpenAI error:", err);
    return null;
  }
}

function fallbackOne(
  date: string,
  pair: { western_sign: string; eastern_sign: string },
  phase: "create" | "rewrite" = "create",
) {
  const western = pair.western_sign;
  const eastern = pair.eastern_sign;
  const title =
    phase === "rewrite"
      ? `${western} × ${eastern}: A Sharper Read Today`
      : `${western} × ${eastern}: Today's Pattern`;

  return {
    ritual_date: date,
    western_sign: western,
    eastern_sign: eastern,
    title,
    ritual_text: [
      `Today brings the visible rhythm of ${western} into conversation with the deeper instinct of ${eastern}.`,
      "Something may ask you to notice the difference between your first reaction and the quieter truth underneath.",
      "Let the day show you where your pattern is useful, and where it needs a little more honesty.",
      "The read is simple: move with awareness before old momentum decides for you.",
    ].join(" "),
    action_text: "Pause once today before reacting, and choose the cleaner response.",
  };
}

function normalizeTitle(title: string, pair: { western_sign: string; eastern_sign: string }) {
  const western = toTitleCase(pair.western_sign);
  const eastern = toTitleCase(pair.eastern_sign);
  const prefix = `${western} × ${eastern}`;
  const cleaned = title.trim().replace(/\s+/g, " ");
  const pairPattern = new RegExp(
    `^${escapeRegExp(western)}\\s*[x×]\\s*${escapeRegExp(eastern)}\\s*:?(\\s*)`,
    "i"
  );

  if (pairPattern.test(cleaned)) {
    return cleaned.replace(pairPattern, `${prefix}: `).replace(/\s+/g, " ").trim();
  }

  if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
    return cleaned;
  }

  return `${prefix}: ${cleaned}`;
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

function extractJson(text: string) {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  return text.slice(start, end + 1);
}

function isHoroscopeLikeRitual(text: string) {
  const lower = text.toLowerCase();
  const blockedPhrases = [
    "begin your day",
    "start your day",
    "step outside",
    "spend a few minutes",
    "practice deep breathing",
    "conclude your morning ritual",
    "morning ritual",
    "evening ritual",
    "here are",
    "first,",
    "second,",
    "third,",
    "follow these steps",
    "do this",
    "try to",
    "take a few",
    "set aside",
  ];

  return !blockedPhrases.some((phrase) => lower.includes(phrase));
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
} 
