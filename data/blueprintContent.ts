/**
 * Curated, authored Blueprint content for popular sign combinations.
 * These provide highly personalized insights for the most common user combos.
 * Fallback to template-based generation for unlisted combos.
 */

import type { ChineseSign, WesternSign } from '../types/astrology';

type AuthoredBlueprint = {
  personal: string;
  love: string;
  compatibility: string;
  work: string;
  growth: string;
};

type BlueprintLookup = Record<string, AuthoredBlueprint>;

const blueprintContent: BlueprintLookup = {
  'Leo-Dragon': {
    personal:
      'You are built to command attention. Leo gives you warmth and star power; Dragon amplifies it into magnetic force. People gravitate to you not just for your confidence, but because your presence feels rare. Your challenge is knowing when to radiate versus when to listen.',
    love:
      'Romance is high-stakes for you--you want both passion and admiration. You commit when someone can match your intensity without needing to dim your light. You are fiercely loyal once trust lands, but you need a partner who celebrates rather than competes with your brilliance.',
    compatibility:
      'Fire signs (Aries, Sagittarius) and Air signs (Libra, Aquarius) usually understand your need for dynamic, expressive connection. In love, you naturally click with Aries x Rat, Sagittarius x Horse, Libra x Monkey--people who both respect and energize your magnetism.',
    work:
      'You thrive in roles with visibility and autonomy. Your Leo side wants recognition; your Dragon side wants impact. You excel when leading, creating, or pioneering--situations where your confidence becomes contagious. The risk: burnout from overcommitting to too many high-stakes projects.',
    growth:
      'Your edge is learning to lead through listening, not just presence. Try this: in your next team dynamic, ask three people for their perspective before sharing yours. Your power doesn\'t diminish--it deepens.',
  },
  'Aries-Snake': {
    personal:
      'You are intensity wrapped in strategy. Aries moves fast; Snake thinks deep. You act on instinct, but your instincts are rarely wrong because you process more than you show. People often miss your depth until they are already drawn in.',
    love:
      'You want romance that feels both urgent and intentional. You move quickly when chemistry hits, but you also expect loyalty and emotional depth in return. You are magnetic to people who appreciate your contradiction: bold but selective, independent but committed.',
    compatibility:
      'Water and Fire can work beautifully when both sides respect the other\'s nature. You click best with Cancer x any sign, Scorpio x any sign, and fellow Fire signs who understand your need for emotional substance beneath the passion.',
    work:
      'You are most effective when you can both strategize and execute. You dislike slow processes, but you won\'t rush quality work. You make excellent project leads, strategists, or roles requiring quick decision-making with calculated risk. Your blind spot: assuming others move at your pace.',
    growth:
      'Learn to slow down long enough to explain your reasoning. Your Snake side sees five moves ahead, but people only see the Aries charge. Monthly practice: share your thinking process, not just your conclusion.',
  },
  'Libra-Monkey': {
    personal:
      'You are clever, charismatic, and never boring. Libra brings grace; Monkey brings wit and playfulness. You disarm people with charm, then surprise them with your tactical mind. You thrive on stimulation and despise monotony.',
    love:
      'You need intellectual and emotional connection--boredom is your biggest dealbreaker. You are flirty and fun, but you commit to people who keep you mentally engaged and can match your humor. You love the game of connection, but you want real substance beneath the charm.',
    compatibility:
      'Air signs (Gemini, Aquarius) and Fire signs (Aries, Sagittarius) usually understand your pace. You naturally click with Gemini x Rooster, Aquarius x Dragon, Sagittarius x Horse--people who are both fun and fast-thinking.',
    work:
      'You excel in roles involving communication, networking, or creative problem-solving. You are adaptable and quick to see angles others miss. Your strength is connecting dots and ideas; your risk is getting distracted by shiny new opportunities before finishing current ones.',
    growth:
      'Your growth edge is follow-through. Commit to completion on 3 things before starting 5 new ones. Your Monkey mind is brilliant, but your Libra side craves the peace of finished work. Depth over options.',
  },
  'Sagittarius-Horse': {
    personal:
      'You are the seeker and the wanderer. Sagittarius chases philosophy and experience; Horse chases freedom and new terrain. Together, you are restless in the best way--always curious, growing, and refusing small living. You inspire others simply by being authentically, unapologetically yourself.',
    love:
      'You need freedom and growth together. You give loyalty when someone respects your independence and your urge to explore--not just externally, but emotionally and intellectually. You are generous with affection but won\'t stay in anything that feels limiting.',
    compatibility:
      'Fire and Air signs often match your pace. You click with Aries x Tiger, Leo x Goat, Libra x any sign--people who see the world as big and beautiful, not small and securing.',
    work:
      'You are at your best doing work that expands your horizons--education, travel, big-picture thinking, or launching new initiatives. You dislike routine and micromanagement. You thrive when you can move genuinely and see the larger purpose in what you are doing.',
    growth:
      'Your edge is going deeper after moving faster. It is easier for you to start ten things than master one. Pick one skill this quarter and push it to real competence. Depth creates more freedom long-term than breadth.',
  },
  'Pisces-Rabbit': {
    personal:
      'You are intuitive, diplomatic, and surprisingly perceptive. Pisces feels everything; Rabbit observes before moving. You notice emotional currents others miss, and you navigate them with care. Your softness is your strength, but you also have quiet boundaries.',
    love:
      'You want emotional safety and genuine connection. You are tender-hearted but discerning--you move slowly into romance, but once you are in, you are devoted. You need reassurance, consistency, and a partner who appreciates your sensitivity rather than seeing it as weakness.',
    compatibility:
      'Water and Air signs bring calm. You click best with Cancer x any sign, Scorpio x Snake, Capricorn x Goat--people who are grounded enough to honor your emotions without overwhelming you.',
    work:
      'You excel in roles requiring empathy, creativity, or detailed care--counseling, design, writing, or caregiving fields. You are thorough and considerate. Your challenge is not over-absorbing other people\'s stress. Set gentle but firm boundaries.',
    growth:
      'Your growth edge is assertiveness. You are so aware of others\' feelings that you sometimes swallow your own needs. Practice asking for what you want clearly, at least once weekly. Your peace matters too.',
  },
  'Capricorn-Rat': {
    personal:
      'You are ambitious, resourceful, and quietly powerful. Capricorn builds lasting structures; Rat plays the long game strategically. You are not flashy, but you are remarkably effective. People underestimate you until they see the empire you have quietly assembled.',
    love:
      'You love slowly and deliberately, but when you commit, it is for real. You want a partner who understands that your ambition isn\'t distance--it\'s vision. You are devoted to people who value security, trust, and long-term thinking as much as you do.',
    compatibility:
      'Earth and Water signs understand your pace. You click best with Taurus x any sign, Virgo x Ox, or fellow Capricorn x Snake--people building something substantial, not just seeking thrills.',
    work:
      'You are built for leadership, strategy, and roles requiring patience and precision. You move methodically, but you always reach your goal. You are excellent in finance, project management, or any field rewarding tenacity. Your superpower: staying calm when others panic.',
    growth:
      'Your edge is loosening grip and trusting others to execute. You control a lot because you are reliable, but you limit your impact. Delegate more; mentor as you climb. Your legacy is proportional to who you have helped rise.',
  },
  'Gemini-Rooster': {
    personal:
      'You are articulate, observant, and slightly perfectionist. Gemini loves to communicate; Rooster insists on precision. You notice everything, express it clearly, and often know exactly what needs fixing. Your gift is seeing what\'s broken and explaining how to repair it.',
    love:
      'You need mental compatibility above all. Physical attraction matters, but if you can\'t talk deeply, you are gone. You are responsive and playful with people who match your wit and don\'t mind your directness. You are loyal to people who appreciate your honesty.',
    compatibility:
      'Air and Fire signs understand your need for stimulation. You click with Libra x Monkey, Aquarius x any sign, Leo x Rooster--people who value intelligence and clear communication.',
    work:
      'You are excellent in roles involving writing, teaching, analysis, or quality control. Your eye for detail is impeccable. You are happiest when you can improve processes or help others see problems more clearly. Your risk: getting stuck perfecting instead of shipping.',
    growth:
      'Your edge is shipping good-enough work instead of perfect work. Set a deadline and commit to it. Done is better than perfect. Release sooner; iterate faster.',
  },
  'Scorpio-Dog': {
    personal:
      'You are intensely loyal, deeply feeling, and profoundly perceptive. Scorpio reads people\'s motivations; Dog reads their character. Together, you are a lie detector. You don\'t have many people in your circle, but those who are in your circle know you are unwavering.',
    love:
      'You love fiercely and exclusively. You don\'t do casual, and you won\'t waste time on people who don\'t deserve your depth. When you commit, you commit completely--and you expect the same. You are intensely private but emotionally available to your person.',
    compatibility:
      'Water and Earth signs match your stability. You click with Cancer x any sign, Capricorn x Rat, Pisces x Rabbit--people who value substance and loyalty as much as you do.',
    work:
      'You thrive in roles requiring trust, insight, or protection--detective work, counseling, security, or any field where people matter more than profit. You are incredibly reliable. Your challenge: not taking work disappointment personally.',
    growth:
      'Your edge is sometimes not everything is a betrayal. Not all misalignment is a moral failing. Practice assuming good intent more often. Trust can deepen when you soften slightly.',
  },
  'Cancer-Pig': {
    personal:
      'You are nurturing, emotionally intelligent, and genuinely kind. Cancer cares deeply; Pig is generous and warm. You are the person everyone feels safe with, and you give without keeping score. Your challenge is not over-giving until you are depleted.',
    love:
      'You want a partner you can nurture and build a home with. Romance for you is domestic, entwining, emotionally safe. You are tender-hearted and devoted. You need reassurance that you matter and that your love is reciprocated fully, not just appreciated.',
    compatibility:
      'Water and Earth signs match your rhythm. You click with Scorpio x Dog, Taurus x Goat, Pisces x Rabbit--people who value slow, deep, rooted connection.',
    work:
      'You excel in caregiving, teaching, human resources, or any role in which people\'s wellbeing is central. You are excellent at creating psychological safety. Your risk: absorbing too much emotional labor and forgetting to protect your own energy.',
    growth:
      'Your edge is saying no without guilt. You can\'t help anyone if you are empty. Practice declining one request per week. You are allowed to have boundaries. Protecting yourself isn\'t selfish.',
  },
  'Aries-Dragon': {
    personal:
      'You are force plus force. Aries gives ignition; Dragon gives scale. You start quickly and think big, which makes you a natural catalyst in social and creative spaces.',
    love:
      'You are drawn to partners who can handle intensity without turning every moment into a power struggle. Passion matters, but respect matters more than drama.',
    compatibility:
      'You tend to click with confident Air and Fire profiles that admire initiative and communicate directly. Emotional steadiness from select Water signs also helps balance your pace.',
    work:
      'You perform best in leadership tracks, launches, and environments that reward speed with strategic ownership. You struggle in slow systems with unclear authority.',
    growth:
      'Your edge is pacing. Pick one major objective per week and finish it before opening a second front. Focus protects your power.',
  },
  'Taurus-Ox': {
    personal:
      'You are grounded twice over. Taurus offers calm consistency; Ox adds endurance and reliability. People trust you because your words and actions align.',
    love:
      'You seek stable affection, emotional safety, and practical loyalty. You open slowly, but your commitment is long-term when trust is proven over time.',
    compatibility:
      'Earth and Water profiles often match your tempo. You do best with partners who value routine, honesty, and tangible care over high-intensity unpredictability.',
    work:
      'You excel in operational roles, finance, craftsmanship, and any domain where quality compounds through consistency. You dislike chaos and last-minute pivots.',
    growth:
      'Your edge is flexibility. Try one small experiment weekly so stability does not become stagnation. Adaptation keeps your strengths future-proof.',
  },
  'Gemini-Monkey': {
    personal:
      'You are mentally fast, socially fluid, and highly adaptive. Gemini brings language and curiosity; Monkey adds improvisation and strategic wit.',
    love:
      'You need playful chemistry and active conversation. Emotional depth matters too, but boredom is the fastest way to lose momentum for you.',
    compatibility:
      'Air and Fire profiles often understand your speed and humor. Grounded Earth partners can work well when they respect your need for variety.',
    work:
      'You thrive in product, media, sales, content, and strategy roles where rapid context switching is an asset. Repetition without creativity drains you.',
    growth:
      'Your edge is depth. Choose one skill to master each quarter and track measurable progress. Breadth plus mastery becomes your unfair advantage.',
  },
  'Cancer-Dog': {
    personal:
      'You are protective, intuitive, and values-led. Cancer reads emotional tone; Dog reads trustworthiness. Together, you form deep bonds with high standards.',
    love:
      'You prioritize safety, loyalty, and emotional reciprocity. You can be cautious early, but once committed you show exceptional consistency and care.',
    compatibility:
      'Water and Earth profiles usually align with your relational priorities. You do best with people who treat commitment as action, not words.',
    work:
      'You are effective in people-facing systems: coaching, team leadership, care work, and community operations. You protect morale as much as outcomes.',
    growth:
      'Your edge is reducing over-vigilance. Not every delay or mismatch means disloyalty. Ask clarifying questions before assuming threat.',
  },
  'Leo-Horse': {
    personal:
      'You are expressive, independent, and high-voltage. Leo seeks creative visibility; Horse seeks motion and freedom. You lead best while staying in motion.',
    love:
      'You want romance that is proud, playful, and growth-oriented. You resist partners who try to control your pace or shrink your social energy.',
    compatibility:
      'Fire and Air profiles often meet your momentum. Water profiles can work when emotional communication is clear and personal space is respected.',
    work:
      'You thrive in entrepreneurship, performance, creative direction, and mission-led leadership where your charisma can mobilize people quickly.',
    growth:
      'Your edge is consistency after inspiration. Build routines that protect your output on low-motivation days, not only high-energy ones.',
  },
  'Virgo-Snake': {
    personal:
      'You are precise, observant, and quietly strategic. Virgo refines systems; Snake sees hidden patterns. You notice what others overlook and act selectively.',
    love:
      'You seek trust built through competence and emotional steadiness. You are selective by design, and your standards protect long-term compatibility.',
    compatibility:
      'Earth and Water profiles often align with your depth and discretion. Fast, chaotic partners may feel exciting but difficult to sustain.',
    work:
      'You excel in analysis, product quality, research, and operations where detail and timing matter. You improve systems without needing spotlight credit.',
    growth:
      'Your edge is openness. Share intent earlier instead of waiting for perfect certainty. Transparency increases collaboration without lowering standards.',
  },
  'Scorpio-Snake': {
    personal:
      'You are intense, insightful, and deeply private. Scorpio brings emotional depth; Snake adds strategic restraint. Your presence is focused and magnetic.',
    love:
      'You need honesty, depth, and exclusivity. Surface-level attention does not satisfy you; you seek emotional substance and dependable behavior.',
    compatibility:
      'Water and Earth profiles often match your seriousness and loyalty. You connect best where trust is earned steadily and respected fully.',
    work:
      'You perform well in high-trust domains: strategy, investigations, psychology, and leadership contexts requiring discretion and long-game thinking.',
    growth:
      'Your edge is calibrated vulnerability. Sharing a little earlier prevents misunderstandings and builds the trust you actually want.',
  },
  'Aquarius-Dragon': {
    personal:
      'You are visionary and forceful. Aquarius contributes originality and systems thinking; Dragon contributes confidence and momentum to execute bold ideas.',
    love:
      'You need both intellectual respect and emotional freedom. You are attracted to people who challenge your thinking without trying to possess you.',
    compatibility:
      'Air and Fire profiles usually keep pace with your innovation and independence. Grounded partners can work if they support your mission scale.',
    work:
      'You thrive in innovation-heavy environments: startups, product strategy, social impact, and future-facing leadership. You prefer influence over routine.',
    growth:
      'Your edge is relational presence. Big vision is powerful, but daily consistency with people determines long-term trust and followership.',
  },
  'Pisces-Pig': {
    personal:
      'You are compassionate, imaginative, and emotionally generous. Pisces feels deeply; Pig offers warmth and sincerity. You naturally create safe emotional space.',
    love:
      'You seek tenderness, reassurance, and mutual devotion. You love deeply and may over-give unless boundaries are clear and respected.',
    compatibility:
      'Water and Earth profiles often match your emotional depth and relational steadiness. You do best with partners who are kind and consistent.',
    work:
      'You excel in creative, healing, and service-oriented roles where empathy and intuition improve real outcomes. Meaning matters more than title.',
    growth:
      'Your edge is boundaries with compassion. Protecting your energy is not selfish; it is what keeps your generosity sustainable.',
  },
  'Capricorn-Ox': {
    personal:
      'You are disciplined, resilient, and long-term oriented. Capricorn sets the strategy; Ox supplies the endurance to see it through under pressure.',
    love:
      'You show care through reliability and follow-through. You value serious commitment and practical partnership over performative romance.',
    compatibility:
      'Earth and Water profiles usually align with your stability and ambition. You struggle with people who confuse intensity for consistency.',
    work:
      'You are built for leadership in structured environments where responsibility and competence are rewarded. You scale systems patiently and effectively.',
    growth:
      'Your edge is emotional expression. Let people hear appreciation while they are still in the room. Warmth increases loyalty around your leadership.',
  },
  'Libra-Rabbit': {
    personal:
      'You are graceful, diplomatic, and socially intuitive. Libra brings fairness and style; Rabbit brings tact and emotional sensitivity.',
    love:
      'You want romance with harmony, gentleness, and mutual effort. You avoid unnecessary conflict but still need honest dialogue to feel secure.',
    compatibility:
      'Air and Water profiles often align with your communication style. You thrive with partners who are kind, thoughtful, and emotionally aware.',
    work:
      'You excel in relationship-heavy work: partnerships, design, mediation, and client leadership where trust and presentation both matter.',
    growth:
      'Your edge is decisiveness. Practice choosing faster when options are close. Momentum often matters more than perfect symmetry.',
  },
  'Sagittarius-Tiger': {
    personal:
      'You are adventurous, bold, and conviction-led. Sagittarius seeks meaning; Tiger seeks challenge. You are energized by movement and purpose.',
    love:
      'You need excitement, honesty, and room to grow. You commit deeply when respect and freedom are both present in the relationship.',
    compatibility:
      'Fire and Air profiles often mirror your drive and optimism. Water partners can work if emotional communication remains direct and steady.',
    work:
      'You excel in high-autonomy environments, especially mission-driven leadership, business development, education, and exploration-heavy roles.',
    growth:
      'Your edge is patience with process. Big outcomes still require repetition and detail. Build stamina for execution, not just inspiration.',
  },
};

export function getAuthoredBlueprint(
  westernSign: WesternSign,
  chineseSign: ChineseSign
): AuthoredBlueprint | null {
  const key = `${westernSign}-${chineseSign}`;
  return blueprintContent[key] ?? null;
}

export function isAuthoredCombo(
  westernSign: WesternSign,
  chineseSign: ChineseSign
): boolean {
  const key = `${westernSign}-${chineseSign}`;
  return key in blueprintContent;
}

export const authoredCombos = Object.keys(blueprintContent) as string[];
