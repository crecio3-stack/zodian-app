import { createClient } from "npm:@supabase/supabase-js@2";

const WESTERN_SIGNS = [
  "Aries","Taurus","Gemini","Cancer","Leo","Virgo",
  "Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"
];

const EASTERN_SIGNS = [
  "Rat","Ox","Tiger","Rabbit","Dragon","Snake",
  "Horse","Goat","Monkey","Rooster","Dog","Pig"
];

const DAILY_ACTIVATION_THEMES = [
  "Identity",
  "Confidence",
  "Momentum",
  "Attention",
  "Curiosity",
  "Creativity",
  "Humor",
  "Belonging",
  "Relationships",
  "Ambition",
  "Leadership",
  "Resilience",
  "Boundaries",
  "Joy",
  "Playfulness",
  "Patience",
  "Uncertainty",
  "Control",
  "Recognition",
  "Independence",
  "Routine",
  "Habits",
  "Adaptability",
  "Influence",
  "Communication",
  "Intuition",
  "Growth",
  "Rest",
  "Purpose",
  "Work",
  "Self-image",
  "Decision making",
  "Attachment",
  "Trust",
] as const;

const BATCH_EMOTIONAL_FRAME_PATTERNS: Record<string, string[]> = {
  control: ["control", "command", "dominance", "follow", "pressure", "power", "lead", "plan"],
  trust: ["trust", "testing", "prove", "loyal", "loyalty", "guard", "suspicion", "betrayal"],
  boundaries: ["boundary", "boundaries", "access", "permission", "too much in", "softness", "protect"],
  uncertainty: ["uncertainty", "certainty", "doubt", "unknown", "unclear", "hesitation", "question"],
  avoidance: ["avoid", "escape", "motion", "move", "moving", "chase", "outrun", "dodge", "deflect"],
  agreeability: ["agree", "pleasant", "harmony", "smooth", "soften", "comfortable", "easygoing"],
  self_doubt: ["second-guess", "doubt", "hesitate", "permission", "unsure", "reassurance", "approval"],
  hidden_flaw: ["secretly", "hidden", "reveals", "exposes", "tension", "problem", "cost"],
};

const PSYCHOLOGICAL_DIMENSION_PATTERNS: Record<string, string[]> = {
  identity: ["identity", "role", "persona", "authentic", "become", "version"],
  confidence: ["confidence", "confident", "bold", "sure", "self-trust", "conviction"],
  momentum: ["momentum", "pace", "progress", "traction", "stalled", "speed", "motion"],
  ambition: ["ambition", "achieve", "achievement", "goal", "success", "drive", "advance"],
  humor: ["humor", "funny", "playful", "lighten", "joke", "wit", "amuse"],
  belonging: ["belong", "belonging", "included", "outsider", "acceptance", "fit in"],
  relationships: ["relationship", "relationships", "closeness", "care", "people", "connection"],
  trust: ["trust", "suspicion", "betrayal", "testing", "prove", "rely", "loyalty"],
  attention: ["attention", "focus", "distraction", "overlook", "priority"],
  curiosity: ["curiosity", "curious", "question", "explore", "interest", "wonder"],
  creativity: ["creativity", "creative", "original", "invent", "expression", "imagination"],
  leadership: ["leadership", "lead", "authority", "direction", "command", "responsibility"],
  resilience: ["resilience", "recover", "steady", "bounce", "endure", "regain", "keep going"],
  boundaries: ["boundary", "boundaries", "limit", "access", "permission", "enough", "protect"],
  joy: ["joy", "delight", "pleasure", "enjoy", "savor", "glad", "bright"],
  playfulness: ["play", "playful", "experiment", "light", "fun", "loosen", "try"],
  patience: ["patience", "patient", "wait", "slow", "unfold", "rush", "delay"],
  uncertainty: ["uncertainty", "uncertain", "unknown", "doubt", "ambiguity", "hesitation"],
  control: ["control", "manage", "command", "grip", "contain", "orchestrate"],
  recognition: ["recognition", "seen", "credit", "acknowledge", "overlooked", "approval"],
  independence: ["independence", "independent", "autonomy", "freedom", "self-reliance"],
  routine: ["routine", "habit", "repeat", "familiar", "consistency", "structure"],
  habits: ["habit", "habits", "routine", "pattern", "repeat", "automatic", "default"],
  adaptability: ["adapt", "adaptability", "adjust", "flexible", "pivot", "change course"],
  influence: ["influence", "persuade", "impact", "shape", "sway", "presence"],
  communication: ["communication", "say", "speak", "words", "explain", "express"],
  intuition: ["intuition", "intuitive", "hunch", "sense", "signal", "notice", "instinct"],
  growth: ["growth", "grow", "learn", "mature", "practice", "expand", "develop"],
  rest: ["rest", "pause", "recover", "ease", "capacity", "exhale", "stop"],
  purpose: ["purpose", "meaning", "matter", "direction", "why", "commitment", "useful"],
  work: ["work", "task", "project", "effort", "deliver", "finish", "standard"],
  "self-image": ["self-image", "image", "appearance", "impression", "presentation", "perception"],
  "decision making": ["decision", "choice", "choose", "decide", "options", "commit"],
  attachment: ["attachment", "attached", "closeness", "connection", "depend", "separation"],
};

const EXHAUSTION_CLUSTER_PATTERNS: Record<string, string[]> = {
  "guarded protection": [
    "guard", "guarded", "protect", "protection", "self-protection", "shield", "armor",
    "defend", "defensive", "distance", "detachment", "exposed", "vulnerability", "vulnerable",
  ],
  "hidden hostility": [
    "resentment", "resentful", "envy", "envious", "rivalry", "grudge", "jealous",
    "judgment", "slight", "scorekeeping", "comparison",
  ],
  "secrecy and withholding": [
    "secret", "secrecy", "hidden", "hide", "withhold", "withholding", "conceal",
    "unspoken", "private motive", "true intention", "strategic reveal",
  ],
  "fairness as cover": [
    "fair", "fairness", "balance", "diplomacy", "compromise", "harmony", "neutral",
    "even", "reasonable", "self-interest",
  ],
  "conflict avoidance": [
    "avoid conflict", "conflict", "disagreement", "pushback", "direct answer", "hard conversation",
    "keep the peace", "pleasant", "smooth over", "uncomfortable", "agreeable",
  ],
  "hesitation and second guessing": [
    "hesitate", "hesitation", "second-guess", "second guess", "doubt", "unsure",
    "reconsider", "overthink", "another option", "wait for permission",
  ],
  "self-softening": [
    "soften", "softening", "tone it down", "make it easier", "less intense", "hold back",
    "want less", "need less", "ask for less", "keeping everyone comfortable",
  ],
  "diagnostic flaw frame": [
    "secretly", "hidden flaw", "reveals where", "exposes where", "the problem starts",
    "the cost", "becomes costly", "tension starts",
  ],
};

const EMOTIONAL_NEIGHBORHOOD_PATTERNS: Record<string, string[]> = {
  "guardedness/protection/boundaries": [
    "guard", "guarded", "protect", "protection", "boundary", "boundaries", "limit",
    "space", "shield", "defend", "defensive", "position", "privacy", "private", "vulnerable",
  ],
  "control/strategy/careful timing": [
    "control", "strategy", "strategic", "timing", "careful", "carefully", "manage",
    "steer", "shape", "calculate", "calculation", "precise", "precision", "watch closely",
    "read the room", "wait for", "right moment",
  ],
  "harmony/smoothing/softening": [
    "harmony", "pleasant", "agreeable", "agree", "keep the peace", "smooth", "soften",
    "diplomacy", "diplomatic", "comfortable", "tone", "polite", "civil", "clash",
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
    "creative", "creativity", "curious", "curiosity", "experiment", "test", "try",
    "idea", "spark", "invent", "imagine", "question", "explore", "offbeat", "different way",
  ],
  "rest/patience/enoughness": [
    "rest", "pause", "patient", "patience", "enough", "enoughness", "settle", "settled",
    "slow", "slower", "capacity", "recover", "ease", "sufficient", "finished",
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
    "intuition", "intuitive", "perception", "notice", "noticing", "sense", "signal",
    "hunch", "read", "discern", "discernment", "subtle", "spot", "see", "detect",
  ],
};

const POSITIVE_NEIGHBORHOOD_FLOORS: Record<string, number> = {
  "joy/playfulness/humor": 2,
  "confidence/leadership/credit": 2,
  "creativity/curiosity/experimentation": 2,
  "rest/patience/enoughness": 1,
};

const NEIGHBORHOOD_SOFT_CAP = 4;

const ACTIVATION_THEME_NEIGHBORHOODS: Record<string, string[]> = {
  Confidence: ["confidence/leadership/credit"],
  Leadership: ["confidence/leadership/credit"],
  Recognition: ["confidence/leadership/credit"],
  Joy: ["joy/playfulness/humor"],
  Playfulness: ["joy/playfulness/humor", "creativity/curiosity/experimentation"],
  Humor: ["joy/playfulness/humor"],
  Creativity: ["creativity/curiosity/experimentation"],
  Curiosity: ["creativity/curiosity/experimentation", "intuition/perception/noticing"],
  Attention: ["intuition/perception/noticing"],
  Intuition: ["intuition/perception/noticing"],
  Rest: ["rest/patience/enoughness"],
  Patience: ["rest/patience/enoughness"],
  Work: ["work/ambition/momentum"],
  Ambition: ["work/ambition/momentum", "confidence/leadership/credit"],
  Momentum: ["work/ambition/momentum"],
  Relationships: ["relationships/warmth/connection"],
  Belonging: ["relationships/warmth/connection"],
  Attachment: ["relationships/warmth/connection"],
  Communication: ["relationships/warmth/connection"],
  Boundaries: ["guardedness/protection/boundaries"],
  Control: ["control/strategy/careful timing"],
  Routine: ["work/ambition/momentum", "rest/patience/enoughness"],
  Habits: ["work/ambition/momentum"],
};

type IdentityRangeProfile = {
  avoidOveruse: string[];
  exploreMore: string[];
  signatureStrengths: string[];
  positiveModes: string[];
  titleLanguageHints: string[];
  emotionalRangeNotes: string[];
};

const IDENTITY_RANGE_PROFILES: Record<string, IdentityRangeProfile> = {
  "Libra × Snake": {
    avoidOveruse: [
      "carefulness",
      "restraint",
      "social management",
      "guardedness",
      "subtle control",
    ],
    exploreMore: [
      "taste",
      "charm",
      "discernment",
      "social intelligence",
      "style",
      "wit",
      "persuasive warmth",
      "intuition",
      "standards",
      "pleasure",
      "creativity",
      "elegance",
      "timing as artistry",
    ],
    signatureStrengths: [
      "making selectiveness feel graceful",
      "using charm without losing standards",
      "turning perception into tasteful action",
    ],
    positiveModes: [
      "playful elegance",
      "confident discernment",
      "creative taste",
      "warm influence",
    ],
    titleLanguageHints: [
      "favor natural, magazine-like titles over abstract inner-state labels",
      "let titles sound witty, stylish, specific, or lightly provocative when the read supports it",
    ],
    emotionalRangeNotes: [
      "Treat timing as artistry, not only caution.",
      "Let pleasure, humor, taste, and social ease appear as real identity details.",
    ],
  },
};

type PriorReadSummary = {
  ritual_date: string;
  title: string;
  theme: string;
  dimension: string;
  dimension_score: number;
  neighborhoods: string[];
  primary_neighborhood: string;
  intro: string;
  pull_quote: string;
  deeper_read: string;
  watch_for: string;
  move: string;
};

type StructuredDailyReadPayload = {
  title: string;
  intro: string;
  pull_quote: string;
  deeper_read: string;
  watch_for: string;
  move: string;
};

type PatternIntelligenceMetadata = {
  confidence: number;
  reflection: number;
  connection: number;
  growth: number;
  momentum: number;
  primary_signal: string;
  secondary_signal: string;
  emotional_tone: string;
  theme_tags: string[];
};

type GenerationFailureStage =
  | "provider_error"
  | "empty_response"
  | "parse_error"
  | "missing_fields"
  | "validation"
  | "exhausted_retries"
  | "unknown";

