import {
ArchetypeProfile,
ChineseSign,
WesternSign,
} from '../types/astrology';
function getFallbackProfile(
westernSign: WesternSign,
chineseSign: ChineseSign
): ArchetypeProfile {
const westernProfiles: Record<WesternSign, ArchetypeProfile> = {
Aries: {
title: 'The Flame Starter',
description: 'You move first, decide fast, and bring heat wherever you go.',
subtext: 'Your power comes from instinct, courage, and refusing to wait.',
},
Taurus: {
title: 'The Velvet Anchor',
description: 'You are steady, sensual, and stronger than people expect.',
subtext: 'Your calm presence hides a deep loyalty and a very firm will.',
},
Gemini: {
title: 'The Electric Mirror',
description: 'You adapt fast, read the room, and keep energy in motion.',
subtext: 'Your brilliance lives in curiosity, language, and reinvention.',
},
Cancer: {
title: 'The Moon Keeper',
description: 'You feel deeply, protect fiercely, and remember everything.',
subtext: 'Your softness is real, but so is your emotional strength.',
},
Leo: {
title: 'The Golden Pulse',
description: 'You were built to radiate, create, and leave a lasting impression.',
subtext: 'Your warmth draws people in, but your pride decides who stays.',
},
Virgo: {
title: 'The Quiet Alchemist',
description: 'You refine, improve, and notice what everyone else misses.',
subtext: 'Your gift is turning chaos into clarity with precision and care.',
},
Libra: {
title: 'The Velvet Dagger',
description: 'You don’t just keep the peace—you control it.',
subtext: 'Your charm disarms, but your intuition decides who gets close.',
},
Scorpio: {
title: 'The Midnight Current',
description: 'You feel everything intensely and reveal only what matters.',
subtext: 'Your magnetism comes from depth, privacy, and emotional power.',
},
Sagittarius: {
title: 'The Wild Compass',
description: 'You chase meaning, momentum, and experiences that expand you.',
subtext: 'Your spirit stays alive when you are moving toward something bigger.',
},
Capricorn: {
title: 'The Iron Ascent',
description: 'You build slowly, move strategically, and play for keeps.',
subtext: 'Your ambition is quiet, but it rarely misses.',
},
Aquarius: {
title: 'The Future Signal',
description: 'You think differently, move independently, and see patterns early.',
subtext: 'Your strength lies in originality, vision, and emotional detachment.',
},
Pisces: {
title: 'The Dream Tide',
description: 'You absorb energy, imagine deeply, and live close to the unseen.',
subtext: 'Your sensitivity is not weakness—it is perception.',
},
};
const chineseTraits: Record<ChineseSign, string> = {
Rat: 'quick-minded and resourceful',
Ox: 'steady and enduring',
Tiger: 'bold and magnetic',
Rabbit: 'graceful and intuitive',
Dragon: 'powerful and radiant',
Snake: 'strategic and perceptive',
Horse: 'free-moving and spirited',
Goat: 'gentle and imaginative',
Monkey: 'clever and adaptable',
Rooster: 'sharp and expressive',
Dog: 'loyal and protective',
Pig: 'warm and generous',
};
const base = westernProfiles[westernSign];
return {
title: base.title,
description: `${base.description} Your ${chineseSign.toLowerCase()} nature
makes you especially ${chineseTraits[chineseSign]}.`,
subtext: base.subtext,
};
}
export function getCombinedProfile(
westernSign: WesternSign,
chineseSign: ChineseSign
): ArchetypeProfile {
const combinedProfiles: Record<string, ArchetypeProfile> = {
  'Libra-Snake': {
title: 'The Velvet Dagger',
description: 'You don’t just keep the peace—you control it.',
subtext: 'Your charm disarms, but your intuition decides who gets close.',
},
'Aries-Dragon': {
title: 'The Solar Flare',
description: 'You don’t wait for momentum—you generate it.',
subtext: 'Confidence, appetite, and force of will make you hard to ignore.',
},
'Scorpio-Ox': {
title: 'The Iron Deep',
description: 'You feel everything—and endure almost anything.',
subtext: 'Your strength comes from emotional depth paired with unshakable resolve.',
},
'Leo-Horse': {
title: 'The Wild Crown',
description: 'You are built for movement, attention, and impact.',
subtext: 'Freedom feeds your fire, and your presence tends to set the pace.',
},
'Pisces-Rabbit': {
title: 'The Soft Oracle',
description: 'You sense what others miss and protect what matters quietly.',
subtext: 'Your gentleness is perceptive, not passive.',
},
'Capricorn-Rat': {
title: 'The Shadow Strategist',
description: 'You are patient, observant, and always three moves ahead.',
subtext: 'You rarely waste energy, and that makes your wins feel inevitable.',
},
};
return (
combinedProfiles[`${westernSign}-${chineseSign}`] ||
getFallbackProfile(westernSign, chineseSign)
);
}