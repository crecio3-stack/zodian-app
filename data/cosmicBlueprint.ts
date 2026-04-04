import type { ChineseSign, WesternSign } from '../types/astrology';
import { getCombinedProfile } from './archetypes';
import { getAuthoredBlueprint } from './blueprintContent';
import { zodiacProfiles } from './zodiacProfiles';

type BlueprintSection = {
  key: 'personal' | 'love' | 'compatibility' | 'work' | 'growth';
  title: string;
  body: string;
};

export type CosmicBlueprint = {
  comboTitle: string;
  comboSubtitle: string;
  signature: string;
  sections: BlueprintSection[];
};

const chineseTraits: Record<ChineseSign, string> = {
  Rat: 'resourceful and socially strategic',
  Ox: 'steady and deeply reliable',
  Tiger: 'bold and instinct-led',
  Rabbit: 'diplomatic and emotionally perceptive',
  Dragon: 'magnetic and high-drive',
  Snake: 'observant and selective',
  Horse: 'independent and momentum-seeking',
  Goat: 'creative and harmony-oriented',
  Monkey: 'adaptable and mentally quick',
  Rooster: 'precise and expressive',
  Dog: 'loyal and values-driven',
  Pig: 'warm and generous',
};

const chineseCompatibilityMatches: Record<ChineseSign, ChineseSign[]> = {
  Rat: ['Dragon', 'Monkey', 'Ox'],
  Ox: ['Snake', 'Rooster', 'Rat'],
  Tiger: ['Horse', 'Dog', 'Pig'],
  Rabbit: ['Goat', 'Pig', 'Dog'],
  Dragon: ['Rat', 'Monkey', 'Rooster'],
  Snake: ['Ox', 'Rooster', 'Monkey'],
  Horse: ['Tiger', 'Dog', 'Goat'],
  Goat: ['Rabbit', 'Horse', 'Pig'],
  Monkey: ['Rat', 'Dragon', 'Snake'],
  Rooster: ['Ox', 'Snake', 'Dragon'],
  Dog: ['Tiger', 'Horse', 'Rabbit'],
  Pig: ['Rabbit', 'Goat', 'Tiger'],
};

function buildDualSignCompatibilityLine(
  westernSign: WesternSign,
  chineseSign: ChineseSign,
  westernMatches: WesternSign[]
) {
  const west = westernMatches.length > 0 ? westernMatches : [westernSign];
  const east = chineseCompatibilityMatches[chineseSign];

  const combos = west.slice(0, 3).map((match, index) => `${match}/${east[index % east.length]}`);
  return `Dual-sign matches to explore: ${combos.join(', ')}.`;
}

function buildDualSignSectionLead(
  section: 'personal' | 'love' | 'compatibility',
  westernSign: WesternSign,
  chineseSign: ChineseSign
) {
  if (section === 'personal') {
    return `As a ${westernSign}/${chineseSign} blend, your ${westernSign.toLowerCase()} side shapes expression while your ${chineseSign.toLowerCase()} side shapes instinct.`;
  }

  if (section === 'love') {
    return `In relationships, your ${westernSign.toLowerCase()} side guides romantic style while your ${chineseSign.toLowerCase()} side guides trust and pacing.`;
  }

  return `For compatibility, the best matches respect both your ${westernSign.toLowerCase()} needs and your ${chineseSign.toLowerCase()} rhythm.`;
}

export function getCosmicBlueprint(westernSign: WesternSign, chineseSign: ChineseSign): CosmicBlueprint {
  const westernProfile = zodiacProfiles.find((profile) => profile.sign === westernSign);
  const westernBestMatches = westernProfile?.bestMatches ?? [];
  const dualSignCompatibilityLine = buildDualSignCompatibilityLine(westernSign, chineseSign, westernBestMatches);

  // Check for authored blueprint first (personalized copy for popular combos)
  const authored = getAuthoredBlueprint(westernSign, chineseSign);
  if (authored) {
    return {
      comboTitle: `${westernSign} × ${chineseSign}`,
      comboSubtitle: getCombinedProfile(westernSign, chineseSign).title,
      signature: `${westernSign} expression with ${chineseSign} instinct.`,
      sections: [
        {
          key: 'personal',
          title: 'Personal',
          body: `${buildDualSignSectionLead('personal', westernSign, chineseSign)} ${authored.personal}`,
        },
        {
          key: 'love',
          title: 'Love',
          body: `${buildDualSignSectionLead('love', westernSign, chineseSign)} ${authored.love}`,
        },
        {
          key: 'compatibility',
          title: 'Compatibility',
          body: `${buildDualSignSectionLead('compatibility', westernSign, chineseSign)} ${authored.compatibility} ${dualSignCompatibilityLine}`,
        },
        { key: 'work', title: 'Work', body: authored.work },
        { key: 'growth', title: 'Growth', body: authored.growth },
      ],
    };
  }

  // Fall back to template-based generation for unlisted combos
  const combined = getCombinedProfile(westernSign, chineseSign);

  const westernDating = westernProfile?.datingStyle ?? 'You connect best when interaction feels intentional and emotionally honest.';
  const westernNeeds = westernProfile?.emotionalNeeds?.join(', ') ?? 'clarity, trust, and consistency';
  const westernMatches = westernProfile?.bestMatches?.join(', ') ?? 'signs that match your emotional rhythm';
  const compatibilityHint = westernProfile?.compatibilityHint ?? 'You thrive when chemistry and emotional pacing are both aligned.';

  const signature = `${westernSign} expression with ${chineseSign} instinct gives you a style that is ${chineseTraits[chineseSign]}.`;

  return {
    comboTitle: `${westernSign} × ${chineseSign}`,
    comboSubtitle: combined.title,
    signature,
    sections: [
      {
        key: 'personal',
        title: 'Personal',
        body: `${buildDualSignSectionLead('personal', westernSign, chineseSign)} ${combined.description} Your baseline energy tends to feel strongest when your day has both direction and emotional meaning. ${combined.subtext}`,
      },
      {
        key: 'love',
        title: 'Love',
        body: `${buildDualSignSectionLead('love', westernSign, chineseSign)} ${westernDating} Your ${chineseSign.toLowerCase()} side pushes you to protect what feels real, so you tend to commit when there is both chemistry and trust. Core needs: ${westernNeeds}.`,
      },
      {
        key: 'compatibility',
        title: 'Compatibility',
        body: `${buildDualSignSectionLead('compatibility', westernSign, chineseSign)} You usually click best with ${westernMatches}. In practice, your best matches are people who respect your pace while matching your intensity. ${compatibilityHint} ${dualSignCompatibilityLine}`,
      },
      {
        key: 'work',
        title: 'Work',
        body: `In career settings, your ${westernSign.toLowerCase()} mode shapes how you show up, while your ${chineseSign.toLowerCase()} pattern shapes how you sustain progress. You perform best with clear ownership, visible impact, and enough autonomy to move in your own style.`,
      },
      {
        key: 'growth',
        title: 'Growth',
        body: `Your growth edge is balancing instinct with consistency. Weekly practice: choose one relationship move and one work move, then execute both fully instead of splitting focus. This keeps your natural strengths from becoming overextension.`,
      },
    ],
  };
}