type GenerationDebugFailure = {
  pair: string;
  stage: GenerationFailureStage;
  phase: "create" | "rewrite";
  theme: string;
  ritual_date: string;
  attempt?: number;
  reasons?: string[];
  provider_status?: number;
  provider_message?: string;
};

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
    const stripTitlePairs = booleanFlag(body?.strip_title_pairs ?? url.searchParams.get("strip_title_pairs"));
    const debugGeneration = booleanFlag(body?.debug_generation ?? url.searchParams.get("debug_generation"));
    const daysAhead = normalizedInteger(body?.days_ahead ?? url.searchParams.get("days_ahead"), 0, 7) ?? 0;
    const supabaseUrl = Deno.env.get("SUPABASE_URL");

    const supabaseKey =
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||
      JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}").service_role;

    const openaiKey = Deno.env.get("OPENAI_API_KEY");

    if (!supabaseUrl || !supabaseKey) {
      return json({ error: "Missing environment variables" }, 500);
    }

    const requiresOpenAI = !fallbackOnly && !stripTitlePairs;
    if (requiresOpenAI && !openaiKey) {
      return json({ error: "Missing OPENAI_API_KEY. Use fallback_only=true for a safe local structured refresh." }, 500);
    }

    const supabase = createClient(supabaseUrl, supabaseKey);

    const ritualDate = normalizedDate(body?.ritual_date ?? url.searchParams.get("ritual_date"))
      ?? dateStringInTimeZone(addDays(new Date(), daysAhead), "America/Los_Angeles");

    const recentReadSummaries = requiresOpenAI
      ? await fetchRecentReadSummaries(supabase, ritualDate, 21)
      : new Map<string, PriorReadSummary[]>();

    if (stripTitlePairs) {
      let rowsQuery = supabase
        .from("daily_rituals")
        .select("id,title,western_sign,eastern_sign");

      if (ritualDate) {
        rowsQuery = rowsQuery.eq("ritual_date", ritualDate);
      }

      const { data: rows, error: rowsError } = await rowsQuery;

      if (rowsError) {
        console.error("Fetch title cleanup rows error:", rowsError.message);
        return json({ error: rowsError.message }, 500);
      }

      let count = 0;

      for (const row of rows || []) {
        const title = typeof row.title === "string" ? row.title : "";
        const western = typeof row.western_sign === "string" ? row.western_sign : "";
        const eastern = typeof row.eastern_sign === "string" ? row.eastern_sign : "";
        const cleanedTitle = stripSignPairFromTitle(title, { western_sign: western, eastern_sign: eastern });

        if (cleanedTitle && cleanedTitle !== title) {
          const { error: updateError } = await supabase
            .from("daily_rituals")
            .update({ title: cleanedTitle })
            .eq("id", row.id);

          if (updateError) {
            console.error("Title cleanup update error:", updateError.message);
          } else {
            count++;
          }
        }
      }

      return json({ count_updated: count, count_checked: rows?.length ?? 0 });
    }

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
      let failed = 0;

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
          const ritual = await generateWithSafeFallback(
            openaiKey,
            date,
            pair,
            "rewrite",
            fallbackOnly,
            recentReadSummaries.get(pairKey(pair.western_sign, pair.eastern_sign)) ?? [],
          );

          if (!ritual) {
            failed++;
            continue;
          }

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
        count_failed: failed,
      });
    }

    const westernBatch = requestedWestern ? [requestedWestern] : WESTERN_SIGNS;
    const easternBatch = requestedEastern ? [requestedEastern] : EASTERN_SIGNS;
    const allPairs = westernBatch.flatMap(w =>
      easternBatch.map(e => ({ western_sign: w, eastern_sign: e }))
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
    let failed = 0;
    const failedPairs: string[] = [];
    const debugFailures: GenerationDebugFailure[] | undefined = debugGeneration ? [] : undefined;

    const dailyThemeOffset = dailyThemeRotationOffset(ritualDate);
    const themeByPair = dailyThemeAssignments(
      ritualDate,
      allPairs,
      dailyThemeOffset,
      recentReadSummaries,
    );
    const batchFrameCounts = new Map<string, number>();
    const batchFrameLimit = emotionalFrameLimit(allPairs.length);

    for (const pair of missing) {
      const ritual = await generateWithSafeFallback(
        openaiKey,
        ritualDate,
        pair,
        "create",
        fallbackOnly,
        recentReadSummaries.get(pairKey(pair.western_sign, pair.eastern_sign)) ?? [],
        themeByPair.get(pairKey(pair.western_sign, pair.eastern_sign))
          ?? chooseDailyActivationTheme(ritualDate, pair),
        batchFrameCounts,
        batchFrameLimit,
        debugFailures,
      );

      if (!ritual) {
        failed++;
        failedPairs.push(`${pair.western_sign} × ${pair.eastern_sign}`);
        continue;
      }

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
        const ritual = await generateWithSafeFallback(
          openaiKey,
          ritualDate,
          pair,
          "rewrite",
          fallbackOnly,
          recentReadSummaries.get(pairKey(pair.western_sign, pair.eastern_sign)) ?? [],
          themeByPair.get(pairKey(pair.western_sign, pair.eastern_sign))
            ?? chooseDailyActivationTheme(ritualDate, pair),
          batchFrameCounts,
          batchFrameLimit,
          debugFailures,
        );

        if (!ritual) {
          failed++;
          failedPairs.push(`${pair.western_sign} × ${pair.eastern_sign}`);
          continue;
        }

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

    const response: Record<string, unknown> = {
      ritual_date: ritualDate,
      count_created: created,
      count_rewritten: rewritten,
      count_skipped: allPairs.length - created - rewritten - failed,
      count_failed: failed,
      failed_pairs: failedPairs,
    };

    if (debugGeneration) {
      response.debug_failures = debugFailures ?? [];
    }

    return json(response);

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

function dateStringShift(dateString: string, days: number) {
  const source = new Date(`${dateString}T12:00:00.000Z`);
  if (Number.isNaN(source.getTime())) return dateString;
  return dateStringInTimeZone(addDays(source, days), "America/Los_Angeles");
}

function pairKey(western: string, eastern: string) {
  return `${western}|${eastern}`;
}

function normalizedInteger(value: unknown, min: number, max: number) {
  const parsed =
    typeof value === "number"
      ? value
      : typeof value === "string"
        ? Number.parseInt(value.trim(), 10)
        : Number.NaN;

  if (!Number.isInteger(parsed)) return null;

  return Math.min(Math.max(parsed, min), max);
}

function addDays(date: Date, days: number) {
  const result = new Date(date);
  result.setUTCDate(result.getUTCDate() + days);
  return result;
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

function booleanFlag(value: unknown) {
  if (typeof value === "boolean") return value;
  if (typeof value !== "string") return false;

  return ["1", "true", "yes", "on"].includes(value.trim().toLowerCase());
}

async function fetchRecentReadSummaries(
  supabase: any,
  ritualDate: string,
  lookbackDays: number,
) {
  const cutoffDate = dateStringShift(ritualDate, -lookbackDays);
  const { data, error } = await supabase
    .from("daily_rituals")
    .select("ritual_date,western_sign,eastern_sign,title,intro,pull_quote,deeper_read,watch_for,move")
    .gte("ritual_date", cutoffDate)
    .lt("ritual_date", ritualDate)
    .order("ritual_date", { ascending: false });

  if (error) {
    console.error("Fetch recent read summaries error:", error.message);
    return new Map<string, PriorReadSummary[]>();
  }

  const grouped = new Map<string, PriorReadSummary[]>();

  for (const row of (data || []) as any[]) {
    const western = typeof row.western_sign === "string" ? row.western_sign : "";
    const eastern = typeof row.eastern_sign === "string" ? row.eastern_sign : "";
    const read = {
      title: typeof row.title === "string" ? row.title.trim() : "",
      intro: typeof row.intro === "string" ? row.intro : "",
      pull_quote: typeof row.pull_quote === "string" ? row.pull_quote : "",
      deeper_read: typeof row.deeper_read === "string" ? row.deeper_read : "",
      watch_for: typeof row.watch_for === "string" ? row.watch_for : "",
      move: typeof row.move === "string" ? row.move : "",
    };
    const theme = summarizeDailyReadTheme(read);
    const dimension = inferPsychologicalDimension(read);
    const dimensionScore = psychologicalDimensionScore(read, dimension);
    const neighborhoods = emotionalNeighborhoods(read);
    const primaryNeighborhood = dominantEmotionalNeighborhood(read);

    if (!western || !eastern || !read.title) continue;

    const key = pairKey(western, eastern);
    const list = grouped.get(key) ?? [];

    if (list.length >= 14) continue;

    list.push({
      ritual_date: typeof row.ritual_date === "string" ? row.ritual_date : "",
      title: read.title,
      theme,
      dimension,
      dimension_score: dimensionScore,
      neighborhoods,
      primary_neighborhood: primaryNeighborhood,
      intro: read.intro,
      pull_quote: read.pull_quote,
      deeper_read: read.deeper_read,
      watch_for: read.watch_for,
      move: read.move,
    });
    grouped.set(key, list);
  }

  for (const [key, list] of grouped.entries()) {
    grouped.set(
      key,
      list
        .slice()
        .sort((a, b) => a.ritual_date.localeCompare(b.ritual_date)),
    );
  }

  return grouped;
}

function inferPsychologicalDimension(read: StructuredDailyReadPayload) {
  const source = Object.values(read).join(" ").toLowerCase();
  let bestDimension = "unclassified";
  let bestScore = 0;

  for (const [dimension, patterns] of Object.entries(PSYCHOLOGICAL_DIMENSION_PATTERNS)) {
    const score = patternScore(source, patterns);
    if (score > bestScore) {
      bestDimension = dimension;
      bestScore = score;
    }
  }

  return bestDimension;
}

function psychologicalDimensionScore(
  read: StructuredDailyReadPayload,
  dimension: string,
) {
  const patterns = PSYCHOLOGICAL_DIMENSION_PATTERNS[dimension];
  if (!patterns) return 0;

  return patternScore(Object.values(read).join(" ").toLowerCase(), patterns);
}

function exhaustionClusters(read: StructuredDailyReadPayload) {
  const source = Object.values(read).join(" ").toLowerCase();

  return Object.entries(EXHAUSTION_CLUSTER_PATTERNS)
    .filter(([, patterns]) => patternScore(source, patterns) >= 2)
    .map(([cluster]) => cluster);
}

function emotionalNeighborhoods(read: StructuredDailyReadPayload) {
  const source = Object.values(read).join(" ").toLowerCase();

  return Object.entries(EMOTIONAL_NEIGHBORHOOD_PATTERNS)
    .filter(([, patterns]) => patternScore(source, patterns) >= 2)
    .map(([neighborhood]) => neighborhood);
}

function dominantEmotionalNeighborhood(read: StructuredDailyReadPayload) {
  const source = Object.values(read).join(" ").toLowerCase();
  let bestNeighborhood = "";
  let bestScore = 0;

  for (const [neighborhood, patterns] of Object.entries(EMOTIONAL_NEIGHBORHOOD_PATTERNS)) {
    const score = patternScore(source, patterns);
    if (score > bestScore) {
      bestNeighborhood = neighborhood;
      bestScore = score;
    }
  }

  return bestScore >= 2 ? bestNeighborhood : "";
}

function recentNeighborhoodCounts(priorReads: PriorReadSummary[], limit = 14) {
  const counts = new Map<string, number>();

  for (const read of priorReads.slice(-limit)) {
    const primary = read.primary_neighborhood || read.neighborhoods[0] || "";
    if (primary) {
      counts.set(primary, (counts.get(primary) ?? 0) + 1);
    }
  }

  return counts;
}

function recentSecondaryNeighborhoodCounts(priorReads: PriorReadSummary[], limit = 14) {
  const counts = new Map<string, number>();

  for (const read of priorReads.slice(-limit)) {
    for (const neighborhood of read.neighborhoods) {
      counts.set(neighborhood, (counts.get(neighborhood) ?? 0) + 1);
    }
  }

  return counts;
}

function overusedNeighborhoods(priorReads: PriorReadSummary[], limit = 14) {
  return Array.from(recentNeighborhoodCounts(priorReads, limit).entries())
    .filter(([, count]) => count >= NEIGHBORHOOD_SOFT_CAP)
    .map(([neighborhood]) => neighborhood);
}

function underservedPositiveNeighborhoods(priorReads: PriorReadSummary[], limit = 14) {
  const counts = recentNeighborhoodCounts(priorReads, limit);

  return Object.entries(POSITIVE_NEIGHBORHOOD_FLOORS)
    .filter(([neighborhood, floor]) => (counts.get(neighborhood) ?? 0) < floor)
    .map(([neighborhood]) => neighborhood);
}

function neighborhoodCountSummary(priorReads: PriorReadSummary[], limit = 14) {
  const counts = recentNeighborhoodCounts(priorReads, limit);
  const secondaryCounts = recentSecondaryNeighborhoodCounts(priorReads, limit);

  return Object.keys(EMOTIONAL_NEIGHBORHOOD_PATTERNS)
    .map((neighborhood) => `${neighborhood}: primary ${counts.get(neighborhood) ?? 0}/${limit + 1}, mentioned ${secondaryCounts.get(neighborhood) ?? 0}/${limit + 1}`)
    .join("; ");
}

function patternScore(source: string, patterns: string[]) {
  return patterns.reduce((score, pattern) => {
    if (pattern.includes(" ")) {
      return source.includes(pattern) ? score + 1 : score;
    }

    const matches = source.match(new RegExp(`\\b${escapeRegExp(pattern)}\\w*\\b`, "g"));
    return score + (matches?.length ?? 0);
  }, 0);
}

function priorReadPayload(read: PriorReadSummary): StructuredDailyReadPayload {
  return {
    title: read.title,
    intro: read.intro,
    pull_quote: read.pull_quote,
    deeper_read: read.deeper_read,
    watch_for: read.watch_for,
    move: read.move,
  };
}

function recentExhaustedDimensions(priorReads: PriorReadSummary[], limit = 7) {
  return Array.from(new Set(
    priorReads
      .slice(-limit)
      .filter((read) => read.dimension_score >= 2)
      .map((read) => read.dimension)
      .filter((dimension) => dimension !== "unclassified"),
  ));
}

function recentExhaustedClusters(priorReads: PriorReadSummary[], limit = 7) {
  return Array.from(new Set(
    priorReads
      .slice(-limit)
      .flatMap((read) => exhaustionClusters(priorReadPayload(read))),
  ));
}

function summarizeDailyReadTheme(read: StructuredDailyReadPayload) {
  const source = [read.pull_quote, read.deeper_read, read.intro, read.watch_for, read.move]
    .find((value) => typeof value === "string" && value.trim().length > 0) ?? read.title;

  const firstSentence = splitSentences(source)[0]?.replace(/\s+/g, " ").trim() ?? "";
  if (firstSentence) {
    return firstSentence.replace(/[.!?]+$/, "").slice(0, 120);
  }

  return read.title;
}

function patternIntelligenceMetadata(
  read: StructuredDailyReadPayload,
  activationTheme: string,
  priorReads: PriorReadSummary[] = [],
): PatternIntelligenceMetadata {
  const dimension = inferPsychologicalDimension(read);
  const dimensionScore = psychologicalDimensionScore(read, dimension);
  const neighborhoods = emotionalNeighborhoods(read);
  const primaryNeighborhood = dominantEmotionalNeighborhood(read);
  const primarySignal = signalLabel(dimension !== "unclassified" ? dimension : activationTheme);
  const secondarySignal = signalLabel(primaryNeighborhood || neighborhoods[0] || activationTheme);
  const themeTags = uniqueNonBlankStrings([
    activationTheme,
    primarySignal,
    secondarySignal,
    ...neighborhoods.map(signalLabel),
  ]).slice(0, 5);
  const readableBehaviorScore = containsRecognizableBehavior(read) ? 0.18 : 0;
  const actionScore = startsWithActionVerb(read.move) ? 0.16 : 0;
  const repeatedDimensionCount = priorReads
    .slice(-7)
    .filter((prior) => prior.dimension === dimension)
    .length;
  const recentNeighborhoodCount = primaryNeighborhood
    ? priorReads.slice(-14).filter((prior) => prior.primary_neighborhood === primaryNeighborhood).length
    : 0;

  return {
    confidence: clamp01(0.46 + Math.min(0.28, dimensionScore * 0.06) + readableBehaviorScore),
    reflection: clamp01(0.38 + patternScore(read.deeper_read.toLowerCase(), [
      "notice",
      "recognize",
      "understand",
      "truth",
      "choice",
      "pattern",
      "name",
    ]) * 0.07),
    connection: clamp01(0.32 + patternScore(Object.values(read).join(" ").toLowerCase(), [
      "connection",
      "connect",
      "people",
      "someone",
      "relationship",
      "belong",
      "share",
      "conversation",
    ]) * 0.08),
    growth: clamp01(0.36 + actionScore + patternScore(read.move.toLowerCase(), [
      "choose",
      "ask",
      "say",
      "start",
      "try",
      "change",
      "let",
      "finish",
    ]) * 0.06),
    momentum: clamp01(0.34 + actionScore + Math.max(0, 0.18 - repeatedDimensionCount * 0.03) + Math.max(0, 0.12 - recentNeighborhoodCount * 0.025)),
    primary_signal: primarySignal,
    secondary_signal: secondarySignal,
    emotional_tone: emotionalToneForNeighborhood(primaryNeighborhood, activationTheme),
    theme_tags: themeTags,
  };
}

function signalLabel(value: string) {
  const normalized = value
    .trim()
    .replace(/[\/_-]+/g, " ")
    .replace(/\s+/g, " ");

  if (!normalized) return "Identity";

  return normalized
    .split(" ")
    .slice(0, 3)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join(" ");
}

function uniqueNonBlankStrings(values: string[]) {
  return Array.from(new Set(
    values
      .map((value) => value.trim())
      .filter((value) => value.length > 0),
  ));
}

function emotionalToneForNeighborhood(neighborhood: string, activationTheme: string) {
  if (neighborhood.includes("joy")) return "playful";
  if (neighborhood.includes("confidence")) return "empowering";
  if (neighborhood.includes("creativity")) return "curious";
  if (neighborhood.includes("rest")) return "grounded";
  if (neighborhood.includes("relationships")) return "relational";
  if (neighborhood.includes("work")) return "momentum";
  if (neighborhood.includes("intuition")) return "reflective";
  if (["Confidence", "Leadership", "Recognition"].includes(activationTheme)) return "empowering";
  if (["Joy", "Playfulness", "Humor"].includes(activationTheme)) return "playful";
  if (["Momentum", "Growth", "Work"].includes(activationTheme)) return "momentum";
  return "reflective";
}

function clamp01(value: number) {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.min(1, Number(value.toFixed(2))));
}

function pushGenerationDebugFailure(
  debugFailures: GenerationDebugFailure[] | undefined,
  entry: GenerationDebugFailure,
) {
  if (debugFailures) {
    debugFailures.push(entry);
  }
}

async function generateWithSafeFallback(
  openaiKey: string | undefined,
  date: string,
  pair: { western_sign: string; eastern_sign: string },
  phase: "create" | "rewrite",
  fallbackOnly: boolean,
  priorReads: PriorReadSummary[] = [],
  activationTheme: string = chooseDailyActivationTheme(date, pair),
  batchFrameCounts?: Map<string, number>,
  batchFrameLimit = emotionalFrameLimit(1),
  debugFailures?: GenerationDebugFailure[],
) {
  if (fallbackOnly || !openaiKey) {
    const fallback = fallbackOne(date, pair, phase, activationTheme);
    if (!fallback) return null;
    recordBatchEmotionalFrame(fallback, batchFrameCounts);
    return fallback;
  }

  const generated = await generateOne(
    openaiKey,
    date,
    pair,
    phase,
    priorReads,
    activationTheme,
    batchFrameCounts,
    batchFrameLimit,
    debugFailures,
  );
  if (generated) {
    recordBatchEmotionalFrame(generated, batchFrameCounts);
    return generated;
  }

  console.error("Today’s Lens generation exhausted retries; no repetitive fallback row was written.", {
    pair: `${pair.western_sign} × ${pair.eastern_sign}`,
    theme: activationTheme,
    phase,
    ritual_date: date,
  });
  pushGenerationDebugFailure(debugFailures, {
    pair: `${pair.western_sign} × ${pair.eastern_sign}`,
    stage: "exhausted_retries",
    phase,
    theme: activationTheme,
    ritual_date: date,
  });

  return null;
}

async function generateOne(
  openaiKey: string,
  date: string,
  pair: any,
  phase: "create" | "rewrite" = "create",
  priorReads: PriorReadSummary[] = [],
  activationTheme: string = chooseDailyActivationTheme(date, pair),
  batchFrameCounts?: Map<string, number>,
  batchFrameLimit = emotionalFrameLimit(1),
  debugFailures?: GenerationDebugFailure[],
) {
  try {
    let lastRejectionReasons: string[] = [];

    // One initial draft plus six corrective regenerations.
    const maxAttempts = 7;

    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      let res: Response;

      try {
        res = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${openaiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: "gpt-4.1-mini",
            temperature: attempt === 0 ? 0.72 : 0.66,
            response_format: { type: "json_object" },
            messages: dailyReadMessages(
              pair,
              phase,
              activationTheme,
              priorReads,
              attempt === 0 ? [] : lastRejectionReasons,
            ),
          }),
        });
      } catch (err) {
        const providerMessage = err instanceof Error ? err.message : String(err);
        pushGenerationDebugFailure(debugFailures, {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          stage: "provider_error",
          phase,
          theme: activationTheme,
          ritual_date: date,
          attempt: attempt + 1,
          provider_message: providerMessage,
        });
        console.error("OpenAI request error:", {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          theme: activationTheme,
          phase,
          attempt: attempt + 1,
          retry_count: attempt + 1,
          max_attempts: maxAttempts,
          error: err instanceof Error ? err.message : String(err),
        });
        lastRejectionReasons = ["OpenAI request failed before a response was returned."];
        await sleep(retryDelayMs(attempt));
        continue;
      }

      if (!res.ok) {
        const providerMessage = debugFailures
          ? await res.text().catch(() => "")
          : "";
        pushGenerationDebugFailure(debugFailures, {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          stage: "provider_error",
          phase,
          theme: activationTheme,
          ritual_date: date,
          attempt: attempt + 1,
          provider_status: res.status,
          provider_message: providerMessage.slice(0, 500),
        });
        console.error("OpenAI status error:", {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          theme: activationTheme,
          phase,
          attempt: attempt + 1,
          retry_count: attempt + 1,
          max_attempts: maxAttempts,
          status: res.status,
        });

        if (res.status === 408 || res.status === 409 || res.status === 429 || res.status >= 500) {
          lastRejectionReasons = [`OpenAI returned retryable status ${res.status}.`];
          await sleep(retryDelayMs(attempt, res.headers.get("retry-after")));
          continue;
        }

        return null;
      }

      const data = await res.json();
      const text = data?.choices?.[0]?.message?.content;

      if (!text) {
        lastRejectionReasons = ["Empty model response."];
        pushGenerationDebugFailure(debugFailures, {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          stage: "empty_response",
          phase,
          theme: activationTheme,
          ritual_date: date,
          attempt: attempt + 1,
          reasons: lastRejectionReasons,
        });
        console.warn("Rejected Today’s Lens output:", {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          theme: activationTheme,
          phase,
          attempt: attempt + 1,
          retry_count: attempt + 1,
          max_attempts: maxAttempts,
          reasons: lastRejectionReasons,
        });
        continue;
      }

      let parsed;
      try {
        parsed = JSON.parse(extractJson(text));
      } catch {
        lastRejectionReasons = ["Response was not valid JSON."];
        pushGenerationDebugFailure(debugFailures, {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          stage: "parse_error",
          phase,
          theme: activationTheme,
          ritual_date: date,
          attempt: attempt + 1,
          reasons: lastRejectionReasons,
        });
        console.warn("Rejected Today’s Lens output:", {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          theme: activationTheme,
          phase,
          attempt: attempt + 1,
          retry_count: attempt + 1,
          max_attempts: maxAttempts,
          reasons: lastRejectionReasons,
        });
        continue;
      }

      const read = structuredReadFromParsed(parsed);
      if (!read) {
        lastRejectionReasons = ["Missing one or more required structured fields."];
        pushGenerationDebugFailure(debugFailures, {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          stage: "missing_fields",
          phase,
          theme: activationTheme,
          ritual_date: date,
          attempt: attempt + 1,
          reasons: lastRejectionReasons,
        });
        console.warn("Rejected Today’s Lens output:", {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          theme: activationTheme,
          phase,
          attempt: attempt + 1,
          retry_count: attempt + 1,
          max_attempts: maxAttempts,
          reasons: lastRejectionReasons,
        });
        continue;
      }

      const validation = validateStructuredDailyRead(
        read,
        batchFrameCounts,
        batchFrameLimit,
        priorReads,
        activationTheme,
      );
      if (!validation.ok) {
        lastRejectionReasons = validation.reasons;
        pushGenerationDebugFailure(debugFailures, {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          stage: "validation",
          phase,
          theme: activationTheme,
          ritual_date: date,
          attempt: attempt + 1,
          reasons: lastRejectionReasons,
        });
        console.warn("Rejected Today’s Lens output:", {
          pair: `${pair.western_sign} × ${pair.eastern_sign}`,
          theme: activationTheme,
          phase,
          attempt: attempt + 1,
          retry_count: attempt + 1,
          max_attempts: maxAttempts,
          reasons: lastRejectionReasons,
        });
        continue;
      }

      console.log("Accepted Today’s Lens structured fields:", {
        pair: `${pair.western_sign} × ${pair.eastern_sign}`,
        theme: activationTheme,
        phase,
        attempt: attempt + 1,
        retry_count: attempt + 1,
        max_attempts: maxAttempts,
      });

      const ritualText = [read.intro, read.pull_quote, read.deeper_read]
        .filter(Boolean)
        .join(" ");
      const patternIntelligence = patternIntelligenceMetadata(
        read,
        activationTheme,
        priorReads,
      );

      return {
        ritual_date: date,
        western_sign: pair.western_sign,
        eastern_sign: pair.eastern_sign,
        title: normalizeTitle(read.title, pair),
        intro: read.intro,
        pull_quote: read.pull_quote,
        deeper_read: read.deeper_read,
        watch_for: read.watch_for,
        move: read.move,
        ritual_text: ritualText,
        action_text: read.move,
        ...patternIntelligence,
      };
    }

    return null;

  } catch (err) {
    pushGenerationDebugFailure(debugFailures, {
      pair: `${pair.western_sign} × ${pair.eastern_sign}`,
      stage: "unknown",
      phase,
      theme: activationTheme,
      ritual_date: date,
      provider_message: err instanceof Error ? err.message : String(err),
    });
    console.error("OpenAI error:", err);
    return null;
  }
}

