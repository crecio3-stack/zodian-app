import {
ChineseSign,
CompatibilityResult,
WesternSign,
} from '../types/astrology';
function getWesternCompatibilityScore(user: WesternSign, other: WesternSign) {
const strongMatches: Partial<Record<WesternSign, WesternSign[]>> = {
Aries: ['Leo', 'Sagittarius', 'Gemini', 'Aquarius'],
Taurus: ['Virgo', 'Capricorn', 'Cancer', 'Pisces'],
Gemini: ['Libra', 'Aquarius', 'Aries', 'Leo'],
Cancer: ['Scorpio', 'Pisces', 'Taurus', 'Virgo'],
Leo: ['Aries', 'Sagittarius', 'Gemini', 'Libra'],
Virgo: ['Taurus', 'Capricorn', 'Cancer', 'Scorpio'],
Libra: ['Gemini', 'Aquarius', 'Leo', 'Sagittarius'],
Scorpio: ['Cancer', 'Pisces', 'Virgo', 'Capricorn'],
Sagittarius: ['Aries', 'Leo', 'Libra', 'Aquarius'],
Capricorn: ['Taurus', 'Virgo', 'Scorpio', 'Pisces'],
Aquarius: ['Gemini', 'Libra', 'Aries', 'Sagittarius'],
Pisces: ['Cancer', 'Scorpio', 'Taurus', 'Capricorn'],
};
return strongMatches[user]?.includes(other) ? 18 : 8;
}
function getChineseCompatibilityScore(user: ChineseSign, other: ChineseSign) {
const strongMatches: Partial<Record<ChineseSign, ChineseSign[]>> = {
Rat: ['Dragon', 'Monkey', 'Ox'],
Ox: ['Snake', 'Rooster', 'Rat'],
Tiger: ['Horse', 'Dog', 'Pig'],
Rabbit: ['Goat', 'Pig', 'Dog'],
Dragon: ['Rat', 'Monkey', 'Rooster'],
Snake: ['Ox', 'Rooster', 'Dragon'],
Horse: ['Tiger', 'Goat', 'Dog'],
Goat: ['Rabbit', 'Horse', 'Pig'],
Monkey: ['Rat', 'Dragon', 'Snake'],
Rooster: ['Ox', 'Snake', 'Dragon'],
Dog: ['Tiger', 'Rabbit', 'Horse'],
Pig: ['Tiger', 'Rabbit', 'Goat'],
};
return strongMatches[user]?.includes(other) ? 18 : 8;
}
function buildSummary(score: number) {
if (score >= 88) {
return 'Rare alignment. Strong chemistry, ease, and mutual momentum.';
}
if (score >= 78) {
return 'Very strong match. Natural attraction with good long-term potential.';
}
if (score >= 68) {
return 'Promising connection. Enough spark to grow into something meaningful.';
}
return 'Intriguing but mixed. Strong lessons, but not always effortless.';
}
export function getCompatibilityScore(
userWestern: WesternSign,
userChinese: ChineseSign,
otherWestern: WesternSign,
otherChinese: ChineseSign
): CompatibilityResult {
12
const baseScore = 55;
const westernScore = getWesternCompatibilityScore(userWestern, otherWestern);
const chineseScore = getChineseCompatibilityScore(userChinese, otherChinese);
const score = Math.min(baseScore + westernScore + chineseScore, 95);
return {
match: `${otherWestern} / ${otherChinese}`,
score,
summary: buildSummary(score),
};
}
export function getCompatibilityMatches(
westernSign: WesternSign,
chineseSign: ChineseSign
): CompatibilityResult[] {
const candidateMatches: { western: WesternSign; chinese: ChineseSign }[] = [
{ western: 'Leo', chinese: 'Dragon' },
{ western: 'Gemini', chinese: 'Monkey' },
{ western: 'Aquarius', chinese: 'Rooster' },
{ western: 'Sagittarius', chinese: 'Horse' },
{ western: 'Cancer', chinese: 'Rabbit' },
{ western: 'Virgo', chinese: 'Ox' },
];
const scored = candidateMatches.map((candidate, index) => {
const result = getCompatibilityScore(
westernSign,
chineseSign,
candidate.western,
candidate.chinese
);
return {
...result,
premium: index === 2,
};
});
return scored.sort((a, b) => b.score - a.score).slice(0, 3);
}