type DailyRitual = {
  headline: string;
  coreMessage: string;
  love: string;
  energy: string;
  advice: string;
  bluntInsight: string;
  focusWord: string;
  focusSupport: string;
};

const defaultRitual: DailyRitual = {
  headline: 'Your energy is louder than your words today.',
  coreMessage:
    'People can feel what you are holding back. The less you force clarity, the more obvious the right move becomes.',
  love: 'Let attraction build naturally. You do not need to overperform to be noticed.',
  energy:
    'Your strongest move today is staying grounded while everything around you speeds up.',
  advice:
    'Say less, mean more. Presence will work better than persuasion.',
  bluntInsight:
    'You already know what feels off. Stop asking for another sign.',
  focusWord: 'Discernment',
  focusSupport:
    'Protect your energy by noticing what feels aligned instead of what merely feels exciting.',
};

const westernOverrides: Record<string, Partial<DailyRitual>> = {
  Aries: {
    headline: 'You are meant to move, but not to rush.',
    coreMessage:
      'Your fire is useful today when it is directed. Momentum matters more than intensity.',
    love:
      'Confidence is attractive today, but impatience is not. Let the tension breathe.',
    energy:
      'You have more power when you slow down enough to choose where it goes.',
    advice:
      'Do not chase what already feels uncertain.',
    bluntInsight:
      'Not everything needs an immediate answer just because you feel it strongly.',
    focusWord: 'Control',
    focusSupport:
      'Real strength today looks like precision, not speed.',
  },
  Taurus: {
    headline: 'Comfort is not the same thing as alignment.',
    coreMessage:
      'You are craving steadiness, but something deeper wants honesty before peace.',
    love:
      'You do not need to settle for mixed signals just because the connection feels familiar.',
    energy:
      'Protect your calm, but do not use calm as a way to avoid the truth.',
    advice:
      'Pay attention to what your body relaxes around.',
    bluntInsight:
      'You keep calling it patience when it is actually avoidance.',
    focusWord: 'Truth',
    focusSupport:
      'Let clarity interrupt the comfort zone.',
  },
  Gemini: {
    headline: 'Your mind is quick, but your heart is being slower on purpose.',
    coreMessage:
      'There is a difference between curiosity and connection. Today asks you to notice which one you are feeding.',
    love:
      'Charm is easy for you. Vulnerability is the real flex today.',
    energy:
      'Your best energy comes from depth, not from scattering yourself across too many signals.',
    advice:
      'Follow what keeps your attention, not what merely entertains it.',
    bluntInsight:
      'You are not confused. You are just not ready to admit what you want.',
    focusWord: 'Depth',
    focusSupport:
      'Choose substance over stimulation.',
  },
  Cancer: {
    headline: 'Sensitivity is your advantage today.',
    coreMessage:
      'You are reading the room correctly. Trust your emotional intelligence without letting it become overprotection.',
    love:
      'You want safety, but real closeness still requires you to be seen.',
    energy:
      'Softness becomes powerful when it is paired with boundaries.',
    advice:
      'Do not shrink to make someone else more comfortable.',
    bluntInsight:
      'You can stop pretending you are okay with less than what you need.',
    focusWord: 'Safety',
    focusSupport:
      'Honor what makes you feel emotionally steady.',
  },
  Leo: {
    headline: 'You do not need to prove your value today.',
    coreMessage:
      'Your presence is already felt. Let yourself be chosen without performing for it.',
    love:
      'Attention is easy to get. Genuine effort is what matters now.',
    energy:
      'You are magnetic when you are fully yourself, not when you are trying to impress.',
    advice:
      'Put your energy where it is reciprocated.',
    bluntInsight:
      'You can want admiration and still admit you need tenderness too.',
    focusWord: 'Worth',
    focusSupport:
      'Let confidence come from self-trust, not reaction.',
  },
  Virgo: {
    headline: 'Perfection is not the assignment today.',
    coreMessage:
      'You are seeing every detail, but not every detail deserves your energy.',
    love:
      'Stop trying to decode everything before you let yourself feel it.',
    energy:
      'Your mind needs less correction and more quiet.',
    advice:
      'Choose what is good and real over what is polished.',
    bluntInsight:
      'You are overthinking something that your instincts solved hours ago.',
    focusWord: 'Trust',
    focusSupport:
      'Let your nervous system breathe before making the next call.',
  },
  Libra: {
    headline: 'Peace is powerful when it is honest.',
    coreMessage:
      'You are being asked to stop smoothing over what actually needs to be said.',
    love:
      'Romance feels stronger today when it is direct instead of perfectly curated.',
    energy:
      'You do not need everyone to understand you to stay aligned with yourself.',
    advice:
      'Choose honesty over likability.',
    bluntInsight:
      'Keeping the vibe nice is not the same thing as keeping it real.',
    focusWord: 'Balance',
    focusSupport:
      'Let harmony come from truth, not self-editing.',
  },
  Scorpio: {
    headline: 'Your intensity is a compass today.',
    coreMessage:
      'What pulls at you strongly is worth examining, but not every urge deserves action.',
    love:
      'You want depth, not noise. Let mystery exist without turning it into a test.',
    energy:
      'Your power grows when you stop controlling the outcome.',
    advice:
      'Notice where obsession is disguising itself as intuition.',
    bluntInsight:
      'You cannot force emotional safety by trying to stay three steps ahead.',
    focusWord: 'Release',
    focusSupport:
      'Control less. Feel more. Observe everything.',
  },
  Sagittarius: {
    headline: 'Freedom means knowing what is worth returning to.',
    coreMessage:
      'You are craving movement, but today is less about escape and more about meaning.',
    love:
      'A real spark should still feel emotionally clean.',
    energy:
      'Your excitement is strongest when it has direction.',
    advice:
      'Stop treating commitment like the opposite of expansion.',
    bluntInsight:
      'Running from boredom is still running.',
    focusWord: 'Meaning',
    focusSupport:
      'Choose what expands you without scattering you.',
  },
  Capricorn: {
    headline: 'You do not have to earn rest through exhaustion.',
    coreMessage:
      'You are capable of carrying a lot, but today asks whether all of it is actually yours.',
    love:
      'Being dependable is beautiful, but intimacy still requires softness.',
    energy:
      'Your strongest posture today is sustainable, not stoic.',
    advice:
      'Drop one thing that is only draining you because you feel responsible.',
    bluntInsight:
      'You keep calling it discipline when sometimes it is just emotional armor.',
    focusWord: 'Ease',
    focusSupport:
      'Let your ambition make room for your humanity.',
  },
  Aquarius: {
    headline: 'Distance is not always clarity.',
    coreMessage:
      'You see things from above so well, but today wants you back inside the feeling.',
    love:
      'Connection gets better when you stop trying to intellectualize every signal.',
    energy:
      'Your uniqueness lands best when it is grounded and sincere.',
    advice:
      'Name what you feel before you analyze it.',
    bluntInsight:
      'Detachment is protecting you from something, but it is also costing you something.',
    focusWord: 'Presence',
    focusSupport:
      'Let yourself be in the moment instead of hovering above it.',
  },
  Pisces: {
    headline: 'Your intuition is right, but it still needs boundaries.',
    coreMessage:
      'You are absorbing a lot today. The answer is not to shut down, but to be more selective.',
    love:
      'Romance feels sweeter when it is mutual instead of imagined.',
    energy:
      'Your softness is not weakness, but it does need protection.',
    advice:
      'Do not romanticize what keeps draining you.',
    bluntInsight:
      'You are not meant to rescue what refuses to meet you halfway.',
    focusWord: 'Boundaries',
    focusSupport:
      'Keep your heart open and your standards intact.',
  },
};