function identityRangeProfileFor(pair: { western_sign: string; eastern_sign: string }): IdentityRangeProfile | null {
  return IDENTITY_RANGE_PROFILES[identityRangeProfileKey(pair)] ?? null;
}

function identityRangeProfileKey(pair: { western_sign: string; eastern_sign: string }) {
  return `${pair.western_sign} × ${pair.eastern_sign}`;
}

function identityProfileInstruction(profile: IdentityRangeProfile | null) {
  if (!profile) {
    return "";
  }

  return [
    "IDENTITY RANGE PROFILE — use this as gentle steering for this Western × Eastern combination.",
    `Avoid over-collapsing the read into: ${profile.avoidOveruse.join(", ")}.`,
    `Explore more: ${profile.exploreMore.join(", ")}.`,
    `Signature strengths to draw from: ${profile.signatureStrengths.join(", ")}.`,
    `Positive modes to include over time: ${profile.positiveModes.join(", ")}.`,
    `Title language hints: ${profile.titleLanguageHints.join(" ")}`,
    `Emotional range notes: ${profile.emotionalRangeNotes.join(" ")}`,
  ].join(" ");
}

function dailyReadMessages(
  pair: { western_sign: string; eastern_sign: string },
  phase: "create" | "rewrite",
  activationTheme: string,
  priorReads: PriorReadSummary[] = [],
  rejectionReasons: string[] = [],
) {
  const identityProfile = identityRangeProfileFor(pair);
  const overusedNeighborhoodList = overusedNeighborhoods(priorReads);
  const underservedPositiveList = underservedPositiveNeighborhoods(priorReads);
  const correctiveMessage = rejectionReasons.length
    ? {
        role: "system",
        content: [
          "The prior Today’s Lens was rejected by validation.",
          `Fix these issues: ${rejectionReasons.join(" ")}`,
          "Rewrite all fields as distinct, complete editorial copy. Do not patch only the failed field.",
        ].join(" "),
      }
    : null;

  return [
    {
      role: "system",
      content: [
        "You write structured Today’s Lens entries for Zodian.",
        "Return only valid JSON. No markdown. No explanation.",
        "Zodian’s Today’s Lens is a personalized daily horoscope. It answers: what is today bringing?",
        "Write at a 90% clear / 10% colorful ratio.",
        "The user should think, 'That sounds like my day,' not, 'This is homework.'",
        "Write like a sharp daily horoscope grounded in the Western × Eastern identity, not like coaching, therapy, journaling, or self-help.",
        "The tone is direct, human, specific, lightly funny when natural, plainspoken, modern, premium, non-spiritual, non-wellness, and non-corporate.",
        "Write with the confidence of an experienced horoscope writer: observant, conversational, psychologically insightful, and grounded in everyday life.",
        "The reader should feel understood rather than analyzed.",
        "The best read should feel less like an explanation and more like recognition, as if it finishes a thought the reader was already having.",
        "Aim for the reaction: 'Dammit, that's true,' not 'That was well written.'",
        "REASON BEFORE WRITING — silently complete a compact daily plan before drafting any JSON field.",
        "Choose one primary human tension, one primary life arena, one daily role, one starting assumption, one realization, and one ordinary-life expression of that realization.",
        "The primary human tension is the competing pull organizing the day, such as truth versus harmony, freedom versus stability, action versus patience, or trust versus caution.",
        "The primary life arena must be exactly one of: work, romance, friends, family, home, money, health, routine, confidence, creativity, travel, timing, conflict, opportunity, or rest.",
        "The daily role describes what this combined identity naturally becomes in that situation, such as mediator, reality checker, protector, organizer, observer, builder, explorer, negotiator, truth teller, or receiver.",
        "The starting assumption is the believable but incomplete idea this identity is likely to carry into this specific day. It is not a timeless flaw or identity summary.",
        "The realization is the more useful truth that today's experience could help the reader recognize. It must change, complicate, or release the starting assumption.",
        "The ordinary-life expression is how that shift in understanding could naturally become visible in the chosen life arena without predicting a specific event.",
        "Build the Lens around the assumption-to-realization arc. The reader should feel that the Lens explains why an ordinary moment mattered, not merely describes what happened.",
        "Use the hidden plan to make every field tell the same daily truth from a different angle. Never reveal, label, list, or serialize the plan.",
        "Confidence comes from specificity, not exaggeration.",
        "Make emotional observations bold. Daily events stay open-ended, but the read can be firm about what the user already knows, avoids, delays, wants, or notices.",
        "Prefer direct observations over explaining the situation. A blunt true line is stronger than a careful paragraph.",
        "Every read must include at least one text-message-worthy line someone could send to a friend with: 'This is literally you.'",
        "Examples of text-message-worthy lines: You've been pretending this can wait. Not everyone needs rescuing. The useful answer is probably simpler than the impressive one. The detail everyone skips is the one you'll remember.",
        "Keep the text-message-worthy line inside the required field word counts. Do not make blunt lines too short for the schema.",
        "Prefer ordinary verbs and visible choices over abstract emotional nouns.",
        "Use situational horoscope language, but do not lean on may/might/could too often. Use confident openers when reasonable: Today begins with..., A small delay becomes important..., Someone finally says..., A useful chance appears..., A familiar routine feels different....",
        "Rotate life context widely. Draw from work, romance, friendship, family, money, timing, confidence, creativity, travel, home, health, routine, opportunities, conflict, unexpected news, celebrations, rest, unfinished business, luck, and responsibilities.",
        "Do not let the same life area dominate. Avoid repeatedly centering the read on someone asking something, a conversation, an agreement, a decision, or clarifying details.",
        "Every day should feel like a different situation and emotional experience from yesterday.",
        "Vary emotional tone, pacing, optimism, seriousness, energy, and emotional weight. Some days are exciting, peaceful, funny, reassuring, low-key lucky, mildly frustrating, reflective, comforting, cautionary, or socially awkward.",
        "Favor everyday situations: a coworker changing the plan, a family expectation, a text that lands oddly, a bill or purchase, a small health routine, a messy errand, a useful delay, a lucky coincidence, a friend celebrating, or unfinished business returning.",
        "Every read must contain at least one situation or behavior the user can picture happening in real life.",
        "Reduce metaphor and abstract phrasing. The best Lens should sound like a clear daily horoscope, not literary copy.",
        "The exact word quiet is invalid in final copy. Use small, calm, low-key, private, subtle, simple, or unshowy instead.",
        "The deeper_read field must be one or two sentences only. Never write three sentences in deeper_read.",
        "The watch_for field must name a visible behavior or concrete exchange, not only a mood or internal feeling.",
        "The move field must begin with a clear action verb such as Ask, Answer, Choose, Decide, Finish, Keep, Leave, Let, Make, Name, Say, Send, Set, Show, Tell, Use, or Write.",
        "Do not stack metaphors or abstract nouns. Use words such as fracture, inner fire, restraint, pressure, tension, instinct, appetite, exposure, guarded, longing, and stillness sparingly, never as a cluster.",
        "Let the Western × Eastern pair shape what kind of day would feel most relevant for this person, but do not reteach the identity.",
        "Identity teaches who the person is. Today’s Lens shows how that identity shows up today.",
        "Assume the reader already has their Identity profile. Do not rewrite or summarize that profile.",
        "When it naturally strengthens the horoscope, briefly show what the Western sign contributes, what the Chinese sign contributes, or how both interact in today’s situation.",
        "These sign references should feel educational without sounding educational: a quick character-reading aside, not an astrology lesson.",
        "Never force sign references. Some reads should mention the Western sign, some should mention the Chinese sign, some should mention the interaction, and some should mention neither.",
        "Do not repeatedly explain the same Western/Chinese relationship across days, and do not reuse a sign explanation simply because it worked before.",
        "Avoid formulaic phrasing like 'Libra wants harmony,' 'Snake notices what is left unsaid,' or 'you have a Libra side and a Snake side.'",
        "Generate a daily forecast, not a personality lesson. The read should point to a likely situation, mood, exchange, plan, responsibility, errand, interruption, invitation, expense, habit, family moment, social opening, delay, or lucky turn.",
        "Make the read feel like today's horoscope, not a timeless identity report.",
        "Make today's forecast feel situated in an ordinary day: a choice, reply, plan, task, conversation, pause, favor, promise, small win, delay, request, bill, meal, trip, deadline, celebration, or rest.",
        "Do not make every read a diagnosis. Rotate between underestimated strengths, surprising advantages, social moments, work decisions, small pleasures, practical irritations, confidence, validation, small wins, unexpected openings, and useful tensions.",
        "Not every read needs a hidden flaw. Some days should feel empowering, playful, encouraging, validating, hopeful, calmly confident, or lightly amused.",
        "Avoid repeatedly writing about avoiding conflict, balancing harmony, hesitating, protecting yourself, softening what you want, second-guessing, or staying agreeable unless recent memory proves that exact territory has not appeared lately.",
        "The sign-pair identity must steer the forecast before the activation theme does, but it should stay underneath the copy.",
        "A user should first think 'that sounds like today,' then feel that it fits their character.",
        "Before writing, identify the Western sign's temperament, the Eastern sign's temperament, and the kind of ordinary situation where both would show up today.",
        "Generate from that daily situation. Do not write a read that could be explained by only the Western sign, only the Eastern sign, or only the activation theme.",
        "If you name one or both signs, connect the reference to today's situation in one sentence and move on.",
        "The pull_quote must fail the transplant test: if it could belong unchanged to another identity, rewrite it around a more specific daily situation.",
        "The pull_quote must contain a crisp forecast, social read, practical warning, everyday truth, or surprisingly simple line. Avoid pull_quotes that merely describe the identity.",
        "The pull_quote must be understandable within three seconds. If a reader must translate it into plain language, rewrite it.",
        "The pull_quote should name what today may bring, what the user may do, or what another person may reveal.",
        "Vary the realization syntax. Do not default to 'you have been calling X, but Y' or repeatedly relabel one behavior as another.",
        "Vary the narrative rhythm inside deeper_read: begin with contrast, a concrete everyday moment, a direct question, an underestimated strength, or a mid-sentence turn. Do not always write observation, explanation, consequence.",
        "Do not let multiple reads share the same hidden structure. Vary where the hook appears, sentence length, pacing, emotional intensity, where the sign interaction appears, and whether the pull_quote summarizes, surprises, reframes, or simply captures today's feeling.",
        "Every field must contain meaningful editorial copy. No empty strings. No placeholder filler.",
        "No repeated sentence stems. No repeating the same metaphor across fields.",
        "Avoid repeating these words unless absolutely necessary: quiet, timing, balance, control, silence, influence.",
        "Avoid overusing these live-output crutches across recent memory: hold back, hesitate, weigh, balance, smooth, soften, perfect moment, right moment, line, edge.",
        "Do not use these exact crutch words in the final JSON: balance, balanced, balancing, harmony, smooth, soften, softened, hesitate, hesitating, hold back, quiet, weigh, weighing.",
        "Avoid mystical filler, vague spiritual advice, wellness language, generic rituals, and instructions to breathe.",
        "Never use: universe, cosmic, destiny, energy is shifting, the stars, invites you, journey, embrace, trust the process, clarity will emerge, healing, aligned.",
        "Do not promise exact outcomes or exact times. Keep future/day events open-ended with may, might, can, likely, could, or may feel.",
        "Avoid generated-analysis phrases such as: Today brings, Today may bring, Today asks, Today invites, The day puts, The day asks, The day becomes, The day rewards, This is a reminder to, This moment is about, The situation may reveal, your inner world, emotional landscape, lean into, hold space, alignment, signal, or momentum.",
        "Prefer concrete anchors over narrating the day itself: Someone, A plan, An invitation, A message, A delay, A purchase, An old habit, A favor, A family expectation, or A small chance.",
        "Use recognizable situations without turning the read into a guaranteed prediction or a fictional story.",
        "Avoid long identity-report paragraphs, 'you are always' framing, and generic personality analysis.",
        "Do not write 'today is a good day to...' or any coaching-style assignment.",
        "You may use day anchors such as 'Someone may,' 'A conversation may,' 'A decision may,' 'A plan may,' 'A promise may,' 'A favor may,' 'You may feel,' or 'You may find' when the sentence stays specific and open-ended, but do not let those anchors become the dominant template.",
        "Do not give generic advice like 'focus on communication', 'stay grounded', 'trust yourself', or 'be mindful.'",
        "Concrete communication behavior is allowed when it is the clearest expression of the pattern. Avoid platform-specific references such as group chats, social media, notifications, inboxes, or DMs.",
        "Do not overproduce these emotional frames across a batch: control, trust-testing, boundaries, uncertainty, avoidance, agreeability, self-doubt, or hidden-flaw diagnosis.",
        "If the theme is broad, make the identity mechanism more specific instead of falling back to control, trust, boundaries, uncertainty, avoidance, harmony maintenance, hesitation, or self-protection.",
        "Across recent reads for the same identity, no emotional neighborhood should dominate. If one neighborhood is already common, choose a different part of the identity even if the wording would be new.",
        "A healthy 15-read set must visibly include joy/playfulness/humor, confidence/leadership/credit, creativity/curiosity/experimentation, rest/patience/enoughness, home/family, work/responsibility, money/practicality, romance/friendship, and luck/opportunity.",
        "Use opening-frame variety. Consider families like: Someone may..., A conversation may..., A decision may..., A plan may..., A promise may..., A favor may..., You may feel..., You may find.... Do not repeat them mechanically.",
        "Avoid literary phrases such as public yes, stealing air, hold shape, opens, polished explanation, or official plan.",
        identityProfileInstruction(identityProfile),
        "The read should feel immediately recognizable, as if it knows the kind of day this person is likely to have.",
        "The long-term standard: a user saving 100 reads should not feel like they are collecting variations of the same lesson or identity explanation.",
        priorReads.length
          ? [
              "THEME MEMORY — recent reads for this combo, oldest to newest:",
              ...priorReads.map((read) => [
                `- ${read.ritual_date} [${read.dimension}] ${read.title}`,
                `  realization: ${read.pull_quote || read.theme}`,
                `  watch_for: ${read.watch_for}`,
                `  move: ${read.move}`,
              ].join("\n")),
              `Themes exhausted by the last 7 reads: ${recentExhaustedDimensions(priorReads).join(", ") || "none classified"}.`,
              `Adjacent emotional territories exhausted by the last 7 reads: ${recentExhaustedClusters(priorReads).join(", ") || "none detected"}.`,
              `Emotional neighborhood counts across the rolling 15-read window, including this draft target: ${neighborhoodCountSummary(priorReads)}.`,
              `Neighborhoods at or above the soft cap (${NEIGHBORHOOD_SOFT_CAP}/15): ${overusedNeighborhoodList.join(", ") || "none"}.`,
              `Positive neighborhoods currently under floor: ${underservedPositiveList.join(", ") || "none"}.`,
              "Treat every theme or adjacent emotional territory used in the last 7 reads as strongly discouraged.",
              "Treat neighborhoods at or above the soft cap as unavailable. Do not merely rename that same emotional territory; choose a different life area, vocabulary set, and daily problem.",
              "If every obvious angle seems capped, move to a practical daily surface such as money, home, health routine, errands, travel, family logistics, rest, responsibility, luck, or a small celebration.",
              "If positive neighborhoods are under floor, choose one as the primary emotional experience of the read.",
              "Choose different daily territory unless the situation, forecast, narrative rhythm, daily setting, and advice are genuinely new.",
              "Do not reuse a recent title shape, opening stem, watch-for detail, move, daily forecast, sentence rhythm, key verb, or disguised synonym.",
              "If recent reads used hold back, hesitate, balance, soften, smooth, weigh, line, edge, perfect moment, or right moment, choose different language and a different psychological neighborhood.",
            ].join(" ")
          : "No recent reads were provided for this combo, so choose a fresh angle without relying on a repeated posture.",
        phase === "rewrite"
          ? "This is a rewrite pass for an already existing row. Give it a new activation angle and avoid any templated structure."
          : "This is a first-draft pass for a missing row.",
        `Daily horoscope theme for this row: ${activationTheme}.`,
      ].join(" "),
    },
    ...(correctiveMessage ? [correctiveMessage] : []),
    {
      role: "user",
      content: `
Create Today’s Lens for Zodian as a personalized daily horoscope.

Western sign: ${pair.western_sign}
Eastern sign: ${pair.eastern_sign}
Daily horoscope theme: ${activationTheme}

Use the Western and Eastern signs as the source of the read's character, but do not explain the signs back to the user.
Write like a direct, specific daily horoscope. Answer: what is today bringing?
Keep the identity confident underneath the forecast, not on top of it.
Identity explains why someone behaves this way. Today’s Lens explains why today’s situation matters to this person.
Write like a smart friend calling out the part the reader already knows.
At least one line should pass the text-message test: someone could send it to a friend with "This is literally you."
Keep that line inside the required field word counts; do not make the copy too short to pass validation.
You may briefly name the Western sign, the Chinese sign, or their interaction when it makes today’s horoscope sharper.
Do not force that reference. If the horoscope is stronger without naming either sign, leave both signs underneath the copy.

Follow this logic:
1. Hidden daily plan
   Before drafting any JSON field, silently choose:
   - one primary human tension
   - exactly one primary life arena
   - one daily role for this combined identity
   - one believable but incomplete assumption this identity is likely to carry into today
   - one realization today's experience could create that changes, complicates, or releases that assumption
   - one ordinary-life way that recognition could naturally become visible in the chosen life arena
   Do not expose, label, list, or serialize this plan. Use it only to guide the final Lens.
2. Western temperament
   Identify the daily temperament created by ${pair.western_sign}.
3. Eastern temperament
   Identify the daily temperament created by ${pair.eastern_sign}.
4. Recognition arc
   Write from the movement between the starting assumption and the realization. The realization should make an ordinary moment newly understandable rather than predict a specific event.
5. Day situation
   Express the recognition arc through one ordinary situation inside the chosen life arena. Do not mix multiple life arenas into the same read.
6. Horoscope theme
   Let "${activationTheme}" sharpen the situation, not replace it.
7. Identity reference choice
   Choose whether today is best shaped by the Western sign, the Chinese sign, their interaction, or neither.
   If you name a sign, make the reference brief, situational, and useful to today's forecast.
8. Difference
   Make this read clearly different from nearby identities that share one sign.
9. Transplant test
   Ask: "Could this exact pull quote belong to another identity?" If yes, make the daily situation more specific.
10. Forecast
   Turn the situation into an open-ended daily forecast, not a lesson.
11. Meaning
   Make the realization the emotional center of the read. The Lens should help the user think, "That's what this day was showing me."
12. Practical nudge
   Once the reader has this realization, ask what tiny action naturally follows. Write that inevitable next step, not a bolted-on ritual, journal prompt, or growth plan.
13. Daily mode
   Choose one mode for today: exciting, peaceful, funny, reassuring, low-key lucky, mildly frustrating, reflective, comforting, cautionary, socially awkward, motivating, playful, or calmly confident.
14. Daily anchor
   Anchor the read in something the user could meet today: a choice, reply, plan, task, conversation, favor, promise, request, delay, bill, errand, family expectation, meal, trip, deadline, celebration, or rest.
15. Clarity pass
   Rewrite any sentence that requires interpretation. Favor plain situations over literary explanation.
16. Real-life behavior
   Include or imply one visible behavior the user can picture from an ordinary day.

The read should feel like: "This knows the kind of day I am having."
Not: "Here is a self-improvement lesson" or "Here is your identity explained again."
Make it skimmable first and deeper only in the deeper_read field.

Return JSON with exactly these keys:
{
  "title": "string",
  "intro": "string",
  "pull_quote": "string",
  "deeper_read": "string",
  "watch_for": "string",
  "move": "string"
}

Field instructions:
- title: 2-4 words. Punchy, screenshot-worthy, natural, and emotionally specific. Do not include the sign pair. Prefer real essay-like titles over abstract noun combinations.
- intro: 1 sentence, 12-22 words. Today-facing horoscope copy. Anchor it in a visible life situation, not only an exchange, plan, favor, promise, request, or decision.
- pull_quote: 1 sentence, 12-22 words. The strongest line on the card. Make it understandable within three seconds and forecast the day without promising an outcome.
- deeper_read: 1-2 sentences, 30-60 words total. Add optional depth without repeating the quote. Read the day in plain language, not as a timeless personality report.
- watch_for: 1 sentence, 10-24 words. Name one visible situation, behavior, or exchange that may be worth noticing.
- move: 1 sentence, 10-24 words. Start with a clear action and give the user one simple response to the day.

Progression rules:
- Choose one daily situation, then make each field move the horoscope forward.
- Choose a life context before writing, and avoid overused contexts from recent reads for this identity.
- The Western × Eastern identity must steer the read first; the daily horoscope theme shapes the angle second.
- The pull_quote should feel specific to this Western × Eastern temperament without naming the signs.
- The pull_quote should make a user feel, "That is exactly the kind of thing today would bring me."
- Pull quotes may summarize, surprise, reframe, or simply capture today's feeling. Not every pull_quote needs to sound philosophical.
- Sign references are allowed outside the title when they improve the read. Keep them brief, natural, and tied to today's situation.
- Sign interaction lines should sound like something a sharp friend might say, not a textbook note.
- Vary the identity component over time: Western sign, Chinese sign, interaction, or no explicit sign reference.
- Do not explain the same Western/Chinese relationship every day, and do not sound like an astrology lesson.
- Avoid simply describing the identity. Do not settle for "you are private", "you protect yourself", or "you value harmony."
- A forecast may use an inversion, but vary the syntax across days.
- Do not use a "you have been calling X..." structure if it appears anywhere in the recent memory.
- Avoid defaulting to "Today reveals," "Today exposes," "Today sharpens," "You secretly," or a hidden-problem frame.
- Favor titles rooted in everyday life, such as "The Extra Errand," "Dinner Gets Weird," "The Late Reply," "Small Money," "The Changed Plan," or "A Useful Delay." Avoid AI-ish titles like "Balancing Self-Shift," "Routine's Quiet Doubt," or "Hidden Inner Calibration."
- Vary the explanation rhythm. Some deeper reads should start with contrast, a question, a familiar everyday moment, or an underestimated strength.
- Keep deeper_read to one or two sentences total. Do not write a three-sentence deeper_read.
- Do not use "hold back," "hesitate," "balance," "weigh," "smooth," or "soften" if those words appear in recent memory.
- Do not use the exact words balance, balanced, balancing, harmony, smooth, soften, softened, hesitate, hesitating, hold back, quiet, weigh, or weighing.
- The exact word "quiet" is invalid even when it sounds natural. Use small, calm, low-key, private, subtle, simple, or unshowy instead.
- If recent titles use "Line" or "Edge," do not use either word in the new title.
- Vary the intro stem. At least half of a long run should not begin with "Today."
- Avoid reads that are mostly ${pair.western_sign}, mostly ${pair.eastern_sign}, or mostly "${activationTheme}".
- Prioritize recognition over explanation.
- Prefer concrete verbs over abstract nouns.
- Keep the full read near a 90% clear / 10% colorful ratio.
- Hide the formula. Do not let title, intro, pull_quote, deeper_read, watch_for, and move feel like they were filled from the same template.
- Use simple sentences. Use concrete situations. Use no more than one mild metaphor across the entire read.
- Do not stack words such as fracture, inner fire, restraint, pressure, tension, instinct, appetite, exposure, guarded, longing, or stillness.
- Avoid fancy or vague phrases like public yes, stealing air, hold shape, opens, polished explanation, official plan, clean container, old story, or hidden truth.
- Avoid defaulting to control, trust-testing, boundaries, uncertainty, or avoidance unless that is the most specific identity mechanism.
- Avoid explaining the quote.
- Avoid explaining the situation more than the reader needs.
- Prefer recognition over explanation. One direct observation can do more work than three careful sentences.
- Include at least one line that passes the text-message test: clear, specific, and recognizable enough for someone to send to a friend.
- Avoid generated-analysis phrases such as "Today brings," "Today may bring," "Today asks," "Today invites," "The day puts," "The day asks," "The day becomes," "The day rewards," "This is a reminder to," "This moment is about," or "The situation may reveal."
- Prefer concrete anchors over narrating the day itself: Someone, A plan, An invitation, A message, A delay, A purchase, An old habit, A favor, A family expectation, or A small chance.
- Avoid repeating the intro.
- Avoid repeating the pull_quote in prose.
- Do not reuse the same metaphor across title, pull_quote, watch_for, and move.
- Do not make watch_for and move say the same thing.
- Make watch_for name a visible behavior or concrete exchange, such as someone answering, asking, pausing, replying, explaining, delaying, changing a plan, making a purchase, offering help, or avoiding a topic.
- Start move with a validator-friendly action verb such as Ask, Answer, Choose, Decide, Finish, Keep, Leave, Let, Make, Name, Say, Send, Set, Show, Tell, Use, or Write.
- If a prior rejection says one move verb appears too often, choose a different verb from that list.
- Avoid repeating key nouns across fields.
- Concrete communication scenarios are welcome when they make the identity pattern immediately recognizable.
- Do not default to any single setting, including communication, work, romance, friends, or social hesitation.
- Do not default to conflict avoidance, harmony maintenance, hesitation, self-protection, softening desire, second-guessing, or agreeability as the forecast.
- Keep every sentence short and direct.
- The default visible card should feel readable in under 10 seconds before deeper_read is expanded.
- No time-of-day instructions.
- No wellness language.
- No generic rituals.
- No "breathe", "meditate", "visualize", "set aside", "begin your day", or "spend a few minutes".
- No vague horoscope filler like "emotions are swirling", "navigate the complexities", or "heartfelt conversation".
- No therapy, self-help, journaling, growth-plan, or identity-review language.
- Do not write "Your ${pair.western_sign} side" or "Your ${pair.eastern_sign} side."
- Do not use repeated templates like "${pair.western_sign} wants..." or "${pair.eastern_sign} always..." when a fresher, more situational line would work.
- Avoid exact time promises such as this afternoon, tonight, by tonight, tomorrow morning, or before the day ends.
- Use open-ended situational phrasing such as "Someone may...", "A conversation may...", "A decision may...", "A plan may...", "A promise may...", "A favor may...", "You may feel...", or "You may find...".
- Avoid platform-specific terms: group chats, social media, notifications, inbox, DMs.
- Do not include "${pair.western_sign}", "${pair.eastern_sign}", the sign pair, an x/× separator, or a colon prefix in the title.
- If prior reads are provided, avoid repeating the same title shape, emotional posture, or daily setting.
- The selected dimension should be shaped by "${activationTheme}", and it must not collapse back into guardedness, secrecy, resentment, envy, vulnerability, emotional protection, or fairness-as-cover.

Quality check before returning JSON:
- Reject and rewrite if the pull_quote needs interpretation instead of landing immediately.
- Reject and rewrite if more than one mild metaphor appears.
- Reject and rewrite if the read lacks a recognizable real-life behavior.
- Reject and rewrite if watch_for is vague or names only an emotion.
- Reject and rewrite if move does not give one concrete action.
- Reject and rewrite if the copy sounds like a personality report instead of a daily horoscope.
- Reject and rewrite if the title sounds like an abstract AI-generated noun phrase.
- Reject and rewrite if the read is mostly a hidden flaw diagnosis and the recent memory already leans diagnostic.
- Reject and rewrite if no line passes the text-message test.
- Reject and rewrite if the copy explains more than it recognizes.
- Reject and rewrite if it uses generated-analysis phrases such as "Today brings," "Today asks," "Today invites," "The day puts," "The day asks," "The day becomes," or "The day rewards."

Style examples — use their clarity and behavioral specificity, not their exact wording:

Libra × Snake
{
  "title": "The Vague Promise",
  "intro": "A promise sounds pleasant today, but the missing detail matters more than the tone.",
  "pull_quote": "Not every kind answer deserves a quick yes just because everyone pauses.",
  "deeper_read": "Libra keeps the exchange graceful; Snake catches when the terms are too convenient. Someone can mean well and still leave you guessing, especially when the friendly version skips the practical part.",
  "watch_for": "Watch for a friendly answer that skips when, how, or who handles it.",
  "move": "Ask for the missing detail before treating the promise as settled."
}

Taurus × Horse
{
  "title": "The Changed Plan",
  "intro": "A plan changes after you already pictured how the day was supposed to go.",
  "pull_quote": "You already know which part of the plan bothers you; name that part first.",
  "deeper_read": "Taurus checks whether the new version is practical. Horse checks whether it still leaves you room to move. The problem is not the change; it is pretending every change costs the same.",
  "watch_for": "Watch for irritation that comes from rearranging your whole day too quickly.",
  "move": "Name what changed first, then decide what still works for your day."
}

Gemini × Snake
{
  "title": "The Late Reply",
  "intro": "A late reply changes the mood of a simple exchange more than expected.",
  "pull_quote": "The delay says something, but not always the story your mind writes first.",
  "deeper_read": "Gemini can make three explanations in a minute. Snake knows which one feels off. The useful answer is probably in the facts, not the whole case your mind builds first.",
  "watch_for": "Watch for a small silence becoming a full story in your head.",
  "move": "Check what actually happened before answering from the imagined version."
}

Aries × Tiger
{
  "title": "The Sudden Errand",
  "intro": "An annoying errand interrupts the day and becomes more useful than expected.",
  "pull_quote": "The errand is not the enemy; arguing with it is where the day gets expensive.",
  "deeper_read": "Aries wants the day back on track fast, and Tiger hates feeling managed by small problems. A delay still gives you information if you do not turn it into a contest.",
  "watch_for": "Watch for impatience making a simple task feel oddly personal.",
  "move": "Handle the errand once, then stop arguing with the inconvenience."
}

Pisces × Goat
{
  "title": "The Soft No",
  "intro": "A family expectation asks more from you than the day can comfortably give.",
  "pull_quote": "Not everyone needs rescuing, even when they make the room feel heavy.",
  "deeper_read": "You can care deeply without becoming available for every emotional weather change. The kinder answer may be the one that says what is possible, not what people hope you can absorb.",
  "watch_for": "Watch for guilt making a small family request feel mandatory.",
  "move": "Offer the part you can do, then leave the rest alone."
}

Virgo × Rooster
{
  "title": "Small Money",
  "intro": "A small expense makes you look twice at what is actually worth paying for.",
  "pull_quote": "The useful answer is probably simpler than the impressive one in front of you.",
  "deeper_read": "Virgo notices waste quickly, and Rooster notices quality. A practical reason appears to separate what looks impressive from what will actually make life easier once the receipt is real later.",
  "watch_for": "Watch for a purchase that feels urgent because it looks tidy or official.",
  "move": "Compare the use, not the presentation, before spending money on it."
}

Leo × Monkey
{
  "title": "The Funny Idea",
  "intro": "A silly idea gets more attention than the serious version you planned to use.",
  "pull_quote": "The joke might be the useful part, not the distraction from the real idea.",
  "deeper_read": "Leo knows when a room is ready to enjoy something. Monkey knows how to turn a loose moment into a smart one. The version with a little mess still on it may travel farther.",
  "watch_for": "Watch for people responding to the playful version before the polished one.",
  "move": "Try the funny version once before making the idea impressive."
}

Capricorn × Dragon
{
  "title": "The Bigger Room",
  "intro": "A celebration puts you closer to the center than you expected to stand.",
  "pull_quote": "Being noticed is not a problem just because people can see you clearly.",
  "deeper_read": "Capricorn respects what was earned. Dragon knows visibility has power. Shrinking the win would be stranger than simply standing there and letting it count without explaining every step to everyone.",
  "watch_for": "Watch for praise that makes you explain the work instead of receiving it.",
  "move": "Say thank you once, then let the attention stay simple."
}

Sagittarius × Rabbit
{
  "title": "The Easy Detour",
  "intro": "A change in route or schedule brings a better option than the original plan.",
  "pull_quote": "The detour is allowed to be lucky before it has to mean anything.",
  "deeper_read": "Sagittarius is quick to follow possibility, while Rabbit notices whether the new path feels pleasant enough to trust. A small change does not need a grand reason to get better than expected.",
  "watch_for": "Watch for a small change that makes the day easier, not harder.",
  "move": "Take the easier route if it honestly works for the day."
}
${phase === "rewrite" ? "- This is a rewrite pass, so prefer a new angle or sharper phrasing rather than repeating the prior draft." : ""}
      `,
    },
  ];
}

