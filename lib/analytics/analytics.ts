/**
 * Analytics infrastructure
 * 
 * Handles:
 * - Event queue (batch sends)
 * - Amplitude integration
 * - Funnel tracking
 * - User identity
 * - Custom properties
 * 
 * Events are queued locally and periodically flushed to Amplitude
 */

import AsyncStorage from '@react-native-async-storage/async-storage';

export type AnalyticsEvent = {
  name: string;
  properties?: Record<string, any>;
  timestamp?: number;
};

const ANALYTICS_QUEUE_KEY = 'zodian:analytics_queue:v1';
const MAX_QUEUE_SIZE = 1000;
let amplitudeKey: string | null = null;
let flushInterval: NodeJS.Timeout | null = null;

/**
 * Initialize analytics
 */
export function initAnalytics(apiKey: string) {
  amplitudeKey = apiKey;
  // Flush every 30 seconds
  flushInterval = setInterval(() => {
    flushQueue().catch((err) => console.warn('Analytics flush error', err));
  }, 30000) as unknown as NodeJS.Timeout;
}

/**
 * Track event
 */
export async function trackEvent(name: string, properties?: Record<string, any>) {
  try {
    const event: AnalyticsEvent = {
      name,
      properties,
      timestamp: Date.now(),
    };

    // Push to local queue
    const raw = await AsyncStorage.getItem(ANALYTICS_QUEUE_KEY);
    const queue: AnalyticsEvent[] = raw ? JSON.parse(raw) : [];
    queue.push(event);

    // Keep queue bounded
    if (queue.length > MAX_QUEUE_SIZE) {
      queue.shift();
    }

    await AsyncStorage.setItem(ANALYTICS_QUEUE_KEY, JSON.stringify(queue));

    // Flush if queue is getting full
    if (queue.length > 100) {
      flushQueue().catch((err) => console.warn('Analytics flush error', err));
    }
  } catch (err) {
    console.warn('trackEvent error', err);
  }
}

/**
 * Flush queue to Amplitude
 */
export async function flushQueue() {
  if (!amplitudeKey) return;

  try {
    const raw = await AsyncStorage.getItem(ANALYTICS_QUEUE_KEY);
    if (!raw) return;

    const queue: AnalyticsEvent[] = JSON.parse(raw);
    if (queue.length === 0) return;

    // Send to Amplitude
    const events = queue.map((e) => ({
      event_type: e.name,
      time: e.timestamp,
      event_properties: e.properties,
    }));

    const response = await fetch('https://api.amplitude.com/2/httpapi', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        api_key: amplitudeKey,
        events,
      }),
    });

    if (response.ok) {
      // Clear queue on success
      await AsyncStorage.removeItem(ANALYTICS_QUEUE_KEY);
    }
  } catch (err) {
    console.warn('flushQueue error', err);
  }
}

/**
 * Cleanup (call on app exit)
 */
export function cleanupAnalytics() {
  if (flushInterval) {
    clearInterval(flushInterval);
    flushInterval = null;
  }
  // Try to flush remaining events
  flushQueue().catch(() => {});
}

/**
 * Get queue size (debug)
 */
export async function getQueueSize(): Promise<number> {
  try {
    const raw = await AsyncStorage.getItem(ANALYTICS_QUEUE_KEY);
    return raw ? JSON.parse(raw).length : 0;
  } catch {
    return 0;
  }
}

export async function getQueuedEvents(limit = 50): Promise<AnalyticsEvent[]> {
  try {
    const raw = await AsyncStorage.getItem(ANALYTICS_QUEUE_KEY);
    const queue: AnalyticsEvent[] = raw ? JSON.parse(raw) : [];
    return queue.slice(-limit).reverse();
  } catch {
    return [];
  }
}

/**
 * Clear queue (debug/testing)
 */
export async function clearQueue() {
  await AsyncStorage.removeItem(ANALYTICS_QUEUE_KEY);
}

/**
 * Standard event names (to prevent typos)
 */
export const EVENTS = {
  // Onboarding
  ONBOARDING_START: 'onboarding_start',
  ONBOARDING_COMPLETE: 'onboarding_complete',
  ONBOARDING_SKIP: 'onboarding_skip',
  ONBOARDING_STEP_VIEWED: 'onboarding_step_viewed',
  ONBOARDING_STEP_COMPLETED: 'onboarding_step_completed',
  ONBOARDING_IDENTITY_REVEALED: 'onboarding_identity_revealed',
  ONBOARDING_IDENTITY_SHARED: 'onboarding_identity_shared',

  // Core user actions
  RITUAL_REVEALED: 'ritual_revealed',
  RITUAL_COMPLETED: 'ritual_completed',
  DAILY_RETURNED: 'daily_returned',
  STREAK_UPDATED: 'streak_updated',
  STREAK_AT_RISK: 'streak_at_risk',
  STREAK_RESTARTED: 'streak_restarted',
  BLUEPRINT_VIEWED: 'blueprint_viewed',
  BLUEPRINT_THEORY_OPENED: 'blueprint_theory_opened',

  // Premium
  PREMIUM_VIEWED: 'premium_viewed',
  PREMIUM_CTA_TAPPED: 'premium_cta_tapped',
  PREMIUM_PROMPT_VIEWED: 'premium_prompt_viewed',
  PREMIUM_PROMPT_ACTION: 'premium_prompt_action',
  PREMIUM_PLAN_SELECTED: 'premium_plan_selected',
  PREMIUM_DISMISSED: 'premium_dismissed',
  PREMIUM_PURCHASED: 'premium_purchased',
  PREMIUM_TRIAL_STARTED: 'premium_trial_started',
  PREMIUM_EXPIRED: 'premium_expired',

  // Matching
  MATCH_SWIPED: 'match_swiped',
  MATCH_SAVED: 'match_saved',
  MATCH_RESET: 'match_reset',

  // Chat
  CHAT_OPENED: 'chat_opened',
  CHAT_MESSAGE_SENT: 'chat_message_sent',
  CHAT_RESPONSE_RECEIVED: 'chat_response_received',

  // User engagement
  TAB_VIEWED: 'tab_viewed',
  SCREEN_VIEWED: 'screen_viewed',
  BUTTON_TAPPED: 'button_tapped',

  // Errors
  ERROR_OCCURRED: 'error_occurred',
  CRASH_REPORTED: 'crash_reported',
};

export type AppEventName = (typeof EVENTS)[keyof typeof EVENTS];

export async function trackAppEvent(name: AppEventName, properties?: Record<string, any>) {
  await trackEvent(name, properties);
}

export async function trackScreenView(screenName: string, properties?: Record<string, any>) {
  await trackAppEvent(EVENTS.SCREEN_VIEWED, { screenName, ...properties });
}

export async function trackTabView(tabName: string, properties?: Record<string, any>) {
  await trackAppEvent(EVENTS.TAB_VIEWED, { tabName, ...properties });
}
