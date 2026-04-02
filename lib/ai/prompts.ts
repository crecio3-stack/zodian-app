
export const DAILY_RITUAL_SYSTEM_PROMPT = `You are Zodian's compassionate astrology guide. Produce a JSON object only, no surrounding text, that exactly matches the schema provided in the user instructions. Keep the tone warm, concise, and actionable. Use short steps and provide durations where appropriate.`;

export function buildDailyRitualUserPrompt(params: {
  westernSign: string;
  chineseSign: string;
  dateISO: string;
  weekday: string;
}) {
  return `Create a personalized daily ritual for a user with the following profile:\n
- westernSign: ${params.westernSign}\n- chineseSign: ${params.chineseSign}\n- dateISO: ${params.dateISO}\n- weekday: ${params.weekday}\n
Requirements:\n1) Output a single JSON object exactly matching this TypeScript shape: { title: string, subtitle?: string, mood?: string, estimatedDurationMinutes?: number, steps: [{ title: string, description: string, durationMinutes?: number }], metadata: { westernSign: string, chineseSign: string, dateISO: string, weekday: string } }\n2) Keep the ritual under 6 steps.\n3) Make each step actionable and no longer than 2 sentences.\n4) Provide short durations for each step where possible.\n5) Include no emojis or markdown.\n\nReturn only JSON.`;
}

// Generic prompts for other features (stubs for future use)
export const DAILY_FATE_SYSTEM_PROMPT = `You are Zodian's fate oracle. Provide concise, hopeful, and evidence-free guidance. Return JSON only.`;
export function buildDailyFatePrompt(profile: Record<string, string>) {
  return `Provide a daily fate reading for: ${JSON.stringify(profile)}. Return JSON only.`;
}

export const COMPATIBILITY_SYSTEM_PROMPT = `You are Zodian's compatibility analyst. Output a single JSON object only that summarizes compatibility between two profiles. Use concise, practical language.`;
export function buildCompatibilityPrompt(left: { westernSign: string; chineseSign: string }, right: { westernSign: string; chineseSign: string }) {
  return `Analyze compatibility between two users. Left: ${JSON.stringify(left)} Right: ${JSON.stringify(right)}. Return a JSON object with: pair, compatibilityScore (0-100), strengths (array), challenges (array), advice (string), metadata.`;
}

export const ARCHETYPE_SYSTEM_PROMPT = `You are Zodian's archetype curator. Provide an archetype profile as JSON only with name, description, practicalTips, and optional short ritual steps.`;
export function buildArchetypePrompt(profile: { westernSign?: string; chineseSign?: string }) {
  return `Create an archetype insight for: ${JSON.stringify(profile)}. Return JSON only that matches the archetype schema.`;
}