function fallbackOne(
  date: string,
  pair: { western_sign: string; eastern_sign: string },
  phase: "create" | "rewrite" = "create",
  activationTheme: string = chooseDailyActivationTheme(date, pair),
) {
  const western = pair.western_sign;
  const eastern = pair.eastern_sign;
  const theme = activationTheme.toLowerCase();
  const variants = [
    {
      title: phase === "rewrite" ? "Cleaner Choice" : "One Clean Step",
      intro: `Today you may notice the moment ${theme} asks for a choice before your old reflex answers.`,
      pull_quote: "Instinct gets loudest once pressure wants an answer before your deeper pattern has finished speaking.",
      deeper_read: "There is a difference between a useful hunch and the urgency attached to it. Today may ask you to separate what you know from what you simply want settled before making the next move.",
      watch_for: "A quick conclusion starting to sound more certain than the evidence you actually have.",
      move: "Name the pressure plainly, then choose one response that does not need to prove anything.",
    },
    {
      title: phase === "rewrite" ? "New Terms" : "Useful Friction",
      intro: `A familiar response around ${theme} can feel polished before it actually fits the moment.`,
      pull_quote: "A polished reflex can preserve an old identity long after that identity has stopped helping.",
      deeper_read: "Familiar responses often feel correct because they protect continuity, not because they match the present. The useful shift is separating the part that wants consistency from the part ready to act without rehearsing an older version of you.",
      watch_for: "The familiar answer arriving before you have named what the present actually requires.",
      move: "Delay the polished response and make one choice that reflects your current priorities instead.",
    },
    {
      title: phase === "rewrite" ? "Sharper Read" : "Enough For Now",
      intro: `Watch for the extra effort around ${theme} that adds weight without making anything more true.`,
      pull_quote: "Effort stops being strength once it exists mainly to keep an outdated pattern intact.",
      deeper_read: "Your strongest habits can make unnecessary effort look admirable. A cleaner read begins by separating the work that advances something real from the work that only protects your usual position without turning intensity into proof of commitment.",
      watch_for: "Extra effort appearing mainly because a simpler response feels unfamiliar or insufficiently impressive.",
      move: "Remove one unnecessary layer and let the more direct response carry the weight today.",
    },
    {
      title: phase === "rewrite" ? "Clearer Position" : "Chosen Ground",
      intro: `Before the next ${theme} choice, notice whether direction matters more than sounding completely resolved.`,
      pull_quote: "Certainty can become a costume once direction matters more than looking completely resolved.",
      deeper_read: "You do not need every internal conflict settled before taking a clean position. The stronger move is distinguishing honest direction from the performance of having no doubt at all or erasing the tension that made the choice meaningful.",
      watch_for: "A useful decision getting delayed by the need to make your reasoning look airtight.",
      move: "Choose the direction you can support now and leave unnecessary certainty out of it.",
    },
  ];
  const variant = variants[stableHash(`${date}|${western}|${eastern}|${phase}`) % variants.length];
  const {
    title,
    intro,
    pull_quote: pullQuote,
    deeper_read: deeperRead,
    watch_for: watchFor,
    move,
  } = variant;
  const read = {
    title,
    intro,
    pull_quote: pullQuote,
    deeper_read: deeperRead,
    watch_for: watchFor,
    move,
  };
  const validation = validateStructuredDailyRead(read);

  console.log("Using Today’s Lens fallback fields:", {
    pair: `${western} × ${eastern}`,
    theme: activationTheme,
    phase,
    fallback: true,
    validation_ok: validation.ok,
    validation_reasons: validation.reasons,
  });

  if (!validation.ok) {
    return null;
  }
  const patternIntelligence = patternIntelligenceMetadata(
    read,
    activationTheme,
    [],
  );

  return {
    ritual_date: date,
    western_sign: western,
    eastern_sign: eastern,
    title,
    intro,
    pull_quote: read.pull_quote,
    deeper_read: read.deeper_read,
    watch_for: read.watch_for,
    move,
    ritual_text: [intro, read.pull_quote, read.deeper_read].join(" "),
    action_text: move,
    ...patternIntelligence,
  };
}

