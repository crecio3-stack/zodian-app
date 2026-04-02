import { ChineseSign, DailyReading, WesternSign } from '../types/astrology';

type ReadingSet = {
  overall: string[];
  love: string[];
  career: string[];
  social: string[];
  headlines: string[];
  luckyColors: string[];
  luckyNumbers: number[];
};

function getDaySeed(date: Date) {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();
  return year * 10000 + month * 100 + day;
}

function pickBySeed<T>(items: T[], seed: number, offset = 0): T {
  return items[(seed + offset) % items.length];
}

function buildReadingFromSet(set: ReadingSet, date: Date): DailyReading {
  const seed = getDaySeed(date);

  return {
    headline: pickBySeed(set.headlines, seed, 0),
    overall: pickBySeed(set.overall, seed, 1),
    love: pickBySeed(set.love, seed, 2),
    career: pickBySeed(set.career, seed, 3),
    social: pickBySeed(set.social, seed, 4),
    luckyColor: pickBySeed(set.luckyColors, seed, 5),
    luckyNumber: pickBySeed(set.luckyNumbers, seed, 6),
  };
}

export function getDailyReading(
  westernSign: WesternSign,
  chineseSign: ChineseSign,
  date: Date
): DailyReading {
  const customSets: Record<string, ReadingSet> = {
    'Libra-Snake': {
      headlines: [
        'Precision over peace today.',
        'Charm works best when it stays honest.',
        'You do not need to explain your intuition.',
        'Subtle power is your advantage today.',
      ],
      overall: [
        'Your instinct to keep things graceful is strong, but today rewards subtle honesty over surface harmony.',
        'A softer approach gets better results than force today, especially when timing is on your side.',
        'You are reading between the lines accurately today. Trust what your body notices before your mind catches up.',
        'Your influence is stronger than it looks. Let elegance do some of the work for you.',
      ],
      love: [
        'Attraction is high, but so is your selectiveness. Let curiosity speak before judgment does.',
        'Romantic energy deepens when you stop performing ease and start naming what you actually want.',
        'Someone may be drawn to your calm exterior today. Let them earn access to the deeper layers.',
        'A low-pressure interaction could become more meaningful than expected.',
      ],
      career: [
        'A quiet strategic move will outperform a loud one. Influence matters more than speed today.',
        'You may gain more by observing first and speaking second.',
        'Polish matters, but clarity matters more. Say less, mean more.',
        'A behind-the-scenes decision could improve your position long term.',
      ],
      social: [
        'Someone is paying closer attention to your tone than your words. Be intentional.',
        'You do not need to match every room. Protect your energy and let the right people come closer.',
        'A one-on-one conversation may reveal more than a group setting today.',
        'Your restraint is being noticed in a positive way.',
      ],
      luckyColors: ['Midnight Gold', 'Smoke Rose', 'Obsidian', 'Deep Plum'],
      luckyNumbers: [8, 11, 17, 22],
    },
    'Aries-Dragon': {
      headlines: [
        'Momentum is on your side.',
        'Your fire needs direction today.',
        'Confidence lands best when it is focused.',
        'Move with purpose, not just speed.',
      ],
      overall: [
        'You are hard to ignore today. Use that energy to start something, not just react to something.',
        'Your drive is strong right now, but intention will outperform impulse.',
        'A decisive move opens more doors than waiting for perfect certainty.',
        'You do not need permission to begin. You need aim.',
      ],
      love: [
        'Confidence reads as magnetism right now. Just make sure boldness leaves room for reciprocity.',
        'You are especially attractive when your energy stays warm instead of overwhelming.',
        'A direct message may work better than trying to play it cool.',
        'Chemistry is strong today, but pacing matters.',
      ],
      career: [
        'Take initiative. People are more likely to follow your lead than question it.',
        'Your timing is sharper than usual. Pitch the idea or take the step.',
        'A leadership moment may appear unexpectedly. Be ready to own it.',
        'Big energy works best when paired with one clear objective.',
      ],
      social: [
        'Your presence shifts the room fast. Aim it well.',
        'Others may mirror your intensity today, so choose the tone carefully.',
        'You can rally people quickly right now. Use that power with intention.',
        'Not every conversation needs to become a challenge or a performance.',
      ],
      luckyColors: ['Solar Red', 'Molten Gold', 'Crimson', 'Electric Orange'],
      luckyNumbers: [1, 5, 9, 14],
    },
  };

  const fallbackSets: Record<WesternSign, ReadingSet> = {
    Aries: {
      headlines: [
        'Move before doubt does.',
        'Your momentum matters today.',
        'Action creates clarity.',
        'Lead with instinct.',
      ],
      overall: [
        'Today rewards action, clarity, and trusting your first instinct.',
        'Your energy is strongest when aimed at one thing instead of five.',
        'The first move matters more than the perfect move today.',
        'You gain confidence by doing, not waiting.',
      ],
      love: [
        'Directness works better than mixed signals.',
        'Chemistry grows faster when you say what you mean.',
        'A bold gesture may land better than you expect.',
        'Let confidence stay warm, not sharp.',
      ],
      career: [
        'Push the thing that has been waiting on your courage.',
        'A quick decision may create useful momentum.',
        'Take initiative before overthinking slows you down.',
        'A visible move gets noticed today.',
      ],
      social: [
        'You set the pace more than you realize.',
        'Others are responding to your energy quickly.',
        'Not every interaction needs full intensity.',
        'Leadership comes naturally today.',
      ],
      luckyColors: ['Ember', 'Scarlet', 'Copper', 'Rust'],
      luckyNumbers: [3, 9, 12, 19],
    },
    Taurus: {
      headlines: [
        'Let steadiness win.',
        'Slow is powerful today.',
        'Consistency is your edge.',
        'Protect your peace and pace.',
      ],
      overall: [
        'Consistency is your edge today. Slow does not mean stagnant.',
        'Your strength comes from staying grounded when others rush.',
        'You do not need to force progress today. Build it.',
        'Patience creates better outcomes than pressure right now.',
      ],
      love: [
        'Comfort deepens connection more than spectacle.',
        'Trust grows through presence, not performance.',
        'A softer pace creates more real intimacy.',
        'Someone may need steadiness more than charm today.',
      ],
      career: [
        'Protect your time and your standards.',
        'Reliable progress beats dramatic effort today.',
        'A practical solution will outperform a flashy one.',
        'The work you keep showing up for is paying off.',
      ],
      social: [
        'Your calm is grounding to the right people.',
        'You do not need to overextend to be appreciated.',
        'A relaxed plan may become the best part of the day.',
        'People trust your steadiness more than they say.',
      ],
      luckyColors: ['Moss', 'Olive', 'Stone Beige', 'Forest'],
      luckyNumbers: [2, 6, 10, 18],
    },
    Gemini: {
      headlines: [
        'Follow the spark.',
        'Curiosity opens doors.',
        'The right conversation changes everything.',
        'Keep the energy moving.',
      ],
      overall: [
        'Your mind is moving fast today. Stay curious, but choose one thread to pull.',
        'You are especially quick and adaptable right now.',
        'A useful idea may come from an unexpected direction.',
        'Your best move today may be starting with a question.',
      ],
      love: [
        'Playfulness opens doors that pressure cannot.',
        'A smart, light conversation could become something more.',
        'Flirting works best when it stays present and real.',
        'Someone may be more interested than they let on.',
      ],
      career: [
        'A smart conversation may become an opportunity.',
        'Your flexibility is especially valuable today.',
        'You do well when translating complex things simply.',
        'A message, pitch, or conversation could unlock momentum.',
      ],
      social: [
        'You are especially readable and memorable today.',
        'One good conversation may energize the rest of your day.',
        'Keep the room light, but not disconnected.',
        'Your wit lands best when paired with attention.',
      ],
      luckyColors: ['Silver', 'Sky', 'Slate Blue', 'Mercury'],
      luckyNumbers: [5, 7, 13, 21],
    },
    Cancer: {
      headlines: [
        'Protect your energy without hiding it.',
        'Softness is strength today.',
        'Trust what feels off.',
        'Your sensitivity is useful.',
      ],
      overall: [
        'Sensitivity is high, but so is insight. Trust what feels off.',
        'Your emotional read of the room is especially accurate today.',
        'You do not need to harden to stay protected.',
        'Listen to what your mood is trying to tell you.',
      ],
      love: [
        'Emotional honesty creates closeness faster than caution.',
        'Someone may respond well to vulnerability today.',
        'You feel safer when things are clear. Ask for that clarity.',
        'Connection deepens through sincerity, not guessing.',
      ],
      career: [
        'Work quietly, but do not undersell your contribution.',
        'A more intuitive approach may solve what logic has not.',
        'Protect your focus from draining dynamics.',
        'Your steadiness matters more than your visibility today.',
      ],
      social: [
        'The right people will respond well to softness today.',
        'A more intimate setting may feel better than a loud one.',
        'You do not owe constant access to your energy.',
        'Your care is meaningful, but boundaries matter too.',
      ],
      luckyColors: ['Pearl', 'Moonstone', 'Soft Blue', 'Cream'],
      luckyNumbers: [2, 4, 16, 20],
    },
    Leo: {
      headlines: [
        'Take up space on purpose.',
        'Warmth is your power today.',
        'Visibility helps when it is sincere.',
        'Your presence is the message.',
      ],
      overall: [
        'Visibility helps you today, especially when paired with generosity.',
        'Your confidence draws attention fast right now.',
        'You shine brightest when your energy stays open, not defensive.',
        'A little courage from the heart goes a long way today.',
      ],
      love: [
        'Warmth is your advantage. Let someone feel chosen.',
        'Romantic attention grows when you stay genuine instead of performing.',
        'A bold gesture may be remembered today.',
        'You are magnetic when you let your softness show too.',
      ],
      career: [
        'A bold presentation or message lands well.',
        'Recognition may come from simply owning your point of view.',
        'Your creativity gets stronger results than playing it safe.',
        'Lead from conviction, not ego.',
      ],
      social: [
        'People notice your confidence before you speak.',
        'Your energy can lift the room quickly today.',
        'You do not need to win every moment to be unforgettable.',
        'Generosity makes your charisma hit even harder.',
      ],
      luckyColors: ['Gold', 'Amber', 'Sunset', 'Marigold'],
      luckyNumbers: [1, 3, 8, 15],
    },
    Virgo: {
      headlines: [
        'Refine, don’t overcorrect.',
        'Precision is useful, perfection is not.',
        'Clarity comes through simplification.',
        'Small improvements matter today.',
      ],
      overall: [
        'Precision helps today, but perfectionism will slow the magic.',
        'You are especially good at seeing what needs adjustment.',
        'A simple improvement could create outsized results.',
        'Let useful be enough today.',
      ],
      love: [
        'Thoughtfulness matters more than saying everything exactly right.',
        'Care lands better than control.',
        'You do not need to solve the feeling to share it.',
        'A small act of attention may mean a lot.',
      ],
      career: [
        'A small improvement creates outsized results.',
        'Your eye for detail is especially sharp today.',
        'Finishing something cleanly matters more than starting five things.',
        'Organization creates momentum for you right now.',
      ],
      social: [
        'Your discernment is useful—just keep it gentle.',
        'Not everyone needs critique; some need calm.',
        'You may feel best in lower-noise settings today.',
        'Helpfulness lands best when it is invited.',
      ],
      luckyColors: ['Stone', 'Sage', 'Bone', 'Soft Taupe'],
      luckyNumbers: [4, 6, 12, 24],
    },
    Libra: {
      headlines: [
        'Charm is power when used clearly.',
        'Elegance works best with honesty.',
        'Say what you mean beautifully.',
        'Alignment is possible today.',
      ],
      overall: [
        'You can create alignment today, but only if you say what you actually mean.',
        'Grace gets better results than force for you today.',
        'A balanced response may open more than a dramatic one.',
        'You do not need to choose between honesty and harmony.',
      ],
      love: [
        'Attraction grows through honesty, not just elegance.',
        'Someone may be more drawn to your sincerity than your polish today.',
        'A softer truth may deepen connection.',
        'Reciprocity matters more than chemistry alone right now.',
      ],
      career: [
        'A diplomatic move opens the next door.',
        'You are especially good at bridging perspectives today.',
        'A clear ask may get a better response than hinting.',
        'Partnership energy is favorable today.',
      ],
      social: [
        'You are especially magnetic in one-on-one moments.',
        'Your tone shapes the outcome more than usual.',
        'A thoughtful message may land better than a group setting.',
        'You do well when you stop trying to please everyone at once.',
      ],
      luckyColors: ['Rose Smoke', 'Soft Gold', 'Dusty Mauve', 'Champagne'],
      luckyNumbers: [7, 11, 18, 22],
    },
    Scorpio: {
      headlines: [
        'Go deeper, not louder.',
        'Intensity works best when focused.',
        'Privacy is power today.',
        'Trust the deeper signal.',
      ],
      overall: [
        'Intensity works best today when it stays focused.',
        'Your read on hidden dynamics is especially sharp right now.',
        'Depth gives you better results than noise today.',
        'Not everything needs to be shared to be real.',
      ],
      love: [
        'A private truth may matter more than a dramatic gesture.',
        'You may crave honesty more than romance today.',
        'Connection deepens when trust feels earned.',
        'Magnetism is high, but so is your discernment.',
      ],
      career: [
        'Your read on hidden dynamics is unusually sharp.',
        'A quieter strategy may reveal more than a confrontation.',
        'Timing matters. Hold your move until it matters.',
        'Focus your power instead of scattering it.',
      ],
      social: [
        'Not everyone needs access to your full energy.',
        'You may prefer fewer but more meaningful interactions today.',
        'A quiet observation could tell you everything you need.',
        'Protecting your peace is not withdrawal.',
      ],
      luckyColors: ['Black Plum', 'Oxblood', 'Ink', 'Burgundy'],
      luckyNumbers: [8, 11, 19, 23],
    },
    Sagittarius: {
      headlines: [
        'Expand something.',
        'Movement creates clarity.',
        'Follow the bigger vision.',
        'Freedom wants direction today.',
      ],
      overall: [
        'Movement creates clarity for you today, physically or mentally.',
        'You are at your best when momentum meets meaning.',
        'A bigger perspective helps solve a smaller frustration today.',
        'Your energy lifts when you aim at something that excites you.',
      ],
      love: [
        'Shared adventure says more than overthinking ever could.',
        'Connection grows when you stay present instead of restless.',
        'Honesty lands best when it stays warm.',
        'You may be drawn to someone who expands your mind.',
      ],
      career: [
        'Pitch the bigger vision, not just the task list.',
        'You do well when you zoom out before deciding.',
        'A spontaneous idea may have real value today.',
        'The path opens when you move with confidence.',
      ],
      social: [
        'Your optimism is contagious when it stays grounded.',
        'You may energize others without trying today.',
        'A change of scene could improve your mood fast.',
        'Your humor lands well right now.',
      ],
      luckyColors: ['Cobalt', 'Indigo', 'Saffron', 'Bright Navy'],
      luckyNumbers: [3, 9, 12, 27],
    },
    Capricorn: {
      headlines: [
        'Play the long game.',
        'Steady wins today.',
        'Discipline creates freedom.',
        'Quiet power is enough.',
      ],
      overall: [
        'Today favors discipline, timing, and strategic restraint.',
        'Your consistency is creating more momentum than it seems.',
        'A patient move may outperform a flashy one.',
        'You do well when you trust the structure you built.',
      ],
      love: [
        'Reliability reads as intimacy right now.',
        'A simple, sincere gesture may matter more than grand romance.',
        'You may be craving steadiness more than excitement today.',
        'Connection deepens when trust feels practical and real.',
      ],
      career: [
        'Quiet execution gets noticed more than you think.',
        'A disciplined approach pays off today.',
        'You may gain ground by staying focused on what actually matters.',
        'Long-term thinking gives you an advantage right now.',
      ],
      social: [
        'You do not need to impress everyone—just the right person.',
        'Your steadiness may be more comforting than you realize.',
        'Keep your energy for what feels worthwhile.',
        'A lower-key plan may be the better one today.',
      ],
      luckyColors: ['Graphite', 'Onyx', 'Charcoal', 'Slate'],
      luckyNumbers: [4, 10, 14, 28],
    },
    Aquarius: {
      headlines: [
        'Trust the unusual route.',
        'Different is useful today.',
        'Your originality has traction.',
        'Let the real version of you lead.',
      ],
      overall: [
        'Your different perspective is useful today. Don’t flatten it to fit in.',
        'Innovation comes more naturally when you stop self-editing.',
        'A less conventional route may be the right one.',
        'Your ideas gain traction when you trust their edge.',
      ],
      love: [
        'Connection deepens when you let someone see the real you, not just the clever you.',
        'Someone may be drawn to your independence today.',
        'You do not need to act detached to stay safe.',
        'The strongest chemistry may come through honesty, not performance.',
      ],
      career: [
        'An unconventional idea has traction.',
        'You may find a better solution by ignoring the default path.',
        'Future-focused thinking helps you today.',
        'Say the thing others are thinking but not yet saying.',
      ],
      social: [
        'You may find your best alignment in unexpected company.',
        'Difference is working for you today, not against you.',
        'Your energy lands best when you stay authentic.',
        'A surprising conversation may click immediately.',
      ],
      luckyColors: ['Electric Blue', 'Silver Mist', 'Iris', 'Steel'],
      luckyNumbers: [7, 13, 17, 29],
    },
    Pisces: {
      headlines: [
        'Your sensitivity is signal.',
        'Trust the softer knowing.',
        'Imagination is useful today.',
        'Let intuition lead gently.',
      ],
      overall: [
        'Your intuition is stronger than logic today, and that is not a weakness.',
        'A quieter, more intuitive approach helps you now.',
        'You may sense the truth before you can explain it.',
        'Your emotional intelligence is especially helpful today.',
      ],
      love: [
        'Tenderness lands well when it is honest instead of evasive.',
        'You may feel more deeply than others realize today.',
        'Connection grows when you stay real instead of retreating.',
        'A gentle gesture may mean more than a dramatic one.',
      ],
      career: [
        'A creative solution may appear when you stop forcing one.',
        'Your imagination has practical value today.',
        'Trust your instincts when something feels aligned.',
        'A softer approach may solve the problem faster.',
      ],
      social: [
        'Protect your peace, but do not disappear.',
        'You may need space, but connection still matters today.',
        'The right people will understand your quieter energy.',
        'A meaningful interaction may come from a simple moment.',
      ],
      luckyColors: ['Sea Glass', 'Moon Blue', 'Lavender Mist', 'Pearl Green'],
      luckyNumbers: [2, 6, 15, 24],
    },
  };

  const custom = customSets[`${westernSign}-${chineseSign}`];
  if (custom) {
    return buildReadingFromSet(custom, date);
  }

  return buildReadingFromSet(fallbackSets[westernSign], date);
}