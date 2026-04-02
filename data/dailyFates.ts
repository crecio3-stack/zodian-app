export type FateArchetype = {
  id: string;
  title: string;
  keyword: string;
  reading: string;
  ritual: string;
  love: number;
  power: number;
  luck: number;
};

export const DAILY_FATES: FateArchetype[] = [
  {
    id: 'magnetism',
    title: 'Magnetism',
    keyword: 'Attraction',
    reading:
      'You are pulling attention without chasing it. Let people come closer before deciding who deserves access.',
    ritual:
      'Wear something intentional today. Let your presence do the talking.',
    love: 88,
    power: 76,
    luck: 69,
  },
  {
    id: 'threshold',
    title: 'Threshold',
    keyword: 'Crossing Over',
    reading:
      'A subtle shift is happening beneath the surface. The right move today is the one that feels slightly bold.',
    ritual: 'Say yes to one thing you would normally overthink.',
    love: 63,
    power: 91,
    luck: 72,
  },
  {
    id: 'velvet-fire',
    title: 'Velvet Fire',
    keyword: 'Controlled Desire',
    reading:
      'Your energy is warm, elegant, and dangerous in the best way. Move slowly. The moment bends toward you.',
    ritual: 'Pause before replying. Let anticipation build.',
    love: 92,
    power: 84,
    luck: 58,
  },
  {
    id: 'mirror',
    title: 'Mirror Hour',
    keyword: 'Reflection',
    reading:
      'Someone is showing you something about yourself today. Notice what triggers you and what feels familiar.',
    ritual: 'Journal one pattern you are ready to outgrow.',
    love: 71,
    power: 73,
    luck: 64,
  },
  {
    id: 'golden-odds',
    title: 'Golden Odds',
    keyword: 'Fortune',
    reading:
      'Luck is not loud today. It hides in timing, chance encounters, and invitations that arrive casually.',
    ritual: 'Take the route, call, or invitation that feels slightly random.',
    love: 60,
    power: 67,
    luck: 94,
  },
  {
    id: 'shadow-work',
    title: 'Shadow Work',
    keyword: 'Depth',
    reading:
      'Not everything heavy is bad. Today asks for honesty, not perfection. What you face loses power over you.',
    ritual: 'Name the thing you have been avoiding, then take one tiny action.',
    love: 55,
    power: 89,
    luck: 48,
  },
  {
    id: 'lucky-collision',
    title: 'Lucky Collision',
    keyword: 'Unexpected Meeting',
    reading:
      'The right person, idea, or opportunity may appear out of sequence. Stay open. Today is not meant to be controlled.',
    ritual: 'Start one conversation you normally would not.',
    love: 85,
    power: 66,
    luck: 90,
  },
  {
    id: 'crown',
    title: 'Crown Energy',
    keyword: 'Presence',
    reading:
      'People are reading your confidence before they hear your words. Carry yourself like the version of you that already arrived.',
    ritual: 'Fix your posture, lift your chin, and enter every room deliberately.',
    love: 74,
    power: 95,
    luck: 61,
  },
  {
    id: 'eclipse',
    title: 'Soft Eclipse',
    keyword: 'Mystery',
    reading:
      'You do not need to explain everything today. Privacy is power. Let your next move stay hidden until it matters.',
    ritual: 'Keep one exciting plan entirely to yourself for 24 hours.',
    love: 68,
    power: 82,
    luck: 70,
  },
  {
    id: 'open-door',
    title: 'Open Door',
    keyword: 'Momentum',
    reading:
      'Something that felt delayed begins to loosen. Be ready when the opening appears. Hesitation could be the only obstacle.',
    ritual: 'Prepare before the opportunity arrives, not after.',
    love: 62,
    power: 79,
    luck: 86,
  },
  {
    id: 'silk-intuition',
    title: 'Silk Intuition',
    keyword: 'Instinct',
    reading:
      'Your first feeling is cleaner than your second guess. Trust the soft signal, even if logic is running late.',
    ritual: 'Make one decision in under ten seconds.',
    love: 77,
    power: 72,
    luck: 80,
  },
  {
    id: 'afterglow',
    title: 'Afterglow',
    keyword: 'Reward',
    reading:
      'Energy you invested earlier is circling back. Receive it without downplaying your worth.',
    ritual: 'Accept praise without making a joke out of it.',
    love: 83,
    power: 78,
    luck: 75,
  },
];