function dailyThemeRotationOffset(date: string) {
  return stableHash(date) % DAILY_ACTIVATION_THEMES.length;
}

function dailyThemeAssignments(
  date: string,
  pairs: Array<{ western_sign: string; eastern_sign: string }>,
  offset: number,
  recentReadsByPair: Map<string, PriorReadSummary[]>,
) {
  const assignments = new Map<string, string>();

  pairs.forEach((pair, index) => {
    const key = pairKey(pair.western_sign, pair.eastern_sign);
    assignments.set(
      key,
      chooseFreshDailyActivationTheme(
        date,
        pair,
        recentReadsByPair.get(key) ?? [],
        offset + index,
      ),
    );
  });

  return assignments;
}

function chooseFreshDailyActivationTheme(
  date: string,
  pair: { western_sign: string; eastern_sign: string },
  priorReads: PriorReadSummary[],
  batchIndex?: number,
) {
  const startingTheme = chooseDailyActivationTheme(date, pair, batchIndex);
  const startingIndex = DAILY_ACTIVATION_THEMES.indexOf(startingTheme);
  const exhausted = new Set(recentExhaustedDimensions(priorReads));
  const overused = new Set(overusedNeighborhoods(priorReads));
  const underserved = new Set(underservedPositiveNeighborhoods(priorReads));
  const orderedCandidates = Array.from({ length: DAILY_ACTIVATION_THEMES.length }, (_, step) =>
    DAILY_ACTIVATION_THEMES[(startingIndex + step) % DAILY_ACTIVATION_THEMES.length]
  );

  const underservedCandidate = orderedCandidates.find((candidate) => {
    const neighborhoods = ACTIVATION_THEME_NEIGHBORHOODS[candidate] ?? [];
    return neighborhoods.some((neighborhood) => underserved.has(neighborhood)) &&
      neighborhoods.every((neighborhood) => !overused.has(neighborhood)) &&
      !exhausted.has(candidate.toLowerCase());
  });

  if (underservedCandidate) {
    return underservedCandidate;
  }

  for (const candidate of orderedCandidates) {
    const neighborhoods = ACTIVATION_THEME_NEIGHBORHOODS[candidate] ?? [];

    if (!exhausted.has(candidate.toLowerCase()) && neighborhoods.every((neighborhood) => !overused.has(neighborhood))) {
      return candidate;
    }
  }

  return startingTheme;
}

