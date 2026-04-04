/**
 * Centralized configuration and constants
 * 
 * Single source of truth for:
 * - Pricing & SKUs
 * - Feature flags
 * - API endpoints
 * - UI constants
 * - Trial/grace periods
 */

// Feature flags
export const FEATURE_FLAGS = {
  // Premium features
  PREMIUM_ENABLED: true,
  DEEP_HOROSCOPE_ENABLED: true,
  ASTROLOGER_CHAT_ENABLED: true,
  ADVANCED_COMPATIBILITY_ENABLED: true,

  // Experimental
  AI_PERSONALIZATION_ENABLED: false,
  SOCIAL_SHARING_ENABLED: false,
  COMMUNITY_FEATURES_ENABLED: false,

  // Debug
  DEBUG_MODE: process.env.NODE_ENV === 'development',
};

// Premium pricing
export const PREMIUM_PRICING = {
  MONTHLY: {
    price: 9.99,
    currency: 'USD',
    skuId: 'zodian_premium_monthly',
    durationDays: 30,
  },
  YEARLY: {
    price: 79.99,
    currency: 'USD',
    skuId: 'zodian_premium_yearly',
    durationDays: 365,
  },
  TRIAL: {
    durationDays: 7,
    price: 0,
  },
};

// Premium features locked behind paywall
export const PREMIUM_FEATURES = {
  // Daily ritual features
  DEEPER_READINGS: { name: 'Deeper daily readings', locked: true },
  ADVANCED_COMPATIBILITY: { name: 'Advanced compatibility', locked: true },
  PREMIUM_GUIDANCE: { name: 'Premium dating guidance', locked: true },
  RITUAL_UNLOCKED: { name: 'Stronger ritual experience', locked: true },

  // Match limit (free users can swipe 3/day)
  DAILY_SWIPE_LIMIT: { value: 3, premium: false, locked: false },
  PREMIUM_SWIPE_LIMIT: { value: -1, premium: true, locked: false }, // unlimited
};

// In-app messaging
export const MESSAGING = {
  // Unlock prompts
  UNLOCK_PROMPT_AFTER_REVEALS: 3, // Show premium modal after 3 reveals
  UNLOCK_PROMPT_AFTER_MATCHES: 5, // Show premium modal after 5 matches

  // Streak notifications
  STREAK_MILESTONES: [7, 30, 100, 365],

  // Empty state messages
  MATCH_EMPTY_STATE: 'You\'ve reviewed all cosmic connections. Reset your deck to see matches again.',
  CHAT_EMPTY_STATE: 'Start a conversation with your astrologer guide.',
  NO_RITUALS: 'No rituals yet. Complete your onboarding to begin.',
};

// API endpoints (move to .env in production)
export const API = {
  // OpenAI for astrologer chat
  OPENAI_ENDPOINT: 'https://api.openai.com/v1/chat/completions',
  OPENAI_MODEL: 'gpt-4-turbo-preview',

  // Analytics
  AMPLITUDE_ENDPOINT: 'https://api.amplitude.com/2/httpapi',

  // Error tracking
  SENTRY_ENDPOINT: process.env.SENTRY_DSN ?? null,
};

export const ADS = {
  ADMOB_REWARDED_UNIT_ID: process.env.EXPO_PUBLIC_ADMOB_REWARDED_UNIT_ID ?? null,
};

// Time constants
export const TIME = {
  MINUTE: 60 * 1000,
  HOUR: 60 * 60 * 1000,
  DAY: 24 * 60 * 60 * 1000,
  WEEK: 7 * 24 * 60 * 60 * 1000,
};

// Animation durations
export const ANIMATIONS = {
  QUICK: 150,
  NORMAL: 300,
  SLOW: 500,
  REVEAL_CARD: 800,
};

// Loading timeouts
export const TIMEOUTS = {
  CHAT_RESPONSE: 30000, // 30s
  DAILY_FETCH: 10000, // 10s
  GENERAL: 5000, // 5s
};

// Retry config
export const RETRY = {
  MAX_ATTEMPTS: 3,
  INITIAL_DELAY: 1000,
  MAX_DELAY: 10000,
  BACKOFF_MULTIPLIER: 2,
};

// Achievement milestones
export const ACHIEVEMENTS = {
  FIRST_RITUAL: { streak: 1, label: 'Cosmic Awakening' },
  WEEK_RITUAL: { streak: 7, label: 'Weekly Devotee' },
  MONTH_RITUAL: { streak: 30, label: 'Monthly Cosmic' },
  QUARTER_RITUAL: { streak: 100, label: 'Quarterly Guardian' },
  YEAR_RITUAL: { streak: 365, label: 'Eternal Cosmic' },
};

// UI spacing and typography (fallback, use tokens.ts for primary)
export const UI = {
  SCREEN_PADDING: 16,
  CARD_RADIUS: 12,
  BUTTON_HEIGHT: 48,
  TAB_BAR_HEIGHT: 88,
};

// Validation
export const VALIDATION = {
  NAME_MIN_LENGTH: 2,
  NAME_MAX_LENGTH: 50,
  CHAT_MESSAGE_MAX_LENGTH: 1000,
  CHAT_HISTORY_LIMIT: 50,
};

// Export all as config object
export const CONFIG = {
  FEATURE_FLAGS,
  PREMIUM_PRICING,
  PREMIUM_FEATURES,
  MESSAGING,
  API,
  ADS,
  TIME,
  ANIMATIONS,
  TIMEOUTS,
  RETRY,
  ACHIEVEMENTS,
  UI,
  VALIDATION,
};
