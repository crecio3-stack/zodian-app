export type WesternSign =
| 'Aries'
| 'Taurus'
| 'Gemini'
| 'Cancer'
| 'Leo'
| 'Virgo'
| 'Libra'
| 'Scorpio'
| 'Sagittarius'
| 'Capricorn'
| 'Aquarius'
| 'Pisces';
export type ChineseSign =
| 'Rat'
| 'Ox'
| 'Tiger'
| 'Rabbit'
| 'Dragon'
| 'Snake'
| 'Horse'
| 'Goat'
| 'Monkey'
| 'Rooster'
| 'Dog'
| 'Pig';
export type ArchetypeProfile = {
title: string;
description: string;
subtext: string;
};
export type DailyReading = {
headline: string;
overall: string;
love: string;
career: string;
social: string;
luckyColor: string;
luckyNumber: number;
};
export type CompatibilityResult = {
match: string;
score: number;
summary: string;
premium?: boolean;
};
export type Screen = 'onboarding' | 'reveal' | 'daily';