const chineseTone: Record<string, Partial<DailyRitual>> = {
  Rat: {
    focusSupport:
      'Your sharp instincts are strongest when you trust timing instead of forcing it.',
  },
  Ox: {
    focusSupport:
      'Steady energy wins today. Slow does not mean stuck.',
  },
  Tiger: {
    focusSupport:
      'Lead with courage, but let restraint shape the outcome.',
  },
  Rabbit: {
    focusSupport:
      'Gentleness is powerful when it is paired with self-respect.',
  },
  Dragon: {
    focusSupport:
      'Your presence is naturally strong. Let calm sharpen it.',
  },
  Snake: {
    focusSupport:
      'Quiet observation reveals more than reaction ever will.',
  },
  Horse: {
    focusSupport:
      'Freedom feels better when your direction is clean.',
  },
  Goat: {
    focusSupport:
      'Stay soft without becoming overly available.',
  },
  Monkey: {
    focusSupport:
      'Your wit is a gift. Use it to connect, not deflect.',
  },
  Rooster: {
    focusSupport:
      'Precision matters, but not at the expense of peace.',
  },
  Dog: {
    focusSupport:
      'Loyalty is beautiful when it includes loyalty to yourself.',
  },
  Pig: {
    focusSupport:
      'Pleasure is part of balance, not the enemy of it.',
  },
};

export function getDailyRitual(
  westernSign: string,
  chineseSign: string
): DailyRitual {
  return {
    ...defaultRitual,
    ...(westernOverrides[westernSign] ?? {}),
    ...(chineseTone[chineseSign] ?? {}),
  };
}