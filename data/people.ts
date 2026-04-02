import type { ZodiacProfile } from '../types/zodiac';

export type PersonProfile = {
  id: string;
  name: string;
  age?: number;
  photoEmoji?: string;
  photo?: any;
  westernSign: string;
  chineseSign: string;
  bio: string;
  interests: string[];
  datingStyle?: string;
  emotionalNeeds?: string[];
};

// Lightweight mock dataset for Cosmic Connections
export const people: PersonProfile[] = [
  {
    id: 'p1',
    name: 'Maya',
    age: 27,
    photoEmoji: '🌙',
    photo: require('../assets/images/maya.jpg'),
    westernSign: 'Aries',
    chineseSign: 'Dragon',
    bio: 'Startup designer who loves late-night coffees and spontaneous road trips.',
    interests: ['Design', 'Travel', 'Coffee'],
    datingStyle: 'Direct, energetic; seeks people who match her momentum.',
    emotionalNeeds: ['Excitement', 'Honesty', 'Independence'],
  },
  {
    id: 'p2',
    name: 'Daniel',
    age: 31,
    photoEmoji: '☀️',
    photo: require('../assets/images/daniel.jpg'),
    westernSign: 'Taurus',
    chineseSign: 'Ox',
    bio: 'Chef and weekend gardener. Slow to warm but deeply loyal.',
    interests: ['Cooking', 'Gardening', 'Vinyl'],
    datingStyle: 'Patient and grounded; values rituals and shared meals.',
    emotionalNeeds: ['Stability', 'Appreciation', 'Sensory connection'],
  },
  {
    id: 'p3',
    name: 'Leah',
    age: 24,
    photoEmoji: '✨',
    photo: require('../assets/images/leah.jpg'),
    westernSign: 'Gemini',
    chineseSign: 'Rat',
    bio: 'Writer, podcast host, and a little too curious about everything.',
    interests: ['Writing', 'Podcasts', 'Hiking'],
    datingStyle: 'Playful and conversational; needs mental sparks.',
    emotionalNeeds: ['Curiosity', 'Conversation', 'Play'],
  },
  {
    id: 'p4',
    name: 'Carlos',
    age: 29,
    photoEmoji: '🔥',
    photo: require('../assets/images/carlos.jpg'),
    westernSign: 'Leo',
    chineseSign: 'Horse',
    bio: 'Actor & part-time astrologer. Loves big ideas and bold nights out.',
    interests: ['Theater', 'Astrology', 'Dancing'],
    datingStyle: 'Charismatic and warm; seeks admiration and partnership.',
    emotionalNeeds: ['Admiration', 'Excitement', 'Loyalty'],
  },
];

// Helper to map PersonProfile to the existing ZodiacProfile shape used by the SwipeDeck cards.
export function mapPersonToProfile(p: PersonProfile): ZodiacProfile & { rawPerson?: PersonProfile } {
  return {
    id: p.id,
    symbol: p.photoEmoji || '★',
    sign: p.name,
    archetype: `${p.age ?? ''}`.trim(),
    tagline: p.bio,
    element: p.westernSign,
    vibe: p.chineseSign,
    traits: p.interests.slice(0, 5),
    datingStyle: p.datingStyle || '',
    emotionalNeeds: p.emotionalNeeds || [],
    bestMatches: [],
    compatibilityHint: `${p.westernSign} • ${p.chineseSign}`,
    rawPerson: p,
  } as unknown as ZodiacProfile & { rawPerson?: PersonProfile };
}
