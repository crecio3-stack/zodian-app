import { AstrologerContext } from '../../types/chat';

/**
 * System prompt for the Zodian astrologer persona.
 * Emphasizes warmth, insight, and reflective guidance.
 */
export const getAstrologerSystemPrompt = (context: AstrologerContext): string => {
  const sign = context.westernSign;
  const chineseSign = context.chineseSign;
  const userName = context.name?.trim() || 'Unknown';

  return `You are Zodian, a premium AI astrology guide. Your job is to help users understand themselves through astrology in a warm, insightful, emotionally intelligent way.

User Profile:
- Name: ${userName}
- Western Sign: ${sign}
- Chinese Sign: ${chineseSign}
- Birthdate: ${context.birthdate.toISOString().slice(0, 10)}

Your Style:
- Modern, intimate, calm, and direct
- Mystical but never cheesy
- Premium, elegant, and reflective
- Answer directly first, then offer deeper explanation
- Conversational, never robotic
- Validating without exaggerating

What You Help With:
- Identity and personality
- Relationship patterns and attraction
- Compatibility and communication style
- Emotional tendencies and growth
- Timing and current energy themes
- Self-reflection and personal development

Response Rules:
1. Answer the user's question directly and personally
2. Personalize with their sign combination when relevant
3. Explain the likely pattern or reason behind the answer
4. Offer reflective takeaways, next steps, or gentle questions
5. Keep responses concise unless they ask to go deeper
6. Avoid generic or repetitive language

Important Boundaries:
- Do not claim certainty about the future
- Do not make medical, legal, financial, or crisis judgments
- Do not encourage dependency on astrology
- Frame insights as guidance, tendencies, themes, or patterns

Example Response Shapes:
1. Direct answer → 2. Personalized interpretation → 3. Reflection or guidance

Tone Examples:
- "Your ${sign} side moves fast, but your ${chineseSign} energy is strategic. That makes you look impulsive on the surface while actually being very calculated."
- "You may not be asking for intensity, but your chart suggests you're drawn to emotionally charged people because calm can feel unfamiliar."
- "The pattern here is less about luck and more about what feels familiar to your nervous system."

Keep responses under 200 words unless the user explicitly asks for more depth.`;
};

/**
 * Mock astrologer response generator.
 * Replace this with real API integration when ready.
 */
export const generateAstrologerResponse = async (
  userMessage: string,
  systemPrompt: string,
  conversationHistory: { role: 'user' | 'assistant'; content: string }[]
): Promise<string> => {
  // Simulate API delay
  await new Promise((resolve) => setTimeout(resolve, 1200));

  // Mock responses based on keywords in user message
  const lowerMessage = userMessage.toLowerCase();

  if (lowerMessage.includes('who am i') || lowerMessage.includes('identity') || lowerMessage.includes('personality')) {
    return "Your western sign gives you one flavor of personality—ambitious, creative, intense—while your Chinese sign adds another layer entirely. Together, they create a unique rhythm. Your western sign is what you show the world easily, while your Chinese sign is deeper, more intuitive, more about how you move through life when nobody's watching.";
  }

  if (lowerMessage.includes('compatibility') || lowerMessage.includes('match') || lowerMessage.includes('attracted')) {
    return "Attraction isn't just about sun signs matching nicely on a chart. Your western sign shows what you think you want, while your Chinese sign often reveals what actually makes you feel safe and seen. The best matches tend to honor both—someone who gets your surface-level energy and also speaks to your deeper emotional language.";
  }

  if (lowerMessage.includes('communication') || lowerMessage.includes('express') || lowerMessage.includes('speak')) {
    return "Your western sign tends to communicate in a certain style—direct, poetic, logical—but your Chinese sign adds nuance to how you're actually heard. You might need to give people permission to wait for the deeper version of what you're saying, because you contain multitudes.";
  }

  if (lowerMessage.includes('emotional') || lowerMessage.includes('feeling') || lowerMessage.includes('sensitive')) {
    return "Your emotional world is complex—your western sign shows you how you want to feel, while your Chinese sign shows you how you actually process feeling. Neither is wrong. Integration is the goal: letting both work together instead of fighting for control.";
  }

  if (lowerMessage.includes('timing') || lowerMessage.includes('when') || lowerMessage.includes('now')) {
    return "Right now, you're in a season where your natural pacing is being tested. Trust it anyway. The rhythm your chart suggests isn't random—it's aligned with something deeper in you. Don't rush it, even if the world around you feels fast.";
  }

  if (lowerMessage.includes('growth') || lowerMessage.includes('develop') || lowerMessage.includes('improve')) {
    return "The most interesting growth happens when you stop trying to be your 'opposite' sign and instead integrate both sides. You already have everything you need. The work is learning when to lead with western energy and when to trust your Chinese instinct.";
  }

  // Default response
  return "That's a meaningful question. Help me understand a bit more—are you asking about how your signs shape who you are, or how they show up in specific situations like relationships or work? The answer shifts depending on context.";
};

/**
 * Starter prompts users can tap to begin conversation.
 */
export const STARTER_PROMPTS = [
  {
    text: 'Who am I under my signs?',
    emoji: '✨',
  },
  {
    text: 'What signs attract me?',
    emoji: '💫',
  },
  {
    text: 'How do I communicate?',
    emoji: '🗣️',
  },
  {
    text: 'What\'s my pattern in love?',
    emoji: '💘',
  },
  {
    text: 'What does now feel like?',
    emoji: '🌙',
  },
  {
    text: 'How do I grow the most?',
    emoji: '🌱',
  },
];
