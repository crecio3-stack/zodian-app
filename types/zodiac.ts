export type ZodiacProfile = {
  id: string;
  sign: string;
  symbol: string;
  archetype: string;
  tagline: string;
  traits: string[];
  datingStyle: string;
  emotionalNeeds: string[];
  bestMatches: string[];
  compatibilityHint: string;
  element: 'Fire' | 'Earth' | 'Air' | 'Water';
  vibe: string;
};