function chooseDailyActivationTheme(date: string, pair: { western_sign: string; eastern_sign: string }, batchIndex?: number) {
  if (typeof batchIndex === "number") {
    return DAILY_ACTIVATION_THEMES[batchIndex % DAILY_ACTIVATION_THEMES.length];
  }

  const key = `${date}|${pair.western_sign}|${pair.eastern_sign}`;
  return DAILY_ACTIVATION_THEMES[stableHash(key) % DAILY_ACTIVATION_THEMES.length];
}

function stableHash(value: string) {
  let hash = 0;

  for (let index = 0; index < value.length; index++) {
    hash = (hash * 31 + value.charCodeAt(index)) >>> 0;
  }

  return hash;
}

function normalizeTitle(title: string, pair: { western_sign: string; eastern_sign: string }) {
  const cleaned = stripSignPairFromTitle(title, pair);
  return cleaned || "Today's Pattern";
}

function stripSignPairFromTitle(title: string, pair: { western_sign: string; eastern_sign: string }) {
  const western = toTitleCase(pair.western_sign);
  const eastern = toTitleCase(pair.eastern_sign);
  let cleaned = title.trim().replace(/\s+/g, " ");
  const pairPattern = new RegExp(
    `^${escapeRegExp(western)}\\s*[x×]\\s*${escapeRegExp(eastern)}\\s*:?(\\s*)`,
    "i"
  );

  if (pairPattern.test(cleaned)) {
    cleaned = cleaned.replace(pairPattern, "").replace(/\s+/g, " ").trim();
  }

  return cleaned.replace(/^[:\-\s]+/, "").trim();
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

function structuredReadFromParsed(parsed: any) {
  const title = normalizedText(parsed?.title);
  const intro = normalizedText(parsed?.intro);
  const pullQuote = normalizedText(parsed?.pull_quote);
  const deeperRead = normalizedText(parsed?.deeper_read);
  const watchFor = normalizedText(parsed?.watch_for);
  const move = normalizedText(parsed?.move);

  if (title && intro && pullQuote && deeperRead && watchFor && move) {
    return {
      title,
      intro,
      pull_quote: pullQuote,
      deeper_read: deeperRead,
      watch_for: watchFor,
      move,
    };
  }

  return null;
}

function normalizedText(value: unknown) {
  return typeof value === "string"
    ? value.trim().replace(/\s+/g, " ")
    : "";
}

function splitSentences(text: string) {
  const matches = text.match(/[^.!?]+[.!?]+/g);
  if (!matches) return [text.trim()].filter(Boolean);
  return matches.map((sentence) => sentence.trim()).filter(Boolean);
}

function validateStructuredDailyRead(
  read: StructuredDailyReadPayload,
  batchFrameCounts?: Map<string, number>,
  batchFrameLimit = emotionalFrameLimit(1),
  priorReads: PriorReadSummary[] = [],
  activationTheme?: string,
) {
  const reasons: string[] = [];

  for (const field of Object.keys(read) as Array<keyof StructuredDailyReadPayload>) {
    const value = read[field].trim();
    if (!value) {
      reasons.push(`${field} is empty.`);
    }
  }

  const titleWords = wordCount(read.title);
  if (titleWords < 2 || titleWords > 4) {
    reasons.push("title must be 2-4 words.");
  }

  const titleIssue = aiGeneratedTitleIssue(read.title);
  if (titleIssue) {
    reasons.push(titleIssue);
  }

  if (splitSentences(read.intro).length !== 1) {
    reasons.push("intro must be exactly one sentence.");
  }

  const introWords = wordCount(read.intro);
  if (introWords < 12 || introWords > 22) {
    reasons.push("intro must be 12-22 words.");
  }

  const introIssue = genericTodayOpeningIssue(read.intro);
  if (introIssue) {
    reasons.push(introIssue);
  }

  if (splitSentences(read.pull_quote).length !== 1) {
    reasons.push("pull_quote must be exactly one sentence.");
  }

  const pullQuoteWords = wordCount(read.pull_quote);
  if (pullQuoteWords < 12 || pullQuoteWords > 22) {
    reasons.push("pull_quote must be 12-22 words.");
  }

  if (splitSentences(read.watch_for).length !== 1) {
    reasons.push("watch_for must be exactly one sentence.");
  }

  const watchForWords = wordCount(read.watch_for);
  if (watchForWords < 10 || watchForWords > 24) {
    reasons.push("watch_for must be 10-24 words.");
  }

  if (splitSentences(read.move).length !== 1) {
    reasons.push("move must be exactly one sentence.");
  }

  const moveWords = wordCount(read.move);
  if (moveWords < 10 || moveWords > 24) {
    reasons.push("move must be 10-24 words.");
  }

  const deeperSentenceCount = splitSentences(read.deeper_read).length;
  if (deeperSentenceCount > 2) {
    reasons.push("deeper_read must be at most 2 sentences.");
  }

  const deeperReadWords = wordCount(read.deeper_read);
  if (deeperReadWords < 30 || deeperReadWords > 60) {
    reasons.push("deeper_read must be 30-60 words.");
  }

  if (overlapScore(read.title, read.intro) > 0.42) {
    reasons.push("title and intro overlap too heavily.");
  }

  if (overlapScore(read.title, read.pull_quote) > 0.34) {
    reasons.push("pull_quote substantially repeats title.");
  }

  if (overlapScore(read.pull_quote, read.deeper_read) > 0.46) {
    reasons.push("deeper_read restates pull_quote instead of progressing it.");
  }

  if (overlapScore(read.watch_for, read.move) > 0.38) {
    reasons.push("watch_for and move communicate the same idea.");
  }

  const repeatedStem = repeatedSentenceStem(read);
  if (repeatedStem) {
    reasons.push(`Repeated sentence stem: "${repeatedStem}".`);
  }

  const repeatedRestrictedWords = overusedRestrictedWords(read);
  if (repeatedRestrictedWords.length) {
    reasons.push(`Restricted words repeat too often: ${repeatedRestrictedWords.join(", ")}.`);
  }

  const blockedPhrase = blockedDailyReadPhrase(read);
  if (blockedPhrase) {
    reasons.push(`Blocked phrase found: "${blockedPhrase}".`);
  }

  const crutchWord = blockedCrutchWord(read);
  if (crutchWord) {
    reasons.push(`Crutch word found: "${crutchWord}".`);
  }

  const diagnosticFrame = hiddenFlawFrameIssue(read);
  if (diagnosticFrame) {
    reasons.push(diagnosticFrame);
  }

  const clarityIssue = pullQuoteClarityIssue(read.pull_quote);
  if (clarityIssue) {
    reasons.push(clarityIssue);
  }

  if (!containsRecognizableBehavior(read)) {
    reasons.push("Today’s Lens must include at least one recognizable real-life behavior.");
  }

  if (!containsRecognizableBehaviorText(read.watch_for)) {
    reasons.push("watch_for must identify a visible behavior, not only an internal feeling.");
  }

  if (!startsWithActionVerb(read.move)) {
    reasons.push("move must begin with one clear, actionable verb.");
  }

  if (soundsLikePersonalityReport(read)) {
    reasons.push("Copy sounds like a personality report instead of a daily horoscope.");
  }

  const bannedCommunicationTerm = bannedCommunicationTermIn(read);
  if (bannedCommunicationTerm) {
    reasons.push(`Banned communication term found: "${bannedCommunicationTerm}".`);
  }

  const scenarioPhrase = hypotheticalScenarioPhrase(read);
  if (scenarioPhrase) {
    reasons.push(`Hypothetical scenario framing found: "${scenarioPhrase}".`);
  }

  const repeatedBatchFrame = overproducedBatchEmotionalFrame(read, batchFrameCounts, batchFrameLimit);
  if (repeatedBatchFrame) {
    reasons.push(repeatedBatchFrame);
  }

  const cappedNeighborhoodIssue = emotionalNeighborhoodCapIssue(read, priorReads);
  if (cappedNeighborhoodIssue) {
    reasons.push(cappedNeighborhoodIssue);
  }

  reasons.push(...recentReadCollisionReasons(read, priorReads, activationTheme));

  return {
    ok: reasons.length === 0,
    reasons,
  };
}

function emotionalNeighborhoodCapIssue(
  read: StructuredDailyReadPayload,
  priorReads: PriorReadSummary[],
) {
  if (!priorReads.length) return null;

  const counts = recentNeighborhoodCounts(priorReads, 14);
  const capped = dominantEmotionalNeighborhood(read);

  return capped && (counts.get(capped) ?? 0) >= NEIGHBORHOOD_SOFT_CAP
    ? `The "${capped}" emotional neighborhood is already at ${counts.get(capped)}/15; choose a different neighborhood.`
    : null;
}

function recentReadCollisionReasons(
  read: StructuredDailyReadPayload,
  priorReads: PriorReadSummary[],
  activationTheme?: string,
) {
  if (!priorReads.length) return [];

  const reasons: string[] = [];
  const recentFourteen = priorReads.slice(-14);
  const recentSeven = priorReads.slice(-7);

  const candidateLesson = [read.intro, read.pull_quote, read.deeper_read].join(" ");
  const candidateNarrativeFrame = narrativeFrame(read.deeper_read);

  for (const prior of recentFourteen) {
    const priorLesson = [prior.intro, prior.pull_quote, prior.deeper_read].join(" ");

    if (overlapScore(read.title, prior.title) >= 0.6) {
      reasons.push(`Title feels like a variation of "${prior.title}" from ${prior.ritual_date}.`);
    }

    if (overlapScore(candidateLesson, priorLesson) >= 0.58) {
      reasons.push(`Realization and emotional lesson overlap the read from ${prior.ritual_date}.`);
    }

    if (overlapScore(read.watch_for, prior.watch_for) >= 0.62) {
      reasons.push(`watch_for overlaps the read from ${prior.ritual_date}.`);
    }

    if (overlapScore(read.move, prior.move) >= 0.62) {
      reasons.push(`move overlaps the read from ${prior.ritual_date}.`);
    }

    const isRecentSeven = recentSeven.includes(prior);

    if (
      isRecentSeven &&
      candidateNarrativeFrame &&
      candidateNarrativeFrame === narrativeFrame(prior.deeper_read)
    ) {
      reasons.push(
        `Narrative rhythm "${candidateNarrativeFrame}" already appeared within the rolling window.`,
      );
    }

  }

  if (
    /^today\b/i.test(read.intro.trim()) &&
    recentSeven.filter((prior) => /^today\b/i.test(prior.intro.trim())).length >= 3
  ) {
    reasons.push("Too many recent intros start with Today; choose a different daily anchor.");
  }

  const introStem = openingStem(read.intro);
  if (
    introStem &&
    recentSeven.filter((prior) => openingStem(prior.intro) === introStem).length >= 2
  ) {
    reasons.push(`Intro stem "${introStem}" appears too often in recent reads.`);
  }

  const moveVerb = firstActionVerb(read.move);
  if (
    moveVerb &&
    recentSeven.filter((prior) => firstActionVerb(prior.move) === moveVerb).length >= 2
  ) {
    reasons.push(`Move starts with "${moveVerb}" too often in recent reads; choose a different action.`);
  }

  return Array.from(new Set(reasons));
}

function realizationFrame(value: string) {
  const lower = value.toLowerCase().replace(/[’]/g, "'");

  if (/\byou(?:'ve| have) been calling\b/.test(lower)) return "you have been calling X but Y";
  if (/\byou(?:'re| are) calling\b/.test(lower)) return "you are calling X but Y";
  if (/\bwhat looks like\b/.test(lower) && /\bactually\b|\breally\b/.test(lower)) {
    return "what looks like X is Y";
  }
  if (/\byou think\b/.test(lower) && /\bbut\b/.test(lower)) return "you think X but Y";
  if (/\byou appear\b/.test(lower) && /\bbut\b/.test(lower)) return "you appear X but Y";
  if (/\bnot\b.+\bbut\b/.test(lower)) return "not X but Y";

  return "";
}

function openingFrame(value: string) {
  const lower = value.toLowerCase().replace(/[’]/g, "'");

  if (/^today (reveals|exposes|sharpens|highlights|shows|makes)\b/.test(lower)) {
    return lower.match(/^today \w+/)?.[0] ?? "";
  }
  if (/^today (surfaces|centers|separates|turns|places)\b/.test(lower)) {
    return lower.match(/^today \w+/)?.[0] ?? "";
  }
  if (/^today you may notice\b/.test(lower)) return "today you may notice";
  if (/^today you may catch\b/.test(lower)) return "today you may catch";
  if (/^today you might catch\b/.test(lower)) return "today you might catch";
  if (/^today you might see\b/.test(lower)) return "today you might see";
  if (/^watch for the moment\b/.test(lower)) return "watch for the moment";
  if (/^you'll probably catch yourself\b/.test(lower)) return "you will probably catch yourself";
  if (/^you might catch yourself\b/.test(lower)) return "you might catch yourself";
  if (/^you may catch yourself\b/.test(lower)) return "you may catch yourself";
  if (/^before .+ today\b/.test(lower)) return "before X today";
  if (/^a conversation today\b/.test(lower)) return "a conversation today";

  return "";
}

function openingStem(value: string) {
  const stem = value
    .trim()
    .toLowerCase()
    .replace(/[’]/g, "'")
    .replace(/^[^a-z]+/, "")
    .split(/\s+/)
    .slice(0, 3)
    .join(" ");

  return stem.split(" ").length === 3 ? stem : "";
}

function repeatedRecentCrutchLanguage(
  read: StructuredDailyReadPayload,
  prior: PriorReadSummary,
) {
  const current = Object.values(read).join(" ").toLowerCase();
  const priorText = Object.values(priorReadPayload(prior)).join(" ").toLowerCase();
  const phrases = [
    "hold back",
    "holding back",
    "hesitate",
    "hesitation",
    "weigh",
    "weighing",
    "smooth",
    "soften",
    "softening",
    "perfect moment",
    "right moment",
    "draw the line",
    "drawing the line",
    "the edge",
  ];

  return phrases.find((phrase) => current.includes(phrase) && priorText.includes(phrase)) ?? null;
}

function narrativeFrame(value: string) {
  const lower = value.toLowerCase().replace(/[’]/g, "'");
  const sentences = splitSentences(value);
  const first = sentences[0]?.toLowerCase() ?? lower;

  if (/\?$/.test(first.trim())) return "question opening";
  if (/^you can\b/.test(first)) return "you can contrast";
  if (/^part of you\b/.test(first)) return "part of you split";
  if (/^there is a difference\b/.test(first)) return "difference explanation";
  if (/\bworks until\b/.test(lower) || /\bthat works until\b/.test(lower)) return "works until consequence";
  if (/\bthe problem starts\b/.test(lower) || /\bthe delay begins\b/.test(lower)) return "problem starts consequence";
  if (/\bnot about\b.+\bit is about\b/.test(lower)) return "not about it is about";

  return "";
}

function adviceFrame(value: string) {
  const lower = value.toLowerCase().replace(/[’]/g, "'");
  const firstWord = lower.replace(/^[^a-z]+/, "").split(/\s+/)[0] ?? "";

  if (/\bthen\b/.test(lower)) return `${firstWord} then`;
  if (/\bbefore\b/.test(lower)) return `${firstWord} before`;
  if (/\bwithout\b/.test(lower)) return `${firstWord} without`;

  return "";
}

function emotionalFrameLimit(batchSize: number) {
  return Math.max(3, Math.ceil(batchSize / DAILY_ACTIVATION_THEMES.length));
}

function overproducedBatchEmotionalFrame(
  read: StructuredDailyReadPayload,
  batchFrameCounts: Map<string, number> | undefined,
  limit: number,
) {
  if (!batchFrameCounts) return null;

  const frame = dominantEmotionalFrame(read);
  if (!frame) return null;

  const currentCount = batchFrameCounts.get(frame) ?? 0;
  if (currentCount < limit) return null;

  return `Batch is overproducing the "${frame}" emotional frame; choose a more identity-specific tension.`;
}

function recordBatchEmotionalFrame(
  read: StructuredDailyReadPayload,
  batchFrameCounts: Map<string, number> | undefined,
) {
  if (!batchFrameCounts) return;

  const frame = dominantEmotionalFrame(read);
  if (!frame) return;

  batchFrameCounts.set(frame, (batchFrameCounts.get(frame) ?? 0) + 1);
}

function dominantEmotionalFrame(read: StructuredDailyReadPayload) {
  const lower = [
    read.title,
    read.intro,
    read.pull_quote,
    read.deeper_read,
    read.watch_for,
    read.move,
  ].join(" ").toLowerCase();
  let bestFrame: string | null = null;
  let bestScore = 0;

  for (const [frame, patterns] of Object.entries(BATCH_EMOTIONAL_FRAME_PATTERNS)) {
    const score = patterns.reduce((count, pattern) => {
      if (pattern.includes(" ")) {
        return lower.includes(pattern) ? count + 1 : count;
      }

      const matches = lower.match(new RegExp(`\\b${escapeRegExp(pattern)}\\b`, "g"));
      return count + (matches?.length ?? 0);
    }, 0);

    if (score > bestScore) {
      bestFrame = frame;
      bestScore = score;
    }
  }

  return bestScore >= 2 ? bestFrame : null;
}

function blockedDailyReadPhrase(read: StructuredDailyReadPayload) {
  const lower = Object.values(read).join(" ").toLowerCase();
  const blockedPhrases = [
    "pay attention",
    "watch your emotions",
    "notice tension",
    "placeholder",
    "n/a",
    "generic",
    "today is a day",
    "you might find",
    "you could find",
    "you could notice",
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
    "healing",
    "journey",
    "cosmic",
    "universe",
    "destiny",
    "the stars",
    "trust the process",
  ];

  return blockedPhrases.find((phrase) => lower.includes(phrase)) ?? null;
}

function blockedCrutchWord(read: StructuredDailyReadPayload) {
  const lower = Object.values(read).join(" ").toLowerCase();
  const crutchWords = [
    "balance",
    "balanced",
    "balancing",
    "harmony",
    "quiet",
    "smooth",
    "soften",
    "softened",
    "hesitate",
    "hesitating",
    "weigh",
    "weighing",
    "hold back",
    "holding back",
  ];

  return crutchWords.find((word) => {
    const escaped = escapeRegExp(word);
    return word.includes(" ")
      ? lower.includes(word)
      : new RegExp(`\\b${escaped}\\b`, "i").test(lower);
  }) ?? null;
}

function aiGeneratedTitleIssue(title: string) {
  const lower = title.toLowerCase().replace(/[’]/g, "'");
  const exactBadFragments = [
    "self-shift",
    "internal alignment",
    "hidden internal",
    "quiet doubt",
    "balancing self",
    "emotional alignment",
    "inner alignment",
  ];
  const fragment = exactBadFragments.find((value) => lower.includes(value));
  if (fragment) {
    return `Title sounds abstract or AI-generated: "${fragment}".`;
  }

  const abstractWords = [
    "alignment",
    "activation",
    "attunement",
    "calibration",
    "duality",
    "essence",
    "expansion",
    "friction",
    "integration",
    "internal",
    "resonance",
    "shift",
    "tension",
  ];
  const words = lower.split(/\s+/).map((word) => word.replace(/[^a-z-]/g, ""));
  const abstractCount = words.filter((word) => abstractWords.includes(word)).length;

  if (abstractCount >= 2) {
    return "Title leans on abstract noun combinations instead of natural, memorable language.";
  }

  if (/\b(balancing|unlocking|activating|navigating|embracing)\b/.test(lower)) {
    return "Title uses a generic gerund instead of a natural essay-like phrase.";
  }

  return null;
}

function genericTodayOpeningIssue(intro: string) {
  const lower = intro.toLowerCase().trim();
  const genericOpenings = [
    "today reveals",
    "today exposes",
    "today sharpens",
    "today highlights",
    "today surfaces",
    "today centers",
  ];
  const opening = genericOpenings.find((phrase) => lower.startsWith(phrase));
  if (opening) {
    return `Intro uses a generic Today’s Lens opening: "${opening}".`;
  }

  return null;
}

function hiddenFlawFrameIssue(read: StructuredDailyReadPayload) {
  const lower = Object.values(read).join(" ").toLowerCase().replace(/[’]/g, "'");

  if (/\byou secretly\b/.test(lower)) {
    return "Read uses a hidden-flaw frame with 'you secretly'.";
  }

  const diagnosticPhrases = [
    "reveals where",
    "exposes where",
    "the problem starts",
    "becomes costly",
    "the cost of",
    "this creates tension",
    "hidden flaw",
  ];
  const matches = diagnosticPhrases.filter((phrase) => lower.includes(phrase));

  if (matches.length >= 2) {
    return `Read leans too heavily on diagnostic hidden-flaw framing: ${matches.join(", ")}.`;
  }

  return null;
}

function bannedCommunicationTermIn(read: StructuredDailyReadPayload) {
  const lower = Object.values(read).join(" ").toLowerCase();
  const bannedTerms = [
    "group chats",
    "social media",
    "notifications",
    "inbox",
    "dms",
    "dm ",
  ];

  return bannedTerms.find((term) => {
    const escaped = escapeRegExp(term.trim());
    return new RegExp(`\\b${escaped}\\b`, "i").test(lower);
  }) ?? null;
}

function hypotheticalScenarioPhrase(read: StructuredDailyReadPayload) {
  const lower = Object.values(read).join(" ").toLowerCase();
  const phrases = [
    "you might find ",
    "you could find ",
    "may find yourself",
    "might find yourself",
    "could find yourself",
  ];

  return phrases.find((phrase) => lower.includes(phrase)) ?? null;
}

function pullQuoteClarityIssue(pullQuote: string) {
  const lower = pullQuote.toLowerCase();
  const abstractTerms = [
    "fracture",
    "inner fire",
    "restraint",
    "pressure",
    "tension",
    "instinct",
    "appetite",
    "exposure",
    "guarded",
    "longing",
    "stillness",
  ];
  const metaphorFragments = [
    "cost of exposure",
    "shelter your",
    "fracture you",
    "inner fire",
    "carry a pull",
    "pressure of wanting",
  ];
  const abstractMatches = abstractTerms.filter((term) => lower.includes(term));
  const metaphorMatch = metaphorFragments.find((phrase) => lower.includes(phrase));

  if (metaphorMatch) {
    return `pull_quote uses literary phrasing that needs translation: "${metaphorMatch}".`;
  }

  if (abstractMatches.length > 2) {
    return `pull_quote stacks too many abstract terms: ${abstractMatches.join(", ")}.`;
  }

  return null;
}

function containsRecognizableBehavior(read: StructuredDailyReadPayload) {
  return [
    read.intro,
    read.pull_quote,
    read.deeper_read,
    read.watch_for,
  ].some(containsRecognizableBehaviorText);
}

function containsRecognizableBehaviorText(value: string) {
  const lower = value.toLowerCase();
  const behaviorPatterns = [
    "answer",
    "agree",
    "add",
    "ask",
    "avoid",
    "cancel",
    "catch",
    "change the subject",
    "check",
    "choose",
    "commit",
    "conclusion",
    "correct",
    "decide",
    "delay",
    "edit",
    "effort",
    "explain",
    "follow",
    "gesture",
    "hold back",
    "interrupt",
    "keep",
    "leave",
    "nod",
    "notice",
    "offer",
    "organize",
    "overexplain",
    "pause",
    "plan",
    "pretend",
    "present",
    "pull back",
    "push",
    "rehearse",
    "remove",
    "reply",
    "revise",
    "respond",
    "rush",
    "say",
    "send",
    "soften",
    "smooth over",
    "stay quiet",
    "wait",
    "withdraw",
  ];

  return behaviorPatterns.some((pattern) => {
    const escaped = escapeRegExp(pattern);
    return pattern.includes(" ")
      ? lower.includes(pattern)
      : new RegExp(`\\b${escaped}\\w*\\b`, "i").test(lower);
  });
}

function startsWithActionVerb(value: string) {
  const firstWord = firstActionVerb(value);
  const actionVerbs = new Set([
    "ask",
    "accept",
    "allow",
    "answer",
    "catch",
    "choose",
    "cut",
    "decide",
    "delay",
    "drop",
    "finish",
    "give",
    "hold",
    "keep",
    "leave",
    "let",
    "make",
    "name",
    "notice",
    "observe",
    "pause",
    "pick",
    "put",
    "reflect",
    "remove",
    "rest",
    "return",
    "say",
    "send",
    "set",
    "share",
    "show",
    "skip",
    "speak",
    "start",
    "state",
    "stop",
    "take",
    "tell",
    "test",
    "try",
    "use",
    "wait",
    "write",
  ]);

  return actionVerbs.has(firstWord);
}

function firstActionVerb(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/^[^a-z]+/, "")
    .split(/\s+/)[0] ?? "";
}

function soundsLikePersonalityReport(read: StructuredDailyReadPayload) {
  const lower = Object.values(read).join(" ").toLowerCase();
  const reportPhrases = [
    "at your core",
    "your personality",
    "your nature",
    "you are someone who",
    "you tend to always",
    "this combination makes you",
  ];

  return reportPhrases.some((phrase) => lower.includes(phrase));
}

function repeatedSentenceStem(read: StructuredDailyReadPayload) {
  const sentences = Object.values(read)
    .flatMap(splitSentences)
    .map((sentence) => contentTokens(sentence).slice(0, 3).join(" "))
    .filter((stem) => stem.split(" ").length >= 3);

  const seen = new Set<string>();
  for (const stem of sentences) {
    if (seen.has(stem)) return stem;
    seen.add(stem);
  }

  return null;
}

function overusedRestrictedWords(read: StructuredDailyReadPayload) {
  const restricted = ["quiet", "timing", "balance", "control", "silence", "influence"];
  const allText = Object.values(read).join(" ").toLowerCase();

  return restricted.filter((word) => {
    const matches = allText.match(new RegExp(`\\b${word}\\b`, "g"));
    return (matches?.length ?? 0) >= 3;
  });
}

function overlapScore(a: string, b: string) {
  const aTokens = contentTokens(a);
  const bTokens = contentTokens(b);

  if (!aTokens.length || !bTokens.length) return 0;

  const aSet = new Set(aTokens);
  const bSet = new Set(bTokens);
  let shared = 0;

  for (const token of aSet) {
    if (bSet.has(token)) shared++;
  }

  return shared / Math.min(aSet.size, bSet.size);
}

function wordCount(text: string) {
  return text.split(/\s+/).filter(Boolean).length;
}

function contentTokens(text: string) {
  const stopWords = new Set([
    "a",
    "an",
    "and",
    "are",
    "as",
    "at",
    "be",
    "before",
    "but",
    "by",
    "can",
    "could",
    "for",
    "from",
    "has",
    "have",
    "how",
    "in",
    "into",
    "is",
    "it",
    "its",
    "may",
    "more",
    "not",
    "of",
    "on",
    "or",
    "so",
    "than",
    "that",
    "the",
    "their",
    "this",
    "to",
    "too",
    "when",
    "where",
    "while",
    "with",
    "without",
    "you",
    "your",
  ]);

  return text
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s'-]/gu, " ")
    .split(/\s+/)
    .map((token) => token.trim())
    .filter((token) => token.length > 2 && !stopWords.has(token));
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

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function retryDelayMs(attempt: number, retryAfter: string | null = null) {
  const retryAfterSeconds = retryAfter ? Number(retryAfter) : NaN;
  if (Number.isFinite(retryAfterSeconds) && retryAfterSeconds > 0) {
    return Math.min(retryAfterSeconds * 1000, 15000);
  }

  return Math.min(750 * (2 ** attempt), 8000);
}
